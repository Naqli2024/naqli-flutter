import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;

import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';

class PartnerHelp extends StatefulWidget {
  final String partnerName;
  final String token;
  final String partnerId;
  final String email;
  const PartnerHelp({super.key, required this.partnerName, required this.token, required this.partnerId, required this.email});

  @override
  State<PartnerHelp> createState() => _PartnerHelpState();
}

class _PartnerHelpState extends State<PartnerHelp> {
  final CommonWidgets commonWidgets = CommonWidgets();
  bool isVisible = false;
  List<bool> isVisibleList = [];

  @override
  void initState() {
    super.initState();
    isVisibleList = List.generate(13, (index) => false);
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
          User: widget.partnerName,
          userId: widget.partnerId,
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
              buildFAQItem(0,'partnerQuestion1'.tr(),'partnerAnswer1'.tr()),
              buildFAQItem(1,'partnerQuestion2'.tr(),'partnerAnswer2'.tr()),
              buildFAQItem(2, 'partnerQuestion3'.tr(),'partnerAnswer3'.tr()),
              buildFAQItem(3, 'partnerQuestion4'.tr(),'partnerAnswer4'.tr()),
              buildFAQItem(4, 'partnerQuestion5'.tr(),'partnerAnswer5'.tr()),
              buildFAQItem(5, 'partnerQuestion6'.tr(),'partnerAnswer6'.tr()),
              buildFAQItem(6, 'partnerQuestion7'.tr(),'partnerAnswer7'.tr()),
              buildFAQItem(7, 'partnerQuestion8'.tr(),'partnerAnswer8'.tr()),
              buildFAQItem(8, 'partnerQuestion9'.tr(),'partnerAnswer9'.tr()),
              buildFAQItem(9, 'partnerQuestion10'.tr(),'partnerAnswer10'.tr()),
              buildFAQItem(10, 'partnerQuestion11'.tr(),'partnerAnswer11'.tr()),
              buildFAQItem(11, 'partnerQuestion12'.tr(),'partnerAnswer12'.tr()),
              buildFAQItem(12, 'partnerQuestion13'.tr(),'partnerAnswer13'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFAQItem(int index,String question,String answer) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: index==12? EdgeInsets.only(bottom: 50):EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12,top: 20),
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
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Container(
                color: isVisibleList[index]?Color(0xffF6F6FF):Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(answer,style: TextStyle(fontSize: viewUtil.isTablet ? 20 :15),),
                ),
              ),
            ),
          ),
          if (index < 12)
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
