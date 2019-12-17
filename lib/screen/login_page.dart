import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:kalamoza_defteri/authentication.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Auth auth = Auth();
  LoginData data;

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'FURKAN',
      onLogin: (_) => auth.signIn(data),
      onSignup: (_) => auth.signUp(data),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      },
    );
  }
}
