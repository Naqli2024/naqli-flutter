import 'package:flutter/material.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:flutter_svg/svg.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                          UserType(
                            firstName: widget.firstName??'',
                            lastName: widget.lastName??'',
                            token: widget.token??'',
                            id: widget.id??'',
                            email: widget.email??'',
                          )));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15,top: 15),
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Color(0xffFFFFFF),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                    size: 24,
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
                    height: 200,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(widget.title,
                  style: TextStyle(
                      fontSize: 26)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Text(widget.subTitle,
                style: TextStyle(
                  fontSize: 25,fontWeight: FontWeight.w500)),
            ),
          ],
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Color(0xffFFFFFF),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                    size: 24,
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
                      fontSize: 25,fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(widget.subTitle,
                  style: TextStyle(
                      fontSize: 17,fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

