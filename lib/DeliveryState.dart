import 'package:delivery_together/utils/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryStatePage extends StatefulWidget {
  const DeliveryStatePage({Key? key}) : super(key: key);

  @override
  State<DeliveryStatePage> createState() => _DeliveryStatePageState();
}

class _DeliveryStatePageState extends State<DeliveryStatePage> {
  User? user;
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
    QuerySnapshot querySnapshot = await _firestore.collection('post-user').where('memberId', isEqualTo: user?.email).get();

    if (querySnapshot.docs.isNotEmpty) {
      isWriter = querySnapshot.docs.first.get('isWriter');
      updateWriterState(isWriter);
    }

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

  Future<String> getStoreNameFromPost() async {
    DocumentSnapshot postUserDoc =
    await _firestore.collection('post-user').doc(user?.uid).get();

    if (postUserDoc.exists) {
      String postId = postUserDoc.get('post-id');

      DocumentSnapshot postDoc =
      await _firestore.collection('post').doc(postId).get();

      if (postDoc.exists) {
        return postDoc.get('storeName');
      }
    }

    return '';
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
                        'Delivery States',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isWriter
                          ? GestureDetector(
                        onTap: () {
                          if(currentSlide == imageList.length - 1) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delivery Complete!'),
                                    content: Text('The delivery has been completed successfully!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                }
                            );
                          } else {
                            updateSlideState((currentSlide + 1) % imageList.length);
                          }
                        },
                        child: Container(
                          width: 45,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF284463),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icon/info.png',
                            ),
                          ),
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),
              ),
              CarouselSlider(
                  carouselController: _controller,
                  items: imageList.map((imagePath) {
                    return Builder(builder: (BuildContext context) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                                image: AssetImage(imagePath), fit: BoxFit.cover)),
                      );
                    });
                  }).toList(),
                  options: CarouselOptions(
                    height: 300.0,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    initialPage: currentSlide,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentSlide = index;
                      });
                    },
                  )),
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
              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(10.0),
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                // child: (
                //   //Text();
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
