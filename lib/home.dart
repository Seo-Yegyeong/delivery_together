import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:delivery_together/DeliveryState.dart';
import 'package:delivery_together/utils/components.dart';
import 'package:delivery_together/utils/size.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'MyPage.dart';
import 'list.dart';
import 'write_order.dart';




class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: FixedAppBar(context),
        body: GridView.count(
          padding: const EdgeInsets.all(25),
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
          crossAxisCount: 2,
          children: [
            MyButton(index: 0,),
            MyButton(index: 1,),
            MyButton(index: 2,),
            MyButton(index: 3,),
          ],
        ));
  }
}

class PostID{
  String PostIndex;
  PostID ({required this.PostIndex,});
}

class MyButton extends StatefulWidget {
  int index;

  MyButton({Key? key, required this.index}) : super(key: key);

  static List<String> _menu = <String>[
    '목록',
    '글쓰기',
    '배달현황',
    '마이페이지'
  ];

  static List<String> _menuIcon = <String>[
    'assets/icon/list.png',
    'assets/icon/write.png',
    'assets/icon/status.png',
    'assets/icon/mypage.png',
  ] ;

  static List<Widget> _LinkTo = <Widget>[
    ListPage(),
    WritePage(),
    DeliveryStatePage(postID: PostID),
    MyPage(),
  ];

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  List<Post> postID = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
     firestore.QuerySnapshot querySnapshot = await firestore.FirebaseFirestore.instance.collection('user').doc(uid).collection('postList').orderBy('timestamp', descending: true).limit(1).get();
    querySnapshot.docs.forEach((doc) {
      String PostIndex = doc['postID'];
       PostID postID = PostID(PostIndex: PostIndex);
    });

    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: getScreenWidth(context) * 0.35,
        width: getScreenWidth(context) * 0.35,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(height: 40, width: 40, child: Image.asset(MyButton._menuIcon[widget.index] as String), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),),
            Center(
              child: Text(
                MyButton._menu[widget.index],
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        // _onItemTapped(_selectedIndex);
        Get.to(() => MyButton._LinkTo[widget.index]);
        print(widget.index);
      },
    );
  }
}
