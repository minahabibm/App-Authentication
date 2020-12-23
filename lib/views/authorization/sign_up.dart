import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_firebase_auth/views/app.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.Email,
            text: "Sign up with Email",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpEmail()),
              );
            },
          )),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.Google,
            text: "Sign up with Google",
            onPressed: () {},
          )),
    ]);
  }
}

class SignUpEmail extends StatefulWidget {
  @override
  _SignUpEmailState createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference _firestore = FirebaseFirestore.instance.collection('users');
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  var _err = "";
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
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
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: 'Enter Your First Name',
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        icon: Icon(null),
                        hintText: 'Enter Your Last Name',
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
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
                    TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: Icon(null),
                          hintText: 'Confirm Password',
                          labelText: 'Confirm Password',
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Password do not match';
                          } else {
                            return null;
                          }
                        }),
                    RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          registerToFirebase();
                        }
                      },
                      child: Text('Submit'),
                    ),                    
                    Visibility(
                      visible: _visible == true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(_err,style: new TextStyle(color:Colors.red), textAlign: TextAlign.center,)
                        ]
                      )
                    )
                  ],
                ),
              )),
        ));
  }

  Future<void> registerToFirebase() async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((result) async {
        await _firebaseAuth.currentUser.updateProfile(
            displayName:
                (_firstNameController.text + " " + _lastNameController.text),
            photoURL: ("http://www.example.com"));
        await _firestore.doc(result.user.uid).set({
          "uid": result.user.uid,
          "first_name": _firstNameController.text,
          "last_name": _lastNameController.text,
          "email": _emailController.text,
        });
      }).then((result) async {
        User user = _firebaseAuth.currentUser;
        print(user);
        setState(() { _visible = false; });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => App( name: _firstNameController.text, uid: user.uid )),
          (Route<dynamic> route) => false);
      });
    } catch (e) {
      if (e.code == 'weak-password') {
        _err = 'The password provided is too weak.';
        print(_err);
        _setErrorMessage();
      } else if (e.code == 'email-already-in-use') {
        _err = 'The account already exists for that email.';
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
