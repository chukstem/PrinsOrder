import 'dart:async';
import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../helper/pusher.dart';
import '../../../models/user_model.dart';
import '../../../screens/notifications/notifications_page.dart';
import '../../../screens/profile/edit_profile_page.dart';
import '../../../screens/settings/kyc_page.dart';
import '../../../screens/settings/password_page.dart';
import '../../../screens/splash/welcome.dart';
import '../../../constants.dart';
import '../../../strings.dart';
import '../../../widgets/snackbar.dart';
import '../../chat/chat_screen.dart';
import '../../settings/pin_page.dart';
import 'profile_menu.dart';
import 'profile_pic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  _Body createState() => _Body();
}

class _Body extends State<Body> {
  String kyc_verified="0";

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      kyc_verified = prefs.getString("kyc_status")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      generalPusher(context)
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
            ),
            padding: EdgeInsets.only(top: 20),
            child: Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10),
              child: Center(child: Text(
                'Profile',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),),
            ),
          ),
          SizedBox(height: 20),
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "My Account",
            icon: "assets/icons/User Icon.svg",
            press: () => {
            Navigator.of(context).push(CupertinoPageRoute(builder: (context) => EditProfile()))
            },
          ),
          ProfileMenu(
            text: "Notifications",
            icon: "assets/icons/Bell.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          Notifications()));
            },
          ),
          ProfileMenu(
            text: "Change Password",
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          ChangePassword()));
            },
          ),
          ProfileMenu(
            text: "Change Pin",
            icon: "assets/icons/Settings.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          ChangePin()));
            },
          ),
          !kyc_verified.contains("Approved") ? ProfileMenu(
            text: "Kyc Verification",
            icon: "assets/icons/kyc.svg",
            press: () {
              Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) =>
                          KycScreen()));
            },
          ) : SizedBox(),
          ProfileMenu(
            text: "Chat Support",
            icon: "assets/icons/chat.svg",
            press: () {
              UserModel to=  new UserModel(id: "4545", username: Strings.app_name, first_name: "Customer", last_name: "Care", created_on: "", isFollowed: "", reviews: "0", trades: "", about: "", avatar: "",
                  phone: "",
                  service: "", cover: "", followers: "", following: "", rank: "", loading: false);
               Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ChatScreen(to: to)));
            },
          ),
          ProfileMenu(
            text: "Terms of Use",
            icon: "assets/images/policy.svg",
            press: () {
              _openLink(Strings.url+"/terms-of-use");
            },
          ),
          ProfileMenu(
            text: "Privacy Policy",
            icon: "assets/images/policy.svg",
            press: () {
              _openLink(Strings.url+"/privacy-policy");
            },
          ),
          ProfileMenu(
            text: "Deactivate Account",
            icon: "assets/images/deactivate.svg",
            press: () {
              delete(context);
            },
          ),
          ProfileMenu(
            text: "Log Out",
            icon: "assets/icons/Log out.svg",
            press: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  logout(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Get.offAllNamed(WelcomeScreen.routeName);
  }

  Future<void> _openLink(String link) async {
    Uri url=Uri.parse(link);
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  delete(BuildContext context) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Account Deactivation',
        titleColor: Colors.white,
        textColor: Colors.white,
        text: 'You will not be able to use this account again. Any saved data will be deleted from our server in the next 15 days.',
        confirmBtnText: 'Deactivate Now',
        cancelBtnText: 'Discard',
        confirmBtnColor: Colors.green,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          delete_account(context);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  delete_account(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Deleting',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/deactivate-account"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
          logout(context);
        }else{
          Navigator.pop(context);
          Snackbar().show(context, ContentType.failure, "Error!", jsondata["response_message"].toString());
        }

      }else{
        Navigator.pop(context);
        Snackbar().show(context, ContentType.failure, "Error!", "Connection error. Try again");
      }

    } catch (e) {
      Navigator.pop(context);
      Snackbar().show(context, ContentType.failure, "Error!", e.toString());
    }

  }


}
