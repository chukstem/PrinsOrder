import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/constants.dart';
import 'package:toast/toast.dart';

import '../../components/coustom_bottom_nav_bar.dart';
import '../../strings.dart';
import '../../widgets/snackbar.dart';
import '../splash/welcome.dart';

class setPin extends StatefulWidget {
  @override
  _setPinState createState() => _setPinState();
}

class _setPinState extends State<setPin> {


  String msg="", new_Pin="", confirm_Pin="";
  bool? error=false, showprogress=false;

  start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username=prefs.getString("username");
    String? email=prefs.getString("email");
    String? token=prefs.getString("token");

    if (new_Pin.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Enter New Pin";
      });
    } else if (confirm_Pin.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Enter Confirm Pin";
      });
    } else if (new_Pin!=confirm_Pin) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        msg = "Pins not match";
      });
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Processing request...',
      );
      String apiurl = Strings.url+"/change-pin";
      var response = null;
      try {
        Map data = {
          'email': email,
          'old_pin': '1234',
          'pin': new_Pin,
          'pin_confirmation': confirm_Pin
        };
        var body = json.encode(data);
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          msg = "Network connection error ";
        });
        Navigator.pop(context);
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {

          prefs.setString("pin", new_Pin);
          prefs.setString("access", "unlocked");
          setState(() {
            showprogress = false; //don't show progress indicator
            error = false;
            msg = jsondata["response_message"];
          });
        }else if (jsondata["status"].toString().contains("error") &&
            jsondata["response_message"].toString().contains("Authentication")) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Toast.show("Session Expired. Please login again", duration: Toast.lengthLong, gravity: Toast.bottom);
          Get.offAllNamed(WelcomeScreen.routeName);

        }else{
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            msg = jsondata["response_message"];
          });
        }
        Navigator.pop(context);
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          msg = "Network connection error";
        });
        Navigator.pop(context);
      }
    }

    if(error!) {
      Snackbar().show(context, ContentType.failure, "Error!", msg!);
    }else{
      Snackbar().show(context, ContentType.success, "Success!", msg!);
      Navigator.pushAndRemoveUntil<dynamic>(
        context, MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => Dashboard(),), (
          route) => false,);
    }
  }

  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: PinCode(
        title: "Set New Security PIN",
        subtitle: "Enter a 4-digit pin to secure your account",
        backgroundColor: kPrimaryColor,
        codeLength: 4,
        error: msg,
        keyboardType: KeyboardType.numeric,
        onChange: (String code) {
          if(code.length!=4){
            setState(() {
              msg="Pin must be 4 digits";
            });
          }else{
            new_Pin=code;
            confirm_Pin=code;
            start();
          }
        },
        obscurePin: false,
      ),
    );
  }

}
