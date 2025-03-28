import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/viewUtil.dart';
import 'package:flutter_naqli/Partner/Views/auth/register_step_one.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;

class Role extends StatefulWidget {
  const Role({Key? key}) : super(key: key);

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {
  int _selectedValue = 1;

  String _getRoleString(int value) {
    switch (value) {
      case 1:
        return 'singleUnit + operator';
      case 2:
        return 'multipleUnits';
      case 3:
        return 'enterprise';
      case 4:
        return 'operator';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: MediaQuery.of(context).size.height * 0.4,
          title: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/joinUs.svg',
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: viewUtil.isTablet
                      ?MediaQuery.of(context).size.height * 0.35
                      :MediaQuery.of(context).size.height * 0.3,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(0xffFFFFFF),
                      child: Icon(
                        Icons.clear,
                        color: Colors.black,
                        size: viewUtil.isTablet?26: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Choose your role'.tr(),
                style: TextStyle(
                    fontSize: viewUtil.isTablet?35:30, color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.13,
                ),
                child: RadioListTile(
                  title: Text(
                    'Single Unit + Operator'.tr(),
                    style: TextStyle(fontSize: viewUtil.isTablet?26:20,color: Color(0xff707070)),
                  ),
                  value: 1,
                  groupValue: _selectedValue,
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.11,
          child: Container(
            margin: const EdgeInsets.fromLTRB(60, 0, 60, 20),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6269FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  String selectedRole = _getRoleString(_selectedValue);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterStepOne(
                        selectedRole: selectedRole,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Next'.tr(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: viewUtil.isTablet?27:18,
                      fontWeight: FontWeight.w500),
                )),
          ),
        ),
      ),
    );
  }
}
