import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/firebase_options.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize firebase
  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  //initialize Hive
  Hive.init((await getApplicationDocumentsDirectory()).path);
  await HiveRepository.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      onGenerateRoute: Routes.onGeneratedRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1d9f9e)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      builder: (final context, final widget) => widget!,
    );
  }
}
