import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/services/authentication.dart';
import 'package:kalamoza_defteri/screen/home_page.dart';
import 'package:kalamoza_defteri/screen/login_page.dart';

class MappingPage extends StatefulWidget {
  final BaseAuth auth;

  MappingPage({this.auth});

  State<StatefulWidget> createState() {
    return _MappingPageState();
  }
}

enum AutStatus {
  notSignedIn,
  signedIn,
}

class _MappingPageState extends State<MappingPage> {
  AutStatus autStatus = AutStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((firebaseUserId) {
      setState(() {
        autStatus =
            firebaseUserId == null ? AutStatus.notSignedIn : AutStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      autStatus = AutStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      autStatus = AutStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (autStatus) {
      case AutStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AutStatus.signedIn:
        return new HomePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
        );
    }
    return null;
  }
}
