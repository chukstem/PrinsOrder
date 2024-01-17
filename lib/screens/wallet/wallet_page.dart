import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../helper/pusher.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../../radius.dart';
import '../../strings.dart';
import '../../widgets/material.dart';
import '../bills/airtime_page.dart';
import '../bills/bet_page.dart';
import '../bills/cable_page.dart';
import '../bills/data_page.dart';
import '../bills/electricity_page.dart';
import '../chat/chat_screen.dart';
import '../splash/welcome.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreen createState() => _WalletScreen();
}


Widget errmsg(String text){
  //error message widget.
  return Container(
    padding: EdgeInsets.all(5.00),
    margin: EdgeInsets.only(left: 10, right: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: yellow50,
    ),
    child: Container(
      margin: EdgeInsets.only(left: 10.00, right: 10),
      child: Text(text, style: TextStyle(color: kPrimaryDarkColor, fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,),
    ),
  );
}

class _WalletScreen extends State<WalletScreen> {
  String errormsg="";
  bool error=false, showprogress=false, wallet_button=false;
  String wallet="0";
  String bankname="", accountname="", accountnumber="";

  List<WalletModel> aList = List.empty(growable: true);
  bool loading=true;
  final pageIndexNotifier = ValueNotifier<int>(0);

  cachedList() async {
    List<WalletModel> iList = await getWalletCached();
    setState(() {
      if(iList.isNotEmpty){
        loading=false;
      }
      aList = iList;
    });
  }

  fetchList() async {
    loading=true;
    try{
    List<WalletModel> iList = await getWallet(new http.Client());
    setState(() {
      aList = iList;
    });
  }catch(e){

  }
  setState(() {
  loading = false;
  }); 
}


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wallet = prefs.getString("wallet")!;
      bankname = prefs.getString("bankname")!;
      accountnumber = prefs.getString("accountnumber")!;
      accountname = prefs.getString("accountname")!;
    });

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

  @override
  void initState() {
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      cachedList(),
      fetchList(),
      fetchQuery(),
      generalPusher(context)
    });
    super.initState();
  }
  int counter = 0;


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryVeryVeryLightColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
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
                    'Wallet',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),),
                ),
              ),
              Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(5),
                    //color: kPrimaryDarkColor,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: circularRadius(AppRadius.border12),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 2.0),
                            blurRadius: 4,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Account: #$accountnumber",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20, bottom: 15),
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                        "NGN Balance:",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),),
                                      Center(
                                        child: Container(
                                        margin: EdgeInsets.only(right: 20),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                                              Center(
                                                child: InkWell(
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
                                              ),
                                            ]),
                                      ))
                                    ]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 2, left: 16, right: 10, top: 0),
                                    width: MediaQuery.of(context).size.width*0.42,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _pay();
                                      },
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(width: 1.0, color: kPrimaryDarkColor),
                                          backgroundColor: kPrimaryDarkColor,
                                          fixedSize: Size.fromHeight(40)
                                      ),
                                      child: const Text(
                                        "Fund",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              Container(
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                ),
                child: getSingleChildScrollView(),
              ),
            ],
         ),
        ),
    );
  }



  Widget getSingleChildScrollView() {
    String assetElectricity = 'assets/images/electricity.svg';
    String assetAirtime = 'assets/images/airtime.svg';
    String assetData = 'assets/images/data.svg';
    String assetCable = 'assets/images/cable.svg';
    String assetBet = 'assets/images/betting.svg';
    String assetChat = 'assets/images/support.svg';
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 220,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 5),
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: kPrimaryDarkColor, width: 1),
                      borderRadius: BorderRadius.circular(5),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child:  Padding(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(builder: (context) => Airtime()));
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                child: new CircleAvatar(
                                                    maxRadius: 18,
                                                    minRadius: 18,
                                                    child: SvgPicture.asset(
                                                      assetAirtime,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    backgroundColor: Colors.white),
                                                padding: EdgeInsets.all(0.5), // borde width
                                                decoration: new BoxDecoration(
                                                  color: Colors.orange, // border color
                                                  shape: BoxShape.circle,
                                                )),
                                            Flexible(
                                              child: Padding(
                                                child: Text("Airtime",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: const Color(0xff000000),
                                                        fontFamily: "AvenirNext",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 12)),
                                                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(builder: (context) => Data()));
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                child: new CircleAvatar(
                                                    maxRadius: 18,
                                                    minRadius: 18,
                                                    child: SvgPicture.asset(
                                                      assetData,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    backgroundColor: Colors.white),
                                                padding: EdgeInsets.all(0.5), // borde width
                                                decoration: new BoxDecoration(
                                                  color: Colors.orange, // border color
                                                  shape: BoxShape.circle,
                                                )),
                                            Flexible(
                                              child: Padding(
                                                child: Text("Buy Data",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: const Color(0xff000000),
                                                        fontFamily: "AvenirNext",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 12)),
                                                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                        onTap: (){
                                          support();
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                child: new CircleAvatar(
                                                    maxRadius: 18,
                                                    minRadius: 18,
                                                    child: SvgPicture.asset(
                                                      assetChat,
                                                      width: 24,
                                                      height: 24,
                                                      color: Colors.orange,
                                                    ),
                                                    backgroundColor: Colors.white),
                                                //padding: EdgeInsets.all(1.0), // borde width
                                                decoration: new BoxDecoration(
                                                  color: Colors.orange, // border color
                                                  shape: BoxShape.circle,
                                                )),
                                            Flexible(
                                              child: Padding(
                                                child: Text("Support",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: const Color(0xff000000),
                                                        fontFamily: "AvenirNext",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 12)),
                                                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(13, 18, 13, 2),
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            height: 0.5,
                            margin: EdgeInsets.only(top: 10),
                            color: kPrimaryDarkColor
                        ),
                        Container(
                          child:  Padding(
                            child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(builder: (context) => Cable()));
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                child: new CircleAvatar(
                                                    maxRadius: 18,
                                                    minRadius: 18,
                                                    child: SvgPicture.asset(
                                                      assetCable,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    backgroundColor: Colors.white),
                                                padding: EdgeInsets.all(0.5), // borde width
                                                decoration: new BoxDecoration(
                                                  color: Colors.orange, // border color
                                                  shape: BoxShape.circle,
                                                )),
                                            Flexible(
                                              child: Padding(
                                                child: Text("Cable",
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: const Color(0xff000000),
                                                        fontFamily: "AvenirNext",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 12)),
                                                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                     width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                        onTap: (){
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(builder: (context) => Bet()));
                                        },
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                child: new CircleAvatar(
                                                    maxRadius: 18,
                                                    minRadius: 18,
                                                    child: SvgPicture.asset(
                                                      assetBet,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    backgroundColor: Colors.white),
                                                padding: EdgeInsets.all(1.0), // borde width
                                                decoration: new BoxDecoration(
                                                  color: Colors.orange, // border color
                                                  shape: BoxShape.circle,
                                                )),
                                            Flexible(
                                              child: Padding(
                                                child: Text("Betting",
                                                    style: const TextStyle(
                                                        color: const Color(0xff000000),
                                                        fontFamily: "AvenirNext",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 12)),
                                                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.20,
                                      child: InkWell(
                                      onTap: (){
                                        Navigator.of(context).push(
                                            CupertinoPageRoute(builder: (context) => Electricity()));
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              child: new CircleAvatar(
                                                  maxRadius: 18,
                                                  minRadius: 18,
                                                  child: SvgPicture.asset(
                                                    assetElectricity,
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                                  backgroundColor: Colors.white),
                                              padding: EdgeInsets.all(0.5), // borde width
                                              decoration: new BoxDecoration(
                                                color: Colors.orange, // border color
                                                shape: BoxShape.circle,
                                              )),
                                          Flexible(
                                            child: Padding(
                                              child: Text("Pay Bills",
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      color: const Color(0xff000000),
                                                      fontFamily: "AvenirNext",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 12)),
                                              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    ),
                                  ],
                                ),
                            padding: EdgeInsets.fromLTRB(13, 18, 13, 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 50,
                    top: 12,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      color: Colors.white,
                      child: Text(
                        'QUICK ACTION',
                        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 30.0, bottom: 10),
                    child: Text(
                      'Account History',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              loading? Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              aList.length <= 0 ?
              Container(
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("Nothing Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryDarkColor),),
                ),
              )
                  :
             Column(
                children: <Widget>[
                  ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: aList.length>5 ? 5 : aList.length,
                      itemBuilder: (context, index) {
                        return getListItem(
                            aList[index], index, context);
                      })
                ],
               ),
        ]
        );
      },
    );
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }



  Container getListItem(WalletModel obj, int index, BuildContext context) {
    return Container(
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        child: InkWell(
          onTap: () => {},
          child: Container(
            padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width*0.10,
                    height: MediaQuery.of(context).size.width*0.10,
                    margin: EdgeInsets.all(10),
                    child: Image.asset(
                      "assets/images/ngn.png" ,
                      height: 25.0,
                      width: 25.0,
                    ),
                    padding: EdgeInsets.all(1.0)),
                Container(
                  width: MediaQuery.of(context).size.width*0.70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.80,
                        child: Text(
                          obj.description.toUpperCase(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(height: 7,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*0.35,
                            child: Text(
                              obj.time,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width*0.35,
                            child: obj.description.contains("DR/") ?
                            Text(
                              "-₦"+obj.amount,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ) :
                            Text(
                              "+₦"+obj.amount,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  support() async{
    UserModel to=  new UserModel(id: "4545", username: Strings.app_name, first_name: "Customer", reviews: "0", last_name: "Care", created_on: "", isFollowed: "", trades: "",
        phone: "",
        service: "", about: "", avatar: "", cover: "", followers: "", following: "", rank: "", loading: false);
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ChatScreen(to: to)));
  }


  _pay() {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, paystate) {
                return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding:
                              EdgeInsets.only(top: 10, right: 20, left: 20),
                              child: Text(
                                'TO RECEIVE MONEY, PAY INTO THIS ACCOUNT',
                                style: TextStyle(
                                    color: kPrimaryDarkColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            errmsg('Bank Name: $bankname'),
                            SizedBox(height: 3,),
                            Container(
                              width: 180,
                              padding: EdgeInsets.all(5.00),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: yellow50,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: accountnumber));
                                  Toast.show("Account number copied!", duration: Toast.lengthLong, gravity: Toast.bottom);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(left: 10.00),
                                      child: Text('Acc/No: $accountnumber', style: TextStyle(color: kPrimaryDarkColor, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,),
                                    ), // icon for error message
                                    Container(
                                      margin: EdgeInsets.only(left: 10.00),
                                      child: Icon(Icons.copy, color: kPrimaryDarkColor)),
                                  ]),
                               ),
                              ),
                            SizedBox(height: 3,),
                            errmsg('Acc/Name: $accountname'),
                            SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding:
                              EdgeInsets.only(top: 10, right: 20, left: 20),
                              child: Text(
                                'Note: Deposit charge of N52 for amounts less than ₦2,500',
                                style: TextStyle(
                                    color: kPrimaryDarkColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        )));
              });
        },
        context: context);
  }

}