import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../constants.dart';
import '../models/post.dart';
import '../screens/Savings/savings.dart';
import '../screens/chat/conversations_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/transactions/transactions.dart';
import '../screens/wallet/wallet_page.dart';
import '../size_config.dart';
import '../strings.dart';
import 'package:http/http.dart' as http;

import '../widgets/snackbar.dart';


class Dashboard extends StatefulWidget {
  @override
  _Dashboard createState() => _Dashboard();

}

class _Dashboard  extends State<Dashboard> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  bool found=false;
  String username="";
  bool refresh=false;
  Timer? _timer;

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(mounted) setState(() {
      username = prefs.getString("username")!;
    });
  }

  final List<Widget> _tabItems = [
    HomeScreen(),
    Savings(),
    WalletScreen(),
    Transactions(),
    ConversationScreen(),
    ProfileScreen(),
  ];


  @override
  void initState() {
    super.initState();
    getuser();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    SizeConfig().init(context);
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kPrimaryColor,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 50.0,
        items: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                Text("Home", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.savings,
                  color: Colors.white,
                ),
                Text("Saving", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                ),
                Text("Wallets", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hive,
                  color: Colors.white,
                ),
                Text("History", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
                Text("Chats", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                Text("Profile", style: TextStyle(color: Colors.white),),
              ],
            ),
          ),
        ],
        color: kPrimaryColor,
        buttonBackgroundColor: kPrimaryColor,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          // _more(context);
          if(mounted) setState(() {
              _page = index;
            });
        },
      ),
      body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap back again to exit'),
          ),
          child: _tabItems[_page]),
    );
  }


  Future<void> _refresh() async {
    if(mounted) _timer=Timer.periodic(new Duration(seconds: 5), (timer) {
      if(!refresh) process();
    });
  }


  process() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("username");
    var token = prefs.getString("token");
    List<Post> posts=List.empty(growable: true);
    if(mounted) setState(() {
      refresh=true;
    });
    try{
      var old_post = json.decode(prefs.getString("queued_posts")!) as List<dynamic>;
      for(var post in old_post) {
        bool isPosted=false;
        try{
          String apiurl = Strings.url + post["url"].toString();
          var response = null;
          if(post["url"]=="/post_conversation_image"){

            var uri = Uri.parse(apiurl);
            var request = http.MultipartRequest("POST", uri);

            try{
                  var stream = http.ByteStream(DelegatingStream.typed(File(post["var1"]).openRead()));
                  var length = await File(post["var1"]).length();
                  var multipartFile = http.MultipartFile(
                      "image", stream, length,
                      filename: File(post["var1"]).path
                          .split('/')
                          .last);
                request.files.add(multipartFile);
            }catch(e){
              isPosted=true;
            }

            request.headers['Content-Type'] = 'application/json';
            request.headers['Authentication'] = '$token';
            request.fields['username'] = username!;
            request.fields['content'] = post["content"].toString();
            request.fields['user'] = post["user"].toString();
            request.fields['uid'] = post["uid"].toString();

            var respond = await request.send();
              if (respond.statusCode == 200) {
                var responseData = await respond.stream.toBytes();
                var responseString = String.fromCharCodes(responseData);
                var jsondata = json.decode(responseString);
                if (jsondata["status"].toString() == "success") {
                  isPosted=true;
                } else {
               //   Snackbar().show(context, ContentType.failure, "Error", jsondata["response_message"].toString());
                  isPosted=true;
                }
              } else {
                isPosted=false;
              }

          }else{
            Map data = {
              'username': username,
              'user': post["user"].toString(),
              'content': post["content"].toString(),
              'id': post["var1"].toString(),
              'uid': post["uid"].toString(),
            };

            var body = json.encode(data);
            response = await http.post(Uri.parse(apiurl),
                headers: {
                  "Content-Type": "application/json",
                  "Authentication": "$token"},
                body: body
            );

            if (response != null && response.statusCode == 200) {
              var jsondata = json.decode(response.body);
              if (jsondata["status"] != null && jsondata["status"].toString().contains("success")) {
                isPosted=true;
              }else{
             //   Snackbar().show(context, ContentType.failure, "Error!", jsondata["response_message"].toString());
                isPosted=true;
              }

            }else{
              isPosted=false;
            }
          }

        }catch(e){
          isPosted=false;
         // Snackbar().show(context, ContentType.failure, "Error!!", e.toString());
        }

        if(!isPosted && post["retries"]<5){
          posts.add(Post(user: post["user"], content: post["content"], url: post["url"], var1: post["var1"], retries: post["retries"]+1, uid: post["uid"]));
        }
      }
      prefs.setString("queued_posts", jsonEncode(posts));

    }catch(e){
      //Snackbar().show(context, ContentType.failure, "Error!!", e.toString());
    }
    if(mounted) setState(() {
      refresh=false;
    });
  }

}
