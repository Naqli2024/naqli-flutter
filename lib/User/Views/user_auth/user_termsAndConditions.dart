import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserTermsAndConditions extends StatefulWidget {
  const UserTermsAndConditions({super.key});

  @override
  State<UserTermsAndConditions> createState() => _UserTermsAndConditionsState();
}

class _UserTermsAndConditionsState extends State<UserTermsAndConditions> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          'assets/naqlee-logo.svg',
          fit: BoxFit.fitWidth,
          height: 40,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: false,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff6A66D1),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Text(
                  'Terms and Conditions'.tr(),
                  style: TextStyle(color: Colors.white),
                ),
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
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("This Privacy Policy sets out the basis on which we will handle any personal data, including but not limited to payment information and other data that we collect from you or from other sources or that you provide to us (“Data”) in connection with your access and use of our website and/or Naqlee mobile application (collectively, the “Site”), services and applications (collectively, the “Services”). We understand the importance of this data and are committed to protecting and respecting your privacy. Please read the following carefully to understand our data practices. By using our Services, you agree to handle data in accordance with this Privacy Policy.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("References to “we” (or similar) in this Privacy Policy are references to Computer Data Corporation (Naqlee) and references to “you” or “user” are references to you as an individual or legal entity, as applicable",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Naqlee Application Terms of Use",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("1. Introduction",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. These terms set out the rules governing your use of the Naqlee application. By using the application, you agree to be bound by these terms.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("2. Modifications to the terms",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. We reserve the right to modify these terms at any time. You will be notified of any changes via the application or by email.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("3. Permitted Use",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("a. The application must be used only for lawful purposes.", textAlign: TextAlign.left,)),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                    child: Text("b. The application must not be used for fraudulent or abusive purposes.", textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("4. Account Creation",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("a.  You must create an account to use the application services.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                    child: Text("b.  You are responsible for maintaining the confidentiality of your account information.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("5. Services Provided",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. The Naqlee application provides transportation services, and you must comply with all instructions while using the service.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("6. Fees and Payment",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("a.  Fees may be imposed for transportation services.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("b.  All payments must be made through approved payment methods.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                    child: Text("c.  The customer must pay the dues and any breach or change thereof and all payments must be made through approved payment methods.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("7. Liability",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("a. Naqlee is not responsible for any damages resulting from the use of the application and during the transportation process and what happens between the carrier and the customer or the inability to use it.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                    child: Text("b. Naqlee is an intermediary institution between the carrier and the customer only. The carrier is obligated to provide the service in the required manner and not to tamper with or neglect the property and must preserve it. The user is obligated to provide the correct information to the carrier and also provide it through the Naqlee application or website.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("8. Termination of use",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. We may terminate or suspend your account at any time if you violate these terms or the terms governing the country in which you operate.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("9. Applicable law",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("a. These terms are subject to applicable laws.",
                    textAlign: TextAlign.left,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("10. Financial transactions",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. Naqlee is a platform for connecting customers and users and has the right to take a commission as it deems appropriate with the requirements of the work. This may include a deduction from the amount for partners due to bank transfer fees.",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("11. Contact us",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 8, 8),
                child: Text("a. If you have any questions regarding these terms, you can contact us via [sales@naqlee.com].",
                  textAlign: TextAlign.left,),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("1. What data may we collect from you?",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("We may collect and process the following data:",
                    textAlign: TextAlign.left,),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("a. Data that you provide by filling in forms on the Site, including data provided when registering to use the Site and other shared registrations (for example, social media logins), subscribing to our services, posting material or requesting other services.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("b. Data that you provide when entering a competition or promotion on our Site, completing a survey or poll, or providing reviews, testimonials or feedback.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("c. Data that you provide to us, or that we may collect from you, when you report any difficulty you are experiencing in using our Site.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("d. Correspondence records if you contact us.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("e. General, aggregated, demographic and non-personal data.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("f. If you download or use our mobile application, we may have access to details relating to your location and the location of your mobile device, including your device’s unique identifier.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("g. Details of transactions you have made through our Site and details of our processing and delivery of goods you have ordered.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("h. Details about your computer, including, for example, your IP address, operating system and browser type, as well as data relating to your general internet usage (for example, by using technology that stores or accesses data on your device, such as cookies, conversion tracking code, web beacons, etc. (collectively, “Cookies”)).",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("i. Your email address, which has been provided to us by third parties who have confirmed to us that they have obtained your consent to share your email address.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 8),
                    child: Text("j. Any other data we consider necessary to enhance your experience of using the Site.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("2. How will we use your data?",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("We may use data in the following circumstances:",
                    textAlign: TextAlign.left,),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("a. To provide you with information, products or services that you request from us or in which we think you may be interested, and where you have consented to being contacted for such purposes.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("b. To provide you with services based on where you are located, such as advertising, search results and other content tailored to you.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("c. To carry out obligations arising from any contracts entered into between you and any other party using our Site, or between you and us.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("d. To improve our services and to provide better and more personalized services.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("e. To ensure that our site content is presented in the most effective manner for you and the device you are using to access our site.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("f. To notify you of changes to our site.",
                        textAlign: TextAlign.left,),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("g. For any other reason we deem necessary to enhance your browsing experience on the site.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("h. To administer incentive programs and fulfill your requests for such incentives, and/or to allow you to participate in competitions and notify you if you win.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("3. What security measures do we apply?",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 0),
                    child: Text("a. We take the necessary technical, commercial, technical and administrative steps to ensure that data is treated securely and in accordance with this Privacy Policy, in order to protect data from unauthorized access, alteration, disclosure or destruction. For example, we may use encrypted electronic technology to protect data during transmission to our site, in addition to an external electronic firewall, and electronic firewall technology on the computer hosting our site so that we can repel malicious attacks on the network. Only employees, service providers and agents who need to know the data in order to carry out their work will be granted access to it.",
                      textAlign: TextAlign.left,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(40, 8, 8, 10),
                    child: Text("b. It is important for you to ensure that your password and the device you use to access our site are protected to prevent unauthorized access by third parties. You are solely responsible for keeping your password confidential, for example, by ensuring that you log out after each session.",
                      textAlign: TextAlign.left,),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        backgroundColor: Color(0xff6A66D1).withOpacity(0.6),
        onPressed: _scrollToTop,
        tooltip: 'Move to Top',
        child: Icon(Icons.arrow_upward,color: Colors.white,),
      ),
    );
  }
}
