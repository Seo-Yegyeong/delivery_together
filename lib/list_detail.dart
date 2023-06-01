import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_together/home.dart';
import 'package:delivery_together/list.dart';
import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'DeliveryState.dart';


class ListDetailPage extends StatefulWidget {
  Post post;
  ListDetailPage({Key? key, required this.post
    // required this.doc, required this.docID
  }) : super(key: key);

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

bool isParticipating = false;

class _ListDetailPageState extends State<ListDetailPage> {
  final user = FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      isParticipating = false;
      Stream<QuerySnapshot<Map<String, dynamic>>> myUserList = FirebaseFirestore.instance.collection('post').doc('${widget.post.postID}').collection('userList').snapshots();
      Stream<List<DocumentSnapshot<Map<String, dynamic>>>> expandedStream = myUserList.asyncExpand((QuerySnapshot<Map<String, dynamic>> querySnapshot) async* {
        yield querySnapshot.docs;
      });
      expandedStream.listen((List<DocumentSnapshot<Map<String, dynamic>>> documentList) {
        for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in documentList) {
          Map<String, dynamic>? data = documentSnapshot.data();
          if('${data!['userID']}' == '${user!.uid}') {
            isParticipating = true;
            print('성공~');
          }
          print('나는 ' + user!.uid);
          print('지금 데이터는 ' + data!['userID']);
          print('여기야 여기!!!' + isParticipating.toString());
        }
      });
      print('바깥이야 여기!!!' + isParticipating.toString());
    });
  }

  // Future<bool> AmIpaticipating(Future<QuerySnapshot<Map<String, dynamic>>> myUserList) async {
  //   bool outresult = false;
  //   List<String> userIDList = [];
  //
  //   await myUserList.then((value){
  //     if(userIDList.contains(value.docs.first.id) == false){
  //       userIDList.add(value.docs.first.id);
  //       print(value.docs.first.id);
  //     }
  //   });
  //   userIDList.forEach((element) {print('============$element============');});
  //   print('userIDList : ' + userIDList.toString());
  //   return outresult;
  //   // bool outresult = false;
  //   // myUserList.get().then((QuerySnapshot querySnapshot) {
  //   //   bool innerresult = false;
  //   //   querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) => {
  //   //   // Perform necessary operations without returning a value
  //   //     print(documentSnapshot.get('userID')),
  //   //
  //   //     if(documentSnapshot.get('userID') == user?.uid){
  //   //       innerresult = true,
  //   //       print('innerresult : ' + innerresult.toString())
  //   //     }
  //   //   });
  //   //   outresult = innerresult;
  //   // });
  //   // print('outresult : ' + outresult.toString());
  //   // return outresult;
  //
  //   // bool result = false;
  //   // myUserList.get().then((QueryDocumentSnapshot querySnapshot){
  //   //   print(querySnapshot.data().toString());
  //   //   if(querySnapshot.get('userID') == user?.uid) {
  //   //     result = true;
  //   //   }
  //   // } as FutureOr Function(QuerySnapshot<Object?> value));
  //   // return result;
  //
  //   // bool result = false;
  //   // myUserList.get().then((QueryDocumentSnapshot querySnapshot){
  //   //   print(querySnapshot.data().toString()
  //   //       if(querySnapshot.get('userID') == user?.uid) {
  //   //   result = true;
  //   //   }
  //   // } as FutureOr Function(QuerySnapshot<Object?> value));
  //   // return result;
  //
  //   // List<String> userIDList = [];
  //   // bool result = false;
  //   // myUserList.get().then((QueryDocumentSnapshot querySnapshot){
  //   //
  //   //   userIDList.add(querySnapshot.get('userID'));
  //   // } as FutureOr Function(QuerySnapshot<Object?> value));
  //   // userIDList.forEach((element) {
  //   //   if(element == user!.uid)
  //   //     return true;
  //   // });
  //   // return result;
  // }

  // Widget checkWriter(CollectionReference myUserList)=>Container(
  //   child: (amIpaticipating(myUserList)==true)? Text('내가 적었엉!!'): Text('내가 안 적었엉!!!'),
  // );

  @override
  Widget build(BuildContext context) {
    // Future<QuerySnapshot<Map<String, dynamic>>> myUserList = FirebaseFirestore.instance.collection('post').doc('${widget.post.postID}').collection('userList').get();

    return Scaffold(
      appBar: FixedAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(child: ElevatedButton(child: Text('click!'), onPressed: (){print(isParticipating);},),),
            TitleWidget(context, '${widget.post.storeName}', 0),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        myText('장소'),
                        SizedBox(height: 8.0),
                        Text('${widget.post.pickupSpot}'),
                        SizedBox(height: 16.0),
                        myText('모집 인원'),
                        SizedBox(height: 8.0),
                        Text('${widget.post.memCurrentCnt}/${widget.post.memTotalCnt}',),
                        SizedBox(height: 16.0),
                        myText('주문 시간'),
                        SizedBox(height: 8.0),
                        Text('${widget.post.orderTime}'),
                        (isParticipating==true)? Text('내가 적었엉!!', style: TextStyle(fontSize: 30),): Text('내가 안 적었엉!!!', style: TextStyle(fontSize: 30),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: ('${widget.post.orderTime}' == '주문 종료' ) ? SizedBox() : Container(
        decoration: BoxDecoration(
            color: Color(0xFF284463), //Color(0xFF98A5B3)
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ElevatedButton(
            child: Text('참여하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF67727D), //Color.fromARGB(255, 81, 99, 113), //Color(0xFF284463),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
              ),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alertDialog();
                },
              );
            }
          ),
        ),
      ),
    );
  }

  Widget alertDialog() => AlertDialog(
    content: const Text('정말 참여하시겠습니까?'),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('참여되었습니다'),
            ),
          );
          Get.to(() => DeliveryStatePage(
              postID: PostID
          ));
        },
        child: const Text('네'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('아니오'),
      ),
    ],
  );

  Widget myText(text) => Text(
    '${text}',
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  );
}
