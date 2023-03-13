import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:provider/provider.dart';

class AccountScreenWidget extends StatelessWidget {
  const AccountScreenWidget({super.key});

  Widget _buildFragmentItem(theme, mediaQuery, Icon icon, Text text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      child: Row(
        children: <Widget>[
          icon,
          SizedBox(
            width: mediaQuery.size.width * 0.1,
          ),
          text,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final auth = Provider.of<Auth>(context).user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      SizedBox(height: mediaQuery.size.height * 0.015),
                      Text(
                        auth.username!,
                        style: theme.textTheme.displayLarge,
                      ),
                      SizedBox(
                        height: mediaQuery.size.height * 0.02,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.orangeAccent),
                        ),
                        onPressed: () {
                          Provider.of<Auth>(context, listen: false).logout();
                        },
                        child: const Text('SIGN OUT'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
