import 'package:video_player/video_player.dart';
// ignore_for_file: must_be_immutable, unused_field, library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';

class VideoApp extends StatefulWidget {
  String _video_url;
  String _title;
  String _description;
  @override
  _VideoAppState createState() =>
      _VideoAppState(this._video_url, this._title, this._description);

  VideoApp(this._video_url, this._title, this._description);
}

class _VideoAppState extends State<VideoApp> {
  final String _video_url;
  final String _title;
  final String _description;

  _VideoAppState(this._video_url, this._title, this._description);

  late VideoPlayerController _controller;
  //  start() async{
  //   _controller = VideoPlayerController.network(_video_url)
  //     ..initialize();
  //
  //
  //
  // }

  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_video_url);

    _controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
