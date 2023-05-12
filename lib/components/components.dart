import 'package:flutter/material.dart';

// class Components extends StatefulWidget {
//   const Components({Key? key}) : super(key: key);

//   @override
//   State<Components> createState() => _ComponentsState();
// }

// class _ComponentsState extends State<Components> {
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//         // leading: Icon(icon: Icons.work),
//         title: Center(child: Text('같이 먹자')),
//         toolbarHeight: 100,
//       );
//   }
// }

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