import 'package:flutter/material.dart';
import 'size.dart';

final _formKey = GlobalKey<FormState>();
String _store_name = "";
String _pickup_spot = "";
int _member_count = 0;
String _order_link = "";
String _category = "";
late DateTime _dateTime;

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
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
              ),
              SizedBox(width: 40,)
            ],
          ),
        ),
        toolbarHeight: getAppBarHeight(context),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xFF98A5B3)),
        child: Column(
          children: [WritingForm(), SizedBox()],
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
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

Widget WritingForm() => Form(
      key: _formKey,
      child: Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: <Widget>[
              InputField("가게 이름: ", 0),
              InputField("받을 장소: ", 1),
              InputField("사람 수: ", 2),
              InputField("배달의 민족 함께주문 링크: ", 3),
              InputField("카테고리", 4),
              // SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );

Widget InputField(String text, int index) {
  return TextFormField(
    //autovalidateMode: AutovalidateMode.always,
    onSaved: (value) {
      if (index == 0)
        _store_name = value as String;
      else if (index == 1)
        _pickup_spot = value as String;
      else if (index == 2)
        _member_count = value as int;
      else if (index == 3)
        _order_link = value as String;
      else
        _category = value as String;
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        if (index == 0) {
          return '수신인 메일을 입력하세요';
        } else if (index == 2) {
          return '제목을 입력하세요';
        } else if (index == 3) {
          return '내용을 입력하세요';
        }
      }
      return null;
    },
    readOnly: (index == 1) ? true : false,
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
