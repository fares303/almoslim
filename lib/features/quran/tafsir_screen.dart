import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/tafsir.dart';
import 'package:al_moslim/core/services/tafsir_service.dart';
import 'package:al_moslim/core/models/surah.dart';
import 'package:al_moslim/core/services/quran_service.dart';
import 'package:provider/provider.dart';
import 'package:al_moslim/features/settings/settings_provider.dart';

/// شاشة تفسير القرآن
class TafsirScreen extends StatefulWidget {
  final Surah surah;
  final int initialAyah;

  const TafsirScreen({
    Key? key,
    required this.surah,
    this.initialAyah = 1,
  }) : super(key: key);

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  final TafsirService _tafsirService = TafsirService();
  final QuranService _quranService = QuranService();
  
  late int _currentAyah;
  late String _currentTafsirSource;
  bool _isLoading = true;
  TafsirModel? _tafsir;
  String? _ayahText;
  
  @override
  void initState() {
    super.initState();
    _currentAyah = widget.initialAyah;
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // الحصول على مصدر التفسير الافتراضي
      _currentTafsirSource = await _tafsirService.getDefaultTafsirSource();
      
      // تحميل نص الآية والتفسير
      await _loadAyahAndTafsir();
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      _showErrorSnackBar('حدث خطأ أثناء تحميل البيانات');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadAyahAndTafsir() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // الحصول على نص الآية
      final ayahText = await _quranService.getAyahText(widget.surah.number, _currentAyah);
      
      // التحقق من وجود تفسير في التخزين المحلي
      TafsirModel? cachedTafsir = await _tafsirService.getTafsirFromCache(
        widget.surah.number,
        _currentAyah,
        _currentTafsirSource,
      );
      
      if (cachedTafsir != null) {
        // استخدام التفسير المخزن محليًا
        setState(() {
          _tafsir = cachedTafsir;
          _ayahText = ayahText;
          _isLoading = false;
        });
        return;
      }
      
      // الحصول على التفسير من الإنترنت
      final tafsir = await _tafsirService.getTafsir(
        widget.surah.number,
        _currentAyah,
        _currentTafsirSource,
      );
      
      // حفظ التفسير في التخزين المحلي
      if (tafsir != null) {
        await _tafsirService.saveTafsirToCache(tafsir);
      }
      
      if (mounted) {
        setState(() {
          _tafsir = tafsir;
          _ayahText = ayahText;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error in _loadAyahAndTafsir: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('حدث خطأ أثناء تحميل التفسير');
      }
    }
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _changeTafsirSource(String sourceId) async {
    if (sourceId == _currentTafsirSource) return;
    
    // تعيين مصدر التفسير الجديد
    await _tafsirService.setDefaultTafsirSource(sourceId);
    
    setState(() {
      _currentTafsirSource = sourceId;
    });
    
    // إعادة تحميل التفسير
    await _loadAyahAndTafsir();
  }
  
  Future<void> _changeAyah(int ayahNumber) async {
    if (ayahNumber < 1 || ayahNumber > widget.surah.ayahCount) return;
    
    setState(() {
      _currentAyah = ayahNumber;
    });
    
    // إعادة تحميل التفسير
    await _loadAyahAndTafsir();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<SettingsProvider>(context).isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('تفسير سورة ${widget.surah.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'تغيير مصدر التفسير',
            onPressed: () => _showTafsirSourcesDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات السورة والآية
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'سورة ${widget.surah.name}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'الآية ${_currentAyah}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // نص الآية
                  if (_ayahText != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _ayahText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontFamily: 'Uthmani',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '﴿${_currentAyah}﴾',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // التنقل بين الآيات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentAyah > 1
                            ? () => _changeAyah(_currentAyah - 1)
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('الآية السابقة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _currentAyah < widget.surah.ayahCount
                            ? () => _changeAyah(_currentAyah + 1)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('الآية التالية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // مصدر التفسير
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book),
                        const SizedBox(width: 8),
                        Text(
                          'مصدر التفسير: ${_getTafsirSourceName(_currentTafsirSource)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // التفسير
                  if (_tafsir != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'التفسير',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            _tafsir!.text,
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // اختيار آية محددة
                  ElevatedButton.icon(
                    onPressed: () => _showAyahPickerDialog(),
                    icon: const Icon(Icons.search),
                    label: const Text('اختيار آية محددة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  String _getTafsirSourceName(String sourceId) {
    final sources = _tafsirService.getAvailableSources();
    for (var source in sources) {
      if (source.id == sourceId) {
        return source.name;
      }
    }
    return 'التفسير الميسر';
  }
  
  void _showTafsirSourcesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر مصدر التفسير'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tafsirService.getAvailableSources().length,
              itemBuilder: (context, index) {
                final source = _tafsirService.getAvailableSources()[index];
                return ListTile(
                  title: Text(source.name),
                  subtitle: Text(source.description),
                  selected: source.id == _currentTafsirSource,
                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    _changeTafsirSource(source.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }
  
  void _showAyahPickerDialog() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر رقم الآية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('أدخل رقم الآية من 1 إلى ${widget.surah.ayahCount}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم الآية',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final ayahNumber = int.tryParse(controller.text);
                if (ayahNumber != null && ayahNumber >= 1 && ayahNumber <= widget.surah.ayahCount) {
                  Navigator.pop(context);
                  _changeAyah(ayahNumber);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('الرجاء إدخال رقم آية صحيح من 1 إلى ${widget.surah.ayahCount}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }
}
