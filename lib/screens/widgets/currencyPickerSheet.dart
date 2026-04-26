import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/currencies.dart';

/// Shows a searchable, premium currency picker as a modal bottom sheet.
Future<void> showCurrencyPicker(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CurrencyCubit>(),
      child: const _CurrencyPickerSheet(),
    ),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet();

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CurrencyData> _filtered = allCurrencies;

  // Popular currencies shown at top
  static const _popularCodes = [
    'USD', 'EUR', 'GBP', 'INR', 'JPY', 'CAD',
    'AUD', 'CHF', 'CNY', 'AED', 'SGD', 'SAR',
  ];

  List<CurrencyData> get _popular => allCurrencies
      .where((c) => _popularCodes.contains(c.code))
      .toList()
    ..sort((a, b) =>
        _popularCodes.indexOf(a.code) - _popularCodes.indexOf(b.code));

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? allCurrencies
          : allCurrencies
              .where((c) =>
                  c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q) ||
                  c.symbol.contains(q))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;
    final selected = context.watch<CurrencyCubit>().state.currency;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff141829).withValues(alpha: 0.96)
                  : Colors.white.withValues(alpha: 0.97),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                  color: context.colors.cardBorderColor, width: 1),
            ),
            child: Column(
              children: [
                // ── Drag handle ──────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.lightGreyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                // ── Header ───────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Currency',
                            style: TextStyle(
                              color: context.colors.blackColors,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            '${allCurrencies.length} currencies worldwide',
                            style: TextStyle(
                              color: context.colors.lightGreyColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Current selection chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color:
                                  context.colors.accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${selected.symbol}  ${selected.code}',
                          style: TextStyle(
                            color: context.colors.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: context.colors.cardBorderColor),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(
                          color: context.colors.blackColors, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name, code or symbol…',
                        hintStyle: TextStyle(
                            color: context.colors.lightGreyColor,
                            fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: context.colors.lightGreyColor, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  FocusScope.of(context).unfocus();
                                },
                                child: Icon(Icons.close_rounded,
                                    color: context.colors.lightGreyColor,
                                    size: 18),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),

                // ── List ─────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      // Popular section (only when not searching)
                      if (_searchCtrl.text.isEmpty) ...[
                        _sectionLabel(context, '⭐  Popular'),
                        ..._popular.map((c) => _CurrencyTile(
                              data: c,
                              isSelected: c.code == selected.code,
                              onTap: () => _pick(context, c),
                            )),
                        const SizedBox(height: 8),
                        _sectionLabel(context, '🌍  All Currencies'),
                      ],
                      ..._filtered.map((c) => _CurrencyTile(
                            data: c,
                            isSelected: c.code == selected.code,
                            onTap: () => _pick(context, c),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.lightGreyColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );

  void _pick(BuildContext context, CurrencyData data) {
    context.read<CurrencyCubit>().selectCurrency(data);
    Navigator.of(context).pop();
  }
}

// ── Individual tile ───────────────────────────────────────────────────────────

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final CurrencyData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? context.colors.accentColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Symbol badge
            Container(
              width: 46,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.accentColor.withValues(alpha: 0.15)
                    : (context.colors.isDarkMode
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  data.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? context.colors.accentColor
                        : context.colors.blackColors,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name & code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    data.code,
                    style: TextStyle(
                      color: context.colors.lightGreyColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Check
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: context.colors.accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}
