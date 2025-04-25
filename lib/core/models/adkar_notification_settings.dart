/// نموذج إعدادات إشعارات الأذكار
class AdkarNotificationSettings {
  /// هل الإشعارات مفعلة
  final bool enabled;
  
  /// وقت إشعار أذكار الصباح
  final DateTime? morningTime;
  
  /// وقت إشعار أذكار المساء
  final DateTime? eveningTime;
  
  /// هل إشعارات أذكار الصباح مفعلة
  final bool morningEnabled;
  
  /// هل إشعارات أذكار المساء مفعلة
  final bool eveningEnabled;
  
  /// هل إشعارات الأذكار العشوائية مفعلة
  final bool randomEnabled;
  
  /// عدد الإشعارات العشوائية في اليوم
  final int randomCount;
  
  /// هل تشغيل الصوت مع الإشعارات
  final bool soundEnabled;
  
  /// هل تفعيل الاهتزاز مع الإشعارات
  final bool vibrationEnabled;

  /// إنشاء إعدادات إشعارات الأذكار
  AdkarNotificationSettings({
    this.enabled = false,
    this.morningTime,
    this.eveningTime,
    this.morningEnabled = false,
    this.eveningEnabled = false,
    this.randomEnabled = false,
    this.randomCount = 3,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  /// إنشاء إعدادات إشعارات الأذكار من JSON
  factory AdkarNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AdkarNotificationSettings(
      enabled: json['enabled'] ?? false,
      morningTime: json['morningTime'] != null
          ? DateTime.parse(json['morningTime'])
          : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              7,
              0,
            ),
      eveningTime: json['eveningTime'] != null
          ? DateTime.parse(json['eveningTime'])
          : DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              19,
              0,
            ),
      morningEnabled: json['morningEnabled'] ?? false,
      eveningEnabled: json['eveningEnabled'] ?? false,
      randomEnabled: json['randomEnabled'] ?? false,
      randomCount: json['randomCount'] ?? 3,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  /// تحويل إعدادات إشعارات الأذكار إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'morningTime': morningTime?.toIso8601String(),
      'eveningTime': eveningTime?.toIso8601String(),
      'morningEnabled': morningEnabled,
      'eveningEnabled': eveningEnabled,
      'randomEnabled': randomEnabled,
      'randomCount': randomCount,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// نسخة جديدة من إعدادات إشعارات الأذكار مع تحديث بعض القيم
  AdkarNotificationSettings copyWith({
    bool? enabled,
    DateTime? morningTime,
    DateTime? eveningTime,
    bool? morningEnabled,
    bool? eveningEnabled,
    bool? randomEnabled,
    int? randomCount,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return AdkarNotificationSettings(
      enabled: enabled ?? this.enabled,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      randomEnabled: randomEnabled ?? this.randomEnabled,
      randomCount: randomCount ?? this.randomCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
