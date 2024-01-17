import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
 
import '../../constants.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../splash/welcome.dart';

class SaveNextKin extends StatefulWidget {
  @override
  _SaveNextKinState createState() => _SaveNextKinState();
}

InputDecoration myInputDecoration({required String label, required IconData icon}){
  return InputDecoration(
    hintText: label,
    hintStyle: TextStyle(color:Colors.black87, fontSize:15), //hint text style
    prefixIcon: Padding(
        padding: EdgeInsets.only(left:20, right:10),
        child:Icon(icon, color: Colors.blue[100],)
      //padding and icon for prefix
    ),

    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color:Colors.white, width: 0)
    ), //default border of input

    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color:Colors.white, width: 0)
    ), //focus border

    fillColor: Colors.white,
    filled: false, //set true if you want to show input background
  );
}

class Item{
  const Item(this.name);
  final String name;
}


class _SaveNextKinState extends State<SaveNextKin> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  String email="", firstname="", lastname="", number="", token="", username="", state="", address="";

  List<Item> items=<Item>[
    const Item('Select Relationship'),
    const Item('Father'),
    const Item('Mother'),
    const Item('Brother'),
    const Item('Sister'),
    const Item('Spouse'),
    const Item('Uncle'),
    const Item('Aunty'),
    const Item('Nephew'),
    const Item('Niece'),
    const Item('Cousin'),
  ];

  Item? item;

  Save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username")!;
    token = prefs.getString("token")!;
    if (firstname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin First Name";
      });
    } else if (lastname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin Last Name";
      });
    } else if (number.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin Number";
      });
    }  else if (email.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin Email";
      });
    } else if (address.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin Address";
      });
    } else if (state.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Next of Kin State";
      });
    } else if (item==null || item!.name.contains("Select")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Select Next of Kin Relationship";
      });
    }else {
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/add-next-kin";
      var response = null;
      try {
         Map data = {
          'username': username,
          'email': email,
          'first_name': firstname.trim(),
          'last_name': lastname.trim(),
          'address': address.trim(),
          'state': state.trim(),
          'number': number.trim(),
          'relationship': item!.name
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
          errormsg = "Network connection error! $e";
        });
      }
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          setState(() {
            success = true;
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = jsondata["response_message"];
          });
        }else if (jsondata["status"].toString().contains("error") &&
            jsondata["response_message"].toString().contains("Authentication")) {

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.clear();
          Toast.show("Session Expired. Please login again", duration: Toast.lengthLong, gravity: Toast.bottom);
          Get.offAllNamed(WelcomeScreen.routeName);

        }else{
          setState(() {
            success = false;
          });
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
          errormsg = "Network connection error.";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              backAppbar(context, "Add Next of Kin"),
              SizedBox(
                height: 20,
              ),
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
          Container(
            margin:
            const EdgeInsets.only(top: 20, right: 20, left: 20),
            height: 60,
            child: SizedBox(
              height: 60,
              child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: false,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: "Next of Kin's First Name",
                  isDense: true,
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
                  onChanged: (value){
                    //set username  text on change
                    firstname = value;
                  },
                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                margin:
                const EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Next of Kin's Last Name",
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                    ),
                  onChanged: (value){
                    //set username  text on change
                    lastname = value;
                  },
                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                const EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Next of Kin's Email",
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    email=value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                const EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: "Next of Kin's Phone Number",
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    number=value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                const EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Next of Kin's House Address",
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    address=value;
                  },
                 ),
               ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.center,
                height: 60,
                child: DropdownButtonFormField<Item>(
                  isExpanded: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      hintText: "Select Relationship",
                      hintStyle: TextStyle(color: Colors.grey[800], fontSize: 2),
                      fillColor: Colors.white
                  ),
                  hint: const Text('Select Relationship'),
                  value: item,
                  onChanged: (Item? value){
                    setState(() {
                      item=value!;
                    });
                  },
                  items: items.map((Item user){
                    return DropdownMenuItem<Item>(value: user, child: Text(user.name, style: TextStyle(color: Colors.black),),);
                  }).toList(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin:
                const EdgeInsets.only(right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "Next of Kin's State",
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                    ),
                  onChanged: (value){
                    state=value;
                  },

                ),
              ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 10,
                  left: 20,
                  right: 20,
                ),
                child: SizedBox(
                  height: 50, width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      if(!showprogress) {
                        setState(() {
                          success = false;
                        });
                        Save();
                      }

                    },
                    style: ElevatedButton.styleFrom(primary: kPrimaryColor),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 10, bottom: 10),
                      child: showprogress?
                      SizedBox(
                        height:20, width:20,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ) : Text(
                        'Submit',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}


