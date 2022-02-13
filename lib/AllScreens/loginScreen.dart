import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/mainScreen.dart';
import 'package:rider_app/AllScreens/registrationScreen.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/main.dart';

class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";
  TextEditingController emailTextController = new TextEditingController();
  TextEditingController passwordTextController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 25.0,
              ),
              Image(
                image: AssetImage("images/logo.png"),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text("Login as a Rider",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold")),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailTextController,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      obscureText: true,
                      controller: passwordTextController,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                        color: Colors.yellow,
                        textColor: Colors.black,
                        child: Container(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0)),
                        onPressed: () {
                          if (!emailTextController.text.contains("@") &&
                              emailTextController.text.length < 3) {
                            displayToastMessage(
                                "Invalid Email Address", context);
                          } else if (passwordTextController.text.isEmpty) {
                            displayToastMessage(
                                "Password cannot be empty", context);
                          } else {
                            loginAndAuthenticateUser(context);
                          }
                        })
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    print("clicked");
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.idScreen, (route) => false);
                  },
                  child: Text("Do not have an Account? Register Here"))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contex) {
          return ProgressDialog(message: "Authenticating pls wait");
        });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      User? user = userCredential.user;

      if (user != null) {
        usersRef.child(user.uid).once().then((DataSnapshot snap) {
          if (snap.value != null) {
            displayToastMessage("You are logged in", context);
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.idScreen, (route) => false);
          } else {
            _firebaseAuth.signOut();
            Navigator.pop(context);
            displayToastMessage("No user record found ", context);
          }
        });
      } else {
        Navigator.pop(context);
        displayToastMessage("User cannot be signed in", context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
