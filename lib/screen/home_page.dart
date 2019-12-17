import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/authentication.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
}

class _HomePageState extends State<HomePage> {
  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: RaisedButton(
        child: Text('ÇIKIŞ'),
        onPressed: _logoutUser,
      ),
    );
  }
}
