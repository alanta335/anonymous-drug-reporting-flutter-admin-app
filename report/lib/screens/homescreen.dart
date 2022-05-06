import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:report/screens/signup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'map.dart';
import '/models/basicJson.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';

class Homepage extends StatefulWidget {
  final idd;
  const Homepage({@required this.idd});

  @override
  State<Homepage> createState() => _HomepageState(Id: idd);
}

class _HomepageState extends State<Homepage> {
  var Id;
  _HomepageState({@required this.Id});

  @override
  void initState() {
    super.initState();
    // uidFetch();
  }

  File? image;
  String? imeiNo, platformVersion;

  // ignore: non_constant_identifier_names

  MaterialColor getcolor(int priority) {
    if (priority == 0) {
      return Colors.grey;
    } else if (priority == 1) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  Future getImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      this.image = imageTemp;
    });
    print(image.path);
    final imageFile = File(image.path);
    final uploadTask = await FirebaseStorage.instance
        .ref()
        .child('user_photo/${Id}_${DateTime.now().toString()}')
        .putFile(imageFile);
    final imageURL = await uploadTask.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('USERS')
        .doc('${Id}')
        .collection('message')
        .doc()
        .set({
      'text': imageURL,
      'priority': 1,
      'type': "image",
      'time': DateTime.now().toString()
    });
  }

  final ImagePicker _picker = ImagePicker();
  var dio = Dio();
  TextEditingController messageController = TextEditingController();
  ScrollController _myController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Query message = FirebaseFirestore.instance
        .collection('USERS')
        .doc('${Id}')
        .collection('message')
        .orderBy('time', descending: true);
    var bs = ElevatedButton.styleFrom(
        padding: EdgeInsets.all(15),
        primary: Colors.white,
        shape: CircleBorder());
    return StreamBuilder<QuerySnapshot>(
      stream: message.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("asset/icon2.png"),
                    fit: BoxFit.cover,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            addAutomaticKeepAlives: true,
                            cacheExtent: 300,
                            reverse: true,
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              return Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(
                                    left: 14, right: 14, top: 10, bottom: 10),
                                child: Align(
                                  alignment: (document.get('type').toString() ==
                                              "sender" ||
                                          document.get('type').toString() ==
                                              "image"
                                      ? Alignment.topRight
                                      : Alignment.topLeft),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: getcolor(document.get('priority')),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: (document.get('type').toString() ==
                                            "image")
                                        ? Image.network(
                                            document.get('text').toString(),
                                          )
                                        : Text(
                                            document.get('text'),
                                            style: TextStyle(fontSize: 15),
                                          ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50)),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'type here',
                            labelText: 'Message',
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: bs,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => const Map()));
                                },
                                child: const Icon(Icons.location_on,
                                    color: Colors.black),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: bs,
                                onPressed: () async {
                                  var sx = jsonEncode(
                                      {"st": messageController.text});
                                  Response x = await dio.post(
                                      "https://reportapitest34.azurewebsites.net/spam",
                                      data: sx);
                                  print(x.data);
                                  if (x.data == false) {
                                    FirebaseFirestore.instance
                                        .collection('USERS')
                                        .doc('$Id')
                                        .set({});

                                    FirebaseFirestore.instance
                                        .collection('USERS')
                                        .doc('$Id')
                                        .collection('message')
                                        .doc()
                                        .set({
                                      'text': messageController.text,
                                      'type': "receiver",
                                      'priority': 0,
                                      'time': DateTime.now().toString()
                                    });
                                    messageController.text = "";
                                  }
                                },
                                child: Icon(Icons.send, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
