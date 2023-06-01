import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:delivery_together/utils/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'list_detail.dart';


class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
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

class _ListPageState extends State<ListPage> {
  List<Post> postList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    firestore.QuerySnapshot querySnapshot =
    await firestore.FirebaseFirestore.instance.collection('post').get();
    List<Post> tempList = [];
    querySnapshot.docs.forEach((doc) {
      String storeName = doc['storeName'];
      String pickupSpot = doc['pickupSpot'];
      int memTotalCnt = doc['memTotalCnt'];
      int memCurrentCnt = doc['memCurrentCnt'];
      DateTime orderTime = doc['orderTime'].toDate();
      DateTime createdTime = doc['createdTime'].toDate();
      int remainingMinutes = calculateRemainingTime(orderTime);
      String orderTimeString =
      remainingMinutes == 0 ? '주문 종료' : remainingMinutes.toString()+'분 후';
      Post post = Post(
        storeName: storeName,
        pickupSpot: pickupSpot,
        memTotalCnt: memTotalCnt,
        memCurrentCnt: memCurrentCnt,
        orderTime: orderTimeString,
        createdTime: createdTime,
      );
      tempList.add(post);
      tempList.sort((a, b) => b.createdTime.compareTo(a.createdTime));
    });
    setState(() {
      postList = tempList;
    });
  }

  @override
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
                        Get.to(()=>ListDetailPage());
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

int calculateRemainingTime(DateTime orderTime) {
  DateTime now = DateTime.now();

  if (now.isBefore(orderTime)) {
    Duration remainingDuration = orderTime.difference(now);
    int remainingMinutes = remainingDuration.inMinutes;
    return remainingMinutes;
  } else {
    return 0;
  }
}
