import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;

  const VideoWidget({Key? key, required this.url,required this.play}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  double volume = 0;
  Icon volIcon = const Icon(Icons.volume_up_sharp);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    volume = 1.0;

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
  void didUpdateWidget(VideoWidget oldWidget) {
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
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              VideoPlayer(_controller),
              Positioned(
                right: 16,
                bottom: 16,
                child: InkWell(
                  onTap: (){
                    setState(() {
                      if(volume == 1.0){
                        _controller.setVolume(0.0);
                        volume = 0.0;
                        volIcon = const Icon(Icons.volume_off_sharp);
                      }
                      else{
                        _controller.setVolume(1.0);
                        volume = 1.0;
                        volIcon = const Icon(Icons.volume_up_sharp);
                      }
                    });
                  },
                  child: Container(
                    height: 27,
                    width: 27,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: volIcon,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
