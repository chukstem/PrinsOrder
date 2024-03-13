import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:crypto_app/models/timeline_images_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';
import '../../models/post.dart';
import '../../widgets/appbar.dart';
import '../../widgets/snackbar.dart';
import '../explore/ImageView.dart';
import '../explore/video_list_offline.dart';

class NewPost extends StatefulWidget {
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  bool progress=false, error=false;
  String content="", videoPath="", audioPath="", price="";
  final controller = TextEditingController();
  List<TimelineImagesModel> images = List.empty(growable: true);
  String currentTime = "0:00:00";
  String completeTime = "0:00:00", errormsg="";
  int playingstatus=0;

  Future<int> getSdkVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt;
  }



  post() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (content.isNotEmpty) {
    String path="";
    if(audioPath.isNotEmpty) {
      setState(() {
        path = path.isEmpty? '{"audio": "$audioPath"}' : '$path, {"audio": "$audioPath"}';
      });
    }
    if(videoPath.isNotEmpty) {
      setState(() {
        path = path.isEmpty? '{"video": "$videoPath"}' : '$path, {"video": "$videoPath"}';
      });
    }

    if(images.isNotEmpty) {
      String path2 = "";
      for (var image in images) {
        setState(() {
          path2 = path2.isEmpty ? '{"url": "${image.url}"}' : '$path2, {"url": "${image.url}"}';
        });
      }
      setState(() {
        path = path.isEmpty ? '{"images": [$path2]}' : '$path, {"images": [$path2]}';
      });
    }
    setState(() {
      path="[$path]";
    });


    List<Post> posts = List.empty(growable: true);
    posts.add(Post(user: "$price", content: "$content", url: "/post_timeline", var1: "$path", retries: 0,
        uid: Uuid().v4()));

    prefs.setString("queued_posts", jsonEncode(posts));
     Toast.show("Uploading post...", duration: Toast.lengthLong, gravity: Toast.bottom);
     Navigator.of(context).pop();
    }else{
      Snackbar().show(context, ContentType.failure, "Error!", "Post body can not be empty");
    }

  }

  final ImagePicker _picker = ImagePicker();



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: kPrimaryColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          backAppbar(context, "Add New Post"),
          SizedBox(
            height: 20,
          ),
          FutureBuilder<void>(
            future: retrieveLostData(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const SizedBox();
                case ConnectionState.done:
                  return SizedBox();
                case ConnectionState.active:
                  if (snapshot.hasError) {
                    return SizedBox();
                  } else {
                    return const SizedBox();
                  }
              }
            },
          ),
          Padding(
            padding:
            const EdgeInsets.only(
                top: 10, right: 20, left: 20),
            child: TextField(
              minLines: 6,
              controller: controller,
              maxLines: 20,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Write something...",
                isDense: true,
                // now you can customize it here or add padding widget
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  content = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Price (optional)",
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  price = "$value";
                });
              },
            ),
          ),
          images.isNotEmpty?
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(left: 10, top: 2, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhotoGrid(
                  imageUrls: images,
                  onImageClicked: (i) => print('Image $i was clicked!'),
                  onExpandClicked: () => print('Expand Image was clicked'),
                  maxImages: 4,
                ),
              ],
            ),
          ) : SizedBox(),
          videoPath.isNotEmpty?
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            child: VideoPlayerLibOffline(url: videoPath),
          ) : SizedBox(),
          audioPath.isNotEmpty ?
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
                        Icons.stop,
                        color: Colors.white,  size: 25,
                      ),
                      onTap: () {
                        setState(() {
                           playingstatus = 0;
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
            margin: EdgeInsets.only(left: 40, top: 20, right: 40),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    if(audioPath.isEmpty && videoPath.isEmpty){
                      if(images.length<4) {
                        if(Platform.isAndroid && await getSdkVersion() <= 30){
                          FilePickerResult? res = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'png', 'jpeg'],
                          );
                          if (res != null) {
                            setState(() {
                              images.add(new TimelineImagesModel(url: res.files.first.path!));
                            });
                          }
                        }else{
                          XFile? res = await _picker.pickImage(source: ImageSource.gallery);
                          if (res != null) {
                            setState(() {
                              images.add(new TimelineImagesModel(url: res.path));
                            });
                          }
                        }
                      }else{
                        Toast.show("Maximum of 4 images", duration: Toast.lengthLong, gravity: Toast.bottom);
                      }
                    }else{
                      Toast.show("Only 1 media type is allowed.", duration: Toast.lengthLong, gravity: Toast.bottom);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 20,),
                      SizedBox(width: 5,),
                      Text(
                        "Select Images",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                     if(images.isEmpty && audioPath.isEmpty){
                       try {
                         final ImagePicker _picker = ImagePicker();
                         XFile? res = await _picker.pickVideo(
                             source: ImageSource.gallery,
                             maxDuration: Duration(minutes: 5));
                         if (res != null) {
                           setState(() {
                             videoPath = res.path;
                           });
                         }
                       }catch(e){ }

                     }else{
                       Toast.show("Only 1 media type is allowed.", duration: Toast.lengthLong, gravity: Toast.bottom);
                     }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_collection, size: 20,),
                      SizedBox(width: 5,),
                      Text(
                        "Select Video",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(
                  top: 20, right: 20, left: 20, bottom: 25),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: kPrimaryDarkColor,
                  minimumSize: const Size.fromHeight(
                      40), // fromHeight use double.infinity as width and 40 is the height
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  post();
                },
              )),
        ],
      ),
      ),
    );
  }



  Future<void> retrieveLostData() async {
    try{
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return;
      }
      if (response.file != null) {
        if (response.type == RetrieveType.video) {
          setState(() {
            videoPath = response.file!.path;
          });
        } else if (response.type == RetrieveType.image) {
          {
            setState(() {
              if (response.files == null) {
                images.add(new TimelineImagesModel(url: response.file!.path));
              }
            });
          }
        } else {}
      }
    }catch(e){}

  }


}
