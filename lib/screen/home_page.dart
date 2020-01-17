import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/services/authentication.dart';
import 'package:kalamoza_defteri/screen/card_page.dart';
import 'package:kalamoza_defteri/screen/dashboard_page.dart';
import 'package:kalamoza_defteri/screen/transactions_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e.toString());
    }
  }

  String _email;

  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  Color backgroundColor = Colors.white;
  Widget screen = DashboardPage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _email = user.email;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void collapsed() {
    if (isCollapsed) {
      backgroundColor = Color(0xFF4A4A58);
      _controller.forward();
    } else {
      backgroundColor = Colors.white;
      _controller.reverse();
    }

    isCollapsed = !isCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: <Widget>[
          menu(context),
          animation(context),
        ],
      ),
    );
  }

  Widget animation(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: backgroundColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Icon(Icons.menu, color: Colors.black),
                        onTap: () {
                          setState(() {
                            collapsed();
                          });
                        },
                      ),
                      Text("Kalamoza Defteri", style: kAppNameTextStyle),
                      InkWell(
                        child: Icon(Icons.exit_to_app, color: Colors.black),
                        onTap: _logoutUser,
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Container(
                    child: screen,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  child: Text(
                    "Dashboard",
                    style: kMenuScreenNameTextStyle,
                  ),
                  onTap: () {
                    setState(() {
                      screen = DashboardPage();
                      collapsed();
                    });
                  },
                ),
                SizedBox(height: 10),
                InkWell(
                  child: Text(
                    "Cards",
                    style: kMenuScreenNameTextStyle,
                  ),
                  onTap: () {
                    setState(() {
                      screen = CardPage();
                      collapsed();
                    });
                  },
                ),
                SizedBox(height: 10),
                InkWell(
                  child: Text(
                    "Transactions",
                    style: kMenuScreenNameTextStyle,
                  ),
                  onTap: () {
                    setState(() {
                      screen = TransactionsPage();
                      collapsed();
                    });
                  },
                ),
                SizedBox(height: 10),
                Text(_email, style: kMenuEmailTextStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
