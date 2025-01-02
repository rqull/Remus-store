import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mob3_uas_klp_04/views/screens/authentification_screens/register_screen.dart';

import '../../../vendor/views/auth/vendor_register_screen.dart';
import '../../controller/vendor_auth_controller.dart';
import '../screens/main_vendor_screen.dart';

class VendorLoginScreen extends StatefulWidget {
  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final VendorAuthController _authController = VendorAuthController();
  bool _isLoading = false;
  bool _isPasswordVisibility = false;

  late String email;
  late String password;

  loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await _authController.loginUser(email, password);

    if (res == 'success') {
      // go to the main screen
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const MainVendorScreen();
          },
        ));

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logged in')));
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res)));
      });
    }
  }

  void _showResetPasswordDialog() {
    String resetEmail = '';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Enter your email to receive a password reset link'),
                  SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      resetEmail = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                    ),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (resetEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please enter your email')),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          String res =
                              await _authController.resetPassword(resetEmail);

                          setState(() {
                            isLoading = false;
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res)),
                          );
                        },
                  child: Text('Reset Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login Vendor Account",
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                      color: Color(0xFF0D120E),
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      letterSpacing: 0.2,
                    )),
                  ),
                  Text(
                    "To Explore the world exclusives",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: Color(0xFF0D120E),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/Illustration.png',
                    width: 200,
                    height: 200,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Email",
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your Email',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Password",
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      } else {
                        return null;
                      }
                    },
                    obscureText: !_isPasswordVisibility,
                    decoration: InputDecoration(
                      hintText: 'Enter your Password',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisibility = !_isPasswordVisibility;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showResetPasswordDialog();
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        loginUser();
                      } else {
                        print("Failed");
                      }
                    },
                    child: Container(
                      width: 319,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF102DE1),
                            Color(0xCC0D6EFF),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 278,
                            top: 19,
                            child: Opacity(
                              opacity: 0.5,
                              child: Container(
                                width: 60,
                                height: 60,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 12,
                                      color: Color(0xFF103DE5),
                                    ),
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 29,
                            child: Opacity(
                              opacity: 0.5,
                              child: Container(
                                width: 10,
                                height: 10,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Color(0XFF2141E5),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 311,
                            top: 36,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 5,
                                height: 5,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 281,
                            top: -10,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 20,
                                height: 20,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          Center(
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Sign In",
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Need an Account?",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) {
                              return RegisterScreen();
                            },
                          ));
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFF103DE5),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Become a Vendor?",
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (context) {
                              return const VendorRegisterScreen();
                            },
                          ));
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                                color: Color(0xFF103DE5),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
