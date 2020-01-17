import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/services/authentication.dart';
import 'package:toast/toast.dart';
import 'package:kalamoza_defteri/utilities/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
}

enum FormType {
  login,
  register,
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  FormType _formType = FormType.login;
  String _email = '';
  String _password = '';
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.signIn(_email, _password);
          print('Login UserId= ' + userId);
        } else {
          String userId = await widget.auth.signUp(_email, _password);
          print('Register UserId= ' + userId);
        }
        widget.onSignedIn();
      } catch (e) {
        Toast.show(e.toString(), context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'images/login_background.jpeg',
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 65.0),
                child: Container(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: createInputs() + createButtons(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> createInputs() {
    return [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), border: Border.all()),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  Pattern pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regex = new RegExp(pattern);
                  if (!regex.hasMatch(value))
                    return 'Enter Valid Email';
                  else
                    return null;
                },
                onSaved: (value) {
                  return _email = value;
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  return value.isEmpty ? 'Password is required' : null;
                },
                onSaved: (value) {
                  return _password = value;
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10.0,
      ),
      SizedBox(height: 20.0),
    ];
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text('Login', style: kLoginPageButtonTextStyle),
          textColor: Colors.white,
          color: Colors.pink,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Not have an Account ? Create Account ?',
              style: TextStyle(fontSize: 14.0)),
          textColor: Colors.red,
          onPressed: moveToRegister,
        )
      ];
    } else {
      return [
        RaisedButton(
          child: Text('Create Account', style: kLoginPageButtonTextStyle),
          textColor: Colors.white,
          color: Colors.pink,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Already have an Account ? Login',
              style: kLoginPageAlreadyTextStyle),
          onPressed: moveToLogin,
        )
      ];
    }
  }

  Widget logo() {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: null,
      ),
    );
  }
}
