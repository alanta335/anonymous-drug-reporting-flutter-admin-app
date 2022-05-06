import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:report/screens/homescreen.dart';

import 'signup.dart';

class ListOfUser extends StatefulWidget {
  const ListOfUser({Key? key}) : super(key: key);

  @override
  State<ListOfUser> createState() => _ListOfUserState();
}

class _ListOfUserState extends State<ListOfUser> {
  Query users = FirebaseFirestore.instance.collection('USERS');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: Text("loading")),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.yellowAccent,
            title: const Text(
              'Client List',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                  color: Colors.black),
            ),
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("asset/icon2.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              addAutomaticKeepAlives: false,
              cacheExtent: 300,
              reverse: false,
              //physics: ,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                print(document.id);
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => Homepage(idd: document.id)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.grey[400],
                      child: ListTile(
                        title: Text('${document.id}'),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
