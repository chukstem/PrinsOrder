import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../models/notifications_model.dart';
import '../../constants.dart';
import '../../helper/networklayer.dart';
import '../../widgets/appbar.dart';

class Notifications extends StatefulWidget {
  static String routeName = "/notifications";
  Notifications({Key? key}) : super(key: key);

  @override
  _Notifications createState() => _Notifications();
}

class _Notifications extends State<Notifications> {
  List<NotificationsModel> aList = List.empty(growable: true);
  bool loading=true;


  fetchList() async {
    loading = true;
    try {
      List<NotificationsModel> iList = await getNotifications(
          new http.Client());
      setState(() {
        aList = iList;
      });
    }catch(e){

    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () =>
    {
      fetchList()
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFf2f2f2),
        body: Container(
        constraints: BoxConstraints(
        minHeight: 500, minWidth: double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            backAppbar(context, "Notifications"),
            SizedBox(
              height: 20,
            ),
            loading? Container(
                margin: const EdgeInsets.all(20),
                child: const Center(
                    child: CircularProgressIndicator()))
                :
            aList.length <= 0 ?
            Container(
              height: 200,
              margin: EdgeInsets.all(20),
              child: Center(
                child: Text("No Notification Yet!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor),),
              ),
            )
                :
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(0),
                physics: BouncingScrollPhysics(),
                child: Column(
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
                ),
              ),
            ),
          ],
        )));
  }

  showAlertDialog(BuildContext context, String title, String msg){
    Widget cancel=ElevatedButton(onPressed: (){
      Navigator.of(context).pop();
    }, child: Text("Close"));
    AlertDialog alert=AlertDialog(
      insetPadding: EdgeInsets.all(10),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Text(msg, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
        ),
      ),
      actions: [cancel],
    );
    showDialog(context: context,
      builder: (BuildContext context){
        return alert;
      },
    );
  }
  Container getListItem(NotificationsModel obj, int index, BuildContext context) {
    return Container(
      child: Card(
        margin: const EdgeInsets.only(
          bottom: 5,
          top: 5,
          left: 10,
          right: 10,
        ),
        elevation: 2,
        child: InkWell(
          onTap: () {
            showAlertDialog(context, obj.title, obj.desc);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: new CircleAvatar(
                            maxRadius: 33,
                            minRadius: 33,
                            child: Icon(
                              Icons.notifications,
                              size: 35,
                              color: yellow80,
                            ),
                            backgroundColor: Colors.white),
                        padding: EdgeInsets.all(1.0),
                        margin: EdgeInsets.only(left: 2, right: 3),
                        decoration: new BoxDecoration(
                          color: Colors.white, // border color
                          shape: BoxShape.circle,
                        )),
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            obj.title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          SizedBox(height: 7,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
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
                              InkWell(
                                onTap: () {
                                  showAlertDialog(context, obj.title, obj.desc);
                                },
                                child: Text(
                                  "Read More",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

}