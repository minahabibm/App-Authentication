import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_firebase_auth/views/app.dart';

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(Buttons.Email, text: "Sign In with Email",
              onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInEmail()),
            );
          })),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.Google,
            text: "Sign In with Google",
            onPressed: () {},
          )),
    ]);
  }
}

class SignInEmail extends StatefulWidget {
  @override
  _SignInEmailState createState() => _SignInEmailState();
}

class _SignInEmailState extends State<SignInEmail> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference _firestore =
      FirebaseFirestore.instance.collection('users');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _err = "";
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log In"),
        ),
        body: Center(
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        hintText: 'Enter Your E-mail',
                        labelText: 'E-mail',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        Pattern pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                        RegExp emailRegex = new RegExp(pattern);
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: 'Enter Password',
                          labelText: 'password',
                        ),
                        validator: (value) {
                          if (value.length < 8) {
                            return 'Password must be longer than 8 characters';
                          } else {
                            return null;
                          }
                        }),
                    RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _logInToFirebase();
                        }
                      },
                      child: Text('Log In'),
                    ),
                    Visibility(
                        visible: _visible == true,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _err,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              )
                            ])),
                    FlatButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPassword()),
                          );
                          '$result' != 'null'
                              ? _emailController.text = '$result'
                              : _emailController.clear();
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
                        ))
                  ],
                ),
              )),
        ));
  }

  Future<void> _logInToFirebase() async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((result) async {
        var firstName = '';
        setState(() {
          _visible = false;
        });
        await _firestore.doc(result.user.uid).get().then((doc) {
          if (doc.exists) {
            print('Document exists on the database');
            firstName = doc.data()['first_name'];
          } else {
            print("No such document!");
          }
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    App(name: firstName, uid: result.user.uid)),
            (Route<dynamic> route) => false);
      });
    } catch (e) {
      if (e.code == 'user-not-found') {
        _err = 'No user found for that email.';
        print(_err);
        _setErrorMessage();
      } else if (e.code == 'wrong-password') {
        _err = 'Wrong password provided for that user.';
        print(_err);
        _setErrorMessage();
      } else {
        _err = e.message;
        print(_err);
        _setErrorMessage();
      }
    }
  }

  void _setErrorMessage() {
    setState(() {
      _visible = true;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKeyPass = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailResetController = TextEditingController();
  var _errPass = "";
  bool _visiblePass = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Log In"),
        ),
        body: Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 250),
                child: Form(
                    key: _formKeyPass,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _emailResetController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.email),
                              hintText: 'Enter Your E-mail',
                              labelText: 'E-mail',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              Pattern pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp emailRegex = new RegExp(pattern);
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter valid email';
                              }
                              return null;
                            },
                          ),
                          RaisedButton(
                            color: Colors.lightBlue,
                            onPressed: () {
                              if (_formKeyPass.currentState.validate()) {
                                _resetPasswordFirebase();
                              }
                            },
                            child: Text('send'),
                          ),
                          Visibility(
                              visible: _visiblePass == true,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      _errPass,
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    )
                                  ])),
                        ])))));
  }

  Future<void> _resetPasswordFirebase() async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
          email: _emailResetController.text);
      _errPass =
          "an email has been sent to you with password reset instructions";
      _setPassMessage();
      Navigator.pop(context, _emailResetController.text);
      //_emailResetController.clear();
    } catch (e) {
      _errPass = e.message;
      _setPassMessage();
    }
  }

  void _setPassMessage() {
    setState(() {
      _visiblePass = true;
    });
  }

  @override
  void dispose() {
    _emailResetController.dispose();
    super.dispose();
  }
}
