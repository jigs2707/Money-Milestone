/**
 * Firestore → Supabase one-time data migration
 *
 * Setup:
 *   1. cd migration
 *   2. npm install firebase-admin @supabase/supabase-js
 *   3. Download your Firebase service account key:
 *        Firebase Console → Project Settings → Service Accounts → Generate new private key
 *        Save it as migration/serviceAccountKey.json
 *   4. Fill in SUPABASE_URL and SUPABASE_SERVICE_KEY below
 *        (use the SERVICE ROLE key, not anon key — found in Supabase Dashboard → Settings → API)
 *   5. node migrate.js
 *
 * What it migrates:
 *   users            → public.users
 *   users/{id}/categories → public.categories  (camelCase → snake_case keys)
 *   goals/{id}/{id}  → public.goals            (Firestore category_id remapped to Supabase UUID)
 *   transactions/{id}/{goalId} → public.transactions (goal_id remapped to Supabase UUID)
 *
 * app_config and app_sessions are NOT migrated (config is set in schema.sql; sessions are analytics noise).
 */

const admin = require('firebase-admin');
const { createClient } = require('@supabase/supabase-js');
const serviceAccount = require('./serviceAccountKey.json');

// ── CONFIG ───────────────────────────────────────────────────────────────────
const SUPABASE_URL = 'https://aaiwlestetmutzjopytj.supabase.co';          // e.g. https://xxxx.supabase.co
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhaXdsZXN0ZXRtdXR6am9weXRqIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NDIxNTgwOSwiZXhwIjoyMDk5NzkxODA5fQ.M3fkyjo2Hc5fpD52zRp6fmAyE558dCVdP86MAj4HS74'; // NOT the anon key
// ─────────────────────────────────────────────────────────────────────────────

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

function log(msg) {
  console.log(`[${new Date().toISOString()}] ${msg}`);
}

async function migrateUser(userId, userData) {
  const { error } = await supabase.from('users').upsert({
    id: userId,
    name: userData.name ?? null,
    currency_code: userData.currency_code ?? 'USD',
    current_streak: userData.current_streak ?? 0,
    longest_streak: userData.longest_streak ?? 0,
    last_deposit_date: userData.last_deposit_date ?? null,
  }, { onConflict: 'id' });

  if (error) throw new Error(`users upsert failed for ${userId}: ${error.message}`);
  log(`  ✓ user ${userId} (${userData.name ?? 'no name'})`);
}

async function migrateCategories(userId) {
  // Returns a map: firestoreCategoryId → supabaseUUID
  const categoryIdMap = {};

  const snap = await db
    .collection('users').doc(userId)
    .collection('categories')
    .get();

  if (snap.empty) return categoryIdMap;

  for (const doc of snap.docs) {
    const d = doc.data();
    const { data, error } = await supabase
      .from('categories')
      .insert({
        user_id: userId,
        name: d.name ?? '',
        code_point: d.codePoint ?? 0,           // Firestore stored camelCase
        font_family: d.fontFamily ?? 'MaterialIcons',
        color_value: d.colorValue ?? 0xFF607D8B,
        is_custom: d.isCustom ?? true,
      })
      .select('id')
      .single();

    if (error) {
      console.warn(`  ⚠ category ${doc.id} failed: ${error.message}`);
      continue;
    }
    categoryIdMap[doc.id] = data.id;
    log(`    ✓ category "${d.name}" (${doc.id} → ${data.id})`);
  }

  return categoryIdMap;
}

async function migrateGoals(userId, categoryIdMap) {
  // Returns a map: firestoreGoalId → supabaseUUID
  const goalIdMap = {};

  const snap = await db
    .collection('goals').doc(userId)
    .collection(userId)   // Firestore structure: goals/{uid}/{uid}/{goalId}
    .get();

  if (snap.empty) return goalIdMap;

  for (const doc of snap.docs) {
    const d = doc.data();

    // Remap old Firestore category_id → new Supabase UUID (null if not found)
    const newCategoryId = d.category_id
      ? (categoryIdMap[d.category_id] ?? null)
      : null;

    if (d.category_id && !categoryIdMap[d.category_id]) {
      console.warn(`  ⚠ goal "${d.goal_name}" has unknown category_id "${d.category_id}" – setting to null`);
    }

    const { data, error } = await supabase
      .from('goals')
      .insert({
        user_id: userId,
        goal_name: d.goal_name ?? '',
        goal_amount: d.goal_amount ?? '0',
        goal_date: d.goal_date ?? '',
        goal_saved_amount: d.goal_saved_amount ?? '0',
        category_id: newCategoryId,
      })
      .select('id')
      .single();

    if (error) {
      console.warn(`  ⚠ goal ${doc.id} failed: ${error.message}`);
      continue;
    }
    goalIdMap[doc.id] = data.id;
    log(`    ✓ goal "${d.goal_name}" (${doc.id} → ${data.id})`);
  }

  return goalIdMap;
}

async function migrateTransactions(userId, goalIdMap) {
  let total = 0;

  for (const [firestoreGoalId, supabaseGoalId] of Object.entries(goalIdMap)) {
    const snap = await db
      .collection('transactions').doc(userId)
      .collection(firestoreGoalId)  // Firestore: transactions/{uid}/{goalId}/{txId}
      .get();

    if (snap.empty) continue;

    const rows = snap.docs.map((doc) => {
      const d = doc.data();
      return {
        user_id: userId,
        goal_id: supabaseGoalId,
        amount: d.amount ?? '0',
        date: d.date ?? '',
        note: d.note ?? null,
        type: d.type ?? 'credit',
      };
    });

    const { error } = await supabase.from('transactions').insert(rows);
    if (error) {
      console.warn(`  ⚠ transactions for goal ${firestoreGoalId} failed: ${error.message}`);
      continue;
    }
    total += rows.length;
    log(`    ✓ ${rows.length} transaction(s) for goal ${firestoreGoalId}`);
  }

  return total;
}

async function main() {
  log('Starting Firestore → Supabase migration…');
  log('');

  const usersSnap = await db.collection('users').get();
  if (usersSnap.empty) {
    log('No users found in Firestore. Nothing to migrate.');
    return;
  }

  log(`Found ${usersSnap.size} user(s).`);
  log('');

  let totalGoals = 0;
  let totalCategories = 0;
  let totalTransactions = 0;

  for (const userDoc of usersSnap.docs) {
    const userId = userDoc.id;
    log(`── User: ${userId}`);

    await migrateUser(userId, userDoc.data());

    log('  Migrating categories…');
    const categoryIdMap = await migrateCategories(userId);
    totalCategories += Object.keys(categoryIdMap).length;

    log('  Migrating goals…');
    const goalIdMap = await migrateGoals(userId, categoryIdMap);
    totalGoals += Object.keys(goalIdMap).length;

    log('  Migrating transactions…');
    const txCount = await migrateTransactions(userId, goalIdMap);
    totalTransactions += txCount;

    log('');
  }

  log('═══════════════════════════════════════');
  log(`Migration complete!`);
  log(`  Users:        ${usersSnap.size}`);
  log(`  Categories:   ${totalCategories}`);
  log(`  Goals:        ${totalGoals}`);
  log(`  Transactions: ${totalTransactions}`);
  log('═══════════════════════════════════════');

  process.exit(0);
}

main().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
