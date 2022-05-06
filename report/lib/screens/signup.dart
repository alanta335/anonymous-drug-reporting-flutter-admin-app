import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/utils/deviceid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:report/main.dart';

import 'homescreen.dart';
import 'list.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

var userType = "";
String? uid;

class _SignupState extends State<Signup> {
  @override
  final _formkey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("asset/icon2.png"),
        fit: BoxFit.cover,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("icon/icon.png", height: 160, width: 160),
          SizedBox(height: 160),
          GestureDetector(
            onTap: () async {
              await GoogleSignInProvider().googleLogin();
              FirebaseFirestore.instance
                  .collection('USERS')
                  .doc('${FirebaseAuth.instance.currentUser!.uid}')
                  .set({});
              FirebaseFirestore.instance
                  .collection('USERS')
                  .doc('${FirebaseAuth.instance.currentUser!.uid}')
                  .collection('message')
                  .doc()
                  .set({
                'priority': 0,
                'text': "welcome",
                'type': "sender",
                'time': DateTime.now().toString()
              });

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (ctx) => const ListOfUser()));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.yellowAccent,
                borderRadius: BorderRadius.circular(50),
              ),
              width: width * 0.87,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Sign up with Google ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Poppins',
                          color: Colors.black),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
