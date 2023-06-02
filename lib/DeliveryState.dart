import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'list.dart';

class DeliveryStatePage extends StatefulWidget {
  // final Post post;
  const DeliveryStatePage({Key? key, required Type postID,
    // required this.post
  }) : super(key: key);

  @override
  State<DeliveryStatePage> createState() => _DeliveryStatePageState();
}

class _DeliveryStatePageState extends State<DeliveryStatePage> {
  User? user;
  late List<String> enteredRooms = [];
  Post? nearestStore;
  CarouselController _controller = CarouselController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isWriter1 = false;
  int currentSlide = 0;
  bool isChanged = false;

  List<String> imageList = [
    "assets/icon/startOrder.png",
    "assets/icon/startDelivery.png",
    "assets/icon/completedDelivery.png",
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    //checkWriterState().then((value) => setState(() => isWriter = value));
    // getSlideState().then((value) => currentSlide = value);
    // getEnteredRooms().then((value) {
    //   setState(() {
    //     enteredRooms = value;
    //     print("enteredRooms입니다.");
    //     print(value);
    //     getNearestStore().then((value) {
    //       if (value != null) {
    //         setState(() {
    //           nearestStore = value;
    //         });
    //       }
    //     });
    //   });
    // });
    // print("user입니다.");
    // print(user);
    //
    // checkIsWriter();
    _fetchData();

  }

  Future<void> _fetchData() async {
    List<String> rooms = await getEnteredRooms();
    setState(() {
      enteredRooms = rooms;
      print("enteredRooms입니다.");
      print(rooms);
    });

    Post? nearest = await getNearestStore();
    if (nearest != null) {
      setState(() {
        nearestStore = nearest;
      });
    }
    print("didiididid");
    print(nearestStore?.storeName);

    getSlideState().then((value) => currentSlide = value);
    checkIsWriter();


  }

  Future<Post?> getNearestStore() async {
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('post')
        .where('postID', whereIn: enteredRooms)
        .get();

    Post? nearestPost;
    DateTime currentTime = DateTime.now();

    int minDifference = 99999999; // 초기값으로 매우 큰 값 설정
    print("/////");

    for (QueryDocumentSnapshot docSnapshot in postSnapshot.docs) {
      DateTime orderTime = docSnapshot.get('orderTime').toDate();
      print(orderTime);
      int difference = orderTime.difference(currentTime).inSeconds.abs();

      if (difference < minDifference) {
        minDifference = difference;

        String storeName = docSnapshot.get('storeName');
        print(storeName);
        String pickupSpot = docSnapshot.get('pickupSpot');
        print(pickupSpot);
        int memTotalCnt = docSnapshot.get('memTotalCnt');
        print(memTotalCnt);
        int memCurrentCnt = docSnapshot.get('memCurrentCnt');
        print(memCurrentCnt);
        DateTime orderTime = docSnapshot.get('orderTime').toDate();
        print(orderTime);
        int remainingMinutes = calculateRemainingTime(orderTime);
        String orderTimeString =
        remainingMinutes == 0 ? '주문 종료' : remainingMinutes.toString()+'분 후';
        String date = orderTimeString;
        String postID = docSnapshot.id;
        DateTime createdTime = docSnapshot.get('createdTime').toDate();
        print(createdTime);
        String memo = docSnapshot.get('memo');
        String link = docSnapshot.get('link');


        nearestPost = Post(
          storeName: storeName,
          pickupSpot: pickupSpot,
          memTotalCnt: memTotalCnt,
          memCurrentCnt: memCurrentCnt,
          orderTime: date,
          createdTime: createdTime,
          isWriter: true, postID: postID,
          memo: memo,
          link: link,
        );

      }

      if(isChanged){
        // currentSlide를 db의 post 컬렉션의 state에 넣어야 한다.
        docSnapshot.reference.update({
          'state': currentSlide,
        });
      }

    }

    return nearestPost;
  }


  Future<List<String>> getEnteredRooms() async {
    List<String> enteredRooms = [];

    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('post')
        .get();

    for (QueryDocumentSnapshot docSnapshot in postSnapshot.docs) {
      String postId = docSnapshot.id;

      QuerySnapshot userListSnapshot = await docSnapshot.reference
          .collection('userList')
          .where('userID', isEqualTo: user?.uid)
          .limit(1)
          .get();


      if (userListSnapshot.docs.isNotEmpty) {
        enteredRooms.add(postId);
      }
      print("entered room 입니다.//////");
      print(enteredRooms);
    }

    return enteredRooms;
  }


  Future<String?> getNearestStoreName() async {
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('post')
        .where('postID', whereIn: enteredRooms)
        .get();

    String? nearestStoreName;
    DateTime currentTime = DateTime.now();

    int minDifference = 99999999; // 초기값으로 매우 큰 값 설정

    for (QueryDocumentSnapshot docSnapshot in postSnapshot.docs) {
      DateTime orderTime = docSnapshot.get('orderTime').toDate();
      int difference = orderTime.difference(currentTime).inSeconds.abs();

      if (difference < minDifference) {
        minDifference = difference;
        nearestStoreName = docSnapshot.get('storeName');
      }
    }

    return nearestStoreName;
  }


  void updateWriterState(bool writerState) async {
    await _firestore
        .collection('deliveryState')
        .doc(user?.uid)
        .set({
      'isWriter': writerState,
      'email': user?.email,
    }, SetOptions(merge: true));
  }

