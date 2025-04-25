import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the default adhan audio
      await _loadAdhanSound();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize audio: $e');
    }
  }

  Future<void> _loadAdhanSound() async {
    try {
      // Get the user's preferred adhan sound from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final adhanSound = prefs.getString('adhanSound') ?? 'default';

      debugPrint('Loading adhan sound: $adhanSound');

      // Always try to load from assets first
      try {
        await _player.setAsset('assets/audio/adhan.mp3');
        debugPrint('Loaded adhan from assets');
        return; // Exit early if asset loading succeeds
      } catch (e) {
        debugPrint('Failed to load adhan from assets: $e');
        // Continue to URL loading if asset loading fails
      }

      // Use more reliable URLs for adhan sounds
      String adhanUrl;

      switch (adhanSound) {
        case 'makkah':
          adhanUrl = 'https://www.islamcan.com/audio/adhan/azan2.mp3';
          break;
        case 'madinah':
          adhanUrl = 'https://www.islamcan.com/audio/adhan/azan2.mp3';
          break;
        case 'alaqsa':
          adhanUrl = 'https://www.islamcan.com/audio/adhan/azan2.mp3';
          break;
        case 'default':
        default:
          adhanUrl = 'https://www.islamcan.com/audio/adhan/azan2.mp3';
          break;
      }

      // Load from URL
      debugPrint('Loading adhan from URL: $adhanUrl');
      await _player.setUrl(adhanUrl);
      debugPrint('Successfully loaded adhan sound');
    } catch (e) {
      debugPrint('Error loading adhan sound: $e');
      // Don't throw an exception, just log the error
      // This prevents the app from crashing
    }
  }

  Future<void> playAdhan() async {
    try {
      // Reload the adhan sound in case the user changed it
      await _loadAdhanSound();

      debugPrint('Starting adhan playback');
      await _player.seek(Duration.zero);
      await _player.play();
      debugPrint('Adhan playback started successfully');
    } catch (e) {
      debugPrint('Error playing adhan: $e');
      // Try one more time with a different URL
      try {
        await _player.setUrl('https://www.islamcan.com/audio/adhan/azan2.mp3');
        await _player.seek(Duration.zero);
        await _player.play();
        debugPrint('Adhan playback started with fallback URL');
      } catch (e2) {
        debugPrint('Failed to play adhan with fallback URL: $e2');
        // Don't throw an exception, just log the error
        // This prevents the app from crashing
      }
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> stopAdhan() async {
    try {
      await _player.stop();
      debugPrint('Adhan stopped successfully');
    } catch (e) {
      debugPrint('Error stopping adhan: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
