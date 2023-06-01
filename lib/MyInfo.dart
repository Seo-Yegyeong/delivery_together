import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'login.dart';
import 'MyPage.dart';

class MyInfo extends StatefulWidget{
  const MyInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyInfoState();
}

// class UserProvider extends ChangeNotifier {
//   String? email;
//   String? name;
//
//   void setUser(String email, String name) {
//     this.email = email;
//     this.name = name;
//     notifyListeners();
//   }
// }

class _MyInfoState extends State<MyInfo> {
  final userAuth = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = (await FirebaseFirestore.instance
          .collection('user').doc(userAuth?.uid).get()) as DocumentSnapshot<Object?>;

      if (userSnapshot.exists) {

        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
        String email = userData?['email'] ?? '';
        String name = userData?['name'] ?? '';
        Provider.of<UserProvider>(context, listen: false).setUser(email, name);

      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',style:TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children:  [
            SizedBox(height: 40,),

            const CircleAvatar(
              radius: 50,
              //backgroundImage: AssetImage('/assets/profile_image.png'),
            ),
            SizedBox(height: 20),
            Text(
              userProvider.name ?? '',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            

            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email,color:Colors.white),
              title: Text('Email',style: TextStyle(fontSize: 18,color:Colors.white)),
              subtitle: Text(userProvider.email ?? '', style:TextStyle(fontSize:16,color:Colors.grey)),
            ),
            SizedBox(height: 20),
            ElevatedButton( // 로그아웃 버튼

              onPressed: () {
                _signOut();
              },
              child: Text('Logout'),
            ),



          ],
        ),
      ),
    );
  }

Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    LoginPage.go = false;
    Get.to(() => const LoginPage());
  }
}

// class MyInfo extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Profile',style:TextStyle(color: Colors.white)),
//       ),
//       body: Center(
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.start,
//           children:  [
//             SizedBox(height: 40,),
//
//             const CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage('assets/profile_image.png'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'SOOBIN',
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Nick name : sooooo',
//               style: TextStyle(fontSize: 20, color: Colors.grey),
//             ),
//
//             SizedBox(height: 20),
//             ListTile(
//               leading: Icon(Icons.email,color:Colors.white),
//               title: Text('Email',style: TextStyle(fontSize: 18,color:Colors.white)),
//               subtitle: Text('example@example.com',style:TextStyle(fontSize:16,color:Colors.grey)),
//             ),
//             ListTile(
//               leading: Icon(Icons.phone,color:Colors.white),
//               title: Text('Phone',style: TextStyle(fontSize:18 ,color:Colors.white)),
//               subtitle: Text('+82 010-1111-1111',style:TextStyle(fontSize:16,color:Colors.grey)),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton( // 로그아웃 버튼
//
//               onPressed: () {
//
//               },
//               child: Text('Logout'),
//             ),
//
//
//
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }
