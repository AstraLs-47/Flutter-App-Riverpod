// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/models/announcement_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _service = AnnouncementService();
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = _service.fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => context.pop(),
          splashRadius: 24,
        ),
      ),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final announcements = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latest',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Announcements',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0E6CF2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Content Section with IntrinsicHeight Timeline
                if (announcements.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: Text(
                        'No announcements yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0E6CF2,
                              ).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: announcements.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final ann = entry.value;
                                final isLast =
                                    index == announcements.length - 1;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isLast ? 0 : 24,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F1F1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ann.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          ann.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          ann.date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }
}
