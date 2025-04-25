import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationErrorWidget extends StatefulWidget {
  const LocationErrorWidget({super.key});

  @override
  State<LocationErrorWidget> createState() => _LocationErrorWidgetState();
}

class _LocationErrorWidgetState extends State<LocationErrorWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'لا يمكن الوصول إلى موقعك',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'يرجى تفعيل خدمة الموقع للحصول على اتجاه القبلة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton.icon(
              onPressed: _requestLocationPermission,
              icon: const Icon(Icons.location_on),
              label: const Text('تفعيل الموقع'),
            ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        await Geolocator.openLocationSettings();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفض إذن الوصول إلى الموقع')),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم رفض إذن الوصول إلى الموقع بشكل دائم. يرجى تفعيله من إعدادات الجهاز',
              ),
            ),
          );
        }
        await Geolocator.openAppSettings();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // When we reach here, permissions are granted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تفعيل الموقع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
