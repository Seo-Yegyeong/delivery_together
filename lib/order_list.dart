import 'package:flutter/material.dart';

class order_list extends StatefulWidget {
  const order_list({Key? key}) : super(key: key);

  @override
  State<order_list> createState() => _order_listState();
}

class _order_listState extends State<order_list> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Text(
      'Hello ^^',
      style: TextStyle(fontSize: 50),
    ));
  }
}
