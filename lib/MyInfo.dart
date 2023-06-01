import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class MyInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',style:TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children:  [
            SizedBox(height: 40,),

            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_image.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'SOOBIN',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Nick name : sooooo',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),

            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.email,color:Colors.white),
              title: Text('Email',style: TextStyle(fontSize: 18,color:Colors.white)),
              subtitle: Text('example@example.com',style:TextStyle(fontSize:16,color:Colors.grey)),
            ),
            ListTile(
              leading: Icon(Icons.phone,color:Colors.white),
              title: Text('Phone',style: TextStyle(fontSize:18 ,color:Colors.white)),
              subtitle: Text('+82 010-1111-1111',style:TextStyle(fontSize:16,color:Colors.grey)),
            ),
            SizedBox(height: 20),
            ElevatedButton( // 로그아웃 버튼

              onPressed: () {

              },
              child: Text('Logout'),
            ),



          ],
        ),
      ),
    );
  }


}
