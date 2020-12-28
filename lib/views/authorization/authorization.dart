import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/views/authorization/sign_up.dart';
import 'package:flutter_firebase_auth/views/authorization/sign_in.dart';

class Authorization extends StatefulWidget {
  @override
  _Authorization createState() => _Authorization();
}

class _Authorization extends State<Authorization> {
  bool _visibleSignUp = false;
  bool _visibleSignIn = true;
  bool _visible = false;

  void _setVisabiltyRegister() {
    setState(() {
      _visibleSignUp = !_visibleSignUp;
      _visible = !_visible;
    });
  }
  void _setVisabiltyLogIn() {
    setState(() {
      _visibleSignIn = !_visibleSignIn;
      _visible = !_visible;
    });
  }
  void _toggleVisabilty() {
    setState(() {
      _visibleSignIn = !_visibleSignIn;
      _visibleSignUp = !_visibleSignUp;
    });
  }
  /* void _toggle() {
    setState(() {
      _visibleSignUp = false;
      _visibleSignIn = false;
      _visible = true;
    });
  } */
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            Visibility(
              visible: _visible == true,
              child: OutlinedButton(
                // or TextButton()
                onPressed: () {
                  _setVisabiltyLogIn();
                },
                child: Text('Login',
                    style: TextStyle(fontSize: 25.0, color: Colors.blue)),
                style: TextButton.styleFrom(
                  //primary: Colors.blue,
                  //backgroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue),
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red)),
                ),
              ),
            ),
            Visibility(
              visible: _visibleSignIn == true,
              child: Column(
                children: <Widget>[
                  SignIn(),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 210.0,
                        minWidth: 170.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Text("Not a user yet?"),
                      GestureDetector(
                        onTap: (){
                          _toggleVisabilty();
                        }, 
                        child: Text(
                          "Sign up",
                          style: new TextStyle(
                            color: Colors.blue, 
                            fontWeight: FontWeight.bold),
                          )
                        )
                      ]
                    )
                  )                  
                ]
              )
              
            ),
            Visibility(
              visible: _visible == true,
              child: SizedBox(height: 20),
            ),
            Visibility(
              visible: _visibleSignUp == true,
              child: Column(
                children: <Widget>[
                  SignUp(),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 210.0,
                        minWidth: 170.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Text("Already User?"),
                      GestureDetector(
                        onTap: (){
                          _toggleVisabilty();
                        }, 
                        child: Text(
                          "Login",
                          style: new TextStyle(
                            color: Colors.blue, 
                            fontWeight: FontWeight.bold),
                          )
                        )
                      ]
                    )
                  )                  
                ]
              )
              
            ),
            Visibility(
              visible: _visible == true,
              child: OutlinedButton(
                onPressed: () {
                  _setVisabiltyRegister();
                },
                child: Text('Register',
                    style: TextStyle(fontSize: 25.0, color: Colors.blue)),
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  //backgroundColor: Colors.blue,
                  side: BorderSide(color: Colors.blue),
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.red)),
                ),
              ),
            ),

          ]),
      )/* ,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15.0),
        child: Container(
          //color: Colors.red,
          child: Row(        
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("user Status"),
              GestureDetector(
                onTap: (){
                  _toggle();
                }, 
                child: Text(
                  "toggle",
                  style: new TextStyle(
                  color: Colors.blue, 
                  fontWeight: FontWeight.bold),
                )
              )
            ] 
          )
        )
      )
     */
    );
  }
}
