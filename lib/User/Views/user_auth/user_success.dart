import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Views/booking/superUserType.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

class SuccessScreen extends StatefulWidget {
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? id;
  final String? email;
  final String title;
  final String subTitle;
  final Image;


  const SuccessScreen({super.key, required this.title, required this.subTitle, this.Image, this.token,this.firstName, this.lastName, this.id, this.email,});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15,top: 15),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(0xffFFFFFF),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: viewUtil.isTablet?27:24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.15, bottom: 20),
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      widget.Image,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: viewUtil.isTablet
                            ? MediaQuery.sizeOf(context).height * 0.27
                            : MediaQuery.sizeOf(context).height * 0.2
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(widget.title,
                    style: TextStyle(
                        fontSize: viewUtil.isTablet?32:26)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(widget.subTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: viewUtil.isTablet? 29:24,fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuperUserMessageScreen extends StatefulWidget {
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? id;
  final String? email;
  final String title;
  final String subTitle;
  final Image;
  const SuperUserMessageScreen({super.key, this.token, this.firstName, this.lastName, this.id, this.email, required this.title, required this.subTitle, this.Image});

  @override
  State<SuperUserMessageScreen> createState() => _SuperUserMessageScreenState();
}

class _SuperUserMessageScreenState extends State<SuperUserMessageScreen> {
  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SuperUsertype(
                              firstName: widget.firstName??'',
                              lastName: widget.lastName??'',
                              token: widget.token??'',
                              id: widget.id??'',
                              email: widget.email??'',
                            )));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15,top: 15),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(0xffFFFFFF),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: viewUtil.isTablet?27:24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.15, bottom: 20),
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      widget.Image,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                        height: viewUtil.isTablet
                            ? MediaQuery.sizeOf(context).height * 0.27
                            : MediaQuery.sizeOf(context).height * 0.2
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(widget.title,
                    style: TextStyle(
                        fontSize: viewUtil.isTablet?32:26)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(widget.subTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: viewUtil.isTablet? 27:20,fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class VerifiedScreen extends StatefulWidget {
  final String? token;
  final String? firstName;
  final String? lastName;
  final String? id;
  final String title;
  final String subTitle;
  final Image;
  const VerifiedScreen({super.key, this.token, this.firstName, this.lastName, this.id, required this.title, required this.subTitle, this.Image});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> {
  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserHomePage()
                    ));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15,top: 15),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xffFFFFFF),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: viewUtil.isTablet?26:22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.15, bottom: 20),
                    alignment: Alignment.bottomCenter,
                    child: SvgPicture.asset(
                      widget.Image,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(widget.title,
                    style: TextStyle(
                        fontSize: viewUtil.isTablet?30:25,fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(widget.subTitle,
                    style: TextStyle(
                        fontSize: viewUtil.isTablet? 26:17,fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

