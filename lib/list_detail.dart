import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_together/list.dart';
import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class _ListDetailPageState extends State<ListDetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference postUser = FirebaseFirestore.instance.collection('post-user');


  @override
  void initState() {
    super.initState();


    // DocumentSnapshot snapshot = await userCollection.doc(user.uid).get();
    //
    // if (!snapshot.exists) {
    //   userCollection.doc(user.uid).set({
    //     'email': user.email,
    //     'name': user.displayName.toString(),
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixedAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
          Get.to(() => DeliveryStatePage(post: widget.post));
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
