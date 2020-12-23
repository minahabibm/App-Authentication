import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/views/authorization/authorization.dart';

class App extends StatefulWidget {
  App({Key key, @required this.name, @required this.uid}) : super(key: key);
  final String name;
  final String uid;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            Text('Hello, ' + widget.name),
          ])),
      floatingActionButton: FloatingActionButton(
        child: Text('Log out', textAlign: TextAlign.center),
        onPressed: () {
          signOutFirebase();
        },
      ),
    );
  }

  void signOutFirebase() async {
    try {
      await _firebaseAuth.signOut();
      print("_!_");
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Authorization()),
          (Route<dynamic> route) => false);
    } catch (e) {
      print(e);
    }
  }
}
