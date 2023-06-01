import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:delivery_together/MyInfo.dart';
import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'MyPage.dart';
import 'list.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({Key? key}) : super(key: key);

  @override
  State<MyOrderPage> createState() => _MyOrderPage();
}
class User{
  String email;
  String name;
  User({
    required this.email,
    required this.name
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

class Post {
  String storeName;
  String pickupSpot;
  int memTotalCnt;
  int memCurrentCnt;
  String orderTime;
  DateTime createdTime;

  Post({
    required this.storeName,
    required this.pickupSpot,
    required this.memTotalCnt,
    required this.memCurrentCnt,
    required this.orderTime,
    required this.createdTime,
  });
}

class _MyOrderPage extends State<MyOrderPage> {
  List<Post> postList = [];
  final userAuth = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    fetchData();
    print(postList);
  }

  Future<void> fetchData() async {

    String? userEmail = Provider.of<UserProvider>(context, listen: false).email;
    print(userEmail);
    if (userEmail != null) {
      print("된다!");
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

        List<Post> tempList = [];
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
            Post post = Post(
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


  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: FixedAppBar(context),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF98A5B3),
          ),
          child: Column(
            children: [
              TitleWidget(context, '글목록', 1),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: postList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, index) {
                      Post post = postList[index];
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
            ],
          ),
        ),
      ),
    );
  }

}