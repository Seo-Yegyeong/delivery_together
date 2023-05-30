import 'package:flutter/material.dart';

import 'size.dart';

PreferredSizeWidget FixedAppBar(context) => AppBar(
  backgroundColor: Color(0xFF284463),
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
      ],
    ),
  ),
  toolbarHeight: getAppBarHeight(context),
  automaticallyImplyLeading: false,
);

Widget TitleWidget(context, title) => Column(
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
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 50,),
          ],
        ),
      ),
    ),              // Rest of your page content
  ],
);

class Components {
  AppBar component_AppBar(){
    return AppBar(
        // leading: Icon(icon: Icons.work),
        title: Center(child: Text('같이 먹자')),
        toolbarHeight: 100,
      );
  }
}

// class Components extends StatelessWidget {
//   const Components({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const AppBar(
//         // leading: Icon(icon: Icons.work),
//         title: Center(child: Text('같이 먹자', style: TextStyle(fontSize: 30),)),
//         toolbarHeight: getAppBarHeight(context),
//       );
//   }
// }