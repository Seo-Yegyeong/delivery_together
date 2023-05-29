import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/components.dart';

final _formKey = GlobalKey<FormState>();
const List<String> category_menu = <String>['한식', '중식', '일식', '치킨', '피자', '분식', '패스트푸드', '카페&디저트'];
String _store_name = "";
String _pickup_spot = "";
late DateTime _order_time;
late DateTime _current_time;
int _member_count = 0;
String _order_link = "";

String _category = category_menu.first;
var logger = Logger();
String _memo = "";



class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FixedAppBar(context),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Column(
          children: [TitleWidget(context, '글쓰기'), WritingForm(), SizedBox()],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            child: Text('올리기'),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                    (color) => Color(0xFF284463))),

            onPressed: () async {
              final form = _formKey.currentState;
              if (form != null && form.validate()) {
                form.save();
                printFormValues();

                CollectionReference post = FirebaseFirestore.instance.collection('post');
                CollectionReference postUser = FirebaseFirestore.instance.collection('post-user');
                _current_time = DateTime.now();

                post.add({
                  'storeName': _store_name,
                  'pickupSpot': _pickup_spot,
                  'category': _category,
                  'memTotalCnt': _member_count,
                  'memCurrentCnt': 0,
                  'link': _order_link,
                  'memo': _memo,
                  'orderTime': _current_time.toLocal(),
                  'createdTime': _current_time.toLocal(),
                  'state': 0,
                });

                QuerySnapshot querySnapshot = await post.get();
                // test: print('doc id: ' + querySnapshot.docs.last.id);
                postUser.add({
                  'postId': querySnapshot.docs.last.id,
                  'memberId': user?.email,
                  'isWriter': true
                });
              }
            },
          ),
        ),
      ),
    );
  }

  void printFormValues() {
    logger.i('가게 이름: $_store_name');
    logger.i('받을 장소: $_pickup_spot');
    logger.i('사람 수: $_member_count');
    logger.i('배달의 민족 링크: $_order_link');
    logger.i('카테고리: $_category');
  }
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
              children: <Widget>[
                InputField("가게 이름", 0),
                InputField("받을 장소", 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10.0, 0, 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('$hours:$minutes', style: TextStyle(fontSize: 30)),
                      ElevatedButton(
                          onPressed: () async {
                            TimeOfDay? newTime = await showTimePicker(context: context, initialTime: time);
                            if(newTime == null) return;
                            setState(() { time = newTime; });
                          },
                          child: Text('Time picker', style: TextStyle(fontSize: 25),),
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((color) => Color(0xFF67727D))),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      underline: SizedBox.shrink(),
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
            height: 60,
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
                  } else if (index == 2) {
                    return '주문 예정 시각을 입력하세요';
                  } else if (index == 3) {
                    // return '을 입력하세요';
                  } else if (index == 4) {
                    return '모집 인원수를 입력하세요';
                  } else if (index == 5) {
                    return '배달의 민족 함께주문 링크를 입력하세요';
                  } else if (index == 6) {
                    // return '내용을 입력하세요';
                  }
                }
                return null;
              },
              // readOnly: (index == 1) ? true : false,
              // initialValue: (index == 1)? FirebaseAuth.instance.currentUser!.email : null,
              keyboardType: (index == 6) ? TextInputType.multiline : TextInputType.text,
              minLines: (index == 6) ? 10 : null,
              maxLines: (index == 6) ? 30 : null,
              textInputAction: TextInputAction.next,
              autofocus: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}