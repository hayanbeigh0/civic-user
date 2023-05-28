import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../models/grievances/grievance_detail.dart';
import '../presentation/utils/colors/app_colors.dart';
import '../presentation/utils/functions/date_formatter.dart';
import '../presentation/utils/styles/app_styles.dart';

class VideoCommentWidget extends StatefulWidget {
  const VideoCommentWidget({
    super.key,
    required this.commentList,
    required this.commentListIndex,
  });
  final List<Comments> commentList;
  final int commentListIndex;

  @override
  State<VideoCommentWidget> createState() => _VideoCommentWidgetState();
}

class _VideoCommentWidgetState extends State<VideoCommentWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  @override
  void initState() {
    _controller = VideoPlayerController.network(widget
        .commentList[widget.commentListIndex].assets!.video![0]
        .toString())
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          isPlaying = false;
        });
      });
    _controller.addListener(() {
      if (!_controller.value.isPlaying) {
        setState(() {
          isPlaying = false;
        });
      } else {
        setState(() {
          isPlaying = true;
        });
      }
      if (_controller.value.position == _controller.value.duration) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    _chewieController = ChewieController(
      videoPlayerController: _controller,
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
    super.initState();
  }

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: widget.commentList[widget.commentListIndex].commentedBy ==
                  AuthBasedRouting.afterLogin.userDetails!.userID
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            // height: 150.h,
            width: 200.w,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.colorPrimary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  // height: 150.h,
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                      icon: isPlaying
                          ? const SizedBox()
                          : Icon(
                              Icons.play_arrow,
                              color: AppColors.colorWhite,
                              size: 50.sp,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => FullScreenVideoPlayer(
                        //       chewieController: _chewieController,
                        //       videoPlayerController: _controller,
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
                Positioned(
                  right: 5.w,
                  bottom: 5.h,
                  child: Container(
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      color: AppColors.colorBlack200,
                      borderRadius: BorderRadius.circular(
                        10.r,
                      ),
                    ),
                    child: Text(
                      DateFormatter.formatDateTime(
                        widget.commentList[widget.commentListIndex].createdDate
                            .toString(),
                      ),
                      style: AppStyles.dateTextWhiteStyle,
                    ),
                  ),
                ),
                Positioned(
                  left: 5.w,
                  top: 5.h,
                  child:
                      widget.commentList[widget.commentListIndex].commentedBy ==
                              AuthBasedRouting.afterLogin.userDetails!.userID
                          ? const SizedBox()
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3.sp),
                                  alignment: Alignment.topLeft,
                                  decoration: BoxDecoration(
                                    color: AppColors.colorBlack200,
                                    borderRadius: BorderRadius.circular(
                                      10.r,
                                    ),
                                  ),
                                  child: Text(
                                    '~ ${widget.commentList[widget.commentListIndex].commentedByName}',
                                    style: TextStyle(
                                      overflow: TextOverflow.fade,
                                      color: AppColors.colorWhite,
                                      fontFamily: 'LexendDeca',
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
