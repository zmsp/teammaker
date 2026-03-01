import 'package:video_player/video_player.dart';
// ignore_for_file: must_be_immutable, unused_field, library_private_types_in_public_api, depend_on_referenced_packages
import 'package:flutter/material.dart';

class VideoApp extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;

  const VideoApp({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.description,
  });

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Center(child: CircularProgressIndicator()),
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
    _controller.dispose();
    super.dispose();
  }
}
