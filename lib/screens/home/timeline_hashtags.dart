import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/timeline_hashtags_model.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto_app/constants.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../../helper/networklayer.dart';
import '../../models/explore_model.dart';
import '../../models/timeline_model.dart';
import '../../strings.dart';
import '../../widgets/appbar.dart';
import '../../widgets/snackbar.dart';
import '../explore/ImageView.dart';
import '../explore/video_list_offline.dart';
import '../explore/video_player.dart';
import '../explore/view_timeline_screen.dart';
import '../profile/user_profile_screen.dart';


class TimelineHashtags extends StatefulWidget {
  String subject;
  TimelineHashtags({Key? key, required this.subject}) : super(key: key);

  @override
  _TimelineHashtags createState() => _TimelineHashtags();
}

class _TimelineHashtags extends State<TimelineHashtags> {
  String token="", username="", errormsg="";
  bool error=false, loading=true, showprogress=false, success=false;
  AudioPlayer audioPlayer = AudioPlayer();
  String currentTime = "0:00:00";
  String completeTime = "0:00:00";

  List<ExploreModel> list = List.empty(growable: true); 
 

  fetch() async {
    setState(() {
      loading = true;
    }); 
    try{
      List<ExploreModel> iList = await getExplore(http.Client(), widget.subject, "0");
      setState(() {
        loading = false;
        list = iList; 
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }

  bool stopRefresh=false;
  addItems() async {
    int length=list.length+1;
    try{
      List<ExploreModel> iList = await getExplore(http.Client(), widget.subject, "$length");
      setState(() {
        loading = false;
        list.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        loading = false;
      });
    }

  }
  
  
  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token")!;
      username = prefs.getString("username")!;
    });
  }


   
  setPlayer(){
    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });

      audioPlayer.onPositionChanged.listen((Duration duration) {
        setState(() {
          currentTime = duration.toString().split(".")[0];
          if(currentTime==completeTime){
            for (int i = 0; i < list.length; i++) {
              if(list.first.timeline![i].mediaModel.isNotEmpty) list.first.timeline![i].mediaModel[0].playingstatus = 0;
            }
          }
        });
      });


    });
  }



  @override
  void initState() {
    super.initState();
    getuser();
    Timer(Duration(seconds: 1), () =>
    {
      setPlayer(),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            backAppbar(context, widget.subject),
            SizedBox(
              height: 20,
            ),
            Timeline()
          ],
        ),
      ),
    );
  }


  Widget Timeline() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              loading ? Container(
                  height: 300,
                  color: Colors.white,
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: CircularProgressIndicator()))
                  :
              list.first.timeline!.length <= 0 ?
              Container(
                height: 80,
                color: Colors.white,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("Empty!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              RefreshIndicator(
                onRefresh: _refresh,
                child: EasyLoadMore(
                  isFinished: list.first.timeline!.length < 30 || list.first.timeline!.length >= 500 || stopRefresh,
                  onLoadMore: _loadMore,
                  runOnEmptyResult: false,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 0),
                      itemCount: list.first.timeline!.length,
                      itemBuilder: (context, index) {
                        return getTimelineItem(
                            list.first.timeline![index], index, context);
                      }),
                ),
              ),
              SizedBox(height: 20,)
            ]
        );
      },
    );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(
      const Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );

    if(stopRefresh==false){ addItems();}
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(
        seconds: 0,
        milliseconds: 2000,
      ),
    );


    fetch();
  }


  InkWell getTimelineItem(TimelineModel obj, int index, BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewTimelineScreen(model: obj, isTimeline: false)));
      },
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 50.0),
            child: Card(
              margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 10, top: 5),
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5, top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              alignment: Alignment.topLeft,
                              width: MediaQuery.of(context).size.width*0.50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
                                    },
                                    child: Text(
                                      obj.userModel.first.first_name + " "+obj.userModel.first.last_name,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  obj.userModel.first.rank=="0" ?
                                  Icon(Icons.verified_user, color: Colors.white, size: 10,) :
                                  obj.userModel.first.rank=="1" ?
                                  Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,) :
                                  Row(mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.star, color: obj.userModel.first.rank=="3" ? Colors.orangeAccent : kPrimaryVeryLightColor, size: 10,),
                                      SizedBox(width: 2,),
                                      Icon(Icons.verified_user, color: kPrimaryLightColor, size: 10,),
                                    ],),
                                  SizedBox(width: 4,),
                                  Text(
                                    "@"+obj.userModel.first.username,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black45,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              )
                          ),
                          SizedBox(width: 10,),
                          Container(
                            alignment: Alignment.topRight,
                            width: MediaQuery.of(context).size.width*0.10,
                            child: Text(
                              obj.date,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black45,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      obj.imagesModel.isNotEmpty?
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 5, top: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PhotoGrid(
                              imageUrls: obj.imagesModel,
                              onImageClicked: (i) => print('Image $i was clicked!'),
                              onExpandClicked: () => print('Expand Image was clicked'),
                              maxImages: 4,
                            ),
                          ],
                        ),
                      ) : SizedBox(),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 5, top: 5),
                        child: Text(obj.content,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 6,
                        ),
                      ),
                      obj.mediaModel.isEmpty ?
                      SizedBox() :
                      obj.mediaModel[0].type.contains("video") ?
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: VideoPlayerLib(url: obj.mediaModel[0].url),
                      ) :
                      obj.mediaModel[0].type.contains("audio") ?
                      Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          width: 240,
                          height: 50,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: BorderRadius.circular(80),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Center(
                                child: InkWell(
                                    child: Icon(
                                      obj.mediaModel[0].playingstatus==1
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onTap: () async {
                                      if (obj.mediaModel[0].playingstatus==1) {
                                        audioPlayer.pause();
                                        setState(() {
                                          for (int i = 0; i < list.length; i++) {
                                            if(list.first.timeline![i].mediaModel.isNotEmpty) list.first.timeline![i].mediaModel[0].playingstatus = 0;
                                          }
                                        });
                                      } else {
                                        await audioPlayer.play(UrlSource(obj.mediaModel[0].url));
                                        setState(() {
                                          for (int i = 0; i < list.length; i++) {
                                            if(list.first.timeline![i].mediaModel.isNotEmpty) list.first.timeline![i].mediaModel[0].playingstatus = 0;
                                          }
                                          obj.mediaModel[0].playingstatus = 1;
                                        });
                                      }
                                    }),
                              ),
                              Center(
                                child: InkWell(
                                  child: Icon(
                                    Icons.stop,
                                    color: Colors.white,  size: 25,
                                  ),
                                  onTap: () {
                                    audioPlayer.stop();
                                    setState(() {
                                      for (int i = 0; i < list.length; i++) {
                                        if(list.first.timeline![i].mediaModel.isNotEmpty) list.first.timeline![i].mediaModel[0].playingstatus = 0;
                                      }
                                    });
                                  },
                                ),
                              ),
                              Text(
                                "   " + currentTime,
                                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              Text(" | ", style: TextStyle(color: Colors.white)),
                              Text(
                                completeTime,
                                style: TextStyle(fontWeight: FontWeight.w300, color: Colors.white),
                              ),
                            ],
                          )) :
                      SizedBox(),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){
                                obj.isLiked=="1" ?
                                unlike(index, obj.id) : like(index, obj.id);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  obj.isLiked=="1" ? Icon(Icons.heart_broken, color: Colors.red, size: 20,) : Icon(Icons.heart_broken, size: 20,),
                                  SizedBox(width: 5,),
                                  Text(
                                    obj.likes,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.comment, size: 20,),
                                SizedBox(width: 5,),
                                Text(
                                  obj.comments,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart, size: 20,),
                                SizedBox(width: 5,),
                                Text(
                                  obj.views,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 35.0,
            child: Container(
              height: double.infinity,
              width: 1.0,
              color: Colors.grey,
            ),
          ),
          Positioned(
            top: 20.0,
            left: 15.0,
            child: InkWell(
              onTap: (){
                Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => UserProfile(user: obj.userModel.first,)));
              },
              child: Container(
                  height: 40,
                  width: 40,
                  child: CircleAvatar(
                    radius: 45,
                    child: Padding(
                      padding: const EdgeInsets.all(1), // Border radius
                      child: ClipOval(child: CachedNetworkImage(
                        height: 40,
                        width: 40,
                        imageUrl: obj.userModel.first.avatar,
                        fit: BoxFit.cover,), ),
                    ),
                  ),
                  padding: EdgeInsets.all(1),
                  decoration: new BoxDecoration(
                    color: Colors.white, // border color
                    shape: BoxShape.circle,
                  )),
            ),
          )
        ],
      ),
    );
  }



  like(int id, String tid) async {
    setState(() {
      list.first.timeline![id].isLiked="1";
    });
    String apiurl = Strings.url+"/like_timeline";
    var response = null;
    try {
      Map data = {
        'username': username,
        'tid': tid,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
    } catch (e) {
    }
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      setState(() {
        list.first.timeline![id].likes=jsonBody["likes"];
      });
    }
  }

  unlike(int id, String tid) async {
    setState(() {
      list.first.timeline![id].isLiked="0";
    });
    String apiurl = Strings.url+"/unlike_timeline";
    var response = null;
    try {
      Map data = {
        'username': username,
        'tid': tid,
      };
      var body = json.encode(data);
      response = await http.post(Uri.parse(apiurl),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "$token"},
          body: body
      );
    } catch (e) {
    }
    if (response.statusCode == 200) {
      var jsonBody = json.decode(response.body);
      setState(() {
        list.first.timeline![id].likes=jsonBody["likes"];
      });
    }
  }

  block(BuildContext context, String user) async{
    QuickAlert.show(
        context: context,
        backgroundColor: kPrimaryDarkColor,
        type: QuickAlertType.confirm,
        title: 'Block User',
        titleColor: Colors.white,
        textColor: Colors.white,
        text: 'Are you sure you want to block @$user?',
        confirmBtnText: 'Block',
        cancelBtnText: 'Discard',
        confirmBtnColor: Colors.red,
        onConfirmBtnTap: () async {
          Navigator.pop(context);
          block_account(context, user);
          return;
        },
        onCancelBtnTap: (){
          Navigator.pop(context);
          return;
        }
    );
  }

  block_account(BuildContext context, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token=prefs.getString("token");
    String? email=prefs.getString("email");
    var response = null;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Blocking',
      text: 'Wait a few secs...',
    );
    try {
      response = await http.post(Uri.parse(Strings.url+"/block-user"),
          headers: {
            "Content-Type": "application/json",
            "Authentication": "Bearer $token"},
          body: json.encode({
            'email': email,
            'user': user,
          })
      );
      if (response != null && response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["status"] != null &&
            jsondata["status"].toString().contains("success")) {
          Navigator.pop(context);
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
