import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_together/MyOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'MyInfo.dart';
import 'list.dart';
import 'login.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF98A5B3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF284463),
        ),
      ),
      home: ChangeNotifierProvider<UserProvider>(
        create: (_) => UserProvider(),
        child: const MyHomePage(title: '같이 먹자'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class UserProvider extends ChangeNotifier {
  String? email;
  String? name;

  void setUser(String email, String name) {
    this.email = email;
    this.name = name;
    notifyListeners();
  }
}

class User{
  String email;
  String name;
  User({
    required this.email,
    required this.name
  });
}

class _MyHomePageState extends State<MyHomePage> {
  final userAuth = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }


  Future<void> fetchUserData() async {

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userAuth?.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
        String email = userData?['email'] ?? '';
        String name = userData?['name'] ?? '';
        Provider.of<UserProvider>(context, listen: false).setUser(email, name);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF284463),
    minimumSize: const Size(100, 70),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final userAuth = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: FixedAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TitleWidget(context, 'My page', 0),
          SizedBox(height: 40,),
          const CircleAvatar(
            radius: 50,
            //backgroundImage: userAuth.photoURL,
          ),
          SizedBox(height: 20),
          Text(
            userProvider.name ?? '',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.email, color: Colors.white),
            title: Text('Email', style: TextStyle(fontSize: 18, color: Colors.black)),
            subtitle: Text(userProvider.email ?? '', style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _signOut();
            },
            child: Text('Logout'),
          ),

          Container(
            margin: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: ElevatedButton(
              style: elevatedButtonStyle,
              onPressed: () {
                Get.to(() => MyOrderPage());
              },
              child: const Text("주문 기록", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    LoginPage.go = false;
    Get.to(() => const LoginPage());
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:delivery_together/MyOrder.dart';
// import 'package:delivery_together/utils/components.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:provider/provider.dart';
// import 'MyInfo.dart';
// import 'login.dart';
//
// class MyPage extends StatelessWidget {
//   const MyPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primaryColor: Colors.amber,
//         scaffoldBackgroundColor: const Color(0xFF98A5B3),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF284463),
//         ),
//         // Color(0xFF284463),
//         // colorScheme: ColorScheme(primary: Color(0xFF284463))
//         // textTheme: ,
//
//       ),
//       home:
//       const MyHomePage(title: '같이 먹자'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
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
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   final userAuth = FirebaseAuth.instance.currentUser;
//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }
//
//   Future<void> fetchUserData() async {
//     try {
//       DocumentSnapshot userSnapshot = (await FirebaseFirestore.instance
//           .collection('user').doc(userAuth?.uid).get()) as DocumentSnapshot<Object?>;
//
//       if (userSnapshot.exists) {
//
//         Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
//         String email = userData?['email'] ?? '';
//         String name = userData?['name'] ?? '';
//         Provider.of<UserProvider>(context, listen: false).setUser(email, name);
//
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }
//
//   final ButtonStyle ElevatedButtonStyle = ElevatedButton.styleFrom(
//     backgroundColor: const Color(0xFF284463),
//     minimumSize: const Size(100, 70),
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(15)),
//     ),
//   );
//   @override
//   Widget build(BuildContext context) {
//     UserProvider userProvider = Provider.of<UserProvider>(context);
//
//     return Scaffold(
//
//       appBar:  FixedAppBar(context),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           TitleWidget(context, 'My page', 0),
//
//           SizedBox(height: 40,),
//           const CircleAvatar(
//             radius: 50,
//             //backgroundImage: AssetImage('/assets/profile_image.png'),
//           ),
//           SizedBox(height: 20),
//           Text(
//             userProvider.name ?? '',
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 20),
//           ListTile(
//             leading: Icon(Icons.email,color:Colors.white),
//             title: Text('Email',style: TextStyle(fontSize: 18,color:Colors.white)),
//             subtitle: Text(userProvider.email ?? '', style:TextStyle(fontSize:16,color:Colors.grey)),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton( // 로그아웃 버튼
//
//             onPressed: () {
//               _signOut();
//             },
//             child: Text('Logout'),
//           ),
//
//           // Container(
//           //     margin: const EdgeInsets.symmetric(
//           //         vertical: 100,
//           //       horizontal: 20
//           //     ),
//           //     child: ElevatedButton(
//           //       style: ElevatedButtonStyle,
//           //       onPressed: () {
//           //         Get.to(() => MyInfo());
//           //       },
//           //       child: const Text("내 정보",style: TextStyle(fontSize: 18)),
//           //     )
//           // ),
//           Container(
//               margin: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 20
//               ),
//               child: ElevatedButton(
//                 style: ElevatedButtonStyle,
//                 onPressed: () {
//                   Get.to(() => MyOrderPage());
//                 },
//                 child: const Text("주문 기록",style: TextStyle(fontSize: 18)),
//               )
//           ),
//
//
//         ],
//       ),
//       // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
//   Future<void> _signOut() async {
//     await FirebaseAuth.instance.signOut();
//     LoginPage.go = false;
//     Get.to(() => const LoginPage());
//   }
//
// }
