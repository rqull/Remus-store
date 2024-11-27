import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mob3_uas_klp_04/controllers/auth_controller.dart';
import 'package:mob3_uas_klp_04/views/screens/authentification_screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  late String email;
  late String fullName;
  late String password;

  registerUser() async {
    BuildContext locaContext = context;
    String res =
        await _authController.registerNewUser(fullName, email, password);

    if (res == 'success') {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(locaContext, MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ));
        ScaffoldMessenger.of(locaContext).showSnackBar(SnackBar(
            content: Text("Congratulation account have been create for you")));
      });
    } else {}
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
                    "Create Your Account",
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
                      "Full Name",
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
                      fullName = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your Full Name';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your Full Name",
                      labelStyle: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/user.jpeg',
                          width: 20,
                          height: 20,
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
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your Email';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your Email",
                      labelStyle: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
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
                        return 'Enter your Password';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: "Enter your Password",
                      labelStyle: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/password.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
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
                            child: Text(
                              "Sign Up",
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
                        "Already have an Account?",
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
                              return LoginScreen();
                            },
                          ));
                        },
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
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
