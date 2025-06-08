import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ProfileSection.dart';

class AboutMeScreen extends StatefulWidget {
  const AboutMeScreen({super.key});

  @override
  State<AboutMeScreen> createState() => AboutMeScreenState();
}

class AboutMeScreenState extends State<AboutMeScreen> with TickerProviderStateMixin {
  final List<ProfileSection> sections = profileSections;
  late final List<AnimationController> controllers;
  late final List<Animation<Offset>> offsets;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(sections.length, (i) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      Future.delayed(Duration(milliseconds: i * 100), () => controller.forward());
      return controller;
    });

    offsets = controllers
        .map((c) => Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOut),
    )).toList();
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length + 3,
        itemBuilder: (context, index) {
          if (index == 0) return const Header();
          if (index == sections.length + 1) return workExperienceSection();
          if (index == sections.length + 2) return buildContactSection();
          final i = index - 1;
          final section = sections[i];
          return SlideTransition(
            position: offsets[i],
            child: buildSection(section),
          );
        },
      ),
    );
  }

  Widget buildSection(ProfileSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...section.bullets.map((item) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text(item)),
            ],
          )),
        ],
      ),
    );
  }

  Widget workExperienceSection() {
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: EdgeInsets.symmetric(horizontal: 0),
      // leading: const Icon(Icons.work_outline),
      title: const Text(
        "Work Experience",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      children: [
        experienceTile(
          company: "DVT",
          duration: "April 2020 – Present",
          title: "Senior iOS Mobile Developer | Absa & Standard Bank",
          bullets: [
            "Spearheaded cross-border payment features for iOS & Android. (Standard Bank)",
            "Integrated PayShap for seamless transactions. (Absa)",
            "Led Agile development using TDD, automation, and CI/CD.",
            "Managed iOS release cycles and resolved production incidents.",
          ],
        ),
        experienceTile(
          company: "Glucode",
          duration: "April 2019 – March 2020",
          title: "Senior iOS Developer | Discovery App",
          bullets: [
            "Enhanced Discovery iOS app with health & vitality features.",
            "Implemented UI automation testing.",
            "Maintained a Git-based iOS codebase.",
          ],
        ),
        experienceTile(
          company: "Britehouse",
          duration: "May 2017 – March 2019",
          title: "Senior Mobile Developer (Contractor) | Standard Bank",
          bullets: [
            "Optimized mobile banking app performance and UX.",
            "Contributed to Agile sprints and API integration.",
          ],
        ),
        experienceTile(
          company: "Avanade",
          duration: "Feb 2015 – May 2017",
          title: "Senior Software Engineer",
          bullets: [
            "Developed Android/iOS apps for Standard Bank & GEMS.",
            "Created responsive web portals and cross-platform apps.",
          ],
        ),
        experienceTile(
          company: "Business Connexion",
          duration: "Sep 2013 – Jan 2015",
          title: "Junior → Senior Mobile Developer",
          bullets: [
            "Built apps for Transnet, Sanlam, Engen, and Sasol.",
            "Awarded the Aspire Award (2014) for excellence.",
          ],
        ),
        experienceTile(
          company: "3fifteen",
          duration: "Jan 2011 – Aug 2013",
          title: "Graduate → Junior Developer",
          bullets: [
            "Developed apps for Edgars, iNetMobile, and Bassa.",
            "Worked across iOS, Android, Windows, and BlackBerry.",
          ],
        ),
      ],
    );
  }

  Widget buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text("Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: const [
          Icon(Icons.location_on, size: 20),
          SizedBox(width: 8),
          Text("Cape Town, South Africa"),
        ]),
        const SizedBox(height: 8),
        Row(children: const [
          Icon(Icons.email, size: 20),
          SizedBox(width: 8),
          Text("siphomoths@gmail.com"),
        ]),
        const SizedBox(height: 8),
        Row(children: const [
          Icon(Icons.phone, size: 20),
          SizedBox(width: 8),
          Text("+27 78 059 3592"),
        ]),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            const url = 'https://www.linkedin.com/in/sipho-motha-8a83b146';
            // if (await canLaunchUrl(Uri.parse(url))) {
            //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            // }
            try {
              final launched = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              if (!launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch LinkedIn')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          child: Row(
            children: [
              Icon(Icons.link),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  "linkedin.com/in/sipho-motha-8a83b146",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        ),
        const SizedBox(height: 32),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget experienceTile({
    required String company,
    required String duration,
    required String title,
    required List<String> bullets,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(duration, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          ...bullets.map((b) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(child: Text(b)),
            ],
          )),
          const Divider(height: 30),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/profile.jpeg'), // or NetworkImage
        ),
        const SizedBox(height: 20),
        const Text(
          "Sipho Motha",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const Text(
          "Senior Mobile Developer",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        const Text(
          "Dynamic and results-driven mobile developer with experience across iOS, Android, and DevOps. Passionate about clean code, architecture, and delivering world-class apps.",
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
