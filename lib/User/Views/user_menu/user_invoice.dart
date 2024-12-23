import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
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
        body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Card(
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> UserInvoiceOverview(
                          firstName: widget.firstName,
                          lastName: widget.lastName, token: widget.token, id: widget.id,email: widget.email,)));
                  },
                  leading: CircleAvatar(
                    child: Text(
                      widget.firstName.substring(0, 2).toUpperCase(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: Colors.grey,
                  ),
                  title: Text(
                    widget.firstName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Invoice id#7588477585758',
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '45,985 SAR',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
