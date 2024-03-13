import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

class VideoPlayerLib extends StatefulWidget {
  final String url;
  const VideoPlayerLib(
      {Key? key, required this.url})
      : super(key: key);

  @override
  _VideoPlayerLibState createState() => _VideoPlayerLibState();
}

class _VideoPlayerLibState extends State<VideoPlayerLib> {
  late BetterPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = BetterPlayerController(
      BetterPlayerConfiguration(
          autoDispose: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            controlsHideTime: const Duration(seconds: 1),
          ),
          aspectRatio: 1,
          looping: true,
          fullScreenAspectRatio: 1,
          autoPlay: false),
      betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.url,
          /*
          bufferingConfiguration: BetterPlayerBufferingConfiguration(
              minBufferMs: 2000,
              maxBufferMs: 10000,
              bufferForPlaybackMs: 1000,
              bufferForPlaybackAfterRebufferMs: 2000),
*/
        cacheConfiguration: BetterPlayerCacheConfiguration(useCache: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: BetterPlayer(controller: _videoController),
      ),
    );
  }


  @override
  void dispose() {
    _videoController.pause();
    //_videoController.dispose();
    super.dispose();
  }



}


