import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:delivery_together/utils/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({Key? key}) : super(key: key);

  @override
  State<MyOrderPage> createState() => _MyOrderPage();
}
class User{
  String email;

  User({required this.email});
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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}