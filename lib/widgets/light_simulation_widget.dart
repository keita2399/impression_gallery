import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sensors_plus/sensors_plus.dart';
import '../services/art_api.dart';

/// Light simulation widget using Fragment Shader
/// Native only - not supported on Web
class LightSimulationWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const LightSimulationWidget({
    super.key,
    required this.imageUrl,
    required this.onClose,
  });

  @override
  State<LightSimulationWidget> createState() => _LightSimulationWidgetState();
}

class _LightSimulationWidgetState extends State<LightSimulationWidget>
    with TickerProviderStateMixin {
  ui.FragmentShader? _shader;
  ui.Image? _image;
  bool _loading = true;
  String? _error;

  // Light parameters
  Offset _lightPos = const Offset(0.5, 0.3);
  double _lightRadius = 0.8;
  double _ambient = 0.3;
  double _intensity = 0.8;
  bool _showControls = true;
  bool _showIntro = true;
  bool _userTouched = false;

  // Color temperature presets
  int _colorPresetIndex = 0;
  static const _colorPresets = <_ColorPreset>[
    _ColorPreset('ろうそく',   Color(0xFFFFD2A0), 1.0, 0.95, 0.75),
    _ColorPreset('暖色',      Color(0xFFFFF0D6), 1.0, 0.95, 0.85),
    _ColorPreset('自然光',    Color(0xFFFFFFF0), 1.0, 1.0,  0.96),
    _ColorPreset('昼白色',    Color(0xFFE8F0FF), 0.92, 0.95, 1.0),
    _ColorPreset('月明かり',  Color(0xFFD0D8FF), 0.85, 0.88, 1.0),
  ];

  // Auto-demo animation
  AnimationController? _demoController;
  // Intro fade animation
  AnimationController? _introFadeController;

  // Sensor mode
  bool _sensorMode = false;
  bool _sensorAvailable = false;
  StreamSubscription<AccelerometerEvent>? _sensorSub;
  // Low-pass filtered sensor values
  double _filteredX = 0.0;
  double _filteredY = 0.0;

  @override
  void initState() {
    super.initState();
    _loadResources();
    _checkSensor();
  }

  Future<void> _checkSensor() async {
    // Check if accelerometer is available
    try {
      final sub = accelerometerEventStream().listen((_) {});
      await Future.delayed(const Duration(milliseconds: 200));
      await sub.cancel();
      if (mounted) setState(() => _sensorAvailable = true);
    } catch (_) {
      // Sensor not available (e.g. Kindle Fire without accelerometer)
    }
  }

  void _startSensorMode() {
    if (!_sensorAvailable) return;
    _sensorMode = true;
    _userTouched = true;
    _demoController?.stop();
    setState(() => _showIntro = false);

    _sensorSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 30),
    ).listen((event) {
      if (!mounted || !_sensorMode) return;
      // Accelerometer: x = left/right tilt, y = forward/back tilt
      // When device is flat: x~0, y~0, z~9.8
      // Tilt right: x becomes negative, Tilt left: x becomes positive
      // Tilt forward (top away): y becomes positive
      // Map to 0..1 range with sensitivity. atan2 gives stable angle.
      const alpha = 0.15; // Low-pass filter strength
      _filteredX = _filteredX * (1 - alpha) + event.x * alpha;
      _filteredY = _filteredY * (1 - alpha) + event.y * alpha;

      // Convert to normalized position (0-1)
      // x: -9.8..+9.8 → map ±4 range to 0..1
      // Negate x so tilting right moves light right
      final nx = (0.5 - _filteredX / 8.0).clamp(0.0, 1.0);
      // y: tilting forward (positive y) moves light up
      final ny = (0.5 - _filteredY / 8.0).clamp(0.0, 1.0);

      setState(() {
        _lightPos = Offset(nx, ny);
      });
    });
  }

  void _stopSensorMode() {
    _sensorSub?.cancel();
    _sensorSub = null;
    _sensorMode = false;
  }

  void _startDemo() {
    // Auto-demo: light moves in a gentle circle to show the effect
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (!_userTouched && mounted) {
          final t = _demoController!.value * 2 * pi;
          setState(() {
            _lightPos = Offset(
              0.5 + 0.25 * cos(t),
              0.4 + 0.15 * sin(t),
            );
          });
        }
      });
    _demoController!.repeat();

    // Fade out intro after 3 seconds
    _introFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showIntro) {
        _introFadeController!.forward().then((_) {
          if (mounted) setState(() => _showIntro = false);
        });
      }
    });
  }

  void _onUserTouch(Offset localPos, Size boxSize) {
    if (_sensorMode) {
      _stopSensorMode();
      setState(() {});
    }
    if (!_userTouched) {
      _userTouched = true;
      _demoController?.stop();
      setState(() => _showIntro = false);
    }
    setState(() {
      _lightPos = Offset(
        (localPos.dx / boxSize.width).clamp(0.0, 1.0),
        (localPos.dy / boxSize.height).clamp(0.0, 1.0),
      );
    });
  }

  Future<void> _loadResources() async {
    try {
      // Load shader
      final program = await ui.FragmentProgram.fromAsset('shaders/lighting.frag');
      _shader = program.fragmentShader();

      // Load image as dart:ui Image
      final completer = Completer<ui.Image>();
      final imageProvider = NetworkImage(widget.imageUrl, headers: ArtApi.imageHeaders);
      final stream = imageProvider.resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          completer.complete(info.image.clone());
          stream.removeListener(listener);
        },
        onError: (error, _) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);
      _image = await completer.future;

      if (mounted) {
        setState(() => _loading = false);
        _startDemo();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    _shader?.dispose();
    _image?.dispose();
    _demoController?.dispose();
    _introFadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(
        child: Text('この機能はネイティブアプリ専用です',
            style: TextStyle(color: Colors.white70)),
      );
    }

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('光シミュレーションを準備中...',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (_error != null || _shader == null || _image == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text('読み込みに失敗しました',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onClose,
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final box = context.findRenderObject() as RenderBox;
          _onUserTouch(details.localPosition, box.size);
        },
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox;
          _onUserTouch(details.localPosition, box.size);
        },
        onTap: () {
          if (_userTouched && !_showControls) {
            setState(() => _showControls = true);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Shader-painted canvas
            CustomPaint(
              painter: _LightingPainter(
                shader: _shader!,
                image: _image!,
                lightPos: _lightPos,
                lightRadius: _lightRadius,
                ambient: _ambient,
                intensity: _intensity,
                lightColor: _colorPresets[_colorPresetIndex],
              ),
            ),

            // Light position indicator (subtle)
            Positioned(
              left: _lightPos.dx * MediaQuery.of(context).size.width - 14,
              top: _lightPos.dy * MediaQuery.of(context).size.height - 14,
              child: IgnorePointer(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Intro overlay (shown at start, fades out)
            if (_showIntro)
              AnimatedBuilder(
                animation: _introFadeController ?? const AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  final opacity = 1.0 - (_introFadeController?.value ?? 0.0);
                  return Opacity(
                    opacity: opacity,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app,
                                color: Colors.white.withValues(alpha: 0.8), size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _sensorAvailable
                                  ? '画面をなぞると光の位置が変わります\n端末を傾けても操作できます'
                                  : '画面をなぞると\n光の位置が変わります',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Close button (always visible)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: _controlButton(
                icon: Icons.close,
                label: '戻る',
                onTap: widget.onClose,
              ),
            ),

            // Settings toggle button
            if (_userTouched)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _controlButton(
                      icon: Icons.tune,
                      label: '調整',
                      onTap: () => setState(() => _showControls = !_showControls),
                    ),
                    if (_sensorAvailable) ...[
                      const SizedBox(width: 8),
                      _controlButton(
                        icon: _sensorMode ? Icons.screen_rotation : Icons.touch_app,
                        label: _sensorMode ? '傾き操作中' : '傾き操作',
                        onTap: () {
                          if (_sensorMode) {
                            _stopSensorMode();
                            setState(() {});
                          } else {
                            _startSensorMode();
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),

            // Sliders panel
            if (_showControls && _userTouched)
              Positioned(
                bottom: 20,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color temperature presets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_colorPresets.length, (i) {
                          final preset = _colorPresets[i];
                          final selected = i == _colorPresetIndex;
                          return GestureDetector(
                            onTap: () => setState(() => _colorPresetIndex = i),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: preset.displayColor,
                                    border: Border.all(
                                      color: selected ? Colors.white : Colors.white24,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  preset.label,
                                  style: TextStyle(
                                    color: selected ? Colors.white : Colors.white38,
                                    fontSize: 10,
                                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      _sliderRow(
                        label: '光の強さ',
                        icon: Icons.wb_sunny_outlined,
                        value: _intensity,
                        min: 0.0,
                        max: 1.5,
                        onChanged: (v) => setState(() => _intensity = v),
                      ),
                      const SizedBox(height: 4),
                      _sliderRow(
                        label: '光の広がり',
                        icon: Icons.blur_on,
                        value: _lightRadius,
                        min: 0.2,
                        max: 2.0,
                        onChanged: (v) => setState(() => _lightRadius = v),
                      ),
                      const SizedBox(height: 4),
                      _sliderRow(
                        label: '周りの明るさ',
                        icon: Icons.brightness_low,
                        value: _ambient,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) => setState(() => _ambient = v),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: Colors.white.withValues(alpha: 0.6),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: Colors.white,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter that applies the lighting fragment shader to the painting
class _LightingPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final Offset lightPos;
  final double lightRadius;
  final double ambient;
  final double intensity;
  final _ColorPreset lightColor;

  _LightingPainter({
    required this.shader,
    required this.image,
    required this.lightPos,
    required this.lightRadius,
    required this.ambient,
    required this.intensity,
    required this.lightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate image display rect (contain mode)
    final imageAspect = image.width / image.height;
    final canvasAspect = size.width / size.height;

    double drawWidth, drawHeight, offsetX, offsetY;
    if (imageAspect > canvasAspect) {
      drawWidth = size.width;
      drawHeight = size.width / imageAspect;
      offsetX = 0;
      offsetY = (size.height - drawHeight) / 2;
    } else {
      drawHeight = size.height;
      drawWidth = size.height * imageAspect;
      offsetX = (size.width - drawWidth) / 2;
      offsetY = 0;
    }

    // Set uniforms
    shader.setFloat(0, drawWidth);   // uSize.x
    shader.setFloat(1, drawHeight);  // uSize.y

    // Convert light position from full-screen coords to image-local coords
    final localLightX = (lightPos.dx * size.width - offsetX) / drawWidth;
    final localLightY = (lightPos.dy * size.height - offsetY) / drawHeight;
    shader.setFloat(2, localLightX);  // uLightPos.x
    shader.setFloat(3, localLightY);  // uLightPos.y

    shader.setFloat(4, lightRadius);  // uLightRadius
    shader.setFloat(5, ambient);      // uAmbient
    shader.setFloat(6, intensity);    // uIntensity
    shader.setFloat(7, lightColor.r); // uLightColor.r
    shader.setFloat(8, lightColor.g); // uLightColor.g
    shader.setFloat(9, lightColor.b); // uLightColor.b

    // Set image sampler
    shader.setImageSampler(0, image);

    // Draw the shader rect (only where the image is)
    final paint = Paint()..shader = shader;
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, drawWidth, drawHeight),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LightingPainter oldDelegate) {
    return lightPos != oldDelegate.lightPos ||
        lightRadius != oldDelegate.lightRadius ||
        ambient != oldDelegate.ambient ||
        intensity != oldDelegate.intensity ||
        lightColor != oldDelegate.lightColor ||
        image != oldDelegate.image;
  }
}

class _ColorPreset {
  final String label;
  final Color displayColor;
  final double r, g, b;
  const _ColorPreset(this.label, this.displayColor, this.r, this.g, this.b);
}
