import 'package:flutter/material.dart';
import 'package:flutter_naqli/Views/auth/register.dart';

class Role extends StatefulWidget {
  const Role({Key? key}) : super(key: key);

  @override
  State<Role> createState() => _RoleState();
}

int _selectedValue = 1;

class _RoleState extends State<Role> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.4,
        title: Stack(
          children: [
            Container(
                alignment: Alignment.center,
                // height: 330,
                child: Image.asset(
                  'assets/Joinus.jpg',
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                )),
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
                  )),
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
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
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
                  'Single Unit + operator',
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
              padding: const EdgeInsets.all(8.0),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()));
                    },
                    child: const Text(
                      'Next',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
