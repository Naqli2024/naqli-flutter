import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/user_home_page.dart';

class ErrorScreen extends StatefulWidget {
  final FlutterErrorDetails errorDetails;
  const ErrorScreen({super.key, required this.errorDetails});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Oops! An error occurred:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Card(
                  child: Column(
                    children: [
                      Text('Error:',style: TextStyle(color: Colors.red,fontWeight: FontWeight.w500,fontSize: 18),),
                      Text(widget.errorDetails.toString(),textAlign: TextAlign.center),
                    ],
                  )),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6269FE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UserHomePage()));
                    },
                    child: Text(
                      'Back to Home Screen',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet?27:18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
