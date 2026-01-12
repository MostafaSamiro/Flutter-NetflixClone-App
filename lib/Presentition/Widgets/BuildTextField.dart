import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Provider/AuthProvider.dart';

Widget buildEmailField(TextEditingController emailController,BuildContext context) {
  final AuthProvider = Provider.of<AuthFireBase>(context);
  return Container(
    width: 75.w,
    height: 6.h,
    decoration: BoxDecoration(
      color: const Color(0xff333333),
      borderRadius: BorderRadius.circular(5),
    ),
    child: TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        border: const UnderlineInputBorder(borderSide: BorderSide.none),
        hintText: "Enter Your Email",
        contentPadding: EdgeInsets.only(left: 2.w),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 15.sp,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }

        final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email address';
        }

        if(value.isNotEmpty){
          AuthProvider.email = emailController.text;
        }

        return null;
      },
    ),
  );
}

class PasswordField extends StatefulWidget {
  TextEditingController passwordController;

   PasswordField({super.key,required this.passwordController});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;


  @override
  Widget build(BuildContext context) {
    final AuthProvider = Provider.of<AuthFireBase>(context);

    return Container(
      width: 75.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: const Color(0xff333333),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        obscureText: _obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
        controller: widget.passwordController,
        decoration: InputDecoration(

          border: const UnderlineInputBorder(borderSide: BorderSide.none),
          hintText: "Password",
          contentPadding: EdgeInsets.only(left: 2.w,top: 1.5.h),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.7),
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        validator: (value) {

          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if(value.isNotEmpty){
            AuthProvider.password = widget.passwordController.text;


          }
          return null;
        },
      ),
    );
  }
}

