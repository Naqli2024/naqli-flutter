import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'package:flutter_naqli/User/user_home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        showLeading: false,
        User: widget.firstName! +' '+ widget.lastName!,
        userId: widget.id,
        showLanguage: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
          child: Column(
            children: [
              AppBar(
                scrolledUnderElevation: 0,
                toolbarHeight: 80,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xff6A66D1),
                title: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Text(
                      'FAQ',
                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 25),
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
            buildFAQItem(0,'How do I book a vehicle through your website?',
                'To book a vehicle, simply choose the type of service you need,'
                    'Select the date and time, enter the value of the product, specify'
                    'additional information, submit your booking request to receive'
                    'quote from our partners.'),
            buildFAQItem(1,'How long does it take to receive a quote after booking?',
                'Once the booking request is submitted, our module will obtain'
                "quotes from partners within 5 seconds. You'll receive the top 3"
                'lowest price to choose from.'),
            buildFAQItem(2, 'Can I choose my preferred vendor?',
                'Yes! After receiving quotes, you can select the vendor the best fits'
                'your budget and requirement.'),
            buildFAQItem(3, 'What payment option do you offer?',
                'You can choose to pay the full amount upfront or pay a partial'
                'advance. Payment methods include credit/debit card and other'
                'secure options available  on our site.'),
            buildFAQItem(4, 'How can I track my order?',
                'After your booking is confirmed and the order has started , you can'
                "view the live location of your vehicle in the booking section. you'll"
                "receive detailed information including the vendor name , operator"
                "name the type of vehicle selected as well as the booking  status"
                "and payment status for you convenience."),
            buildFAQItem(5, 'Will I be notified when my driver is arriving?',
                "Yes, the driver will notify you once they are en-route to your location,"
                "ensuring you are informed about their arrival time."),
            buildFAQItem(6, 'What should I do when I need to cancel my booking?',
                'If you need to cancel your booking you can easily do so by clicking'
                'the cancel icon located in the top right corner during the vendor'
                'selection process. Follow the prompts to complete you cancellation.'),
            buildFAQItem(7, 'Are there any additional fee that I should be aware of?',
                'While we aim to provide clear pricing, additional fees may apply'
                'based on specific services or circumstances. This will be disclosed'
                'in the quotes you receive.'),
            buildFAQItem(8, 'What happen if my vehicle does not arrive on time?',
                'If your vehicle is late, please contact our support team, We will'
                'assist you in tracking the status and addressing the issues.'),
            buildFAQItem(9, 'How do I contact customer support?',
                'You can reach our customer support team via the report section in'
                'the website or email to us. We are here to assist you 24 hours.'),
          ],
        ),
      ),
    );
  }

  Widget buildFAQItem(int index,String question,String answer) {
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
                        child: Text(question,style: TextStyle(color: Color(0xff6269FE),fontSize: 16),),
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
                  child: Text(answer,style: TextStyle(fontSize: 15),),
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
