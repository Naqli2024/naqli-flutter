import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_vendor.dart';
import 'package:flutter_naqli/User/Views/user_menu/user_requestSupport.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserSubmitTicket extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String token;
  final String id;
  final String email;
  const UserSubmitTicket({super.key, required this.firstName, required this.lastName, required this.token, required this.id, required this.email});

  @override
  State<UserSubmitTicket> createState() => _UserSubmitTicketState();
}

class _UserSubmitTicketState extends State<UserSubmitTicket> {
  final UserService userService = UserService();
  final CommonWidgets commonWidgets = CommonWidgets();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        User: widget.firstName +' '+ widget.lastName,
        showLeading: false,
        userId: widget.id
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.sizeOf(context).width,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/submitTicket.svg',height: MediaQuery.sizeOf(context).height * 0.3,),
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text('We are available to assist you',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                              ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5,bottom: 40),
                            child: Text("To get assistance on your naqlee journey.Please click on the ticket form below if you have any question about billing or logistics.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6A66D1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserRequestSupport(firstName: widget.firstName, lastName: widget.lastName, token: widget.token, id: widget.id,email: widget.email,)
                                    ),
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: const Text(
                                  'Submit a ticket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 40,bottom: 5),
                            child: Text("You can reach us via email at naqlee45@gmail.com if that would be more convenient for you in either case we try to reply to every communication Within 1 working day",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Support FAQS",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 30,
                              ),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                              text: TextSpan(
                                text: "Look no further if you are having trouble logging and navigating into our website or controlling your account information, don't worry our help ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // Set the default text color
                                ),
                                children: [
                                  TextSpan(
                                    text: "Doc",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                    recognizer: TapGestureRecognizer()..onTap = () {
                                      // Define the action to be performed when "Doc" is clicked
                                      final Uri docUrl = Uri.parse('https://example.com/help-doc'); // Replace with your actual doc URL
                                      // launchUrl(docUrl.toString());
                                    },
                                  ),
                                  TextSpan(
                                    text: " are available for you even when our employees are asleep.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black, // Set color back to default for remaining text
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
            
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
              top: 20,
              child: GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: const CircleAvatar(child: Icon(FontAwesomeIcons.arrowLeft,size: 20,))))
        ],
      ),
    );
  }
}
