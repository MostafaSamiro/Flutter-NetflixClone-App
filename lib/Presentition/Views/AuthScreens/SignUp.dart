import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildSmoothNavigates.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../Provider/AuthProvider.dart';
import '../../Widgets/BuildTextField.dart';
import '../../Widgets/BuildTexts.dart';
import 'LoginScreen.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final AuthProvider = Provider.of<AuthFireBase>(context);


    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/MoviesPosters.png"),fit: BoxFit.cover)
        ),child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.w,
            height: 50.h,
            decoration: BoxDecoration(
                border: Border.all(width: 0.5.w,color: Color(0xff564d4d)),
                borderRadius: BorderRadius.circular(20),
                color: Color(0xff010100).withOpacity(0.7)
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  SizedBox(height: 5.h,),
                  Row(
                    children: [
                      SizedBox(width: 5.w,),

                      buildTexts(
                          "Sign Up",
                          Colors.white,
                          21,
                          FontWeight.bold

                      )
                    ],
                  ),
                  SizedBox(height: 2.h,),

                  buildEmailField(emailController,context),
                  SizedBox(height: 2.h,),

                  PasswordField(passwordController: passwordController,),

                  SizedBox(height: 5.h,),
                  InkWell(
                      onTap: isLoading
                          ? null
                          : () async {
                        if (!_formKey.currentState!.validate()) return;

                        setState(() {
                          isLoading = true;
                        });

                        await Future.delayed(const Duration(milliseconds: 100)); // ⭐ KEY LINE

                        final success = await AuthProvider.createUserWithEmailAndPassword(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          context
                        );

                        setState(() {
                          isLoading = false;
                        });

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Email Created Successfully",style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp
                            ),),backgroundColor: Colors.green,),
                          );
                          navigateWithTransitionPushAndRemoveUntil(context, Login());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Sign Up failed")),
                          );
                        }
                      },

                    child: Container(
                      width: 75.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: const Color(0xffe50913),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: isLoading
                            ?  SpinKitWave(
                          color: Colors.white,
                          size: 5.w,
                        )
                            : buildTexts(
                          "Sign Up",
                          Colors.white,
                          16,
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 5.h,),
                  Row(
                    children: [
                      SizedBox(width:8.w,),

                      RichText(
                        text: TextSpan(
                          text: 'Already have account? ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: Color(0xffe50913),
                                fontWeight: FontWeight.normal,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  navigateWithTransitionPushAndRemoveUntil(context, Login());
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )








                ],
              ),
            ),
          )

        ],
      ),

      ),
    );
  }
}
