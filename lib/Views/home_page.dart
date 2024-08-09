import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naqli/Views/auth/login.dart';
import 'package:flutter_naqli/Views/auth/role.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Container(
            margin: const EdgeInsets.only(top: 20),
            child: SvgPicture.asset(
              'assets/naqlee-logo.svg',
              fit: BoxFit.fitWidth,
              height: 40,
            )),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                color: Color(0xff5D5151),
                size: 50,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 220,
              width: MediaQuery.sizeOf(context).width,
              decoration: const BoxDecoration(
                color: Color(0xff6A66D1),
              ),
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: const Text(
                      'Partner with Naqli',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: const Text(
                      'Make money on your schedule',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Role()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sign up now',
                      style: TextStyle(
                          color: Color(0xff140303),
                          fontSize: 30,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: Color(0xff140303),
                      size: 40,
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              indent: Checkbox.width,
              endIndent: Checkbox.width,
              color: Color(0xff707070),
              thickness: 3,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Log in',
                      style: TextStyle(
                          color: Color(0xff140303),
                          fontSize: 30,
                          fontWeight: FontWeight.w500),
                    ),
                    Icon(
                      Icons.arrow_forward_outlined,
                      color: Color(0xff140303),
                      size: 40,
                    )
                  ],
                ),
              ),
            ),
            const Divider(
              indent: Checkbox.width,
              endIndent: Checkbox.width,
              color: Color(0xff707070),
              thickness: 4,
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Driving with naqli',
                    style: TextStyle(
                        color: Color(0xff5D5151),
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  )),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: ListView(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 14 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      viewportFraction: 0.9,
                    ),
                    items: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                child: Image.asset('assets/Truck.jpg')),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 20),
                                child: const Text(
                                  'Regular trips',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                )),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(top: 20, right: 20),
                                child: const Text(
                                  'With our growing presence across multiple cities, we always have our hands full this means you will never Run out of trips',
                                  style: TextStyle(
                                    color: Color(0xff5D5151),
                                    fontSize: 20,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Image.asset('assets/Earnings.jpg')),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 20),
                                child: const Text(
                                  'Better Earnings',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                )),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(top: 20, right: 20),
                                child: const Text(
                                  'Earn money by partnering with The best regular trips and efficient service and grow your earnings!',
                                  style: TextStyle(
                                    color: Color(0xff5D5151),
                                    fontSize: 20,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                child: Image.asset('assets/Payments.jpg')),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(top: 20),
                                child: const Text(
                                  'On-Time Payments',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                )),
                            Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(top: 20, right: 20),
                                child: const Text(
                                  'Be assured to receive allpayment on time & get the best in class support',
                                  style: TextStyle(
                                    color: Color(0xff5D5151),
                                    fontSize: 20,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
