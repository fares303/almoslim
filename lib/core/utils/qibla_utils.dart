import 'dart:math' as math;

class QiblaUtils {
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Coordinates of the Kaaba
    const kaabaLatitude = 21.422487;
    const kaabaLongitude = 39.826206;

    // Convert to radians
    final latRad = latitude * (math.pi / 180);
    final longRad = longitude * (math.pi / 180);
    final kaabaLatRad = kaabaLatitude * (math.pi / 180);
    final kaabaLongRad = kaabaLongitude * (math.pi / 180);

    // Calculate the qibla direction
    final y = math.sin(kaabaLongRad - longRad);
    final x =
        math.cos(latRad) * math.tan(kaabaLatRad) -
        math.sin(latRad) * math.cos(kaabaLongRad - longRad);

    var qiblaDirection = math.atan2(y, x);
    qiblaDirection = qiblaDirection * (180 / math.pi);
    qiblaDirection = (qiblaDirection + 360) % 360;

    return qiblaDirection;
  }

  // Removed this method as it's now implemented in the QiblaCompass widget

  static String getQiblaDirectionText(double direction) {
    if (direction >= 337.5 || direction < 22.5) {
      return 'شمال';
    } else if (direction >= 22.5 && direction < 67.5) {
      return 'شمال شرق';
    } else if (direction >= 67.5 && direction < 112.5) {
      return 'شرق';
    } else if (direction >= 112.5 && direction < 157.5) {
      return 'جنوب شرق';
    } else if (direction >= 157.5 && direction < 202.5) {
      return 'جنوب';
    } else if (direction >= 202.5 && direction < 247.5) {
      return 'جنوب غرب';
    } else if (direction >= 247.5 && direction < 292.5) {
      return 'غرب';
    } else {
      return 'شمال غرب';
    }
  }
}
