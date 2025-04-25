import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/hadith.dart';
import 'package:al_moslim/core/services/hadith_service.dart';
import 'package:share_plus/share_plus.dart';

class DailyHadithCard extends StatefulWidget {
  const DailyHadithCard({super.key});

  @override
  State<DailyHadithCard> createState() => _DailyHadithCardState();
}

class _DailyHadithCardState extends State<DailyHadithCard> {
  final HadithService _hadithService = HadithService();
  Hadith? _hadith;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHadith();
  }

  Future<void> _loadHadith() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final hadith = await _hadithService.getRandomHadith();

      setState(() {
        _hadith = hadith;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color:
          Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'حديث اليوم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadHadith,
                ),
              ],
            ),
            const Divider(),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'حدث خطأ في تحميل الحديث',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadHadith,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_hadith != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hadith!.text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _hadith!.source,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          // TODO: Save hadith as favorite
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة الحديث إلى المفضلة'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          if (_hadith != null) {
                            Share.share(
                              '${_hadith!.text}\n\n${_hadith!.source}',
                              subject: 'حديث من تطبيق المسلم',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
