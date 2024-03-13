import 'dart:async';
import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_app/models/timeline_hashtags_model.dart';
import 'package:crypto_app/screens/home/timeline_hashtags.dart';
import 'package:easy_load_more/easy_load_more.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypto_app/constants.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:video_player/video_player.dart';
import '../../helper/networklayer.dart';
import '../../models/timeline_model.dart';
import '../../strings.dart';
import '../../widgets/image.dart';
import '../../widgets/snackbar.dart';
import '../explore/ImageView.dart';
import '../explore/video_list_offline.dart';
import '../explore/video_player.dart';
import '../explore/view_timeline_screen.dart';
import '../profile/user_profile_screen.dart';


class Timeline extends StatefulWidget {
  bool loading;
  List<TimelineModel> tList;
  List<HashtagsModel> hList;
  Timeline({Key? key, required this.loading, required this.tList, required this.hList}) : super(key: key);

  @override
  _Timeline createState() => _Timeline();
}

class Item{
  const Item(this.name);
  final String name;
}


class _Timeline extends State<Timeline> {
  String token="", username="", errormsg="";
  bool error=false, showprogress=false, success=false;
  String currentTime = "0:00:00", search="";
  String completeTime = "0:00:00";

  Future<void> getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token")!;
      username = prefs.getString("username")!;
    });
  }


  Map<String, dynamic> cStates = {};
  String stateValue = NigerianStatesAndLGA.allStates[0];
  String lgaValue = 'Select LGA';
  List<String> statesLga = [];

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
  Item? state;
  List<Item> states=<Item>[
    const Item('Select State'),
    const Item('Abia'),
  ];
  Item? lga;
  List<Item> lgas=<Item>[
    const Item('Select LGA'),
    const Item('Abia'),
  ];

  String? selectedValue;

  fetchTimeline() async {
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), "ALL", "0");
      setState(() {
        widget.loading = false;
        widget.tList = iList;
      });

    }catch(e){
      setState(() {
        widget.loading = false;
      });
    }

  }


  searchList() async {
    if (search.isNotEmpty) {
      if (mounted) setState(() {
        widget.loading = true;
      });
      try {
        List<TimelineModel> iList = await getTimelineSearch(http.Client(), "", "", "", "", search);
        if (mounted) setState(() {
          widget.loading = false;
          widget.tList = iList;
        });
      } catch (e) {
        if (mounted) setState(() {
          widget.loading = false;
        });
      }
    }
  }

  searchList2() async {
    if(stateValue.isNotEmpty && lgaValue.isNotEmpty && type!=null && category!=null && !type!.name.contains("Category") && !category!.name.contains("Category")){
      if(mounted) setState(() {
        widget.loading = true;
      });
      try{
        List<TimelineModel> iList = await getTimelineSearch(http.Client(), stateValue, lgaValue, type!.name, category!.name, search);
        if(mounted) setState(() {
          widget.loading = false;
          widget.tList = iList;
        });

      }catch(e){
        if(mounted) setState(() {
          widget.loading = false;
        });
      }
    }
  }


  bool stopRefresh=false;
  addItems() async {
    int length=widget.tList.length+1;
    try{
      List<TimelineModel> iList = await getTimeline(http.Client(), "ALL", "$length");
      setState(() {
        widget.loading = false;
        widget.tList.addAll(iList);
        if(iList.isEmpty){
          stopRefresh=true;
        }
      });

    }catch(e){
      setState(() {
        widget.loading = false;
      });
    }

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




  @override
  void initState() {
    super.initState();
    getuser();
  }


  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return RefreshIndicator(
        onRefresh: () {
          return fetchTimeline();
        },
        child: SingleChildScrollView(
        padding: EdgeInsets.all(0),
        physics: NeverScrollableScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 5.0),
              ],
            ),
            child: CupertinoTextField(
              keyboardType: TextInputType.text,
              placeholder: 'Find Hashtags, People, Posts e.t.c',
              placeholderStyle: TextStyle(
                color: Color(0xffC4C6CC),
                fontSize: 14.0,
              ),
              suffix: InkWell(
                onTap: (){
                  if(mounted) setState(() {
                    widget.loading=true;
                  });
                  searchList();
                },
                child: Container(
                  height: 40,
                  width: 80,
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.only(top: 2, bottom: 2, right: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: kPrimaryLightColor,
                  ),
                  child: Center(
                    child: Text("Search", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
              onChanged: (value){
                search=value;
              },
              prefix: InkWell(
                onTap: (){
                  showFilter(context);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 5.0),
                  child: Icon(
                    Icons.filter_list_sharp,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
            ),
          ),
          widget.loading ? Container(
              height: 300,
              color: Colors.white,
              margin: EdgeInsets.only(top: 20),
              child: Center(
                  child: CircularProgressIndicator()))
              :
          widget.hList!.length <= 0 ?
          SizedBox() :
          Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "Trending Hashtags",
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 20.0,
                  color: kPrimaryDarkColor,
                  fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Column(
            children: [
              widget.hList!.length <= 0 ?
              SizedBox() :
              widget.loading? SizedBox() :
              ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 0),
                  itemCount: widget.hList!.length,
                  itemBuilder: (context, index) {
                    return getHashtagItem(
                        widget.hList![index], index, context);
                  }),

              !widget.loading && widget.tList!.length <= 0 ?
              Container(
                height: 80,
                color: Colors.white,
                margin: EdgeInsets.all(20),
                child: Center(
                  child: Text("Empty!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
                ),
              )
                  :
              widget.loading? SizedBox() :
              EasyLoadMore(
                isFinished: widget.tList!.length < 30 || widget.tList!.length >= 500 || stopRefresh,
                onLoadMore: _loadMore,
                runOnEmptyResult: false,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 0),
                    itemCount: widget.tList!.length,
                    itemBuilder: (context, index) {
                      return getTimelineItem(
                          widget.tList![index], index, context);
                    }),
              ),
            ],
          )
        ]),)
    );
  }




  InkWell getTimelineItem(TimelineModel obj, int index, BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => ViewTimelineScreen(model: obj, isTimeline: false,)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Card(
              margin: EdgeInsets.only(left: 10.0, right: 10, bottom: 10, top: 5),
              color: Colors.white,
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5, top: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              ImagePreview().preview(context, obj.userModel.first.avatar, setState);
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
                          SizedBox(width: 5,),
                          Container(
                              margin: EdgeInsets.only(left: 5),
                              alignment: Alignment.topLeft,
                              width: MediaQuery.of(context).size.width*0.50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: MediaQuery.of(context).size.width*0.10,
                                    child: Text(
                                      obj.date,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black45,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                      obj.imagesModel.isNotEmpty?
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 5, top: 2),
                          child: Center(
                            child: obj.imagesModel.length>1?
                            PhotoGrid(
                              imageUrls: obj.imagesModel,
                              onImageClicked: (i) => ImagePreview().preview(context, obj.imagesModel[i].url, setState),
                              onExpandClicked: () => print('Expand Image was clicked'),
                              maxImages: 4,
                            ) : Container(
                              constraints: BoxConstraints(
                                  maxHeight: 300
                              ),
                              child: InkWell(
                                child: CachedNetworkImage(
                                  imageUrl: obj.imagesModel.first.url,
                                  fit: BoxFit.cover,
                                ),
                                onTap: () => ImagePreview().preview(context, obj.imagesModel.first.url, setState),
                              ),
                            ),
                          ),
                        ),
                      ) : SizedBox(),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 5, top: 10, bottom: 10),
                        child: Text(obj.content,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 6,
                        ),
                      ),
                      obj.mediaModel.isEmpty ?
                      SizedBox() :
                      obj.mediaModel[0].type.contains("video") ?
                      Container(
                        margin: EdgeInsets.only(top: 2, bottom: 10),
                        child: VideoPlayerLib(url: obj.mediaModel[0].url),
                      ) : SizedBox(),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: obj.price.length>2?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₦'+obj.price,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                obj.isLiked=="1" ?
                                unlike(index, obj.id) : like(index, obj.id);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  obj.isLiked=="1" ? Icon(Icons.favorite, color: Colors.red, size: 20,) : Icon(Icons.favorite, size: 20,),
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
                        ) :
                        Row(
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
                                  obj.isLiked=="1" ? Icon(Icons.favorite, color: Colors.red, size: 20,) : Icon(Icons.favorite, size: 20,),
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
        ],
      ),
    );
  }



  like(int id, String tid) async {
    setState(() {
      widget.tList[id].isLiked="1";
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
        widget.tList[id].likes=jsonBody["likes"];
      });
    }
  }

  unlike(int id, String tid) async {
    setState(() {
      widget.tList[id].isLiked="0";
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
        widget.tList[id].likes=jsonBody["likes"];
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

  Widget getHashtagItem(HashtagsModel hashtagsModel, int index, BuildContext context) {
    return InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute<dynamic>(builder: (BuildContext context) => TimelineHashtags(subject: hashtagsModel.subject,)));
    },
    child: Card(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
            child: Text(
              widget.hList![index].subject,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 17.0,
                color: kPrimaryDarkColor,
                fontWeight: FontWeight.bold
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 10),
            child: Text(
              widget.hList![index].total,
              textAlign: TextAlign.start,
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
      ),
    );
  }


  showFilter(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(5),
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
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(5),
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
                        SizedBox(height: 5,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.90,
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: kPrimary,
                              minimumSize: const Size.fromHeight(
                                  60), // fromHeight use double.infinity as width and 40 is the height
                            ),
                            child: widget.loading?
                            const SizedBox(
                              height:20, width:20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                              ),
                            ) : const Text(
                              'Search',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: (){
                              if(!widget.loading) {
                                searchList2();
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20,),
                      ],
                    )),
              );
            });
      },
    );
  }
}
