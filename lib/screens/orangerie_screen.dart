import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html' as html;
import '../config/constants.dart';

class OrangerieScreen extends StatefulWidget {
  const OrangerieScreen({super.key});

  @override
  State<OrangerieScreen> createState() => _OrangerieScreenState();
}

class _OrangerieScreenState extends State<OrangerieScreen> {
  // Unique view type per build to bust cache
  static final _viewType = 'orangerie-iframe-${DateTime.now().millisecondsSinceEpoch}';
  static bool _registered = false;

  @override
  void initState() {
    super.initState();
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) {
          final cacheBuster = DateTime.now().millisecondsSinceEpoch;
          final iframe = html.IFrameElement()
            ..src = 'orangerie.html?v=$cacheBuster&proxy=${Uri.encodeComponent(kBotBaseUrl)}'
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true
            ..setAttribute('allow', 'accelerometer; gyroscope');
          return iframe;
        },
      );
      _registered = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
