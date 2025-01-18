import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naqli/Partner/Viewmodel/sharedPreferences.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/SuperUser/Viewmodel/superUser_services.dart';
import 'package:flutter_naqli/User/Views/user_auth/user_success.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_makePayment.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:webview_flutter/webview_flutter.dart';

class Payment extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  final String email;
  final String? quotePrice;

  const Payment({
    super.key,
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.id, this.quotePrice, required this.email,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  final SuperUserServices superUserServices = SuperUserServices();
  late Future<List<dynamic>> paymentHistory;
  bool isLoading = true;
  int zeroQuotePrice = 0;
  String bookingId ='';
  bool isOtherCardTapped = false;
  bool isMADATapped = false;
  String? checkOutId;
  String? integrityId;
  String? resultCode;
  String? paymentStatus;

  @override
  void initState() {
    super.initState();
    paymentHistory = fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonWidgets.commonAppBar(
          context,
          User: widget.firstName +' '+ widget.lastName,
          showLeading: false,
            userId: widget.id,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(90.0),
            child: AppBar(
              scrolledUnderElevation: 0,
              centerTitle: false,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff6A66D1),
              title: Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Text(
                        'payment'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?26:24),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> UserType(
                        firstName: widget.firstName,
                        lastName: widget.lastName, token: widget.token, id: widget.id,quotePrice: widget.quotePrice,email: widget.email,)));
                },
                icon: Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                  size: viewUtil.isTablet?27: 24,
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: fetchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.17),
                      child: SvgPicture.asset('assets/noPayment.svg',
                          height: viewUtil.isTablet
                              ? MediaQuery.sizeOf(context).height * 0.22
                              : MediaQuery.sizeOf(context).height * 0.2),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40, bottom: 0),
                      child: Text(
                        "No Payment information Available".tr(),
                        style: TextStyle(fontSize: viewUtil.isTablet ? 27 : 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 0),
                      child: Text(
                        "It looks like you don't have any recent payment details available at the moment. Please check back later.".tr(),
                        style: TextStyle(fontSize: viewUtil.isTablet ? 22 :16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final paymentHistory = snapshot.data!;
              return ListView.builder(
                itemCount: paymentHistory.length,
                itemBuilder: (context, index) {
                  final booking = paymentHistory[index];
                  bookingId = '${booking['_id'].toString()}';
                  final fromTime = booking?['fromTime'] ?? 'N/A';
                  final toTime = booking?['toTime'] ?? 'N/A';
                  final time = booking?['time'] ?? 'N/A';
                  return Container(
                    height: viewUtil.isTablet
                        ? MediaQuery.of(context).size.height * 0.08
                        : MediaQuery.of(context).size.height * 0.11,
                    margin: viewUtil.isTablet
                      ? EdgeInsets.fromLTRB(40, 20, 40, 0)
                      : EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xffE0E0E0), // Border color
                          width: 1, // Border width
                        ),
                      ),
                      shadowColor: Colors.black,
                      elevation: 3.0,
                      child: Container(
                        padding: viewUtil.isTablet
                            ? EdgeInsets.all(8)
                            : EdgeInsets.all(2),
                        child: Container(
                          child: ListTile(
                            title: Text('${'Booking id'.tr()}: ${booking['_id'].toString()}'),
                            subtitle: Row(
                              children: [
                                Text('${booking['date']}'),
                                time == 'N/A'
                                    ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$fromTime - $toTime'),
                                )
                                    :Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('$time'),
                                ),
                              ],
                            ),
                            trailing: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.05,
                                width: viewUtil.isTablet
                                  ? MediaQuery.of(context).size.width * 0.2
                                  : MediaQuery.of(context).size.width * 0.23,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff6A66D1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () {
                                    showBookingDialog(context, booking);
                                  },
                                  child: Text(
                                    booking['paymentStatus'] == 'Pending' || booking['paymentStatus'] == 'HalfPaid' ? 'Pay Bal'.tr() : 'View'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: viewUtil.isTablet ? 20 : 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchHistory() async {
    try {
      final data = await getSavedUserData();
      final String? id = data['id'];
      final String? token = data['token'];

      if (id != null && token != null) {
        return await userService.fetchPaymentBookingHistory(id, token);
      } else {
        setState(() {
          isLoading = false;
        });
        return [];
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return [];
    }
  }

  void showBookingDialog(BuildContext context, Map<String, dynamic> booking) {
    ViewUtil viewUtil = ViewUtil(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String paymentStatus = booking['paymentStatus'] ?? 'N/A'.tr();
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
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
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: Color(0xffE0E0E0), // Border color
                              width: 1, // Border width
                            ),
                          ),
                        ),
                        child: Container(
                          width: viewUtil.isTablet
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Booking id'.tr(),
                                        style: TextStyle(
                                            fontSize: viewUtil.isTablet ? 22 : 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${booking?['_id'] ?? 'N/A'}',
                                        style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16,color: Color(0xff79797C)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Date'.tr(),
                                        style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${booking?['date'] ?? ''}',
                                        style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16,color: Color(0xff79797C)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      child: Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:Border.all(color: booking?['paymentStatus'] == 'Completed'
                              ? Colors.greenAccent
                              : booking?['paymentStatus'] == 'Paid'
                              ? Colors.green
                              : Colors.red,),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text('${booking?['paymentStatus'] ?? 'N/A'.tr()}' == 'Completed' ? 'Paid'.tr(): paymentStatus.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 19)),
                      ),
                    ),
                    Positioned(
                      top: -40,
                      right: -30,
                      child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                              backgroundColor: Colors.red,
                              minRadius: 20,
                              maxRadius: double.maxFinite,
                              child: Icon(Icons.cancel_outlined, color: Colors.white,size: 30,))),
                    ),
                  ],
                ),
                booking?['paymentStatus'] == 'Paid' || booking?['paymentStatus'] == 'Completed'
                    ?Padding(
                  padding: const EdgeInsets.only(top: 30,bottom: 10),
                  child: Text(
                    '${booking?['paymentStatus'] ?? ''}'== 'Completed' ? 'Total Paid'.tr(): '${'Total'.tr()} ${paymentStatus.tr()}',
                    style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 19),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.only(top: 30,bottom: 10),
                  child: Text(
                    'Pending Amount'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 19),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${booking['paymentStatus'] ?? ''}'== 'Completed' ? '${booking['paymentAmount'] ?? 'No Amount'} SAR':'${booking['remainingBalance'] ?? 'No Amount'} SAR',
                    style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 19),
                  ),
                ),
                booking?['paymentStatus'] == 'Pending' || booking?['paymentStatus'] == 'HalfPaid'
                    ? Container(
                  margin: const EdgeInsets.only(
                      top: 10, left: 10),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.054,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6269FE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          showSelectPaymentDialog(booking['remainingBalance'],booking['partner']??'',booking['_id']??'');
                        },
                        child: Text(
                          '${'Pay :'.tr()} ${booking['remainingBalance']??''} SAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ? 22 :17,
                              fontWeight: FontWeight.w500),
                        )),
                  ),
                )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }

  void showSelectPaymentDialog(int amount,String partnerId,String bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            insetPadding: EdgeInsets.symmetric(horizontal: 25),
            backgroundColor: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(0),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              isOtherCardTapped = false;
                              isMADATapped = false;
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            )),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isMADATapped = true;
                            isOtherCardTapped = false;
                            Navigator.pop(context);
                          });
                          await initiatePayment('MADA', amount);
                          showPaymentDialog(checkOutId??'', integrityId??'', true,amount,partnerId,bookingId);
                        },
                        child: Container(
                          color: isMADATapped
                              ? Color(0xffD4D4D4)
                              : Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pay using MADA".tr(),
                                style: TextStyle(fontSize: 18),
                              ),
                              SvgPicture.asset(
                                'assets/Mada_Logo.svg',
                                height: 25,
                                width: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isMADATapped = false;
                            isOtherCardTapped = true;
                            Navigator.pop(context);
                          });
                          await initiatePayment('OTHER', amount);
                          showPaymentDialog(checkOutId??'', integrityId??'', false,amount,partnerId,bookingId);
                        },
                        child: Container(
                          color: isOtherCardTapped
                              ? Color(0xffD4D4D4)
                              : Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("Pay using Other Card Types".tr(),
                                    style: TextStyle(fontSize: 18)),
                              ),
                              SvgPicture.asset('assets/visa-mastercard.svg',
                                  height: 40, width: 20)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30)
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future initiatePayment(String paymentBrand,int amount) async {
    setState(() {
      commonWidgets.loadingDialog(context, true);
    });
    final result = await superUserServices.choosePayment(
      context,
      userId: widget.id,
      paymentBrand: paymentBrand,
      amount: amount,
    );
    if (result != null) {
      setState(() {
        checkOutId = result['id'];
        integrityId = result['integrity'];
      });
    }
    setState(() {
      Navigator.pop(context);
    });
  }

  Future<void> getPaymentStatus(String checkOutId, bool isMadaTapped) async {
    final result = await superUserServices.getPaymentDetails(context, checkOutId, isMadaTapped);
    if (result != null && result['code'] != null) {
      setState(() {
        resultCode = result['code'] ?? '';
        paymentStatus = result['description'] ?? '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve payment status.')),
      );
    }
  }

  void showPaymentDialog(String checkOutId, String integrity, bool isMADATapped,int amount,String partnerID,String bookingId) {
    if (checkOutId.isEmpty || integrity.isEmpty) {
      return;
    }

    final String visaHtml = '''
          <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>HyperPay Payment Integration</title>
              <style>
                body {
                  margin: 0;
                  padding: 0;
                  display: flex;
                  flex-direction: column;
                  justify-content: center;
                  align-items: center;
                }
                .paymentWidgets {
                  width: 50%;
                  max-width: 100px;
                  box-sizing: border-box;
                }
                .paymentWidgets button {
                  background-color: #4CAF50;
                  color: white;
                  border: none;
                  padding: 10px 20px;
                  font-size: 16px;
                  border-radius: 5px;
                  cursor: pointer;
                }
                .paymentWidgets button:hover {
                  background-color: #45a049;
                }
                #submitButton {
                  display: none;
                  margin-top: 20px;
                  padding: 10px 20px;
                  font-size: 16px;
                  background-color: #4CAF50;
                  color: white;
                  border: none;
                  cursor: pointer;
                  border-radius: 5px;
                }
                #submitButton:active {
                  background-color: #45a049;
                }
              </style>
          
              <script>
                 window['wpwlOptions'] = {
                billingAddress: {},
                mandatoryBillingFields: {
                  country: true,
                  state: true,
                  city: true,
                  postcode: true,
                  street1: true,
                  street2: false,
                },
              };
          
                // Function to load the HyperPay payment widget script
                function loadPaymentScript(checkoutId, integrity) {
                  const script = document.createElement('script');
                  script.src = "https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId=" + checkoutId;
                  script.crossOrigin = 'anonymous';
                  script.integrity = integrity;
                  script.onload = () => {
                    console.log('Payment widget script loaded'); 
                  };
                  document.body.appendChild(script);
                }
                document.addEventListener("DOMContentLoaded", function () {
                  loadPaymentScript("${checkOutId}", "${integrity}");
                });
              </script>
            </head>
          
            <body>
              <form action="https://naqlimobilepaymentresult.onrender.com/" method="POST" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
            </body>
          </html>
          ''';

    final String madaHtml = visaHtml.replaceAll("VISA MASTER AMEX", "MADA");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              child: WebView(
                backgroundColor: Colors.transparent,
                initialUrl: Uri.dataFromString(
                    isMADATapped ? madaHtml : visaHtml,
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8')
                ).toString(),
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: {
                  JavascriptChannel(
                    name: 'NavigateToFlutter',
                    onMessageReceived: (JavascriptMessage message) async {
                      await getPaymentStatus(checkOutId, isMADATapped);
                      if (resultCode == "000.100.110") {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentSuccessScreen(
                              onContinuePressed: () async {
                                await userService.updatePayment(
                                  widget.token,
                                  amount,
                                  'Completed',
                                  partnerID,
                                  bookingId,
                                  amount * 2,
                                  0,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => Payment(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    token: widget.token,
                                    id: widget.id,
                                    email: widget.email,
                                  ),),
                                );
                              },
                            ),
                          ),
                        );
                        Future.delayed(Duration(seconds: 3), () async {
                          await userService.updatePayment(
                            widget.token,
                            amount,
                            'Completed',
                            partnerID,
                            bookingId,
                            amount * 2,
                            0,
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Payment(
                              firstName: widget.firstName,
                              lastName: widget.lastName,
                              token: widget.token,
                              id: widget.id,
                              email: widget.email,
                            ),),
                          );
                        });
                      }
                      else {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => PaymentFailureScreen(
                              paymentStatus: paymentStatus??'',
                              onRetryPressed:() {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => Payment(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    token: widget.token,
                                    id: widget.id,
                                    email: widget.email,
                                  ),),
                                );
                              },)));
                      }
                    },
                  ),
                },
                onWebViewCreated: (WebViewController webViewController) {
                  webViewController.clearCache();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
