import 'package:delivery_together/utils/components.dart';
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
        appBar: FixedAppBar(context),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF98A5B3),
          ),
          child: Column(
            children: [
              TitleWidget(context, 'Delivery State Page'),
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
