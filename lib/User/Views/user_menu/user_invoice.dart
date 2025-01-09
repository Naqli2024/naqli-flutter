import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/User/Model/user_model.dart';
import 'package:flutter_naqli/User/Viewmodel/user_services.dart';
import 'package:flutter_naqli/User/Views/user_createBooking/user_type.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/User/Views/user_menu/user_invoice_overview.dart';
class UserInvoice extends StatefulWidget {
  final String token;
  final String firstName;
  final String lastName;
  final String id;
  final String email;
  const UserInvoice({super.key, required this.token, required this.firstName, required this.lastName, required this.id, required this.email});

  @override
  State<UserInvoice> createState() => _UserInvoiceState();
}

class _UserInvoiceState extends State<UserInvoice> {
  final CommonWidgets commonWidgets = CommonWidgets();
  final UserService userService = UserService();
  late Future<UserInvoiceModel> invoiceData;

  @override
  void initState() {
    invoiceData = userService.getUserInvoiceData(widget.id);
    super.initState();
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
                        style: TextStyle(color: Colors.white, fontSize: viewUtil.isTablet?26:24),
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
          body: FutureBuilder<UserInvoiceModel>(
            future: invoiceData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'An error occurred while fetching data.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              } else if (snapshot.hasData) {
                final invoices = snapshot.data!.invoices;
                if (invoices.isEmpty) {
                  return Center(
                    child: Text(
                      'No invoice data found',
                      style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }
                else {
                  return ListView.builder(
                    itemCount: invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return Container(
                        margin: viewUtil.isTablet
                            ? EdgeInsets.fromLTRB(30, 20, 30, 0)
                            : EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: Color(0xffE0E0E0),
                              width: 1,
                            ),
                          ),
                          shadowColor: Colors.black,
                          elevation: 3.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserInvoiceOverview(
                                      firstName: widget.firstName,
                                      lastName: widget.lastName,
                                      token: widget.token,
                                      id: widget.id,
                                      email: widget.email,
                                      invoiceId: invoice.invoiceId,
                                      paymentType: invoice.paymentType,
                                      paymentAmount: invoice.paymentAmount,
                                      unitType: invoice.unitType,
                                      bookingId: invoice.id,
                                      pickup: invoice.pickup,
                                      dropPoints: invoice.dropPoints,
                                      city: invoice.city,
                                      partnerId: invoice.partnerId,
                                      userId: invoice.user
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                child: Text(
                                  widget.firstName.substring(0, 2).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: viewUtil.isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Colors.grey,
                              ),
                              title: Text(
                                widget.firstName+' '+widget.lastName,
                                style: TextStyle(
                                  fontSize: viewUtil.isTablet ? 22 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Invoice ID: ${invoice.invoiceId}',
                                style: TextStyle(fontSize: viewUtil.isTablet ? 17 : 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                '${invoice.paymentAmount} SAR',
                                style: TextStyle(
                                  fontSize: viewUtil.isTablet ? 20 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                return Center(
                  child: Text(
                    'No invoice data found',
                    style: TextStyle(fontSize: viewUtil.isTablet ? 20 : 16, fontWeight: FontWeight.w500),
                  ),
                );
              }
            },
          )
      ),
    );
  }
}
