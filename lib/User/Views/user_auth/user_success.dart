import 'package:flutter/material.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_login.dart';
import 'package:flutter_svg/svg.dart';

class SuccessScreen extends StatefulWidget {
  final String title;
  final String subTitle;
  final Image;

  const SuccessScreen({super.key, required this.title, required this.subTitle, this.Image, });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: widget.builder
    //     ),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // toolbarHeight: MediaQuery.of(context).size.height * 0.5,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
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
