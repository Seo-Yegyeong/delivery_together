import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  CollectionReference userCollection = FirebaseFirestore.instance.collection('user');
  late QuerySnapshot querySnapshot;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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

  Future<UserCredential?> signInWithEmailAndPassword() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        print('Email and password must be provided.');
        return null;
      }

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        print('Email and password must be provided.');
        return null;
      }

      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: _bodyWidget(),
        ),
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
              const SizedBox(
                height: 50,
              ),
              Image.asset(
                'assets/icon/cookie.png',
                width: 150, // Adjust the image width here
                height: 150, // Adjust the image height here
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: '이메일',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: '비밀번호',
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final UserCredential? userCredential = await signInWithEmailAndPassword();
                              if (userCredential != null) {
                                // 로그인 성공한 경우의 처리
                                // 예: 홈 화면으로 이동
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ),
                                );
                              }
                            },
                            child: Text('이메일로 로그인'),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text('회원 가입'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 60, // Adjust the button height here
                width: 250, // Adjust the button width here
                child: ElevatedButton(
                  onPressed: () async {
                    final UserCredential? userCredential = await signInWithEmailAndPassword();
                    if (userCredential != null) {
                      User? user = userCredential.user;

                      if (user != null) {
                        int i;
                        querySnapshot = await userCollection.get();

                        for (i = 0; i < querySnapshot.docs.length; i++) {
                          var a = querySnapshot.docs[i];

                          if (a.get('uid') == user.uid) {
                            break;
                          }
                        }

                        print('=============test1=============');
                        if (i == (querySnapshot.docs.length)) {
                          userCollection.doc(user.uid).set({
                            'email': user.email,
                            'name': user.displayName.toString(),
                          });
                        }
                        print('=============test2=============');
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    '구글로 로그인',
                    style: TextStyle(
                      fontSize: 20.0, // Adjust the button text size here
                      color: Color(0xFF000000),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFC700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
