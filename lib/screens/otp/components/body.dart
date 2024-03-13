import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chukstem/constants.dart';
import 'package:chukstem/size_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../strings.dart';
import '../../../widgets/snackbar.dart';
import 'otp_form.dart';

class Body extends StatefulWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  resendOtp(BuildContext context) async {
    String apiurl = Strings.url+"/resend";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = null;
    try {
      QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryColor,
        textColor: Colors.white,
        titleColor: Colors.white,
        type: QuickAlertType.loading,
        title: 'Processing request',
        text: 'Please wait...',
        barrierDismissible: false,
      );
      Map data = {
        'email': prefs.getString("email"),
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer Access0987654321"},
          body: body
      );

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata["status"].toString().contains("success")) {
        setState(() {
          success = true;
        });
      }
      setState(() {
        showprogress = false; //don't show progress indicator
        error = false;
        errormsg = jsondata["response_message"];
      });
    } else {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Network connection error";
      });
    }
    Navigator.pop(context);
    if (error!) {
      Snackbar().show(context, ContentType.failure, "Error!", errormsg);
    }else{
      Snackbar().show(context, ContentType.success, "Success!", errormsg);
    }

    } catch (e) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Network connection error ";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Text(
                "OTP Verification",
                style: headingStyle,
              ),
              Text("We sent your code to your email"),
              Text("Please check your inbox/spam folder"),
              OtpForm(),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              GestureDetector(
                onTap: () {
                  if(!showprogress) {
                    setState(() {
                      success=false;
                      showprogress = true;
                      error=false;
                    });
                    resendOtp(context);
                  }
                },
                child: Text(
                  "Resend OTP Code",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row buildTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This code will expired in "),
        TweenAnimationBuilder(
          tween: Tween(begin: 30.0, end: 0.0),
          duration: Duration(seconds: 30),
          builder: (_, dynamic value, child) => Text(
            "00:${value.toInt()}",
            style: TextStyle(color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
