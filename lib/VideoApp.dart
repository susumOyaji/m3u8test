class VideoApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    _VideoAppState();
  }

}
class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.initialized
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
and chrome console getting following error
Error: Expected a value of type 'PlatformException', but got one of type 'Event$'
    at Object.throw_ [as throw] (errors.dart:196)
    at Object.castError (errors.dart:45)
    at Object.cast [as as] (operations.dart:426)
    at Function.check_C [as _check] (classes.dart:522)
    at errorListener (video_player.dart:272)
    at _RootZone.runUnaryGuarded (zone.dart:1316)
    at sendError (stream_impl.dart:361)
    at _ControllerSubscription.new.[_sendError] (stream_impl.dart:376)
    at async._DelayedError.new.perform (stream_impl.dart:605)
    at _StreamImplEvents.new.handleNext (stream_impl.dart:710)
    at async._AsyncCallbackEntry.new.callback (stream_impl.dart:670)
    at Object._microtaskLoop (schedule_microtask.dart:43)
    at _startMicrotaskLoop (schedule_microtask.dart:52)
    at async_patch.dart:168