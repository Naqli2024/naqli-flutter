import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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
  const UserInvoiceOverview({super.key, required this.token, required this.firstName, required this.lastName, required this.id, required this.email});

  @override
  State<UserInvoiceOverview> createState() => _UserInvoiceOverviewState();
}

class _UserInvoiceOverviewState extends State<UserInvoiceOverview> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();

  Future<void> _generateAndDownloadPdf() async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/naqleePdf.png');
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex:5,
                  child: pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Image(logoImage),
                  ),
                ),
                pw.Expanded(flex:3,child: pw.Text('INVOICE',style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)))
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PIANNAT AL-HASIB',style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('3455 al-dhammam'),
                      pw.Text('24164-7932 3'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex:3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice id:#7686868'),
                      pw.Text('Invoice date:12/04/2024')
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
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill to:',style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                      pw.Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex:3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Partner: Akbar'),
                      pw.Text('Unit type: Six'),
                      pw.Text('Booking id: #7686876896'),
                      pw.Text('Payment type: Mada'),
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
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Descriptrion',style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                      pw.Text('Qty:2'),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex:3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('23.896 SAR'),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text("Total Summary", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("Sub total"), pw.Text("23.896 SAR")],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("Labour charge"), pw.Text("4000 SAR")],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("VAT"), pw.Text("-")],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("27.896 SAR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
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
                          Expanded(flex:3,child: Text('INVOICE',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))
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
                                Text('PIANNAT AL-HASIB',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                Text('3455 al-dhammam'),
                                Text('24164-7932 3'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex:3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Invoice id:#7686868'),
                                Text('Invoice date:12/04/2024')
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
                                Text('Bill to:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                                Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex:3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Partner: Akbar'),
                                Text('Unit type: Six'),
                                Text('Booking id: #7686876896'),
                                Text('Payment type: Mada'),
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
                                Text('Descriptrion',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                Text('xxxxxxxxxxxxxxxxxxxxxxxx'),
                                Text('Qty:2'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex:3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('23.896 SAR'),
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
                                  Text('Total Summary',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Sub total'),
                                            Text('23.896 SAR'),
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
                                        Text('Labour charge'),
                                        Text('4000 SAR'),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('VAT'),
                                        Text('-'),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                        Text('27.896 SAR',style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                    onPressed: _generateAndDownloadPdf,
                    child: Text(
                      'Download'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
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
