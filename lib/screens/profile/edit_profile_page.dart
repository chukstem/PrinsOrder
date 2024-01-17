import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
 
import '../../constants.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/material.dart';
import '../splash/welcome.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class Item{
  const Item(this.name);
  final String name;
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


class _EditProfileState extends State<EditProfile> {
  String errormsg="";
  bool error=false, success=false, showprogress=false;

  String email="", firstname="", lastname="", number="", token="", about="";
  TextEditingController emailController=new TextEditingController();
  TextEditingController numberController=new TextEditingController();
  TextEditingController firstnameController=new TextEditingController();
  TextEditingController lastnameController=new TextEditingController();
  TextEditingController aboutController=new TextEditingController();

  Map<String, dynamic> cStates = {};
  String stateValue = 'Select State';
  String lgaValue = 'Select LGA';
  String selectedLGAFromAllLGAs = NigerianStatesAndLGA.getAllNigerianLGAs()[0];
  List<String> statesLga = [];
  Item? state;
  Item? category;
  List<Item> services=<Item>[
    const Item('Select Sub Category'),
    Item('Bricklayer - mason'),
    Item('carpenter'),
    Item('furniture services'),
    Item('painter'),
    Item('pop - Plaster of Paris'),
    Item('Iron bender'),
    Item('Ganbolians- concrete casting'),
    Item('Gmp aluminum window services'),
    Item('Interior decorator'),
    Item('plumber'),
    Item('Tiller'),
    Item('Professionals'),
    Item('Iron fabricator- welders'),
    Item('Industrial cleaner'),
    Item('concrete mixer renters'),
    Item('Electrician'),
    Item('Dispatch rider- delivery bike'),
    Item('Auto mechanic'),
    Item('mobile gas filling'),
    Item('Event planner'),
    Item('caterer'),
    Item('laundry'),
    Item('soak- away waste evacuation service'),
    Item('Fashion designer'),
    Item('self defense instructor'),
    Item('Business- plan consultant'),
    Item('Delivery van service'),
    Item('basic First Aider'),
    Item('Pet sitting'),
    Item('Waste disposal'),
    Item('car wash'),
    Item('computer repair'),
    Item('Phone repair'),
    Item('social media manager'),
    Item('Taxi service'),
    Item('computer consultant'),
    Item('Dept collection services'),
    Item('seminar promotion'),
    Item('copy writing/ proofreading'),
    Item('lawn care- taking care of compound'),
    Item('language translation services'),
    Item('Towing van services'),
    Item('Pet food and home delivery services'),
    Item('school bus transportation services'),
    Item('Tutor'),
    Item('Nanny consulting services'),
    Item('Photographer'),
    Item('Disc jockey- DJ'),
    Item('wedding planner'),
    Item('children fitness services'),
    Item('website designer'),
    Item('canopy/ chair renters'),
    Item('Janitorial services'),
    Item('shoe manufacturer'),
    Item('Craftsmanship'),
    Item('mobile barber'),
    Item('Hair stylist'),
    Item('makeup artist'),
    Item('Entertainers'),
    Item('Driving school services'),
    Item('Property services'),
    Item('General Hiring'),
    Item('App developer'),
    Item('Fitness services/ massaging'),
    Item('Artist - painting'),
    Item('Bag manufacturer'),
    Item('Printing Press'),
    Item('Important/Exportation services'),
  ];
  List<Item> vendors=<Item>[
    const Item('Select Sub Category'),
    Item('Building materials'),
    Item('wood'),
    Item('Furniture'),
    Item('Paint'),
    Item('POP materials'),
    Item('Blocks & interlocks'),
    Item('Cement'),
    Item('Construction steel bars'),
    Item('construction equipment'),
    Item('Aluminum windows/ doors'),
    Item('security gadgets'),
    Item('Interiors'),
    Item('Doors'),
    Item('Plumbing materials'),
    Item('Tiles'),
    Item('safety tools/ materials'),
    Item('Doors'),
    Item('Roofing sheets'),
    Item('Gates/burglary proof'),
    Item('Stairs Case rails'),
    Item('Electrical materials'),
    Item('Swimming pool equipment'),
    Item('Construction materials'),
    Item('Property'),
    Item('Auto mobile'),
    Item('Auto mobile accessories'),
    Item('Motorcycle - bike'),
    Item('Bicycle'),
    Item('Office products'),
    Item('Home & Kitchen products'),
    Item('Grocery'),
    Item('Baby products'),
    Item('Health & beauty'),
    Item('Fashion - men'),
    Item('Fashion - women'),
    Item('Animals'),
    Item('Electronics'),
    Item('Phone & tablet'),
    Item('Phone accessories'),
    Item('Laptop - Computer'),
    Item('computer accessories'),
    Item('Generators'),
    Item('Inverters'),
    Item('Rechargeable power supplies'),
    Item('Generator parts'),
    Item('Cameras'),
    Item('Garden'),
    Item('Sporting goods'),
    Item('Gaming'),
    Item('completion of services'),
    Item('swimming pool - construction'),
    Item('Relocation services'),
    Item('Procurement  services'),
    Item('Carport canopy - construction'),
    Item('Increte flooring'),
    Item('Bush Bar - construction'),
  ];
  Item? type;
  List<Item> types=<Item>[
    const Item('Select Category'),
    const Item('Vendor'),
    const Item('Service'),
  ];
  List<Item> categories=<Item>[
    const Item('Select Category'),
  ];
  List<Item> states=<Item>[
    const Item('Select State'),
    const Item('Abia'),
  ];
  Item? lga;
  List<Item> lgas=<Item>[
    const Item('Select LGA'),
    const Item('Abia'),
  ];



  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
      number = prefs.getString("number")!;
      firstname = prefs.getString("firstname")!;
      lastname = prefs.getString("lastname")!;
      about = prefs.getString("about")!;
      firstnameController.text="$firstname";
      lastnameController.text="$lastname";
      emailController.text="$email";
      numberController.text="$number";
      aboutController.text="$about";
    });
  }


  saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email")!;
    token = prefs.getString("token")!;
    if (firstname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter First Name";
      });
    } else if (lastname.isEmpty) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Enter Last Name";
      });
    }else if (stateValue==null) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Select State";
      });
    }else if (lgaValue==null) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Select LGA";
      });
    }else if (type==null || type!.name.contains("Category")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Select Category";
      });
    }else  if (category==null || category!.name.contains("Category")) {
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Please Select Sub Category";
      });
    }else {
      setState(() {
        showprogress = true;
        error=false;
      });
      String apiurl = Strings.url+"/update-profile";
      var response = null;
      try {
         Map data = {
          'email': email,
          'first_name': firstname.trim(),
          'last_name': lastname.trim(),
          'about': about.trim(),
          'state': stateValue,
          'lga': lgaValue,
          'category': type!.name,
          'sub_category': category!.name,
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
          });
          prefs.setString("firstname", firstname.trim());
          prefs.setString("lastname", lastname.trim());
          setState(() {
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
    getUser();
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
              backAppbar(context, "Edit Profile"),
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
                controller: firstnameController, 
                decoration: const InputDecoration(
                  hintText: "First Name",
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
                const EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                  obscureText: false,
                    keyboardType: TextInputType.text,
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      hintText: "Last Name",
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
                const EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 60,
                child: SizedBox(
                  height: 60,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    keyboardType: TextInputType.text,
                    controller: emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "Email",
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
                  },

                ),
              ),
              ),
              SizedBox(
                height: 20,
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
                    controller: numberController,
                    keyboardType: TextInputType.text,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
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
                  },

                ),
              ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
                height: 120,
                child: SizedBox(
                  height: 120,
                  child: TextField(
                  style:TextStyle(color: kPrimaryColor, fontSize:14),
                    obscureText: false,
                    maxLength: 200,
                    minLines: null,
                    maxLines: null,
                    expands: true,
                    controller: aboutController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "About",
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
                    setState(() {
                      about=value;
                    });
                  },

                ),
               ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                alignment: Alignment.topLeft,
                child: Text(
                  "Select Work",
                  style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 16, fontWeight: FontWeight.bold),
                ),),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(right: 20, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.45,
                      alignment: Alignment.center,
                      child: DropdownButtonFormField<Item>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            filled: true,
                            hintText: "Select Category",
                            hintStyle: TextStyle(color: Colors.grey[800]),
                            fillColor: Colors.white
                        ),
                        hint: const Text('Select Category'),
                        value: type,
                        onChanged: (Item? value){
                          setState(() {
                            type=value!;
                            if(type!.name!="Select Category") {
                              if (type!.name == "Service") {
                                categories = services;
                              } else {
                                categories = vendors;
                              }
                            }
                          });
                        },
                        items: types.map((Item user){
                          return DropdownMenuItem<Item>(value: user, child: Text(user.name, style: TextStyle(color: Colors.black),),);
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 2,),
                    Container(
                      width: MediaQuery.of(context).size.width*0.45,
                      alignment: Alignment.center,
                      child: DropdownButtonFormField<Item>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            filled: true,
                            hintText: "Select Sub Category",
                            hintStyle: TextStyle(color: Colors.grey[800]),
                            fillColor: Colors.white
                        ),
                        hint: const Text('Select Sub Category'),
                        value: category,
                        onChanged: (Item? value){
                          setState(() {
                            category=value!;
                          });
                        },
                        items: categories.map((Item user){
                          return DropdownMenuItem<Item>(value: user, child: Text(user.name, style: TextStyle(color: Colors.black),),);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, left: 20, right: 20),
                alignment: Alignment.topLeft,
                child: Text(
                  "Select Location",
                  style: TextStyle(color: Color.fromRGBO(111, 129, 132, 1), fontSize: 16, fontWeight: FontWeight.bold),
                ),),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(right: 20, left: 20),
                decoration: BoxDecoration(
                  color: Colors.white60,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width*0.45,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        color: Colors.white,
                        child: DropdownButton<String>(
                            key: const ValueKey('States'),
                            value: stateValue,
                            isExpanded: true,
                            hint: const Text('Select State'),
                            items: NigerianStatesAndLGA.allStates
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              );
                            }).toList(),
                            onChanged: (val) {
                              lgaValue = 'Select LGA';
                              statesLga.clear();
                              statesLga.add(lgaValue);
                              statesLga.addAll(NigerianStatesAndLGA.getStateLGAs(val!));
                              setState(() {
                                stateValue = val;
                              });
                            })),
                    SizedBox(width: 2,),
                    Container(
                        width: MediaQuery.of(context).size.width*0.45,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        color: Colors.white,
                        child: DropdownButton<String>(
                            key: const ValueKey('Local Governments'),
                            value: lgaValue,
                            isExpanded: true,
                            hint: const Text('Select LGA'),
                            items:
                            statesLga.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                lgaValue = val!;
                              });
                            })),
                  ],
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
                        saveProfile();
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
                        'Save Profile',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    ) ,
                    // if showprogress == true then show progress indicator
                    // else show "LOGIN NOW" text

                      //button corner radius
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


