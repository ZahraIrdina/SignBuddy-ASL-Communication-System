import 'package:flutter/material.dart';
//import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/constants.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(
          title: const Text('SignBuddy',
              style: TextStyle(
                  color: Color.fromARGB(236, 171, 4, 71),
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () => Navigator.pushNamed(c, AppRoutes.about),
                icon: const Icon(Icons.info_outline))
          ]),
      bottomNavigationBar: _nav(c),
      body: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(children: [
            const Text('Choose an Option',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            FeatureCard(
                title: 'Deaf-Mute → Hearing',
                subtitle: 'Use camera to recognize signs',
                icon: Icons.camera_alt,
                color: Color.fromARGB(255, 207, 2, 57),
                onTap: () => Navigator.pushNamed(c, AppRoutes.deafToHearing)),
            const SizedBox(height: 16),
            FeatureCard(
                title: 'Hearing → Deaf-Mute',
                subtitle: 'Speak or type to convert sign language',
                icon: Icons.mic,
                color: const Color.fromARGB(255, 221, 3, 76),
                onTap: () => Navigator.pushNamed(c, AppRoutes.hearingToDeaf)),
            const SizedBox(height: 25),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Quick Phrases',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => Navigator.pushNamed(c, AppRoutes.phrases),
                  child: const Text('View All'))
            ]),
            Wrap(
                spacing: 8,
                children: Constants.quickPhrases
                    .take(5)
                    .map((e) => ActionChip(
                        label: Text(e),
                        onPressed: () => Navigator.pushNamed(
                            c, AppRoutes.alphabet,
                            arguments: e)))
                    .toList())
          ])));
}

Widget _nav(BuildContext c) => NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) Navigator.pushNamed(c, AppRoutes.history);
          if (i == 2) Navigator.pushNamed(c, AppRoutes.phrases);
          if (i == 3) Navigator.pushNamed(c, AppRoutes.settings);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
        ]);
