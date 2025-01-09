import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';

class UserHelp extends StatefulWidget {
  final String ?firstName;
  final String ?lastName;
  final String ?token;
  final String ?id;
  final String ?email;
  const UserHelp({super.key, this.firstName, this.lastName, this.token, this.id, this.email});

  @override
  State<UserHelp> createState() => _UserHelpState();
}

class _UserHelpState extends State<UserHelp> {
  final CommonWidgets commonWidgets = CommonWidgets();
  bool isVisible = false;
  List<bool> isVisibleList = [];

  @override
  void initState() {
    super.initState();
    isVisibleList = List.generate(10, (index) => false);
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
          showLeading: false,
          User: '${widget.firstName ?? ''} ${widget.lastName ?? ''}',
          userId: widget.id,
          showLanguage: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(90),
            child: Column(
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  toolbarHeight: 80,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xff6A66D1),
                  title: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 25),
                      child: Text(
                        'FAQ'.tr(),
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: viewUtil.isTablet?27:25),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: CircleAvatar(
                      backgroundColor: Color(0xffB7B3F1),
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildFAQItem(0,'question1'.tr(),'answer1'.tr()),
              buildFAQItem(1,'question2'.tr(),'answer2'.tr()),
              buildFAQItem(2,'question3'.tr(),'answer3'.tr()),
              buildFAQItem(3,'question4'.tr(),'answer4'.tr()),
              buildFAQItem(4,'question5'.tr(),'answer5'.tr()),
              buildFAQItem(5,'question6'.tr(),'answer6'.tr()),
              buildFAQItem(6,'question7'.tr(),'answer7'.tr()),
              buildFAQItem(7,'question8'.tr(),'answer8'.tr()),
              buildFAQItem(8,'question9'.tr(),'answer9'.tr()),
              buildFAQItem(9,'question10'.tr(),'answer10'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFAQItem(int index,String question,String answer) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: index==9? EdgeInsets.only(bottom: 50):EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12,top: 20),
            child: Container(
              color: isVisibleList[index]?Color(0xffF6F6FF):Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isVisibleList[index] = !isVisibleList[index];
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 12,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(question,style: TextStyle(color: Color(0xff6269FE),fontSize: viewUtil.isTablet ? 22:16),),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          color: Color(0xff6269FE),
                          isVisibleList[index]
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down_outlined,
                          size: viewUtil.isTablet ? 30:20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: isVisibleList[index],
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Container(
                color: isVisibleList[index]?Color(0xffF6F6FF):Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(answer,style: TextStyle(fontSize:  viewUtil.isTablet ? 20 :15),),
                ),
              ),
            ),
          ),
          if (index < 9)
            Divider(
            indent: 20,
            endIndent: 20,
            thickness: 1,
          )
        ],
      ),
    );
  }

}
