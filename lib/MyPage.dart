import 'package:delivery_together/utils/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'MyInfo.dart';

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF98A5B3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF284463),
        ),
        // Color(0xFF284463),
        // colorScheme: ColorScheme(primary: Color(0xFF284463))
        // textTheme: ,

      ),
      home:
      const MyHomePage(title: '같이 먹자'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF284463),
    minimumSize: const Size(100, 70),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:  FixedAppBar(context),
      body: Container(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TitleWidget(context, 'My page'),
            Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 100,
                  horizontal: 20
                ),
                child: ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: () {
                    Get.to(() => MyInfo());
                  },
                  child: const Text("내 정보",style: TextStyle(fontSize: 18)),
                )
            ),
            Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20
                ),
                child: ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: () {
                    Get.to(() => MyInfo());
                  },
                  child: const Text("주문 기록",style: TextStyle(fontSize: 18)),
                )
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}