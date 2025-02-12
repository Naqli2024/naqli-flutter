import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/booking/booking_details.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/requestSupport.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class SubmitTicket extends StatefulWidget {
  final String firstName;
  final String token;
  final String email;
  final String partnerId;
  const SubmitTicket({super.key, required this.firstName, required this.token, required this.partnerId, required this.email});

  @override
  State<SubmitTicket> createState() => _SubmitTicketState();
}

class _SubmitTicketState extends State<SubmitTicket> {
  final AuthService _authService = AuthService();
  final CommonWidgets commonWidgets = CommonWidgets();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
            context,
            User: widget.firstName,
            showLeading: false,
            userId: widget.partnerId
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
                              child: Text('We are available to assist you'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: viewUtil.isTablet? 30 : 25,
                                ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,bottom: 40),
                              child: Text("To get assistance on your naqlee journey.Please click on the ticket form below if you have any question about billing or logistics.".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: viewUtil.isTablet? 22 :16,
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
                                          builder: (context) => RequestSupport(firstName: widget.firstName, token: widget.token, partnerId: widget.partnerId,email: widget.email,)
                                      ),
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: Text(
                                    'Submit a ticket'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: viewUtil.isTablet? 24 : 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 40,bottom: 5),
                              child: Text("${'You can reach us via email at'.tr()} sales@naqlee.com ${'if that would be more convenient for you.'.tr()} ${'In either case, we try to reply to every communication within 1 working day.'.tr()}".tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: viewUtil.isTablet? 22 : 16,
                                ),
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("SUPPORT FAQS".tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: viewUtil.isTablet? 30 :25,
                                ),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Look no further if you are having trouble logging and navigating into our website or controlling your account information, don't worry our help".tr(),
                                  style: TextStyle(
                                    fontSize: viewUtil.isTablet? 22 : 16,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Doc".tr(),
                                      style: TextStyle(
                                        fontSize: viewUtil.isTablet? 22 : 16,
                                        color: Colors.blue,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        final Uri docUrl = Uri.parse('https://example.com/help-doc');
                                        // launchUrl(docUrl.toString());
                                      },
                                    ),
                                    TextSpan(
                                      text: "are available for you even when our employees are asleep.".tr(),
                                      style: TextStyle(
                                        fontSize: viewUtil.isTablet? 22 :16,
                                        color: Colors.black,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookingDetails(partnerName: widget.firstName, partnerId: widget.partnerId, token: widget.token, quotePrice: '', paymentStatus: '', email: widget.email)
                        ),
                      );
                    },
                    child: const CircleAvatar(child: Icon(FontAwesomeIcons.arrowLeft,size: 20,))))
          ],
        ),
      ),
    );
  }
}
