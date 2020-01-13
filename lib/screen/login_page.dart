import 'package:flutter/material.dart';
import 'package:kalamoza_defteri/authentication.dart';

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
  Icon passIcon = Icon(Icons.visibility_off);
  bool obscureText = true;
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
        print('Error= ' + e.toString());
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
              Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: createInputs() + createButtons(),
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
      TextFormField(
        decoration:
            InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail)),
        validator: (value) {
          return value.isEmpty ? 'Email is required' : null;
        },
        onSaved: (value) {
          return _email = value;
        },
      ),
      SizedBox(
        height: 10.0,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.lock),
          suffixIcon: InkWell(
            child: passIcon,
            onTap: () {
              //Todo: Çalışmıyor aq düzelt
              //Todo: şifre 123456 unutma aq
              // TODO:Tamam temizlemem yellos
              setState(() {
                if (passIcon == Icon(Icons.visibility_off)) {
                  passIcon = Icon(Icons.visibility);
                  obscureText = false;
                } else {
                  passIcon = Icon(Icons.visibility_off);
                  obscureText = true;
                }
              });
            },
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          return value.isEmpty ? 'Password is required' : null;
        },
        onSaved: (value) {
          return _password = value;
        },
      ),
      SizedBox(
        height: 20.0,
      ),
    ];
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text('Login', style: TextStyle(fontSize: 20.0)),
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
          child: Text('Create Account', style: TextStyle(fontSize: 20.0)),
          textColor: Colors.white,
          color: Colors.pink,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text('Already have an Account ? Login',
              style: TextStyle(fontSize: 14.0)),
          textColor: Colors.red,
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
