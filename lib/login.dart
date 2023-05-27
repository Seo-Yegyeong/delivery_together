import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  CollectionReference database = FirebaseFirestore.instance.collection('user');
  late QuerySnapshot querySnapshot;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: _bodyWidget(),
      ),
    );
  }

  _bodyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              Image.asset('assets/icon/cookie.png'),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 80,
                width: 300,
                child: ElevatedButton(
                  onPressed: () async {
                    final UserCredential userCredential =
                    await signInWithGoogle();

                    User? user = userCredential.user;

                    if (user != null) {
                      int i;
                      querySnapshot = await database.get();

                      for (i = 0; i < querySnapshot.docs.length; i++) {
                        var a = querySnapshot.docs[i];

                        if (a.get('uid') == user.uid) {
                          break;
                        }
                      }

                      if (i == (querySnapshot.docs.length)) {
                        database.doc(user.uid).set({
                          'email': user.email.toString(),
                          'name': user.displayName.toString(),
                          'uid': user.uid,
                        });
                      }

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    '구글로 로그인',
                    style: TextStyle(fontSize: 30.0, color: Color(0xFF000000),),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
