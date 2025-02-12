import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
  bool isVerified = false;

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
        return 'Invalid Date Format';
      }
    } else {
      return 'Invalid Date String';
    }
  }

  Future<void> fetchPartnerData() async {
    try {
      final data = await userService.getPartnerData(widget.partnerId, widget.token,widget.bookingId);
      if (data.isNotEmpty) {
        setState(() {
          partnerData = data;
        });
      } else {

      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }

  Future<Uint8List> _generateQrCodeImage(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
    final picData = await qrPainter.toImageData(150.0);
    return picData!.buffer.asUint8List();
  }

  bool get isTablet {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    return diagonal > 1100;
  }

  Future<void> _generateAndDownloadPdf(String address) async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/naqleePdf.png');
    final qrCodeData = 'http://localhost:4200/home/user/invoice-data/${widget.invoiceId}/${formatDateFromInvoiceId(widget.invoiceId)}/${'${widget.firstName} ${widget.lastName}'}/${widget.paymentAmount.toInt()}/${address}/${widget.bookingId}/${widget.unitType}/${partnerData?[0]['partnerName']}/${widget.paymentType}';
    final qrCodeImage = await _generateQrCodeImage(qrCodeData);

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Image(
                logoImage,
                width: 200,
                height: 200,
                fit: pw.BoxFit.contain),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex:4,
                  child: pw.Align(
                    alignment: pw.Alignment.topLeft,
                    child: pw.Image(pw.MemoryImage(qrCodeImage)),
                  ),
                ),
                pw.Expanded(
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text('PIANNAT AL-HASIB',textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Text('3455 al-dammam',textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 16)),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8.0),
                        child: pw.Text('34264-7932 3',textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                    flex:5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Tax Invoice'.tr(),style: pw.TextStyle(fontSize:16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Invoice no:'.tr(),textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('${widget.invoiceId}'.tr(),textAlign: pw.TextAlign.center,style: pw.TextStyle(fontSize: 16)),
                      ],
                    ))
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Date'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                      pw.Text(formatDateFromInvoiceId(widget.invoiceId),style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 50,
                    child: pw.VerticalDivider(
                      thickness: 1,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Booking id'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.bookingId,style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 50,
                    child: pw. VerticalDivider(
                      thickness: 1,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex:5,
                  child: pw.Padding(
                    padding: pw.EdgeInsets.only(left: 8,right:8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Unit type'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                        pw.Text(widget.unitType,style: pw.TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 50,
                    child: pw.VerticalDivider(
                      thickness: 1,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex:5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Payment type'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.paymentType,style: pw.TextStyle(fontSize: 16)),
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
                      pw.Text('Name:'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                      pw.Text(widget.firstName+' '+widget.lastName,style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    height: 50,
                    child: pw.VerticalDivider(
                      thickness: 1,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex:11,
                  child: pw.Padding(
                    padding: pw.EdgeInsets.only(left: 8,right:8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Address:'.tr(),style: pw.TextStyle(fontSize: 16,fontWeight: pw.FontWeight.bold)),
                        pw.Text(address,style: pw.TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                    flex:6,
                    child: pw.Container()
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Description'.tr(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      widget.pickup.isNotEmpty || widget.pickup != ''
                          ? pw.Column(
                        children: [
                          pw.Text(widget.pickup,style: pw.TextStyle(fontSize: 16)),
                          pw.Text((widget.dropPoints as List).join(', '),style: pw.TextStyle(fontSize: 16)),
                        ],
                      )
                          : pw.Text(widget.city,style: pw.TextStyle(fontSize: 16)),
                      pw.Text('${"Qty:".tr()} 1',style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${widget.paymentAmount.toInt()} SAR',style: pw.TextStyle(fontSize: 16)),
                    ],
                  ),
              ],
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.topLeft,
              child: pw.Text("Total Summary".tr(),textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("Subtotal".tr(),style: pw.TextStyle(fontSize: 16)), pw.Text('${widget.paymentAmount.toInt()} SAR',style: pw.TextStyle(fontSize: 16))],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Text("VAT".tr(),style: pw.TextStyle(fontSize: 16)), pw.Text("0%",style: pw.TextStyle(fontSize: 16))],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total".tr(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 16)),
                pw.Text("${widget.paymentAmount.toInt()} SAR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
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
                            SvgPicture.asset('assets/naqlee-logo.svg',
                                height: MediaQuery.of(context).size.height * 0.055),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:4,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: PrettyQr(
                                      data: 'https://naqlee.com/home/user/invoice-data?InvoiceId=${widget.invoiceId}&InvoiceDate=${formatDateFromInvoiceId(widget.invoiceId)}&CustomerName=${'${userData.firstName} ${userData.lastName}'}&PaymentAmount=${widget.paymentAmount.toInt()}&Address=${userData.address1}&bookingId=${widget.bookingId}&unitType=${widget.unitType}&partnerName=${partnerData?[0]['partnerName']}&paymentType=${widget.paymentType}',
                                      size: viewUtil.isTablet ?100:80,
                                      errorCorrectLevel: QrErrorCorrectLevel.M,
                                      roundEdges: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text('PIANNAT AL-HASIB',textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12, fontWeight: FontWeight.w500)),
                                      ),
                                      Text('3455 al-dammam',textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('34264-7932 3',textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex:5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text('Tax Invoice'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 24 : 20, fontWeight: FontWeight.w500)),
                                        Text('Invoice no:'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14,fontWeight: FontWeight.w500)),
                                        Text('${widget.invoiceId}'.tr(),textAlign: TextAlign.center,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                      ],
                                    ))
                              ],
                            ),
                            SizedBox(height: 20),
                            Divider(),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                      Text(formatDateFromInvoiceId(widget.invoiceId),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Booking id'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                      Text(widget.bookingId,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:5,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Unit type'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                        Text(widget.unitType,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Payment type'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                      Text(widget.paymentType,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex:5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Name:'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                      Text(userData.firstName+' '+userData.lastName,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    child: const VerticalDivider(
                                      color: Colors.grey,
                                      thickness: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:11,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Address:'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 12,fontWeight: FontWeight.w500)),
                                        Text(userData.address1,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:6,
                                  child: Container()
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 23 : 16, fontWeight: FontWeight.w500)),
                                    widget.pickup.isNotEmpty || widget.pickup != ''
                                    ? Column(
                                      children: [
                                        Text(widget.pickup,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                        Text( (widget.dropPoints as List).join(', '),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                      ],
                                    )
                                    : Text(widget.city,style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                    buildLabelValue('Qty'.tr(),'1'),
                                  ],
                                ),
                                Text('${widget.paymentAmount.toInt()} SAR',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
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
                                        Text('Total Summary'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 22 : 16, fontWeight: FontWeight.w500)),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Subtotal'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
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
                                              Text('VAT'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                              Text('0%',style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 14)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Total'.tr(),style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16, fontWeight: FontWeight.w500)),
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
                            SizedBox(height: 10),
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

