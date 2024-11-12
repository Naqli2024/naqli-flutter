import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonWidgets.commonAppBar(
        context,
        showLeading: false,
        User: widget.partnerName,
        userId: widget.partnerId,
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
            buildFAQItem(0,'How is the price calculated?',
                    'The price is calculated according to the estimated distance between the loading and delivery point , automatically'
                    ' and directly through the platform.'),
            buildFAQItem(1,'What are the sizes and type of truck?',
                'We provide a shipping platform of multiple sizes, Which are as follows: trailer, truck, lorry, diana, and pickup truck.'),
            buildFAQItem(2, 'Do you own the truck?',
                'We have our own trucks and we also have contracts with transportation agents throughout the kingdom.'),
            buildFAQItem(3, 'I have a furniture that I need to move. What shipping platform can you provide me with and what are the condition?',
                'To reserve a truck for transporting furniture, you can request the truck through the application, and to find out the prices'
                ' through the application, specify the loading and delivery address and it will appear for your price automatically.\n'
                     "\n"
                    '1.Loading and unloading workers can be requested for an additional fee through the application.\n'
                    '2.Furniture should be well wrapped to prevent damage.\n'
                    '3.We do not provide shipping packaging or dismantling and installation services.\n'
                    '4.In shipping, we provide rental trucks to transport all type of products, and we do not specialize in transporting furniture'
                    'in particular.'),
            buildFAQItem(4, 'We have a load of 30 tons and we need a trailer to transport it. is that possible?',
                'The maximum load that can be loaded in 25 tons and it is not possible to load more than that, but there are exceptional'
                " cases in which we provide assistance to our customers continuing to move higher than that if necessary."),
            buildFAQItem(5, 'What products are prohibited from being transported on a shipping platform?',
                "The transportation of all products prohibited by the kingdom of Saudi Arabia is prohibited. it is also prohibits the transportation"
                " of people, flammable materials, and the transportation of money."),
            buildFAQItem(6, 'What is the size of the truck: trailer - Lorry - Dyna?',
                'You can view the truck measurements and details by visiting the following link.'),
            buildFAQItem(7, 'What is the maximum weight that can be loaded per truck?',
                'The trailer 25 tons - the lorry 8 tons - the dyna 4.5 tons the pick up 1 ton "varies depending on the type of truck,'
                ' more or less".'),
            buildFAQItem(8, 'How many pallets can be loaded per truck?',
                'According to the standard pallet size 120 x100, the trailer has 24 pallets, the lorry has 7.5 meters, 10 pallets, the lorry'
                ' has 8 pallets, and the lorry has 4 pallets.'),
            buildFAQItem(9, 'Can a driver of a specific nationality be provided?',
                "Drivers of specific nationalities can be provided according to the customer's request for reason of entering government"
                ' facilities or according to followed regulations and policies of some companies.'),
            buildFAQItem(10, 'What are the nationalities of your driver?',
                "We have all nationalities of drivers working with us, Saudis and non-Saudis."),
            buildFAQItem(11, 'Can you provide us with a fixed price that is not based on kilometers?',
                "The policy of the shipping platform requires that the price be calculated according to the estimated distance between the"
                " loading point and the delivery point, so you may find that prices vary depending on this distance."),
            buildFAQItem(12, 'What payment methods are available?',
                "On the shipping platform, we provide many payment options, which are as follows: Apple pay, STC pay, visa or Mada."),
          ],
        ),
      ),
    );
  }

  Widget buildFAQItem(int index,String question,String answer) {
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
              padding: EdgeInsets.only(left: 12, right: 12),
              child: Container(
                color: isVisibleList[index]?Color(0xffF6F6FF):Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(answer,style: TextStyle(fontSize: 15),),
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
