import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/loginScreen.dart';
import 'package:rider_app/AllScreens/mainScreen.dart';
import 'package:rider_app/AllWidgets/progressDialog.dart';
import 'package:rider_app/main.dart';

class RegistrationScreen extends StatelessWidget {
  static const String idScreen = "register";
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
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
                height: 20.0,
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
              Text("Register as a Rider",
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
                      keyboardType: TextInputType.text,
                      controller: nameTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(fontSize: 14.0),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0)),
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailTextEditingController,
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
                      keyboardType: TextInputType.phone,
                      controller: phoneTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Phone",
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
                      controller: passwordTextEditingController,
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
                              "Create Account",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(24.0)),
                        onPressed: () {
                          if (nameTextEditingController.text.length < 4) {
                            displayToastMessage(
                                "Name must be at least 3 characters", context);
                          } else if (!emailTextEditingController.text
                              .contains("@")) {
                            displayToastMessage(
                                "Email address is not valid", context);
                          } else if (phoneTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Phone number is empty", context);
                          } else if (passwordTextEditingController.text.length <
                              6) {
                            displayToastMessage(
                                "Password must be more than 6 characters",
                                context);
                          } else {
                            registerNewUser(context);
                          }
                        })
                  ],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, LoginScreen.idScreen, (route) => false);
                  },
                  child: Text("Already have an Account? Login Here"))
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contex) {
          return ProgressDialog(message: "Registering pls wait");
        });

    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: emailTextEditingController.text,
              password: passwordTextEditingController.text);
      User? user = userCredential.user;

      if (user != null) {
        Map userDataMap = {
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim()
        };
        usersRef.child(user.uid).set(userDataMap);
        displayToastMessage(
            "Congratulations account have been created", context);
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.idScreen, (route) => false);
      } else {
        displayToastMessage("Account Creation Failed", context);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        Navigator.pop(context);
        displayToastMessage('The password provided is too weak.', context);
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        Navigator.pop(context);
        displayToastMessage(
            'The account already exists for that email.', context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
