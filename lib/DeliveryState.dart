import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late List<String> enteredRooms;
  CarouselController _controller = CarouselController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isWriter = false;
  int currentSlide = 0;

  List<String> imageList = [
    "assets/icon/startOrder.png",
    "assets/icon/startDelivery.png",
    "assets/icon/completedDelivery.png",
  ];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    checkWriterState().then((value) => setState(() => isWriter = value));
    getSlideState().then((value) => currentSlide = value);
    getEnteredRooms().then((value) {
      print("enteredRoom입니다.");
      setState(() {
        print(value);
        enteredRooms = value;
      });
    });
    print("user입니다.");
    print(user);
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
        String memo = docSnapshot.get('memo');
        int remainingMinutes = calculateRemainingTime(orderTime);
        String orderTimeString =
        remainingMinutes == 0 ? '주문 종료' : remainingMinutes.toString()+'분 후';
        String date = orderTimeString;
        String postID = docSnapshot.id;
        DateTime createdTime = docSnapshot.get('createdTime').toDate();
        print(createdTime);


        nearestPost = Post(
          storeName: storeName,
          pickupSpot: pickupSpot,
          memTotalCnt: memTotalCnt,
          memCurrentCnt: memCurrentCnt,
          orderTime: date,
          createdTime: createdTime,
          isWriter: true, postID: postID,
          memo: memo,
        );

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
          .get();


      if (userListSnapshot.docs.isNotEmpty) {
        enteredRooms.add(postId);
      }
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
    if (isWriter) {
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


  Future<bool> checkWriterState() async {
    //DocumentSnapshot firstDoc;

    QuerySnapshot myPost = await FirebaseFirestore.instance.collection('user').doc(user?.uid).collection('postList').get();
    if (myPost.docs.isNotEmpty) {
      isWriter = myPost.docs.first.get('isWriter');
      updateWriterState(isWriter);
      print("mypost에서의 postID");
      print(myPost.docs.first.get('postId'));
    }
    // QuerySnapshot querySnapshot = await _firestore.collection('post').doc('${widget.post.postID}').collection('userList');
    // QuerySnapshot querySnapshot = await _firestore.collection('post-user').where('memberId', isEqualTo: user?.email).get();

    return isWriter;
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(entry.key);
                      setState(() {});
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
              ),
              isWriter
                  ? Container()
                  : GestureDetector(
                onTap: () {
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
              ),



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
                                  ),
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
}