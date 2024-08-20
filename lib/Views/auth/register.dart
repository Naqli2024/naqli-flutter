import 'package:flutter/material.dart';
import 'package:flutter_naqli/Viewmodel/services.dart';

class Register extends StatefulWidget {
  final String selectedRole;
  final String partnerId;

  const Register({Key? key, required this.selectedRole, required this.partnerId}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

final TextEditingController nameController = TextEditingController();
final TextEditingController mobileController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final AuthService _authService = AuthService();
bool isLoading = false;

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>(); // Global key for form validation

  Future<void> _submitForm() async {
      setState(() {
        isLoading = true;
      });
        _authService.registerUser(
          context,
          partnerName: nameController.text,
          mobileNo: mobileController.text,
          email: emailController.text,
          password: passwordController.text,
          role: widget.selectedRole,
          partnerId: widget.partnerId
        );
        setState(() {
          isLoading = false;
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.31,
        title: Stack(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/Register.jpg',
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                )),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0),
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
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildTextField(
                context: context,
                controller: nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                context: context,
                controller: mobileController,
                label: 'Mobile No',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                context: context,
                controller: emailController,
                label: 'Email Id',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              _buildTextField(
                context: context,
                controller: passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Container(
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
                      if (_formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            validator: validator, // Add the validator here
          ),
        ],
      ),
    );
  }
}
