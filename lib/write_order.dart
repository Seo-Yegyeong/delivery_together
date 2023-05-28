import 'package:flutter/material.dart';
import 'components/components.dart';

final _formKey = GlobalKey<FormState>();
String _store_name = "";
String _pickup_spot = "";
late DateTime _order_time;
String _category = "";
int _member_count = 0;
String _order_link = "";
int _delivery_state = 0;
String _additional = "";
String _memo = "";


class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
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
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

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
              DropdownButtonExample(),
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
              else if (index == 2)
                _order_time = value as DateTime;
              else if (index == 3)
                _category = value as String;
              else if (index == 4)
                _member_count = value as int;
              else if (index == 5)
                _order_link = value as String;
              else if (index == 6)
                _memo = value as String;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                if (index == 0) {
                  return '가게 이름을 입력하세요';
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