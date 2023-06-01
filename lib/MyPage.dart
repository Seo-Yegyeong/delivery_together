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

class PostMypage {
  String storeName;
  String pickupSpot;
  int memTotalCnt;
  int memCurrentCnt;
  String orderTime;
  DateTime createdTime;

  PostMypage({
    required this.storeName,
    required this.pickupSpot,
    required this.memTotalCnt,
    required this.memCurrentCnt,
    required this.orderTime,
    required this.createdTime,
  });
}

class PostUser{
  String memberId;
  String postId;
  bool isWriter;

  PostUser({
    required this.memberId,
    required this.isWriter,
    required this.postId
  });
}

class _MyHomePageState extends State<MyHomePage> {
  final userAuth = FirebaseAuth.instance.currentUser;
  List<PostMypage> postList = [];
  @override
  void initState() {
    super.initState();
    fetchData();
    fetchUserData();
  }

  Future<void> fetchData() async {


    String? userEmail = Provider.of<UserProvider>(context, listen: false).email;
    print(userEmail);
    if (userEmail != null) {
      print("된다!");
      // 2. user 컬렉션에서 해당 이메일과 일치하는 문서 조회
      firestore.QuerySnapshot userSnapshot = await firestore.FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: userEmail)
          .get();


      if (userSnapshot.docs.isNotEmpty) {
        String userId = userEmail;

        // 3. post-user 컬렉션에서 해당 이메일과 일치하는 문서 조회
        firestore.QuerySnapshot postUserSnapshot = await firestore.FirebaseFirestore.instance
            .collection('post-user')
            .where('memberId', isEqualTo: userId)
            .get();


        List<String> postIds = [];
        postUserSnapshot.docs.forEach((doc) {
          String postId = doc['postId'];
          postIds.add(postId);
          print(postId);
        });

        List<PostMypage> tempList = [];
        for (String postId in postIds) {
          // 4. post 컬렉션에서 postId에 해당하는 문서 조회
          firestore.DocumentSnapshot postSnapshot = await firestore.FirebaseFirestore.instance
              .collection('post')
              .doc(postId)
              .get();

          if (postSnapshot.exists) {
            String storeName = postSnapshot['storeName'];
            String pickupSpot = postSnapshot['pickupSpot'];
            int memTotalCnt = postSnapshot['memTotalCnt'];
            int memCurrentCnt = postSnapshot['memCurrentCnt'];
            DateTime orderTime = postSnapshot['orderTime'].toDate();
            DateTime createdTime = postSnapshot['createdTime'].toDate();
            int remainingMinutes = calculateRemainingTime(orderTime);
            String orderTimeString = remainingMinutes == 0 ? '주문 종료' : remainingMinutes.toString() + '분 후';
            PostMypage post = PostMypage(
              storeName: storeName,
              pickupSpot: pickupSpot,
              memTotalCnt: memTotalCnt,
              memCurrentCnt: memCurrentCnt,
              orderTime: orderTimeString,
              createdTime: createdTime,
            );
            tempList.add(post);
          }
        }

        tempList.sort((a, b) => b.createdTime.compareTo(a.createdTime));
        setState(() {
          postList = tempList;
        });
      }
    }
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

    return Scaffold(
      appBar: FixedAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TitleWidget(context, 'My page', 0),
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
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: postList.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, index) {
                  PostMypage post = postList[index];
                  return GestureDetector(
                    onTap: (){
                      // Get.to(()=>ListDetailPage(post: post));
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      padding: EdgeInsets.fromLTRB(8,10,8,10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF284463),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(post.storeName,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 130,
                                height: 40,
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child:Text(post.pickupSpot,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,),
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 40,
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${post.memCurrentCnt.toString()}/${post.memTotalCnt.toString()}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 20,
                                    color: Colors.black,),
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 40,
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(post.orderTime,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 20,
                                    color: Colors.black,),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),


          // Container(
          //   margin: const EdgeInsets.symmetric(
          //     vertical: 10,
          //     horizontal: 20,
          //   ),
          //   child: ElevatedButton(
          //     style: elevatedButtonStyle,
          //     onPressed: () {
          //       Get.to(() => MyOrderPage());
          //     },
          //     child: const Text("주문 기록", style: TextStyle(fontSize: 18)),
          //   ),
          // ),
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
