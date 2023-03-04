import 'package:flutter/material.dart';
import 'package:my_pensieve/themes/primary_pallete.dart';
import 'package:my_pensieve/themes/second_pallete.dart';
import 'package:my_pensieve/widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PrimaryPalette.kToDark.withOpacity(0.5),
                SecondPallete.kToDark.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 1],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: mediaQuery.size.height,
            width: mediaQuery.size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: mediaQuery.size.width > 600 ? 2 : 1,
                  child: const AuthCardWidget(),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
