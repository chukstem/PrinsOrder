import 'package:cached_video_player_plus/cached_video_player_plus.dart';
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
  late CachedVideoPlayerPlusController controller;

  @override
  void initState() {
    super.initState();

    controller = new CachedVideoPlayerPlusController.networkUrl(
      //use widget.url for server file
      Uri.parse('https://download.samplelib.com/mp4/sample-5s.mp4'),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      invalidateCacheIfOlderThan: const Duration(days: 7),
    )..initialize().then((value) async {
      await controller.setLooping(true);
      //controller.play();
      //duration=controller.value.duration.toString();
      controller.addListener(() {
        setState(() {});
      });
      setState(() {});
    });


  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            height: 240,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(4)),
            child: Center(
              child: controller.value.isInitialized
                  ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRect(
                    child: Container(
                      child: Transform.scale(
                        scale: 1/controller.value.aspectRatio,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: CachedVideoPlayerPlus(controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _ControlsOverlay(controller: controller),
                  VideoProgressIndicator(controller, allowScrubbing: true, padding: EdgeInsets.all(5),),
                ],
              ) : const CircularProgressIndicator(),
            ),
          ),
        ]);
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    super.dispose();
  }



}


class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final CachedVideoPlayerPlusController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
                semanticLabel: 'Play',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}