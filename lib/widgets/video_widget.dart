import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../presentation/utils/colors/app_colors.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.url,
  });
  final String url;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  bool isPlaying = false;
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
      widget.url,
    );
    _videoPlayerController.setVolume(0);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      allowMuting: true,
      looping: false,
      showControls: false,
      aspectRatio: 1,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
    );
  }

  @override
  void dispose() {
    // Dispose the chewie and video player controllers when the widget is disposed
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            // height: 150.h,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    // FullScreenVideo(
                    //       videoUrl: widget.url,
                    //     )));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenVideoPlayer(
                          url: widget.url,
                          file: null,
                        ),
                      ),
                    );
                  },
                  child: Chewie(
                    controller: _chewieController,
                  ),
                ),
                Positioned(
                  // top: 0,
                  bottom: 0,
                  right: 0,
                  // left: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => FullScreenVideoPlayer(
                        //       chewieController: _chewieController,
                        //       videoPlayerController: _videoPlayerController, file: null,
                        //     ),
                        //   ),
                        // );
                      },
                      icon: Icon(
                        Icons.fullscreen,
                        color: AppColors.colorWhite,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  File? file;
  String? url;
  FullScreenVideoPlayer({
    Key? key,
    // required this.chewieController,
    // required this.videoPlayerController,

    required this.file,
    required this.url,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;
  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      videoPlayerController = VideoPlayerController.file(
        widget.file!,
      );
    } else {
      videoPlayerController =
          VideoPlayerController.network(widget.url.toString());
    }
    videoPlayerController.setVolume(50);
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      fullScreenByDefault: true,
      autoInitialize: true,
      allowFullScreen: true,
      zoomAndPan: true,
      autoPlay: true,
      allowMuting: true,
      looping: false,
      showControls: true,
      aspectRatio: 1,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ],
    );
    chewieController.enterFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.0.sp),
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: Chewie(
                  controller: chewieController,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 24.sp,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }
}

class FullScreenVideo extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FullScreenVideoState createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<FullScreenVideo> {
  late VideoPlayerController _controller;
  bool _isPortrait = true;

  void _playVideo({String vidUrl = '', bool init = false}) {
    _controller = VideoPlayerController.network(vidUrl)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((value) => _controller.play());
  }

  String _videoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  @override
  void initState() {
    super.initState();
    _playVideo(vidUrl: widget.videoUrl, init: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: _controller.value.isInitialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: _isPortrait ? 0 : 3,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, VideoPlayerValue value, child) {
                              return Text(
                                _videoDuration(value.position),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                ),
                              );
                            }),
                        Expanded(
                          child: SizedBox(
                            height: 20.h,
                            child: VideoProgressIndicator(
                              _controller,
                              colors: const VideoProgressColors(
                                  playedColor: AppColors.colorPrimary,
                                  backgroundColor: AppColors.colorGreyLight),
                              allowScrubbing: true,
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12.h),
                            ),
                          ),
                        ),
                        Text(
                          _videoDuration(_controller.value.duration),
                          style:
                              TextStyle(color: Colors.white, fontSize: 20.sp),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play(),
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.colorPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
