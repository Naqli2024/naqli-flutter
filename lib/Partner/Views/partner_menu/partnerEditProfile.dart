import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/commonWidgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/partner_menu/EditOperator.dart';

class PartnerEditProfile extends StatefulWidget {
  final String partnerName;
  final String partnerId;
  final String token;
  final String email;
  const PartnerEditProfile({super.key, required this.partnerName, required this.partnerId, required this.token, required this.email});

  @override
  State<PartnerEditProfile> createState() => _PartnerEditProfileState();
}

class _PartnerEditProfileState extends State<PartnerEditProfile> with SingleTickerProviderStateMixin {
  final CommonWidgets commonWidgets = CommonWidgets();
  File? _profileImage;
  String? partnerEmailId;
  String? partnerMobileNo;
  String? partnerName;
  String? partnerCity;
  String? partnerCompany;
  String? partnerIban;
  String? partnerRegion;
  String? partnerBank;
  String? partnerCompanyName;
  String? partnerLegalName;
  String? partnerPhoneNo;
  String? partnerAltNo;
  String? partnerAddress;
  String? partnerCityName;
  String? partnerZipCode;
  String? partnerCompanyType;
  String? partnerCompanyId;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController IBANController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController legalNameController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController altNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController companyTypeController = TextEditingController();
  final TextEditingController companyIdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  final AuthService authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchBookingDetails().then((data) {
      nameController.text = partnerName??'';
      mobileNoController.text = partnerMobileNo??'';
      emailController.text = partnerEmailId??'';
      cityController.text = partnerCity??'';
      companyController.text = partnerCompany??'';
      IBANController.text = partnerIban??'';
      bankNameController.text = partnerBank??'';
      regionController.text = partnerRegion??'';
      companyNameController.text = partnerCompanyName??'';
      legalNameController.text = partnerLegalName??'';
      phoneNoController.text = partnerPhoneNo??'';
      altNumberController.text = partnerAltNo??'';
      addressController.text = partnerAddress??'';
      cityNameController.text = partnerCityName??'';
      zipcodeController.text = partnerZipCode??'';
      companyTypeController.text = partnerCompanyType??'';
      companyIdController.text = partnerCompanyId??'';
    }).catchError((e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    });
  }

  Future<List<Map<String, dynamic>>> fetchBookingDetails() async {
    try {
      final bookingIds = await authService.getBookingData(widget.partnerId, widget.token);
      if (bookingIds.isEmpty) {
        return [];
      }

      final bookingDetails = <Map<String, dynamic>>[];

      for (var booking in bookingIds) {
        final name = booking['name'] ?? 'Unknown Partner';
        final mobileNo = booking['mobileNo'] ?? 'No Mobile Number';
        final email = booking['email'] ?? 'No Email Address';
        final city = booking['city'] ?? 'No City';
        final company = booking['company'] ?? '';
        final iban = booking['ibanNumber'] ?? '';
        final region = booking['region'] ?? '';
        final bank = booking['bank'] ?? '';
        final companyDetails = booking['companyDetails'] ?? [];

        partnerName = name;
        partnerMobileNo = mobileNo;
        partnerEmailId = email;
        partnerCity = city;
        partnerCompany = company;
        partnerIban = iban;
        partnerRegion = region;
        partnerBank = bank;

        for (var companyDetail in companyDetails) {
          partnerCompanyName = companyDetail['companyName'] ?? '';
          partnerLegalName = companyDetail['legalName'] ?? '';
          partnerPhoneNo = companyDetail['phoneNumber']?.toString() ?? '';
          partnerAltNo = companyDetail['alternativeNumber']?.toString() ?? '';
          partnerAddress = companyDetail['address'] ?? '';
          partnerCityName = companyDetail['cityName'] ?? '';
          partnerZipCode = companyDetail['zipCode']?.toString() ?? '';
          partnerCompanyType = companyDetail['companyType'] ?? '';
          partnerCompanyId = companyDetail['companyIdNo']?.toString() ?? '';

          bookingDetails.add({
            'partnerName': partnerName,
            'partnerMobileNo': partnerMobileNo,
            'partnerEmailId': partnerEmailId,
            'partnerCity': partnerCity,
            'partnerCompany': partnerCompany,
            'partnerIban': partnerIban,
            'partnerRegion': partnerRegion,
            'partnerBank': partnerBank,
            'companyName': partnerCompanyName,
            'legalName': partnerLegalName,
            'phoneNo': partnerPhoneNo,
            'alternativeNo': partnerAltNo,
            'address': partnerAddress,
            'cityName': partnerCityName,
            'zipCode': partnerZipCode,
            'companyType': partnerCompanyType,
            'companyId': partnerCompanyId,
          });
        }

        if (companyDetails.isEmpty) {
          bookingDetails.add({
            'partnerName': partnerName,
            'partnerMobileNo': partnerMobileNo,
            'partnerEmailId': partnerEmailId,
            'partnerCity': partnerCity,
            'partnerCompany': partnerCompany,
            'partnerIban': partnerIban,
            'partnerRegion': partnerRegion,
            'partnerBank': partnerBank,
          });
        }
      }
      return bookingDetails;
    } catch (e) {
      return [];
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
          User: widget.partnerName,
          showLeading: false,
          userId: widget.partnerId,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130.0),
            child: Column(
              children: [
                AppBar(
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
                            'Edit Profile'.tr(),
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
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Edit Profile'.tr()),
                    Tab(text: 'Edit Operator'.tr()),
                    Tab(text: 'Company Details'.tr()),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              maxRadius: viewUtil.isTablet?60:50,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? Icon(Icons.person, color: Color(0xff6A66D1), size: viewUtil.isTablet?70:60)
                                  : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 1,
                          child: GestureDetector(
                            onTap: pickProfileImage,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: CircleAvatar(
                                maxRadius: viewUtil.isTablet?20:15,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.edit, color: Colors.black, size: viewUtil.isTablet?20: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        commonWidgets.buildTextField('Partner Name'.tr(), nameController,context: context),
                        commonWidgets.buildTextField('Mobile No'.tr(), mobileNoController,context: context),
                        commonWidgets.buildTextField('Email Address'.tr(), emailController,context: context),
                        commonWidgets.buildTextField('Password'.tr(), passwordController,obscureText: isPasswordObscured,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordObscured = !isPasswordObscured;
                                });
                              },
                            ),context: context),
                        commonWidgets.buildTextField('Confirm Password'.tr(), confirmPasswordController,obscureText: isConfirmPasswordObscured,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordObscured = !isConfirmPasswordObscured;
                                });
                              },
                            ),context: context),
                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Bank Details'.tr(),
                              style: TextStyle(fontSize: viewUtil.isTablet ?26 :24, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        commonWidgets.buildTextField('City'.tr(), cityController,context: context),
                        commonWidgets.buildTextField('Company'.tr(), companyController,context: context),
                        commonWidgets.buildTextField('IBAN'.tr(), IBANController,context: context),
                        commonWidgets.buildTextField('Region'.tr(), regionController,context: context),
                        commonWidgets.buildTextField('Bank Name'.tr(), bankNameController,context: context),
                        Container(
                          margin: const EdgeInsets.only(top:20,bottom: 20),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.057,
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff6269FE),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await authService.updatePartnerProfile(
                                      widget.partnerId,
                                      widget.token,
                                      _profileImage,
                                      nameController.text,
                                      mobileNoController.text,
                                      emailController.text,
                                      passwordController.text,
                                      confirmPasswordController.text,
                                      cityController.text,
                                      companyController.text,
                                      IBANController.text,
                                      regionController.text,
                                      bankNameController.text
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: Text(
                                  'Save'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: viewUtil.isTablet?25: 18,
                                    fontWeight: FontWeight.w500,),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              child: EditOperator(partnerId: widget.partnerId,partnerName: widget.partnerName),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      commonWidgets.buildTextField('Company'.tr(), companyNameController,context: context),
                      commonWidgets.buildTextField('Legal Name'.tr(), legalNameController,context: context),
                      commonWidgets.buildTextField('Phone No'.tr(), phoneNoController,context: context),
                      commonWidgets.buildTextField('Alternate Number'.tr(), altNumberController,context: context),
                      commonWidgets.buildTextField('Address'.tr(), addressController,context: context),
                      commonWidgets.buildTextField('City'.tr(), cityNameController,context: context),
                      commonWidgets.buildTextField('Zipcode'.tr(), zipcodeController,context: context),
                      commonWidgets.buildTextField('Company Type'.tr(), companyTypeController,context: context),
                      commonWidgets.buildTextField('Company Id No'.tr(), companyIdController,context: context),
                      Container(
                        margin: const EdgeInsets.only(top:20,bottom: 20),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.057,
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6269FE),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await authService.addCompanyDetails(
                                  context,
                                   widget.partnerId,
                                   companyNameController.text,
                                  legalNameController.text,
                                  phoneNoController.text,
                                  altNumberController.text,
                                  addressController.text,
                                  cityNameController.text,
                                  zipcodeController.text,
                                  companyTypeController.text,
                                  companyIdController.text
                                );
                                setState(() {
                                  isLoading = false;
                                });
                              },
                              child: Text(
                                'Save'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: viewUtil.isTablet?25: 18,
                                  fontWeight: FontWeight.w500,),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickProfileImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _profileImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      commonWidgets.showToast('An error occurred,Please try again.');
    }
  }
}
