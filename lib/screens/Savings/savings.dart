import 'dart:async';
import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:chukstem/constants.dart';
import 'package:chukstem/helper/networklayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../components/get_products.dart';
import '../../helper/pusher.dart';
import '../../models/thrift_transactions_model.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/material.dart';
import '../../widgets/snackbar.dart';
import '../splash/welcome.dart';

class Savings extends StatefulWidget {
  Savings({Key? key}) : super(key: key);

  @override
  _Savings createState() => _Savings();
}



class _Savings extends State<Savings> {
  String amount="0", wallet="0", code="";
  String msg="";
  List<ThriftTransactionsModel> aList = List.empty(growable: true);
  bool loading=false, history_button=false, limit_button=false, wallet_button=false;
  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();
  bool error=false, showprogress=false, success=false;

  cachedList() async {
    List<ThriftTransactionsModel> iList = await getSavingsCached();
    setState(() {
      if(iList.isNotEmpty){
        loading=false;
      }
      aList = iList;
    });
  }

  fetchList() async {
    try{
    loading=true;
    List<ThriftTransactionsModel> iList = await getSavings(new http.Client());
    setState(() { 
      aList = iList;
    });
    }catch(e){

    }
    setState(() {
      loading = false;
    });
  }

  startWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var token = prefs.getString("token");
    if(amount.isEmpty){
      setState(() {
        error=true;
        msg="Amount is empty";
      });
    } else {
      String apiurl = Strings.url+"/pay_with_wallet";
      success=false;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Processing request...',
      );
      var response = null;
      Map data = {
        'username': username,
        'reference': username!+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'amount': amount
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
            setState(() {
            error=false;
            success=true;
            msg=jsondata["response_message"];
          });
          } else {
            setState(() {
            error=true;
            msg=jsondata["response_message"];
          });
            Navigator.pop(context);
          }
        } catch (e) {
          setState(() {
          error=true;
          msg="Network connection error.";
          });
          Navigator.pop(context);
        }
      } else {
        setState(() {
        error=true;
        msg="Network connection error";
      });
        Navigator.pop(context);
      }
    } catch (e) {
       setState(() {
        error=true;
        msg="Network connection error.";
      });
       Navigator.pop(context);
    }
    }

    setState(() {
      showprogress=false;
    });
    if(error!) {
        Snackbar().show(context, ContentType.failure, "Error!", msg!);
    }else{
      Navigator.pop(context);
      Navigator.pop(context);
      Snackbar().show(context, ContentType.success, "Success!", msg!);
      fetchList();
      fetchQuery();
    }
  }


  withdrawNow() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var token = prefs.getString("token");
    if(amount.isEmpty){
      setState(() {
        error=true;
        msg="Amount is empty";
      });
    }else {
      String apiurl = Strings.url+"/withdraw_saving";
      success=false;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Processing request...',
      );
      var response = null;
      Map data = {
        'username': username,
        'reference': username!+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'amount': amount
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
              setState(() {
                error=false;
                success=true;
                msg=jsondata["response_message"];
              });
            } else {
              setState(() {
                error=true;
                msg=jsondata["response_message"];
              });
              Navigator.pop(context);
            }
          } catch (e) {
            setState(() {
              error=true;
              msg="Network connection error.";
            });
            Navigator.pop(context);
          }
        } else {
          setState(() {
            error=true;
            msg="Network connection error";
          });
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          error=true;
          msg="Network connection error.";
        });
        Navigator.pop(context);
      }
    }

    setState(() {
      showprogress=false;
    });
    if(error!) {
      Snackbar().show(context, ContentType.failure, "Error!", msg!);
    }else{
      Navigator.pop(context);
      Navigator.pop(context);
      Snackbar().show(context, ContentType.success, "Success!", msg!);
      fetchList();
      fetchQuery();
    }
  }


  fetchQuery() async {
    try {
      var res = await getQuery();
      if (res.contains("Authentication")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Toast.show("Session Expired. Please login again", duration: Toast.lengthLong, gravity: Toast.bottom);
        Get.offAllNamed(WelcomeScreen.routeName);
      } else {
        getuser();
        Products().getProducts();
      }
    }catch(e){ }
    getuser();
  }



  startVoucher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var token = prefs.getString("token");
    if(code.isEmpty){
      setState(() {
        error=true;
        msg="Voucher code is empty";
      });
      } else {
      String apiurl = Strings.url+"/redeem_voucher";
      success=false;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'Processing request...',
      );
      var response = null;
      Map data = {
        'username': username,
        'reference': username!+'_'+Uuid().v4()+'_${DateTime.now().millisecondsSinceEpoch/1000}',
        'code': code
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
            setState(() {
            error=false;
            success=true;
            msg=jsondata["response_message"];
            });
          } else {
            setState(() {
            error=true;
            msg=jsondata["response_message"];
            });
            Navigator.pop(context);
          }
        } catch (e) {
            setState(() {
          error=true;
          msg="Network connection error.";
          });
            Navigator.pop(context);
        }
        } else {
           setState(() {
          error=true;
          msg="Network connection error";
          });
           Navigator.pop(context);
        }
      } catch (e) {
            setState(() {
            error=true;
            msg="Network connection error.";
            });
            Navigator.pop(context);
      }
    }

    setState(() {
      showprogress=false;
    });
      if(error!) {
        Snackbar().show(context, ContentType.failure, "Error!", msg!);
      }else{
        Navigator.pop(context);
        Navigator.pop(context);
        Snackbar().show(context, ContentType.success, "Success!", msg!);
        fetchList();
        fetchQuery();
      }

  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wallet = prefs.getString("save_wallet")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getuser();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList(),
      fetchQuery(),
      generalPusher(context)
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
              ),
              padding: EdgeInsets.only(top: 20),
              child: Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10),
                child: Center(child: Text(
                  'Savings',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),),
              ),
            ),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            //color: kPrimary,
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: circularRadius(AppRadius.border12),
            ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, bottom: 40),
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                  "Saving Balance:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          wallet_button==true ?
                          Text(
                            "₦$wallet",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ) :
                          Text(
                            "₦ ****",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(width: 10,),
                          InkWell(
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: Icon(
                                wallet_button==true ?
                                Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                                color: Colors.white,
                              ),
                            ),
                            onTap: (){
                              setState(() {
                                if(wallet_button==true){
                                  wallet_button=false;
                                }else{
                                  wallet_button=true;
                                }
                              });
                            },
                          ),
                        ]),
                  )
                ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Container(
                    width: MediaQuery.of(context).size.width*0.28,
                    padding: const EdgeInsets.all(10),
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.orange),
                    child: Center(
                    child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12, ),
                      ),
                    )),
                    onTap: (){
                      setState(() {
                        error=false;
                        msg="";
                      });
                      _Method(context);
                    }),
                InkWell(
                    child: Container(
                    width: MediaQuery.of(context).size.width*0.28,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white60),
                    child: Center(
                      child: Text(
                          'Withdraw',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, ),
                        ),
                      ),
                    ),
                  onTap: (){
                    setState(() {
                      error=false;
                      msg="";
                    });
                    _Withdraw(context);
                  },),
                InkWell(
                    child: Container(
                    width: MediaQuery.of(context).size.width*0.28,
                    padding: const EdgeInsets.all(10),
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white60),
                    child: Center(
                      child: Text(
                          history_button ? 'Hide' : 'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, ),
                        ),
                      ),
                    ),
                  onTap: (){
                    setState(() {
                      if (history_button == true) {
                        history_button = false;
                      } else {
                        history_button = true;
                      }
                    });
                  },),
              ],
            ),
           ]),
           ),
           history_button?
            loading? Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                  child: CircularProgressIndicator()))
                  :
              aList.isEmpty ?
            Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.asset("assets/images/saving.png"),
                          )
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                      margin: EdgeInsets.only(top: 50, right: 20, left: 20),
                       child: Center(
                        child: Text(
                        'You have not saved anything this month. Kindly click the Save Now button to start saving this month',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                       color: kPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                ),
               ),
              )
             ]
            )) :
            Column(
                  children: <Widget>[
                    ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 0),
                        itemCount: aList.length,
                        itemBuilder: (context, index) {
                          return getListItem(
                              aList[index], index, context);
                        })
                  ],
                ) :
           Container(
             color: Colors.white,
             child: Center(
                 child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       SizedBox(
                         height: 30,
                       ),
                       Center(
                           child: SizedBox(
                             height: 150,
                             width: 150,
                             child: Image.asset("assets/images/saving_method.png"),
                           ),
                       ),
                       SizedBox(
                         height: 20,
                       ),
                       Container(
                         margin: EdgeInsets.only(top: 30, right: 20, left: 20, bottom: 20),
                         child: Center(
                           child: Text(
                             'Welcome to Saving Menu. You can now save money in PrinsOrder to Collect it at the end of the month.',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                                 color: kPrimary,
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold),
                           ),
                         ),
                       )
                     ]
                 )),
           ),
          ]),
        ),
    );
  }

  Container getListItem(ThriftTransactionsModel obj, int index, BuildContext context) {
    return Container(
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 10,
          top: 5,
          left: 10,
          right: 10,
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => {},
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 15, bottom: 2.5),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  child: new CircleAvatar(
                      maxRadius: 23,
                      minRadius: 23,
                      child: SvgPicture.asset("assets/images/transactions.svg",
                        height: 25.0,
                        width: 25.0,
                      ),
                      backgroundColor: Colors.white),
                  padding: EdgeInsets.all(1.0),
                  margin: EdgeInsets.only(left: 5, right: 15),
                  decoration: new BoxDecoration(
                    color: kPrimary, // border color
                    shape: BoxShape.circle,
                  )),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      obj.description,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 17.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                SizedBox(height: 7,),
                Wrap(
                 alignment: WrapAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      obj.time,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "₦"+obj.amount,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    ],
                   ),
                  ],
                ),
              ),

             ],
            ),
           ),
                Container(
                    width: double.infinity,
                    height: 0.5,
                    margin: EdgeInsets.only(top: 10),
                    color: kPrimary
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Month",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 5,),
                          Text(
                            obj.month,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 55),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Status",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 5,),
                          Text(
                            obj.status,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 55),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            obj.status=="Withdraw"? "Withdraw Method" : "Saving Method",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 5,),
                          Text(
                            obj.method,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }


  void _Wallet(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding:
                              EdgeInsets.only(top: 20, right: 20, left: 20),
                              child: Text(
                                'Enter Amount to save from your wallet',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            error? Container(
                              //show error message here
                              margin: EdgeInsets.only(bottom:10),
                              padding: EdgeInsets.all(10),
                              child: errmsg(msg, success, context),
                              //if error == true then show error message
                              //else set empty container as child
                            ) : Container(),
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                              height: 60,
                              child: SizedBox(
                                height: 60,
                                child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Amount",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                                onChanged: (value){
                                  amount=value;
                                },
                              ),
                            ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimary,
                                    minimumSize: const Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    if(!showprogress) {
                                      state(() {
                                        showprogress = true;
                                        error = false;
                                        startWallet();
                                      });
                                    }
                                  },
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    minimumSize: const Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                        )));
              });
        },
        context: context);
  }

  void _Voucher(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                              EdgeInsets.only(top: 20, right: 20, left: 20),
                              child: Text(
                                'Save using 16 digit Voucher Code',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            error? Container(
                              //show error message here
                              margin: EdgeInsets.only(bottom:10),
                              padding: EdgeInsets.all(10),
                              child: errmsg(msg, success, context),
                              //if error == true then show error message
                              //else set empty container as child
                            ) : Container(),
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                              height: 60,
                              child: SizedBox(
                                height: 60,
                                child: TextField(
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  hintText: "Code",
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                ),
                                onChanged: (value){
                                  code=value;
                                },
                              ),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    minimumSize: const Size.fromHeight(
                                        50),),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    if(!showprogress) {
                                      state(() {
                                        showprogress = true;
                                        error = false;
                                        startVoucher();
                                      });
                                    }
                                  },
                                )),
                            Padding(padding: const EdgeInsets.only(
                                top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    minimumSize: const Size.fromHeight(
                                        50),),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                        )));
              });
        },
        context: context);
  }

  void _Method(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                            const Padding(
                              padding:
                              EdgeInsets.only(top: 20, right: 20, left: 20),
                              child: Text(
                                'Choose Method of Saving',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                           Center(
                             child: Container(
                                 child: Image.asset("assets/images/saving_method.png",
                                       height: 150.0,
                                       width: 150.0,
                                     ),
                                     ),
                           ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 180,
                                    padding: const EdgeInsets.only(
                                        top: 20, right: 5, left: 5, bottom: 25),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimary,
                                        minimumSize: const Size.fromHeight(
                                            50), // fromHeight use double.infinity as width and 40 is the height
                                      ),
                                      child: Text(
                                        'Cash Pin',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: (){
                                        setState(() {
                                        error=false;
                                        msg="";
                                      });
                                      Navigator.pop(context);
                                      _Voucher(context);
                                      },
                                    )),
                                Container(
                                    width: 180,
                                    padding: const EdgeInsets.only(
                                        top: 20, right: 5, left: 5, bottom: 25),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimary,
                                        minimumSize: const Size.fromHeight(
                                            50), // fromHeight use double.infinity as width and 40 is the height
                                      ),
                                      child: Text(
                                        'Wallet Payment',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: (){
                                        setState(() {
                                        error=false;
                                        msg="";
                                      });
                                       Navigator.pop(context);
                                      _Wallet(context);
                                      },
                                    )),
                              ],
                            ),
                            Container(
                            padding: const EdgeInsets.only(
                                top: 10, right: 20, left: 20, bottom: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size.fromHeight(
                                    50), // fromHeight use double.infinity as width and 40 is the height
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            )),
                          ],
                        ));
              });
        },
        context: context);
  }



  void _Withdraw(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, state) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                              child: Text(
                                'Withdraw Amount (Bal: ₦$wallet)',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            error? Container(
                              //show error message here
                              margin: EdgeInsets.only(bottom:10),
                              padding: EdgeInsets.all(10),
                              child: errmsg(msg, success, context),
                              //if error == true then show error message
                              //else set empty container as child
                            ) : Container(),
                            Container(
                              margin: const EdgeInsets.only(top: 10, right: 20, left: 20),
                              height: 60,
                              child: SizedBox(
                                height: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Amount",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value){
                                    amount=value;
                                  },
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: kPrimary,
                                    minimumSize: const Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Withdraw Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    if(!showprogress) {
                                      state(() {
                                        showprogress = true;
                                        error = false;
                                        withdrawNow();
                                      });
                                    }
                                  },
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, right: 20, left: 20, bottom: 25),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    minimumSize: const Size.fromHeight(
                                        50), // fromHeight use double.infinity as width and 40 is the height
                                  ),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                        )));
              });
        },
        context: context);
  }

}