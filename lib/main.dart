import 'package:flutter/material.dart';

import 'features/number_trivia/presentation/routes/number_trivia_route.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeServiceLocator().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primaryColor: Colors.green.shade800,
      primarySwatch: Colors.green,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondary: Colors.green.shade600,
        ),
      ),
      home: const NumberTriviaRoute(),
    );
  }
}
