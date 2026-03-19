import 'dart:js_interop';
import 'package:http/http.dart' as http;
import 'dart:convert';

@JS('eval')
external JSAny? _eval(JSString code);

bool _speaking = false;

Future<void> speakText(String text) async {
  _speaking = true;
  try {
    // Call TTS proxy API
    final response = await http.post(
      Uri.parse('https://impressionist-bot.vercel.app/api/tts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final audioBase64 = data['audioContent'] as String;
      // Play audio via HTML Audio element
      _eval('''
        if(window._ttsAudio){window._ttsAudio.pause();}
        window._ttsAudio=new Audio("data:audio/mp3;base64,$audioBase64");
        window._ttsAudio.onended=function(){window._ttsSpeaking=false;};
        window._ttsAudio.play();
        window._ttsSpeaking=true;
      '''.toJS);
    } else {
      // Fallback to Web Speech API
      _speakFallback(text);
    }
  } catch (_) {
    // Fallback to Web Speech API
    _speakFallback(text);
  }
}

void _speakFallback(String text) {
  final escaped = text.replaceAll("'", "\\'").replaceAll('\n', ' ');
  _eval('''
    window.speechSynthesis.cancel();
    var u = new SpeechSynthesisUtterance('$escaped');
    u.lang = 'ja-JP';
    u.rate = 0.9;
    window.speechSynthesis.speak(u);
  '''.toJS);
}

void stopSpeaking() {
  _speaking = false;
  _eval('''
    if(window._ttsAudio){window._ttsAudio.pause();window._ttsAudio=null;}
    window.speechSynthesis.cancel();
    window._ttsSpeaking=false;
  '''.toJS);
}

bool isSpeakingNow() {
  final result = _eval('window._ttsSpeaking || window.speechSynthesis.speaking'.toJS);
  if (result == null) return _speaking;
  return (result as JSBoolean).toDart;
}
