import 'dart:developer';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'size.dart';

final _formKey = GlobalKey<FormState>();
const List<String> category_menu = <String>['category1', 'category2', 'category3', 'category4'];
String _store_name = "";
String _pickup_spot = "";
int _member_count = 0;
String _order_link = "";
String _category = category_menu.first;
late DateTime _dateTime;
var logger = Logger();

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
          children: [
            WritingForm(),
            SizedBox()
          ],
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
            onPressed: () {
              final form = _formKey.currentState;
              if(form != null && form.validate()){
                form.save();
                printFormValues();
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
  @override
  Widget build(BuildContext context) {
    return Form(
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
              // InputField("카테고리", 4),
              // SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  }

Widget InputField(String text, int index) {
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
}
