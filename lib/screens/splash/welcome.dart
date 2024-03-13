import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chukstem/constants.dart';
import 'package:chukstem/screens/sign_up/sign_up_screen.dart';

import '../../size_config.dart';
import '../sign_in/sign_in_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/welcome";
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
           SizedBox(height:  MediaQuery.of(context).size.height*0.25,),
            Center(
              child: SizedBox(
                height: 270,
                width: 370,
                child: Image.asset("assets/images/onboard.png"),
              ),
              ),
              SizedBox(height:  MediaQuery.of(context).size.height*0.10,),
              Container(
                height: 60,
                  width: MediaQuery.of(context).size.width*0.90,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0), bottomRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0)),
                      color: Colors.white
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      side: BorderSide(width: 0, color: Colors.white),
                      minimumSize: const Size.fromHeight(
                          50), // fromHeight use double.infinity as width and 40 is the height
                    ),
                    child: Text(
                      'Create New Account',
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: (){
                      Navigator.pushNamed(context, SignUpScreen.routeName);
                    },
                  )),
              SizedBox(height: 15,),
              InkWell(
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Already Have An Account?  ",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(
                            text: "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
              ),
              SizedBox(height: 15,),
           ],
         ),
      ),
    );
  }

}