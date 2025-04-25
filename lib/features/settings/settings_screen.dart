import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_moslim/core/constants/app_constants.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:al_moslim/core/services/adkar_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AdkarNotificationService _adkarNotificationService =
      AdkarNotificationService();
  String _appVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    final settings = Provider.of<SettingsProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('المظهر'),
        _buildThemeSelector(settings),
        const Divider(),
        _buildSectionHeader('الإشعارات'),
        SwitchListTile(
          title: const Text('تفعيل الإشعارات'),
          subtitle: const Text('تفعيل أو تعطيل جميع الإشعارات'),
          value: settings.notificationsEnabled,
          onChanged: (value) {
            settings.setNotificationsEnabled(value, context);
          },
        ),
        if (settings.notificationsEnabled) ...[
          SwitchListTile(
            title: const Text('إشعارات الأذان'),
            subtitle: const Text('إشعارات لمواقيت الصلاة'),
            value: settings.adhanNotificationsEnabled,
            onChanged: (value) {
              settings.setAdhanNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('إشعارات الأذكار'),
            subtitle: const Text('تذكير بأذكار الصباح والمساء'),
            value: settings.adkarNotificationsEnabled,
            onChanged: (value) {
              settings.setAdkarNotificationsEnabled(value);
            },
          ),
          if (settings.adkarNotificationsEnabled) ...[
            ListTile(
              title: const Text('وقت أذكار الصباح'),
              subtitle: Text(
                _formatTimeOfDay(
                  _adkarNotificationService.getMorningAdkarTime(),
                ),
              ),
              leading: const Icon(Icons.wb_sunny),
              onTap: () => _showTimePicker(
                context,
                _adkarNotificationService.getMorningAdkarTime(),
                (time) => _adkarNotificationService.setMorningAdkarTime(time),
              ),
            ),
            ListTile(
              title: const Text('وقت أذكار المساء'),
              subtitle: Text(
                _formatTimeOfDay(
                  _adkarNotificationService.getEveningAdkarTime(),
                ),
              ),
              leading: const Icon(Icons.nightlight_round),
              onTap: () => _showTimePicker(
                context,
                _adkarNotificationService.getEveningAdkarTime(),
                (time) => _adkarNotificationService.setEveningAdkarTime(time),
              ),
            ),
          ],
          SwitchListTile(
            title: const Text('آية يومية'),
            subtitle: const Text('إشعار يومي بآية من القرآن الكريم'),
            value: settings.dailyAyahNotificationsEnabled,
            onChanged: (value) {
              settings.setDailyAyahNotificationsEnabled(value);
            },
          ),
          if (settings.dailyAyahNotificationsEnabled) ...[
            ListTile(
              title: const Text('وقت الآية اليومية'),
              subtitle: Text(
                _formatTimeOfDay(_adkarNotificationService.getDailyAyahTime()),
              ),
              leading: const Icon(Icons.menu_book),
              onTap: () => _showTimePicker(
                context,
                _adkarNotificationService.getDailyAyahTime(),
                (time) => _adkarNotificationService.setDailyAyahTime(time),
              ),
            ),
          ],
          ListTile(
            title: const Text('صوت الأذان'),
            subtitle: Text(_getAdhanSoundName(settings.adhanSound)),
            leading: const Icon(Icons.music_note),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAdhanSoundSelector(settings);
            },
          ),
        ],
        const Divider(),
        _buildSectionHeader('القرآن الكريم'),
        ListTile(
          title: const Text('القارئ'),
          subtitle: Text(
            AppConstants.reciters[settings.reciterId] ?? 'مشاري راشد العفاسي',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showReciterSelector(settings);
          },
        ),
        const Divider(),
        _buildSectionHeader('حول التطبيق'),
        ListTile(
          title: const Text('إصدار التطبيق'),
          subtitle: Text(_appVersion),
        ),
        ListTile(
          title: const Text('تقييم التطبيق'),
          leading: const Icon(Icons.star),
          onTap: () {
            // TODO: Open app store page
          },
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'تطبيق المسلم © ${DateTime.now().year}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              hourMinuteTextColor: Theme.of(context).primaryColor,
              dayPeriodTextColor: Theme.of(context).primaryColor,
              dialHandColor: Theme.of(context).primaryColor,
              dialBackgroundColor: Theme.of(context).primaryColor.withAlpha(30),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  Widget _buildThemeSelector(SettingsProvider settings) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('النظام'),
          subtitle: const Text('استخدام إعدادات النظام'),
          value: ThemeMode.system,
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('فاتح'),
          value: ThemeMode.light,
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('داكن'),
          value: ThemeMode.dark,
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
            }
          },
        ),
      ],
    );
  }

  void _showReciterSelector(SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر القارئ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.reciters.length,
                  itemBuilder: (context, index) {
                    final reciterId = AppConstants.reciters.keys.elementAt(
                      index,
                    );
                    final reciterName = AppConstants.reciters.values.elementAt(
                      index,
                    );

                    return RadioListTile<String>(
                      title: Text(reciterName),
                      value: reciterId,
                      groupValue: settings.reciterId,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setReciterId(value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAdhanSoundName(String sound) {
    switch (sound) {
      case 'makkah':
        return 'أذان الحرم المكي';
      case 'madinah':
        return 'أذان المسجد النبوي';
      case 'alaqsa':
        return 'أذان المسجد الأقصى';
      case 'default':
      default:
        return 'الأذان الافتراضي';
    }
  }

  void _showAdhanSoundSelector(SettingsProvider settings) {
    final adhanSounds = {
      'default': 'الافتراضي',
      'makkah': 'أذان الحرم المكي',
      'madinah': 'أذان المسجد النبوي',
      'alaqsa': 'أذان المسجد الأقصى',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر صوت الأذان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: adhanSounds.length,
                  itemBuilder: (context, index) {
                    final soundId = adhanSounds.keys.elementAt(index);
                    final soundName = adhanSounds.values.elementAt(index);

                    return RadioListTile<String>(
                      title: Text(soundName),
                      value: soundId,
                      groupValue: settings.adhanSound,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setAdhanSound(value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
