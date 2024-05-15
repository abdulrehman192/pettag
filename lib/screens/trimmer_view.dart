import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;

  const TrimmerView(this._trimmer, {super.key});

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String value = '';

    await widget._trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        storageDir: StorageDir.temporaryDirectory,

      onSave: (String? outputPath) {
          setState(() {
            value = outputPath!;
          });
      },
       );

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: GestureDetector(
              onTap: _progressVisibility
                  ? null
                  : () async {
                      _saveVideo().then((outputPath) {
                        Navigator.of(context).pop(outputPath);
                      });
                    },
              child: const Icon(Icons.done),
            ),
          )
        ],
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      VideoViewer(trimmer: widget._trimmer,),
                      Center(
                          child: ElevatedButton(
                        child: _isPlaying
                            ? const Icon(
                                Icons.pause,
                                size: 80.0,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.play_arrow,
                                size: 80.0,
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          bool playbackState = await widget._trimmer.videoPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );
                          setState(() {
                            _isPlaying = playbackState;
                          });
                        },
                      ))
                    ],
                  ),
                ),
                Center(
                  child: TrimViewer(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 30),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    }, trimmer: widget._trimmer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
