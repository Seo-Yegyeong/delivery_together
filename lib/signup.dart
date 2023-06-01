import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_together/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      
      try {
        // Firebase에 사용자 등록
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        await FirebaseFirestore.instance.collection('user').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });
        
        // 사용자 등록 후 추가 작업 수행 가능
        
        // Sign Up 성공 시 로그인 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        // 등록 중에 오류 발생 시 오류 처리
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            const SizedBox(height: 50.0),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Email Address';
                }
                else if (!value.contains('@')) {
                  return 'Please contain "@"';
                }
                return null;
              },
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Password';
                }
                return null;
              },
              obscureText: true,
            ),
            const SizedBox(height: 12.0),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Confirm Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                } else if (value != _passwordController.text) {
                  return 'Confirm Password doesn\'t match Password';
                }
                return null;
              },
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text('Sign Up'),
              onPressed: _signUp,
            ),
          ],
        ),
      ),
    );
  }
}
