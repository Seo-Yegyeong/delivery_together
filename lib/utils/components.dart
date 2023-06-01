import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home.dart';
import '../write_order.dart';
import 'size.dart';

PreferredSizeWidget FixedAppBar(context) => AppBar(
  backgroundColor: Color(0xFF284463),
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
        ),
      ],
    ),
  ),
  toolbarHeight: getAppBarHeight(context),
  automaticallyImplyLeading: false,
);

Widget TitleWidget(context, title, type) => Column(
  children: [
    Container(
      decoration: BoxDecoration(
        color: const Color(0xFF67727D),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(()=>Home());
              },
              child: Container(
                width: 52,
                height: 30,
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            (type == 0)? const SizedBox(width: 50,) : WritingButton(),
          ],
        ),
      ),
    ),              // Rest of your page content
  ],
);

Widget WritingButton() => GestureDetector(
  onTap: () {
    // Write button action
  },
  child: Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
      color: const Color(0xFF284463),
      borderRadius: BorderRadius.circular(26),
    ),
    child: GestureDetector(
      onTap: () {
        Get.to(() => WritePage());
      },
      child: Center(
        child: Image.asset(
          'assets/icon/write.png',
          width: 42,
        ),
      ),
    ),
  ),
);