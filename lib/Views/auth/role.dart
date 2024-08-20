import 'package:flutter/material.dart';
import 'package:flutter_naqli/Views/auth/register.dart';

class Role extends StatefulWidget {
  const Role({Key? key}) : super(key: key);

  @override
  State<Role> createState() => _RoleState();
}

class _RoleState extends State<Role> {
  int _selectedValue = 1;

  // Helper method to convert selected value to corresponding role string
  String _getRoleString(int value) {
    switch (value) {
      case 1:
        return 'enterprise';
      case 2:
        return 'multipleUnits';
      case 3:
        return 'singleUnit + operator';
      case 4:
        return 'operator';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.4,
        title: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/Joinus.jpg',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: 300,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Color(0xffFFFFFF),
                  child: Icon(
                    Icons.clear,
                    color: Colors.black,
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Choose your role',
              style: TextStyle(
                  fontSize: 35, color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.08,
              ),
              child: RadioListTile(
                title: const Text(
                  'Enterprise',
                  style: TextStyle(fontSize: 23),
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
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.08,
              ),
              child: RadioListTile(
                title: const Text(
                  'Multiple Units',
                  style: TextStyle(fontSize: 23),
                ),
                value: 2,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.08,
              ),
              child: RadioListTile(
                title: const Text(
                  'Single Unit + Operator',
                  style: TextStyle(fontSize: 23),
                ),
                value: 3,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.08,
              ),
              child: RadioListTile(
                title: const Text(
                  'Operator',
                  style: TextStyle(fontSize: 23),
                ),
                value: 4,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6A66D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    String selectedRole = _getRoleString(_selectedValue);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Register(
                          selectedRole: selectedRole,
                          partnerId: '',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.normal),
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
