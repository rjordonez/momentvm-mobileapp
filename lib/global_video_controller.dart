import 'package:video_player/video_player.dart';

class GlobalVideoController {
  static final GlobalVideoController _instance = GlobalVideoController._internal();

  factory GlobalVideoController() {
    return _instance;
  }

  late VideoPlayerController controller;

  GlobalVideoController._internal() {
    // Initialize your controller here
    controller = VideoPlayerController.asset('assets/video1.mp4')
      ..initialize().then((_) {
        controller.play();
      });
  }

  void dispose() {
    controller.dispose();
  }
}
