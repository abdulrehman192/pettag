import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pettag/screens/image_zoon_screen.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:video_player/video_player.dart';

class WallCard extends StatefulWidget {
  const WallCard({Key? key, required this.postPicture,required this.play}) : super(key: key);
  final String postPicture;
  final bool play;
  @override
  State<WallCard> createState() => _WallCardState();
}

class _WallCardState extends State<WallCard> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.postPicture);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(WallCard oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (widget.postPicture.contains(".jpg")) {
              return GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, ImageZoomScreen.imageZoomScreenRoute,
                  arguments: widget.postPicture);
                },
                  child: CachedNetworkImage(imageUrl: widget.postPicture,fit: BoxFit.cover,)
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return VideoPlayer(_controller);
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        // child: widget.postPicture != null
        //     ? widget.postPicture.contains(".mp4")
        //         ? FutureBuilder(
        //             builder: (context, AsyncSnapshot<String> snapshot) {
        //               if (snapshot.hasData) {
        //                 return GestureDetector(
        //                   onTap: () {
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) => VideoPlayerScreen(
        //                           videoUrl: widget.postPicture,
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                   child: Image.file(
        //                     File(snapshot.data),
        //                     fit: BoxFit.cover,
        //                   ),
        //                 );
        //               }
        //               return const Center(child: CircularProgressIndicator());
        //             },
        //             future: getThumb(data['postPicture']),
        //           )
        //         : CachedNetworkImage(
        //             imageUrl: data['postPicture'],
        //             fit: BoxFit.cover,
        //           )
        //     : Container(),
      ),
    );
  }
}
