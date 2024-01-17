import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_app/components/custom_surfix_icon.dart';
import 'package:crypto_app/components/default_button.dart';
import 'package:crypto_app/components/form_error.dart';
import 'package:crypto_app/screens/otp/otp_screen.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import '../../../strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../widgets/material.dart';
import '../../../widgets/snackbar.dart';

class CompleteProfileForm extends StatefulWidget {
  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class Item{
  const Item(this.name);
  final String name;
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String?> errors = [];
  String? firstName="";
  String? lastName="";
  String? password="";
  String? confirm_password="";
  String referral="";
  String errormsg="Login to continue";
  bool error=false, success=false, showprogress=false;

  List<Item> genders=<Item>[
    const Item('Select Gender'),
    const Item('Male'),
    const Item('Female'),
  ];

  Item? gender;



  startReg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString("temp_username")!;
    String email = prefs.getString("temp_email")!;
    String number = prefs.getString("temp_number")!;
    if (username.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Username";
      });
    } else if (email.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Email";
      });
    } else if (number.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Number";
      });
    } else if (number.length != 11) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Number must be 11 digits";
      });
    } else if (firstName!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Firstname";
      });
    } else if (lastName!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Lastname";
      });
    } else if (password!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Old Password";
      });
    } else if (confirm_password!.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Old Password";
      });
    } else if (gender==null || gender!.name.contains("Select")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Select Gender";
      });
    } else if (password != confirm_password!) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Passwords not match";
      });
    } else {
      setState(() {
        showprogress=true;
      });
      String apiurl = Strings.url + "/complete-register";
      var response;

      try {
        Map data = {
          'username': username.trim(),
          'first_name': firstName!.trim(),
          'last_name': lastName!.trim(),
          'email': email.trim(),
          'referral': referral.trim(),
          'mobile': number.trim(),
          'password': password!.trim(),
          'gender': gender!.name,
          'country': 'Nigeria',
          'password_confirmation': confirm_password!.trim()
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
            error = false;
            showprogress = false;
            success = true;
            errormsg = jsondata["response_message"];
          });
          prefs.setString("firstname", firstName!);
          prefs.setString("lastname", lastName!);
          prefs.setString("number", number);
          prefs.setString("email", email);
          prefs.setString("username", username);
        } else {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = jsondata["response_message"];
          });
        }
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Network connection error";
        });
      }

      } catch (e) {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Network connection error ";
        });
       }
      }

    if (error!) {
      Snackbar().show(context, ContentType.failure, "Error!", errormsg);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, OtpScreen.routeName, (route) => false,);
      Snackbar().show(context, ContentType.success, "Success!", errormsg);
    }

  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          error? Container(
            //show error message here
            margin: EdgeInsets.only(bottom:10),
            padding: EdgeInsets.all(10),
            child: errmsg(errormsg, success, context),
            //if error == true then show error message
            //else set empty container as child
          ) : Container(),
          SizedBox(
            height: 10,
          ),
          buildFirstNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildLastNameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildConfirmPassFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildGenderFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildReferralFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          showprogress? Center(child: SizedBox(
            height:40, width:40,
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          ),) :
          DefaultButton(
            text: "Submit",
            press: () {
                if(!showprogress) {
                  startReg();
              }
            },
          ),
        ],
      ),
    );
  }


  TextFormField buildConfirmPassFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        confirm_password = value;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }


  Container buildGenderFormField() {
    return Container(
        alignment: Alignment.center,
        height: 60,
        child: DropdownButtonFormField<Item>(
          isExpanded: true,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              hintText: "Select Gender",
              labelText: "Select Gender",
              hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
              fillColor: Colors.white
          ),
          hint: const Text('Select Gender'),
          value: gender,
          onChanged: (Item? value){
            gender = value;
          },
          items: genders.map((Item item){
            return DropdownMenuItem<Item>(value: item, child: Container(
              width: MediaQuery.of(context).size.width-20,
              height: 40,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),),
              child: Text(item.name, overflow: TextOverflow.ellipsis, maxLines: 1, style: TextStyle(color: Colors.black), textAlign: TextAlign.left),
            ),);
          }).toList(),
        )
    );
  }


  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onChanged: (value) {
        password = value;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }


  TextFormField buildLastNameFormField() {
    return TextFormField(
      onChanged: (value) {
        if (value.isNotEmpty) {
          lastName = value;
        }
      },
      decoration: InputDecoration(
        labelText: "Last Name",
        hintText: "Enter your last name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildReferralFormField() {
    return TextFormField(
      onChanged: (value){
        referral=value;
      },
      decoration: InputDecoration(
        labelText: "Referral (optional)",
        hintText: "Referral (optional)",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildFirstNameFormField() {
    return TextFormField(
      onSaved: (newValue) => firstName = newValue,
      onChanged: (newValue) {
        firstName = newValue;
      },
      decoration: InputDecoration(
        labelText: "First Name",
        hintText: "Enter your first name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
