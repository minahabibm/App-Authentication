import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_firebase_auth/views/app.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          }
        )),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.Email,
            text: "Sign In Passwordless",
            onPressed: () {
              // Uncomment the following lines to enable passwordless signin, for ios Development it requires apple Developer Account, and few extra steps in the Runner.xcodeproj file.  
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => EmailLinkSignIn()),
              // );
            },
          )),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.GoogleDark,
            text: "Sign In with Google",
            onPressed: () {
              GooglLinkeSignIn()._signInWithGoogle(context);
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => ),
            // );
            },
          )),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.FacebookNew,
            text: "Sign In with Facebook",
            onPressed: () {
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => ),
            // );
            },
          )),
      Padding(
          padding: EdgeInsets.all(5.0),
          child: SignInButton(
            Buttons.AppleDark,
            text: "Sign In with Apple",
            onPressed: () {
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => ),
            // );
            },
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

class EmailLinkSignIn extends StatefulWidget {
  @override
  _EmailLinkSignInState createState() => _EmailLinkSignInState();
}

class _EmailLinkSignInState extends State<EmailLinkSignIn> with WidgetsBindingObserver {
  final _formKeyPasswordless = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDynamicLinks _firebaseDynLinks = FirebaseDynamicLinks.instance;
  final TextEditingController _emailLogInController = TextEditingController();
  bool _visiblEerrLog = false;
  String _link;
  String _errlogIn = "";

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
  }

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
            key: _formKeyPasswordless,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailLogInController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    hintText: 'Enter Your E-mail',
                    labelText: 'E-mail',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
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
                      if (_formKeyPasswordless.currentState.validate()) {
                        _passwordlessLoginFirebase();
                      }
                    },
                    child: Text('send'),
                ),
                Visibility(
                  visible: _visiblEerrLog == true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _errlogIn,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                    ])),
              ])))));
  }

  
  Future<void> _passwordlessLoginFirebase() async {
    var acs = ActionCodeSettings(
      url: "https://flutterfirebaseautherization.page.link/qbvQ",
      handleCodeInApp: true,
      iOSBundleId: "com.example.flutterfirebaseautherization",
      androidPackageName: "com.example.flutterfirebaseautherization",
      androidInstallApp: true,      
      androidMinimumVersion: "12"
    ); 

    await _firebaseAuth.sendSignInLinkToEmail( email: _emailLogInController.text, actionCodeSettings: acs)
      .then((value) => {
        _errlogIn = 'Successfully sent email verification',
        print(_errlogIn),
        _setPassMessage()
        //Navigator.pop(context)
      }).catchError((onError) => {
        print('Error sending email verification $onError'),
        _errlogIn = onError.toString(),
        _setPassMessage()
      });
  }

  Future<void> _retrieveDynamicLink() async {
    try {
      
      final PendingDynamicLinkData data = await _firebaseDynLinks.getInitialLink();
      final Uri deepLink = data?.link;
      print(deepLink.toString());
      if (deepLink.toString() != null) {
        _link = deepLink.toString();
        _signInWithEmailAndLink();
      }

      _firebaseDynLinks.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;
          print(deepLink);
          if (deepLink != null) {
             _signInWithEmailAndLink();
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }  
      );

    }catch(e){
      _errlogIn = e.toString();
      _setPassMessage();
    }
  }

  Future<void> _signInWithEmailAndLink() async {
    bool validLink = _firebaseAuth.isSignInWithEmailLink(_link);
    print(validLink);
    if (validLink){
      try {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute( builder: (context) => App(name: _emailLogInController.text, uid: null)),
          (Route<dynamic> route) => false
        );

      }catch (onError) {
        _errlogIn = onError.toString();
        _setPassMessage();
      } 
    } else {
      print("Invalid Link");
      _errlogIn = "Invalid Link";
        _setPassMessage();
    }

  }

  void _setPassMessage() {
    setState(() {
      _visiblEerrLog = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.resumed) {
      _retrieveDynamicLink();
    }
  }
  
  @override
  void dispose() {
    _emailLogInController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
}

class GooglLinkeSignIn extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );    
  }

  Future<UserCredential> _signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn() ;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final test = await FirebaseAuth.instance.signInWithCredential(credential);
    String name = test.additionalUserInfo.profile['given_name'];
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute( builder: (context) => App(name: name, uid: test.user.uid)),
      (Route<dynamic> route) => false
    );
    
    return test;
  }

}
