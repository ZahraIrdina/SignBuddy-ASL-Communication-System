import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SignVideoPlayer extends StatefulWidget {
  final String path;

  const SignVideoPlayer({
    super.key,
    required this.path,
  });

  @override
  State<SignVideoPlayer> createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.path)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      }).catchError((error) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Video cannot load:\n${widget.path}',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: 220,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          icon: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
          label: Text(
            _controller.value.isPlaying ? 'Pause' : 'Play',
          ),
        ),
      ],
    );
  }
}
