import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerLibOffline extends StatefulWidget {
  final String url;
  const VideoPlayerLibOffline(
      {Key? key, required this.url})
      : super(key: key);

  @override
  _VideoPlayerLibOfflineState createState() => _VideoPlayerLibOfflineState();
}

class _VideoPlayerLibOfflineState extends State<VideoPlayerLibOffline> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  _VideoPlayerLibOfflineState();
  final CustomVideoPlayerSettings _customVideoPlayerSettings =
  CustomVideoPlayerSettings(showSeekButtons: true, placeholderWidget: CircularProgressIndicator(), customAspectRatio: 3/2);

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(widget.url))
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController,
      customVideoPlayerSettings: _customVideoPlayerSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: CustomVideoPlayer(
            key: widget.key,
            customVideoPlayerController: _customVideoPlayerController
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    _customVideoPlayerController.dispose();
    super.dispose();
  }
}