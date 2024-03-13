import 'package:flutter/material.dart';
import 'package:chukstem/size_config.dart';

const List<Color> indicators = [
  Color(0xffFED2C7),
  Color(0xffFED2C7),
  Color(0xff886b07),
  Color(0xffce8b27),
  Color(0xffab7d07),
];

const Color yellow100 = Color(0xfff89503);
const Color yellow80 = Color(0xfff89503);
const Color yellow50 = Color(0xffFFDF8B);
const Color yellow20 = Color(0xffFFEFC3);

const kWhite = Color(0xfff3f4f5);
const kPrimary = Color(0xFF1F97C9);
const kSecondary = Color(0xffffffff);
const kPrimaryColor = Color(0xFF1F97C9);
const kPrimaryDarkColor = Color(0xFF1F97C9);
const kPrimaryLightColor = Color(0xFF1F97C9);
const kPrimaryVeryLightColor = Color(0xFF58B4DA);
const kPrimaryVeryVeryLightColor = Color(0xFFEFF6FC);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1F97C9), Color(0xFFF6B205)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kUsernameNullError = "Please Enter your username";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kInvalidNumberError = "Please Enter Valid Phone Number";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short. At least 5 characters";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}
