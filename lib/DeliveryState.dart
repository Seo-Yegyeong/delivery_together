import 'package:flutter/material.dart';

class DeliveryStatePage extends StatefulWidget {
  const DeliveryStatePage({Key? key}) : super(key: key);

  @override
  State<DeliveryStatePage> createState() => _DeliveryStatePageState();
}

class _DeliveryStatePageState extends State<DeliveryStatePage> {
  int _radioValue = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF284463),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                child: Image.asset('assets/icon/cookie.png'),
              ),
              const SizedBox(width: 10),
              const Text(
                '같이 먹자',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF98A5B3),
          ),
          child: Column(
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
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 52,
                          height: 30,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      const Text(
                        'Delivery State Page',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
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
                          child: Center(
                            child: Image.asset(
                              'assets/icon/write.png',
                              width: 42,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                      (index) => Radio(
                    value: index,
                    groupValue: _radioValue,
                    onChanged: (int? value) {
                      setState(() {
                        _radioValue = value!;
                      });
                    },
                  ),
                ),
              ),
              // Rest of your page content
            ],
          ),
        ),
      ),
    );
  }
}

class ListElement extends StatelessWidget {
  final String text;

  const ListElement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
