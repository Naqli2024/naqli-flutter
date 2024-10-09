import 'package:flutter/material.dart';
import 'package:flutter_naqli/Partner/Viewmodel/services.dart';

class Register extends StatefulWidget {
  final String selectedRole;
  final String partnerId;
  final String token;

  const Register({Key? key, required this.selectedRole, required this.partnerId, required this.token}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

final TextEditingController nameController = TextEditingController();
final TextEditingController mobileController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final AuthService _authService = AuthService();
bool isLoading = false;
bool isPasswordObscured = true;

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
      setState(() {
        isLoading = true;
      });
        await _authService.registerUser(
          context,
          partnerName: nameController.text,
          mobileNo: mobileController.text,
          email: emailController.text,
          password: passwordController.text,
          role: widget.selectedRole,
          partnerId: widget.partnerId,
          token: ''
        );
        setState(() {
          isLoading = false;
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
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
              Container(
                margin: const EdgeInsets.fromLTRB(30, 15, 30, 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Password',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordObscured,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordObscured ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6269FE),
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
