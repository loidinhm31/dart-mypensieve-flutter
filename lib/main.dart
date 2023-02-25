import 'package:flutter/material.dart';
import 'package:my_pensieve/themes/primary_pallete.dart';
import 'package:my_pensieve/themes/second_pallete.dart';
import 'package:my_pensieve/widgets/user_fragment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'University-Oldstyle',
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: PrimaryPalette.kToDark,
              secondary: SecondPallete.kToDark,
            ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'University-Oldstyle',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              displayLarge: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              titleMedium: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PrimaryPalette.kToDark,
              ),
              labelLarge: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SecondPallete.kToDark,
              ),
              labelMedium: const TextStyle(
                fontFamily: 'University-Oldstyle',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: SecondPallete.kToDark,
              ),
            ),
      ),
      home: const MyHomePage(title: 'My Pensieve'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const <Widget>[
          UserFragmentsWidget(),
        ],
      ),
    );
  }
}
