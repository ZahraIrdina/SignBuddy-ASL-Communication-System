import 'package:flutter/material.dart';

class AlphabetSignList extends StatelessWidget {
  final List<String> letters;

  const AlphabetSignList({
    super.key,
    required this.letters,
  });

  @override
  Widget build(BuildContext context) {
    if (letters.isEmpty) {
      return const Text('No alphabet output available.');
    }

    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: letters.map((letter) {
        final imagePath = 'assets/signs_images/${letter.toUpperCase()}.jpg';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 90,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      letter.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              letter.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }
}
