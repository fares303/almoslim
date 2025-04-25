import 'package:flutter/material.dart';
import 'package:al_moslim/core/models/surah.dart';

class SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahListItem({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${surah.number}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        surah.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(
        '${surah.englishName} - ${surah.numberOfAyahs} آية',
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
        ),
      ),
    );
  }
}
