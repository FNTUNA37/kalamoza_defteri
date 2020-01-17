import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/services/authentication.dart';
import 'package:kalamoza_defteri/services/mapping.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: MappingPage(
        auth: Auth(),
      ),
    );
  }
}
