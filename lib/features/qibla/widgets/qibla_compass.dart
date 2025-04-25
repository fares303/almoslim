import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:al_moslim/features/qibla/widgets/qibla_arrow.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass>
    with TickerProviderStateMixin {
  bool _hasPermission = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Mecca coordinates
  final double _meccaLatitude = 21.422487;
  final double _meccaLongitude = 39.826206;

  // Current position
  Position? _currentPosition;

  // Compass heading
  double _heading = 0;
  double _qiblaAngle = 0;

  // Animation controllers
  late AnimationController _compassController;
  late Animation<double> _compassAnimation;

  // Subscription to position updates
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _compassController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _compassAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _compassController, curve: Curves.easeOutBack),
    );

    _checkLocationPermission();
  }

  @override
  void dispose() {
    _compassController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'خدمة الموقع غير مفعلة';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'تم رفض إذن الموقع';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage =
              'تم رفض إذن الموقع بشكل دائم، يرجى تفعيله من إعدادات الجهاز';
        });
        return;
      }

      setState(() {
        _hasPermission = true;
      });

      await _getCurrentLocation();
      _startListeningToLocationUpdates();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _calculateQiblaDirection();
        _isLoading = false;
      });

      _compassController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'حدث خطأ في الحصول على الموقع: $e';
      });
    }
  }

  void _startListeningToLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      timeLimit: Duration(seconds: 2),
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
          _calculateQiblaDirection();
        });
      },
      onError: (e) {
        print('Error getting position updates: $e');
        // Try to get at least one position
        _getCurrentLocation();
      },
    );

    // Add a timer to update the compass heading regularly
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        _updateCompassHeading();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateCompassHeading() async {
    try {
      // Simulate compass movement if heading is not available
      if (_currentPosition != null) {
        double newHeading;
        try {
          // Try to get the actual heading
          newHeading = _currentPosition!.heading;
        } catch (e) {
          // If heading is not available, simulate rotation
          newHeading = (_heading + 1) % 360;
        }

        if (mounted) {
          setState(() {
            _heading = newHeading;
          });
        }
      }
    } catch (e) {
      print('Error updating compass heading: $e');
    }
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;

    // Convert to radians
    final lat1 = _currentPosition!.latitude * (math.pi / 180);
    final lon1 = _currentPosition!.longitude * (math.pi / 180);
    final lat2 = _meccaLatitude * (math.pi / 180);
    final lon2 = _meccaLongitude * (math.pi / 180);

    // Calculate qibla direction using the formula
    final y = math.sin(lon2 - lon1);
    final x =
        math.cos(lat1) * math.tan(lat2) -
        math.sin(lat1) * math.cos(lon2 - lon1);

    double qiblaDirection = math.atan2(y, x);
    qiblaDirection = qiblaDirection * (180 / math.pi); // Convert to degrees
    qiblaDirection = (qiblaDirection + 360) % 360; // Normalize to 0-360

    // Get device heading (compass direction)
    double heading = 0;
    try {
      heading = _currentPosition!.heading;
    } catch (e) {
      // If heading is not available, use a default value
      heading = 0;
    }

    setState(() {
      _qiblaAngle = qiblaDirection;
      _heading = heading;
    });
  }

  String _getQiblaDirectionText() {
    if (_qiblaAngle >= 337.5 || _qiblaAngle < 22.5) {
      return 'شمال';
    } else if (_qiblaAngle >= 22.5 && _qiblaAngle < 67.5) {
      return 'شمال شرق';
    } else if (_qiblaAngle >= 67.5 && _qiblaAngle < 112.5) {
      return 'شرق';
    } else if (_qiblaAngle >= 112.5 && _qiblaAngle < 157.5) {
      return 'جنوب شرق';
    } else if (_qiblaAngle >= 157.5 && _qiblaAngle < 202.5) {
      return 'جنوب';
    } else if (_qiblaAngle >= 202.5 && _qiblaAngle < 247.5) {
      return 'جنوب غرب';
    } else if (_qiblaAngle >= 247.5 && _qiblaAngle < 292.5) {
      return 'غرب';
    } else {
      return 'شمال غرب';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحديد موقعك...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkLocationPermission,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: FadeTransition(
              opacity: _compassAnimation,
              child: ScaleTransition(
                scale: _compassAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass background
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Compass markings
                          Transform.rotate(
                            angle: -_heading * (math.pi / 180),
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: CompassPainter(),
                            ),
                          ),

                          // Qibla arrow
                          Transform.rotate(
                            angle: (_qiblaAngle - _heading) * (math.pi / 180),
                            child: QiblaArrow(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          // Center dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withAlpha(25),
          child: Column(
            children: [
              Text(
                'اتجاه القبلة: ${_getQiblaDirectionText()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'زاوية القبلة: ${_qiblaAngle.toStringAsFixed(2)}°',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'ضع هاتفك بشكل مستوٍ وحرك السهم ليشير إلى اتجاه القبلة',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Draw compass circle
    canvas.drawCircle(center, radius, paint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // North
    _drawCardinalDirection(
      canvas,
      center,
      radius,
      0,
      'N',
      textPainter,
      Colors.red,
    );

    // East
    _drawCardinalDirection(canvas, center, radius, 90, 'E', textPainter);

    // South
    _drawCardinalDirection(canvas, center, radius, 180, 'S', textPainter);

    // West
    _drawCardinalDirection(canvas, center, radius, 270, 'W', textPainter);

    // Draw tick marks
    for (int i = 0; i < 360; i += 15) {
      final angle = i * (math.pi / 180);
      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final innerRadius =
          i % 90 == 0 ? radius - 20 : (i % 45 == 0 ? radius - 15 : radius - 10);
      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );

      final tickPaint =
          Paint()
            ..color =
                i % 90 == 0
                    ? Colors.black
                    : (i % 45 == 0 ? Colors.black87 : Colors.grey)
            ..strokeWidth = i % 90 == 0 ? 3 : (i % 45 == 0 ? 2 : 1);

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  void _drawCardinalDirection(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
    TextPainter textPainter, [
    Color color = Colors.black,
  ]) {
    final radians = angle * (math.pi / 180);
    final offset = Offset(
      center.dx + (radius - 30) * math.cos(radians),
      center.dy + (radius - 30) * math.sin(radians),
    );

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
