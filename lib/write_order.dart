import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_together/utils/components.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
//import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'list.dart';

final _formKey = GlobalKey<FormState>();
const List<String> category_menu = <String>['한식', '중식', '일식', '치킨', '피자', '분식', '패스트푸드', '카페&디저트'];
String _store_name = "";
String _pickup_spot = "";
String _order_time = "";
DateTime _current_time = DateTime.now();
int _member_count = 0;
String _order_link = "";

String _category = category_menu.first;
//var logger = Logger();
String _memo = "";



class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final me = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixedAppBar(context),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Column(
          children: [TitleWidget(context, '글쓰기', 0), WritingForm(), SizedBox()],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ElevatedButton(
            child: Text('올리기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF284463),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
        ),
            onPressed: () async {
              final form = _formKey.currentState;
              if (form != null && form.validate()) {
                form.save();
                //printFormValues();

                CollectionReference post = FirebaseFirestore.instance.collection('post');
                CollectionReference myPostList = FirebaseFirestore.instance.collection('user').doc('${me?.uid}').collection('postList');
                _current_time = DateTime.now(); //2023-05-29 18:04:45.425863
                DateTime orderDateTime = DateFormat('yyyy-MM-dd hh:mm:ss').parse('${DateFormat('yyyy-MM-dd').format(_current_time)} $_order_time');

                print('in 올리기 버튼 - _current_time : ' + _current_time.toString());
                print('in 올리기 버튼 - orderDateTime : ' + orderDateTime.toString());


                QuerySnapshot querySnapshot = await post.get();
                var postID = querySnapshot.size.toString();

                post.doc(postID).set({
                  'postID': postID,
                  'storeName': _store_name,
                  'pickupSpot': _pickup_spot,
                  'category': _category,
                  'memTotalCnt': _member_count,
                  'memCurrentCnt': 0,
                  'link': _order_link,
                  'memo': _memo,
                  'orderTime': orderDateTime,
                  'createdTime': _current_time,
                  'state': 0,
                });

                CollectionReference myUserList = FirebaseFirestore.instance.collection('post').doc('${postID}').collection('userList');
                myUserList.doc(me?.uid).set({
                  'userID': me?.uid,
                  'isWriter': true,
                });

                myPostList.doc(postID).set({
                  'postId': postID,
                  'isWriter': true
                });

                Get.to(()=>ListPage());
              }
            },
          ),
        ),
      ),
    );
  }

  /* For test */
  // void printFormValues() {
  //   logger.i('가게 이름: $_store_name');
  //   logger.i('받을 장소: $_pickup_spot');
  //   logger.i('사람 수: $_member_count');
  //   logger.i('배달의 민족 링크: $_order_link');
  //   logger.i('카테고리: $_category');
  // }
}

class WritingForm extends StatefulWidget {
  const WritingForm({super.key});

  @override
  State<WritingForm> createState() => _WritingForm();
}

class _WritingForm extends State<WritingForm> {
  String dropdownValue = category_menu.first;
  TimeOfDay time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');

    return Form(
      key: _formKey,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InputField("가게 이름", 0),
                InputField("받을 장소", 1),
                Text('주문 예정 시각', style: TextStyle(color: Colors.white, fontSize: 20),),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                  child: Container(
                    height: 65,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('$hours:$minutes', style: TextStyle(fontSize: 30)),
                        ElevatedButton(
                            onPressed: () async {
                              TimeOfDay? newTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if(newTime == null) return;
                              setState(() {
                                time = newTime;
                                final hours = time.hour.toString().padLeft(2, '0');
                                final minutes = time.minute.toString().padLeft(2, '0');
                                _order_time = '$hours:$minutes:00';
                                print('in time picker button : ' + _order_time);
                              });
                            },
                            child: Text('Time picker', style: TextStyle(fontSize: 25),),
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((color) => Color(0xFF67727D))),
                        ),
                      ],
                    ),
                  ),
                ),
                Text('카테고리', style: TextStyle(color: Colors.white, fontSize: 20),),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,15.0),
                  child: Container(
                    height: 65,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      underline: SizedBox.shrink(),
                      style: TextStyle(fontSize: 25, color: Colors.black),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValue = value!;
                          _category = dropdownValue;
                        });
                      },
                      items: category_menu.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                InputField("모집 인원", 4),
                InputField("배달의 민족 함께주문 링크", 5),
                InputField('메모', 6),
                SizedBox(height: 16,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget InputField(String text, int index) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(color: Colors.white, fontSize: 20),),
          Container(
            height: (index == 6)? 200: 65,
            padding: EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextFormField(
              //autovalidateMode: AutovalidateMode.always,
              onSaved: (value) {
                if (index == 0)
                  _store_name = value as String;
                else if (index == 1)
                  _pickup_spot = value as String;
                // else if (index == 2)
                //   _order_time = value as DateTime;
                else if (index == 4)
                  _member_count = int.parse(value!);
                else if (index == 5)
                  _order_link = value as String;
                else if (index == 6)
                  _memo = value as String;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  if (index == 0) {
                    return '가게 이름을 입력하세요';
                  } else if (index == 1) {
                    return '받을 장소를 입력하세요';
                  } else if (index == 4) {
                    return '모집 인원수를 입력하세요';
                  } else if (index == 5) {
                    return '함께주문 링크를 입력하세요';
                  }
                }

                if(index == 4 && int.tryParse(value!) == null){
                  return '숫자를 입력하세요';
                } else if (index == 4 && _member_count <= 0) {
                  return '1명 이상 입력하세요';
                }

                return null;
              },
              // readOnly: (index == 1) ? true : false,
              // initialValue: (index == 1)? FirebaseAuth.instance.currentUser!.email : null,
              keyboardType: _getKeyboardType(index),
              minLines: (index == 6) ? 10 : null,
              maxLines: (index == 6) ? 30 : null,
              textInputAction: TextInputAction.next,
              autofocus: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                errorStyle: TextStyle(fontSize: 13, height: 0.2),

              ),
              // strutStyle: StrutStyle(height: 1.5),
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(height: 15,)
        ],
      ),
    );
  }

  TextInputType _getKeyboardType(int value) {
    switch (value) {
      case 6:
        return TextInputType.multiline;
      case 4:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}