import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/components.dart';

final _formKey = GlobalKey<FormState>();
const List<String> category_menu = <String>['한식', '중식', '일식', '치킨', '피자', '분식', '패스트푸드', '카페&디저트'];
String _store_name = "";
String _pickup_spot = "";
// late DateTime _order_time;
late DateTime _current_time;
String _category = "";
int _member_count = 0;
String _order_link = "";

String _category = category_menu.first;
late DateTime _dateTime;
var logger = Logger();

int _delivery_state = 0;
String _additional = "";
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
          children: [TitleWidget(context, '글쓰기'), WritingForm(context), SizedBox()],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Padding(
          padding: EdgeInsets.all(20),
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
                //insertOnePost();
                print('_store_name ' + _store_name + ' *****');
                print('_pickup_spot ' + _pickup_spot + ' *****');
                // print('_order_time' + _order_time);
                print('_category ' + _category + ' *****');
                print('_member_count ' + _member_count.toString());
                print('_memo ' + _memo);
                print('link ' + _order_link);

                CollectionReference post = FirebaseFirestore.instance.collection('post');
                CollectionReference postUser = FirebaseFirestore.instance.collection('postUser');
                _current_time = DateTime.now();

                post.add({
                  'storeName': _store_name,
                  'pickupSpot': _pickup_spot,
                  'category': _category,
                  'memberTotalCount': _member_count,
                  'link': _order_link,
                  'memo': _memo,
                  'orderTime': _current_time.toLocal(),
                  'createdTime': _current_time.toLocal(),
                });
                print('===========test1==========');
                QuerySnapshot querySnapshot = await post.get();
                // test: print('doc id: ' + querySnapshot.docs.last.id);
                postUser.add({
                  'postId': querySnapshot.docs.last.id,
                  'memberId': user?.email,
                  'isWriter': true
                });

                print('===========test2==========');
                print('postId: ' + querySnapshot.docs.last.id +
                    'memberId: ' + user!.email.toString() +
                    'isWriter: ' + true.toString()
                );
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

  // 디비에 저장하기
  void insertOnePost() {
    // final moviesRef = FirebaseFirestore.instance
    //     .collection('together-e6cc2')
    //     .withConverter<Movie>(
    //   fromFirestore: (snapshots, _) => Movie.fromJson(snapshots.data()!),
    //   toFirestore: (movie, _) => movie.toJson(),
    // );
  }
}

/*class WritingForm extends StatefulWidget {
  const WritingForm({super.key});

  @override
  State<WritingForm> createState() => _WritingForm();
}

class _WritingForm extends State<WritingForm> {
  @override
  Widget build(BuildContext context) {
    return Form(*/


Widget WritingForm(context) => Form(
      key: _formKey,
      child: Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: <Widget>[
              InputField("가게 이름", 0),
              InputField("받을 장소", 1),
              InputField("주문예정시각", 2),
              DropdownButton(
                value: _category,
                icon: const Icon(Icons.arrow_downward),
                onChanged: (String? value) {
                  setState(() {
                    _category = value!;
                  });
                },
                items: category_menu.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
              InputField('카테고리', 3),
              InputField("모집 인원", 4),
              InputField("배달의 민족 함께주문 링크", 5),
              InputField('메모', 6),
              // SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  //}


  /*Widget InputField(String text, int index) {
    return TextFormField(
      //autovalidateMode: AutovalidateMode.always,
      onSaved: (value) {
        if (index == 0)
          _store_name = value as String;
        else if (index == 1)
          _pickup_spot = value as String;
        else if (index == 2)
          _member_count = int.parse(value!);
        else if (index == 3)
          _order_link = value as String;
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          if (index == 0) {
            return '가게 이름을 입력하세요';
          } else if (index == 1) {
            return '받을 장소를 입력하세요';
          } else if (index == 2) {
            return '사람 수를 입력하세요';
          } else if (index == 3) {
            return '배달의 민족 함께주문 링크를 입력하세요';
          }
        }
        return null;
      },
      // readOnly: (index == 1) ? true : false,
      // initialValue: (index == 1)? FirebaseAuth.instance.currentUser!.email : null,
      keyboardType: (index == 3) ? TextInputType.multiline : TextInputType.text,
      // minLines: (index == 3) ? 40 : null,
      // maxLines: (index == 3) ? 100 : null,
      textInputAction: TextInputAction.next,
      autofocus: true,
      decoration: InputDecoration(
        hintText: text,
        // helperText: text,
        // labelText: text,
        labelStyle: TextStyle(
          fontSize: 12,
        ),
        //prefix: Text(text),
      ),
    );
  }

}*/

class DeliveryPostDTO{
  late String store_name;
  late String pickup_spot;
  late int member_count;
  late String order_link;
  late String category;
}

const List<String> list = <String>['디저트', '한식', '양식', '중식', '일식', '기타'];

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          _category = dropdownValue;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      dropdownColor: Colors.white,
    );
  }
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
              else if (index == 3)
                _category = value as String;
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
                  return '수령 장소를 입력하세요';
                } else if (index == 2) {
                  return '주문 예정 시각을 입력하세요';
                } else if (index == 3) {
                  // return '을 입력하세요';
                } else if (index == 4) {
                  return '모집 인원을 입력하세요';
                } else if (index == 5) {
                  return '같이주문 링크를 입력하세요';
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
