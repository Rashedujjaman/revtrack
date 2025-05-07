import 'package:flutter/material.dart';
import 'package:revtrack/theme/gradient_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: gradientBackground(context),
        child: Center(
            child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              // height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: Center(
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Color(0xFF62BDBD), // Avatar background color
                            child: CircleAvatar(
                              // Inner circle for the Icon
                              radius:
                                  39, // Slightly smaller to create the border
                              backgroundImage: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/68024439?v=4'),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        child: Center(
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Color(0xFF62BDBD), // Avatar background color
                            child: CircleAvatar(
                              // Inner circle for the Icon
                              radius:
                                  39, // Slightly smaller to create the border
                              backgroundImage: NetworkImage(
                                  'https://avatars.githubusercontent.com/u/68024439?v=4'),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 120,
              // width: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: Center(
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF62BDBD), // Avatar background color
                  child: CircleAvatar(
                    // Inner circle for the Icon
                    radius: 49, // Slightly smaller to create the border
                    backgroundImage: NetworkImage(
                        'https://avatars.githubusercontent.com/u/68024439?v=4'),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
