import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'dart:ui' as ui;
import 'package:flutter_naqli/User/Views/user_menu/user_invoice.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class UserInvoiceOverview extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  final String email;
  final String invoiceId;
  final String paymentType;
  final int paymentAmount;
  final String unitType;
  final String bookingId;
  final String pickup;
  final List dropPoints;
  final String city;
  final String partnerId;
  final String userId;
  const UserInvoiceOverview({super.key, required this.token, required this.firstName, required this.lastName, required this.id, required this.email, required this.invoiceId, required this.paymentType, required this.unitType, required this.bookingId, required this.paymentAmount, required this.pickup, required this.dropPoints, required this.city, required this.partnerId, required this.userId});

  @override
  State<UserInvoiceOverview> createState() => _UserInvoiceOverviewState();
}

class _UserInvoiceOverviewState extends State<UserInvoiceOverview> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late Future<UserDataModel> userData;
  List<Map<String, dynamic>>? partnerData;

  @override
  void initState() {
    super.initState();
    userData = userService.getUserData(widget.userId,widget.token);
    fetchPartnerData();
  }

  String formatDateFromInvoiceId(String invoiceId) {
    String dateString = invoiceId.substring(4, 12);
    if (dateString.length == 8) {
      try {
        String formattedDateString = '${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6, 8)}';
        DateTime date = DateTime.parse(formattedDateString);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        print('Error parsing date: $e');
        return 'Invalid Date Format';
      }
    } else {
      return 'Invalid Date String';
    }
  }

  Future<void> fetchPartnerData() async {
    try {
      final data = await userService.getPartnerData(widget.partnerId, widget.token,widget.bookingId);

      print('Fetched Partner Data: $data');

      if (data.isNotEmpty) {
        setState(() {
          partnerData = data;
        });
      } else {
        print('No partner data available');
      }
    } catch (e) {
      print('Error fetching partner data: $e');
    }
  }

  Future<void> _generateAndDownloadPdf(String address) async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/naqleePdf.png');

    // Create the invoice PDF with dynamic data
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Image(logoImage),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PIANNAT AL-HASIB', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('3455 al-dhammam'),
                      pw.Text('24164-7932 3'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Invoice id: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: widget.invoiceId,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Invoice date: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: '${formatDateFromInvoiceId(widget.invoiceId)}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill to:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.firstName+' '+widget.lastName),
                      pw.Text(address),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Partner: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: partnerData?[0]['partnerName'] ?? 'No data',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Unit type: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: widget.unitType,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Booking id: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: widget.bookingId,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Payment type: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.TextSpan(
                              text: widget.paymentType,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Description', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      widget.pickup.isNotEmpty || widget.pickup != ''
                          ? pw.Column(
                        children: [
                          pw.Text(widget.pickup),
                          pw.Text((widget.dropPoints as List).join(', ')),
                        ],
                      )
                          : pw.Text(widget.city),
                      pw.Text('Qty: 1'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${widget.paymentAmount.toInt()} SAR'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text("Total Summary", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("Sub total"), pw.Text('${widget.paymentAmount.toInt()} SAR')],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("Labour charge"), pw.Text("0 SAR")],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("VAT"), pw.Text("0%")],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("${widget.paymentAmount.toInt()} SAR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    try {
      // Print the generated PDF
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("Error: $e");
    }
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
                        'Invoice'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?27:24),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
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
        body: FutureBuilder(
        future: userData,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: SvgPicture.asset('assets/naqlee-logo.svg',
                                        height: MediaQuery.of(context).size.height * 0.04),
                                  ),
                                ),
                                Expanded(flex:3,child: Text('INVOICE',style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 20, fontWeight: FontWeight.w500)))
                              ],
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('PIANNAT AL-HASIB',style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 16, fontWeight: FontWeight.w500)),
                                      Text('3455 al-dammam',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                      Text('34264-7932 3',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildLabelValue('Invoice id', widget.invoiceId),
                                      buildLabelValue('Invoice date', '${formatDateFromInvoiceId(widget.invoiceId)}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Bill to:',style: TextStyle(fontSize: viewUtil.isTablet ? 22 :16, fontWeight: FontWeight.w500)),
                                      Text(userData.firstName+' '+userData.lastName,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                      Text(userData.address1,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildLabelValue('Partner', partnerData?[0]['partnerName'] ?? 'no_data'.tr()),
                                      buildLabelValue('Unit type', widget.unitType),
                                      buildLabelValue('Booking id', widget.bookingId),
                                      buildLabelValue('Payment type', widget.paymentType),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Description',style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16, fontWeight: FontWeight.w500)),
                                      widget.pickup.isNotEmpty || widget.pickup != ''
                                      ? Column(
                                        children: [
                                          Text(widget.pickup,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                          Text( (widget.dropPoints as List).join(', '),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                        ],
                                      )
                                      : Text(widget.city,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                      buildLabelValue('Qty','1'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${widget.paymentAmount.toInt()} SAR',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex:6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Summary',style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16, fontWeight: FontWeight.w500)),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Sub total',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                                  Text('${widget.paymentAmount.toInt()} SAR',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Labour charge',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                              Text('0',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('VAT',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                              Text('0%',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Total',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16, fontWeight: FontWeight.w500)),
                                              Text('${widget.paymentAmount.toInt()} SAR',style: TextStyle(fontSize: viewUtil.isTablet ? 20 :16, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6269FE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            await _generateAndDownloadPdf(userData.address1);
                          },
                          child: Text(
                            'Download'.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ? 25 : 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        }
        ),
      ),
    );
  }

  Widget buildLabelValue(String label, String value) {
    ViewUtil viewUtil = ViewUtil(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(fontWeight: FontWeight.w500,fontSize: viewUtil.isTablet ? 20 : 14), // Bold label
          ),
          TextSpan(
            text: value,
            style: TextStyle(fontWeight: FontWeight.normal,fontSize: viewUtil.isTablet ? 20 : 14), // Regular text
          ),
        ],
      ),
    );
  }
}
