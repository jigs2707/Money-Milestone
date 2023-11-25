import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_financial_goals/data/repository/authRepository.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final User userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route route(final RouteSettings routeSettings) {
    Map<String, dynamic> arguments =
        routeSettings.arguments as Map<String, dynamic>;
    return CupertinoPageRoute(
      builder: (final _) => HomeScreen(
        userData: arguments["userData"],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  //
  //Stream<QuerySnapshot> _booksStream = FirebaseFirestore.instance.collection('Users').snapshots();

  Stream<DocumentSnapshot>? _documentStream;

  final databaseReference = FirebaseFirestore.instance;

  User? user;

  @override
  void initState() {
    super.initState();
    //
    _documentStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userData.uid)
        .snapshots();

    // Future.delayed(
    //   Duration.zero,
    //   () async{
    //     user = await AuthRepository().getCurrentUser();
    //     print("init before");
    //
    //     print("init after");
    //     setState(() {
    //
    //     });
    //   },
    // );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireStore Demo'),
        actions: [
          IconButton.outlined(
            onPressed: () {
              AuthRepository()
                  .signOut()
                  .then((value) => Navigator.pop(context));
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // StreamBuilder(
            //   stream: _booksStream,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasError) {
            //       return const Text("error here");
            //     } else if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Text("Loading");
            //     } else {
            //       if (snapshot.hasData) {
            //         return SizedBox(
            //           height: 100,
            //           child: ListView(
            //             scrollDirection: Axis.vertical,
            //             children: snapshot.data!.docs.map((DocumentSnapshot document) {
            //               Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            //               if (data.isEmpty) {
            //                 return const Text("No data found");
            //               } else {
            //                 return ListTile(
            //                   title: Text(data['name'] ?? ""),
            //                 );
            //               }
            //             }).toList(),
            //           ),
            //         );
            //       } else {
            //         return const Text("No data found");
            //       }
            //     }
            //   },
            // ),
            const Divider(),
            StreamBuilder(
              stream: _documentStream,
              builder: (context, snapshot) {
                //connection established and active
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return const Text("error here");
                  }
                  if (snapshot.hasData) {
                    DocumentSnapshot? data = snapshot.data;

                    if (data!.exists) {
                      return SizedBox(
                        height: 200,
                        child:
                            ListView(scrollDirection: Axis.vertical, children: [
                          Text(snapshot.data!["name"]),
                        ]),
                      );
                    } else {
                      return Container(
                        height: 200,
                        width: 20,
                        color: Colors.amber,
                      );
                    }
                  } else {
                    return const Text("No data found");
                  }
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Text("Loading");
                } else {
                  print("here ${snapshot.connectionState}");
                  return const Text("none");
                }
              },
            ),
            const Divider(),
            ElevatedButton(
              child: const Text('Create Record'),
              onPressed: () {
                createRecord();
                setState(() {});
              },
            ),
            ElevatedButton(
              child: const Text('View Record'),
              onPressed: () {
                getData();
              },
            ),
            ElevatedButton(
              child: const Text('Update Record'),
              onPressed: () {
                updateData();
              },
            ),
            ElevatedButton(
              child: const Text('Delete Record'),
              onPressed: () {
                deleteData();
              },
            ),
          ],
        ),
      ), //center
    );
  }

  void createRecord() async {
    User user = await AuthRepository().getCurrentUser();
    await databaseReference
        .collection("Users")
        .doc(user.uid)
        .set({'name': 'Jignesh1', 'description': 'test1'}).then((value) {
      print("user is added");
    }).catchError((error) {
      if (kDebugMode) {
        print("error ");
      }
    });
  }

  void getData() async {
    User user = await AuthRepository().getCurrentUser();
    await databaseReference
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      print(snapshot.data());
    });
  }

  void updateData() async {
    try {
      User user = await AuthRepository().getCurrentUser();
      databaseReference
          .collection('Users')
          .doc(user.uid)
          .set({'name': 'Jignesh', 'description': 'test'}).then((value) {
        print("data updates ");
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteData() {
    try {
      databaseReference
          .collection('Users')
          .doc(user?.uid)
          .delete()
          .then((value) {
        print("data deleted");
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
