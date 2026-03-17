import 'dart:js_interop';

// Use eval to create and control audio - simplest approach that works
@JS('eval')
external JSAny? _eval(JSString code);

void playAudioWeb(String url) {
  try {
    // Stop previous audio if any
    _eval('if(window._bgm){window._bgm.pause();}'.toJS);
    // Create new audio and play
    _eval('window._bgm=new Audio("$url");window._bgm.volume=1.0;window._bgm.play();'.toJS);
  } catch (_) {}
}

void pauseAudioWeb() {
  try {
    _eval('if(window._bgm){window._bgm.pause();}'.toJS);
  } catch (_) {}
}