  void updateSlideState(int newSlide) async {
    if (isWriter1) {
      await _firestore
          .collection('deliveryState')
          .doc(user?.uid)
          .set({
        'currentSlide': newSlide,
      }, SetOptions(merge: true));

      setState(() {
        currentSlide = newSlide;
        _controller.jumpToPage(currentSlide);
      });
    }
  }


  Future<void> checkIsWriter() async {
    DocumentSnapshot userSnapshot =
    await _firestore.collection('user').doc(user?.uid).get();
    QuerySnapshot postListSnapshot = await _firestore
        .collection('user')
        .doc(user?.uid)
        .collection('postList')
        .where('postId', isEqualTo: nearestStore?.postID) // nearestStore의 postID와 일치하는 문서를 쿼리합니다.
        .get();
    print("in IsWriter() nearestStore");
    print(nearestStore?.storeName);
    print(postListSnapshot);

    if (postListSnapshot.docs.isNotEmpty) {
      print("!");
      DocumentSnapshot postSnapshot = postListSnapshot.docs.first;
      print(postSnapshot);
      print(postSnapshot.get('postId'));
      setState(() {
        isWriter1 = postSnapshot.get('isWriter') ?? false;
        print("isWriter!!!!!!!!!!!!!!!!!!");
        print(isWriter1);
      });
    }


  }

  // Future<bool> checkWriterState() async {
  //   //DocumentSnapshot firstDoc;
  //
  //   QuerySnapshot myPost = await FirebaseFirestore.instance.collection('user').doc(user?.uid).collection('postList').get();
  //   if (myPost.docs.isNotEmpty) {
  //     isWriter1 = myPost.docs.first.get('isWriter');
  //     updateWriterState(isWriter1);
  //     print("mypost에서의 postID");
  //     print(myPost.docs.first.get('postId'));
  //   }
  //   // QuerySnapshot querySnapshot = await _firestore.collection('post').doc('${widget.post.postID}').collection('userList');
  //   // QuerySnapshot querySnapshot = await _firestore.collection('post-user').where('memberId', isEqualTo: user?.email).get();
  //
  //   return isWriter1;
  // }

  Future<int> getSlideState() async {
    final DocumentSnapshot snapshot =
    await _firestore.collection('deliveryState').doc(user?.uid).get();

    if (!snapshot.exists) {
      updateSlideState(0);
      return 0;
    }

    return snapshot.get('currentSlide') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    print("Current User Email: ${user?.email}");
    return MaterialApp(
      home: Scaffold(
        appBar: FixedAppBar(context),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // mainAxisAlignment를 spaceBetween으로 변경
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
                        'Delivery States',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(width: 52), // 아이콘을 중앙에 배치하기 위한 빈 컨테이너
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CarouselSlider(
                  carouselController: _controller,
                  items: imageList.map((imagePath) {
                    return Builder(builder: (BuildContext context) {
                      return Container(
                        width: 250,
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          image: DecorationImage(
                            image: AssetImage(imagePath), fit: BoxFit.cover,
                          ),
                        ),
                      );
                    });
                  }).toList(),
                  options: CarouselOptions(
                    viewportFraction: 0.7,
                    height: 300.0,
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    enlargeCenterPage: true,
                    initialPage: currentSlide,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentSlide = index;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              isWriter1
              ?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(entry.key);
                    },
                    child: Container(
                      margin: EdgeInsets.all(12),
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: currentSlide == entry.key
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        color: currentSlide == entry.key
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ): Container(),
              isWriter1
                  ? GestureDetector(
                onTap: () {
                  isChanged = true;
                  if (currentSlide == imageList.length - 1) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delivery Complete!'),
                          content: Text('The delivery has been completed successfully!'),
                          actions: [
                            TextButton(
                              onPressed: (){
                                setState(() {

                                });
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      currentSlide = (currentSlide + 1) % imageList.length;
                      _controller.jumpToPage(currentSlide);
                    });
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF284463),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1/1, // For square images
                        child: Image.asset(
                          'assets/icon/button.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              )
               : Container(),



               FutureBuilder<Post?>(
                  future: getNearestStore(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasData && snapshot.data != null) {
                      Post nearestStore = snapshot.data!;
                      return

                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          padding: EdgeInsets.fromLTRB(8,10,8,10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF284463),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(nearestStore.storeName,
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 130,
                                    height: 40,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child:Text(nearestStore.pickupSpot,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,),
                                    ),
                                  ),
                                  Container(
                                    width: 90,
                                    height: 40,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${nearestStore.memCurrentCnt.toString()}/${nearestStore.memTotalCnt.toString()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 20,
                                        color: Colors.black,),
                                    ),
                                  )
                                  ,
                                  Container(
                                    width: 130,
                                    height: 40,
                                    margin: EdgeInsets.only(top: 10),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(nearestStore.orderTime,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        backgroundColor: Colors.white,
                                        fontSize: 20,
                                        color: Colors.black,),
                                    ),
                                  ),


                                ],
                              ),

                              TextButton(
                                child: Text("Open chat Room link: "+nearestStore.link),
                                onPressed: () {
                                  var url = nearestStore.link; // 열고자 하는 웹 URL
                                  launchURL(url);
                                },
                              ),
                            ],

                          ),
                        );

                    } else {
                      return Text('No nearest store found');
                    }
                  },
                ),


            ],
          ),
        ),
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}