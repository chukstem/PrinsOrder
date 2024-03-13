import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart'; 
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:pin_code_view/pin_code_view.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:chukstem/screens/splash/welcome.dart';
import 'package:toast/toast.dart'; 
import '../../components/coustom_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/material.dart';
import '../../widgets/snackbar.dart';


class PinScreen extends StatefulWidget {
  @override
  _PinUIState createState() => _PinUIState();
}


class _PinUIState extends State<PinScreen> {
  String msg="";
  bool error=false, showprogress=false;
  String pin="", errorText="";
  int count=0;

  void getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pin = prefs.getString("pin")!;
  }

  @override
  void initState() {
    getuser();
    super.initState();
  }

  void _saveSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access", "unlocked");
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => Dashboard()));
  }

  recoverPin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    var token = prefs.getString("token");
    String apiurl = Strings.url+"/reset-pin"; //api url
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Processing request...',
      );
      var response = null;
      Map data = {
        'email': email,
      };

      var body = json.encode(data);
      try {
        response = await http.post(Uri.parse(apiurl),
            headers: {
              "Content-Type": "application/json",
              "Authentication": "Bearer $token"},
            body: body
        );
        if (response != null && response.statusCode == 200) {
          try {
            var jsondata = json.decode(response.body);
            if (jsondata["status"] != null &&
                jsondata["status"].toString().contains("success")) {
              error=false;
              msg=jsondata["response_message"];
              prefs.setString("pin", jsondata["pin"]);

               pin=jsondata["pin"];
            }else if (jsondata["status"].toString().contains("error") &&
                jsondata["response_message"].toString().contains("Authentication")) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              Toast.show("Session Expired. Please login again", duration: Toast.lengthLong, gravity: Toast.bottom);
              Get.offAllNamed(WelcomeScreen.routeName);

            } else {
              error=true;
              msg=jsondata["response_message"];
            }
          } catch (e) {
            error=true;
            msg="Network connection error. $e";
          }
        } else {
          error=true;
          msg="Network connection error";
        }
      } catch (e) {
        error=true;
        msg="Network connection error! $e";
      }

    if(error!) {
      Snackbar().show(context, ContentType.failure, "Error!", msg!);
    }else{
      Snackbar().show(context, ContentType.success, "Success!", msg!);
    }
     Navigator.pop(context);
  }

  resetPin(){
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Seems you forgot your pin. Do you want to reset?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        showCancelBtn: true,
        confirmBtnColor: kPrimaryColor,
        onConfirmBtnTap: (){
          Navigator.pop(context);
          recoverPin();
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(bottom: 20),
          margin: const EdgeInsets.only(bottom: 20, top: 40),
        child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Container(
        height: 600,
        width: MediaQuery.of(context).size.width,
          child: PinCode(
            title: "Enter Security PIN",
            subtitle: "Enter your 4-digits security pin to unlock",
            backgroundColor: kPrimaryColor,
            codeLength: 4,
            error: errorText,
            keyboardType: KeyboardType.numeric,
            onChange: (String code) {
              setState(() {
                count=count+1;
              });
              if(code.length!=4){
                setState(() {
                  errorText="";
                });
              }else if(pin==code){
                setState(() {
                  errorText="Success!";
                });
                _saveSession();
              }else {
                setState(() {
                  errorText = "Incorrect Pin! ($count)";
                });
                if (count >= 6) {
                  logout();
                }else if (count > 4) {
                  resetPin();
                }
              }
            },
            obscurePin: true,
           ),
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: "Forgot Your Pin? ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  children: const [
                    TextSpan(
                        text: "Reset Now",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          color: yellow100,
                        )),
                  ],
                ),
              ),
            ),
            onTap: () {
              resetPin();
            },
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              width: MediaQuery.of(context).size.width*0.70,
              padding: const EdgeInsets.only(
                  bottom: 2, left: 2, right: 2, top: 2),
              decoration: BoxDecoration(
                  borderRadius: circularRadius(AppRadius.border12),
                  color: kPrimaryLightColor
              ),
              child: OutlinedButton(
                child: Text(
                  'Logout this Session',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: (){
                  logout();
                },
              )),
          SizedBox(
            height: 10,
          ),
        ],
       ),
      ),
      ),
    );
  }

  logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(WelcomeScreen.routeName);
  }

}
