
import 'package:firebase_core/firebase_core.dart';
import 'package:my_financial_goals/app/routes.dart';
import 'package:my_financial_goals/firebase_options.dart';
import 'package:my_financial_goals/utils/constant.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //intialize firebase
  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      onGenerateRoute: Routes.onGeneratedRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff01c5c3)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      builder: (final context, final widget) => widget!,
    );
  }
}
