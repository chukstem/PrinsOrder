import 'dart:async';
import 'package:crypto_app/screens/home/post_timeline.dart';
import 'package:crypto_app/screens/home/timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../components/get_products.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../helper/pusher.dart';
import '../../models/explore_model.dart';
import '../settings/Unlock_screen.dart';
import '../settings/set_pin.dart';
import '../splash/welcome.dart';
import 'find_people.dart';
import 'followers.dart';
import 'following.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin{
  bool loading=true;
  List<ExploreModel> list = List.empty(growable: true);
  List<ExploreModel> olist = List.empty(growable: true);
  String search="ALL";
  var _scrollController, _tabController;

  cachedList() async {
    List<ExploreModel> iList = await getExploreCached();
      if (iList.isNotEmpty) {
        if(mounted) setState(() {
          loading = false;
          list = iList;
          olist = iList;
        });
      }
  }

  fetch() async {
    if(search.isEmpty){
      if(mounted) setState(() {
        search="ALL";
      });
    }
    try{
      List<ExploreModel> iList = await getExplore(http.Client(), search, "0");
      if(mounted) setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });

    }catch(e){
      if(mounted) setState(() {
        loading = false;
      });
    }

  }

  fetchList(setState) async {
    if(mounted) setState(() {
      loading = true;
    if(search.isEmpty){
        search="ALL";
     }
   });
    try{
      List<ExploreModel> iList = await getExplore(http.Client(), search, "0");
      if(mounted) setState(() {
        loading = false;
        list = iList;
        olist = iList;
      });

    }catch(e){
      if(mounted) setState(() {
        loading = false;
      });
    }

  }



  fetchQuery() async {
    Products().getProducts();
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
    }catch(e){

    }
  }


  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPasscode = prefs.getString("pin");
    String? access = prefs.getString("access");
    if(storedPasscode == "1234") {
      if(mounted) Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => setPin()));
    }else if (access != "unlocked") {
      if(mounted) Navigator.of(context).pushReplacement(
          PageRouteBuilder(pageBuilder: (_, __, ___) => PinScreen()));
    }

  }





  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: 4);
    getuser();
    cachedList();
    Timer(Duration(seconds: 1), () =>
    {
      fetchQuery(),
      fetch(),
      generalPusher(context)
    });
  }

  fetchdelay(){
    Timer(Duration(seconds: 120), () =>
    {
      fetch(),
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: kWhite,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Skills/Service"),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Icon(Icons.add_shopping_cart, color: Colors.white,),
                         Text("Shop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                       ],
                     )
                  ],
                ),
              ),
              pinned: false,
              floating: true,
              snap: false,
              backgroundColor: kPrimaryColor,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                indicatorPadding: EdgeInsets.only(left: 10, right: 10),
                unselectedLabelStyle: TextStyle(color: Colors.white70),
                labelStyle: TextStyle(color: kSecondary, fontWeight: FontWeight.bold),
                padding: EdgeInsets.all(0),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.timeline, color: Colors.white,),
                      child: Text("Posts", style: TextStyle(color: Colors.white70)),
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.people, color: Colors.white,),
                      child: Text("People", style: TextStyle(color: Colors.white70)),
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.supervised_user_circle_sharp, color: Colors.white,),
                      child: Text("Following", style: TextStyle(color: Colors.white70)),
                    ),),
                  Container(width: MediaQuery.of(context).size.width/5.5,
                    child: Tab(
                      icon: Icon(Icons.supervised_user_circle_sharp, color: Colors.white,),
                      child: Text("Followers", style: TextStyle(color: Colors.white70)),
                    ),),
                ],
                controller: _tabController,
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () {
            return fetch();
          },
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Timeline(loading: loading, tList: list.isEmpty?[]:list.first.timeline, hList: list.isEmpty?[]:list.first.hashtags),
              FindPeople(loading: loading, tList: list.isEmpty?[]:list.first.findpeople),
              Following(loading: loading, tList: list.isEmpty?[]:list.first.following),
              Followers(loading: loading, tList: list.isEmpty?[]:list.first.followers),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) => NewPost())).whenComplete(() => fetchdelay());
        },
        backgroundColor: kPrimaryLightColor,
        child: const Icon(Icons.add, size: 40,),
      ),
    );


  }



}