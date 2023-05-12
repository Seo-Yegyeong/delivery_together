import 'package:delivery_together/order_list.dart';
import 'package:delivery_together/size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'write_order.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 45, width: 45, child: Image.asset('assets/icon/cookie.png'),),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '같이 먹자',
                  style: TextStyle(fontSize: 30),
                )
              ],
            ),
          ),
          toolbarHeight: getAppBarHeight(context),
        ),
        body: GridView.count(
          padding: const EdgeInsets.all(25),
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
          crossAxisCount: 2,
          children: [
            MyButton(),
            MyButton(),
            MyButton(),
            MyButton(),
          ],
        ));
  }
}



class MyButton extends StatelessWidget {
  const MyButton({Key? key}) : super(key: key);

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
            Container(height: 40, width: 40, child: Image.asset('assets/icon/list.png'), decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),),
            Center(
              child: Text(
                '같이 묵자',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Get.to(() => WritePage());
      },
    );
  }
}
