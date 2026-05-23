// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/models/announcement_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_calendar_picker.dart';
import '../../data/admin_service.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final AdminService _adminService = AdminService();
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAnnouncements();
  }

  void _refreshAnnouncements() {
    setState(() {
      _announcementsFuture = _adminService.fetchAnnouncements();
    });
  }

  void _addAnnouncement(String title, String description, String date) async {
    final announcement = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: date,
    );
    await _adminService.addAnnouncement(announcement);
    _refreshAnnouncements();
  }

  void _editAnnouncement(
    String id,
    String title,
    String description,
    String date,
  ) async {
    final announcement = Announcement(
      id: id,
      title: title,
      description: description,
      date: date,
    );
    await _adminService.updateAnnouncement(announcement);
    _refreshAnnouncements();
  }

  void _deleteAnnouncement(String id) async {
    await _adminService.deleteAnnouncement(id);
    _refreshAnnouncements();
  }

  Widget _buildInputField({
    required String hintText,
    String? initialValue,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    double fontSize = 13,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _showAddDialog() {
    String title = '';
    String description = '';
    final TextEditingController dateController = TextEditingController(
      text: '2026-04-12',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'New ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Announcement',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      hintText: 'Title...',
                      onChanged: (val) => title = val,
                      fontSize: 15,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      hintText: 'Description...',
                      onChanged: (val) => description = val,
                      maxLines: 3,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: CustomCalendarPicker(
                              initialDate:
                                  DateTime.tryParse(dateController.text) ??
                                  DateTime.now(),
                              onDateSelected: (date) {
                                setDialogState(() {
                                  dateController.text =
                                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                });
                              },
                              onCancel: () => Navigator.pop(context),
                              onConfirm: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              if (title.isEmpty) return;

                              // Date validation
                              final selectedDate = DateTime.tryParse(
                                dateController.text,
                              );
                              if (selectedDate != null &&
                                  selectedDate.isBefore(
                                    DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    ),
                                  )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a current or future date.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              _addAnnouncement(
                                title,
                                description,
                                dateController.text,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(Announcement announcement, int index) {
    String title = announcement.title;
    String description = announcement.description;
    final TextEditingController dateController = TextEditingController(
      text: announcement.date,
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Edit ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Announcement',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      initialValue: title,
                      hintText: 'Title...',
                      onChanged: (val) => title = val,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      initialValue: description,
                      hintText: 'Description...',
                      onChanged: (val) => description = val,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                            ),
                            child: CustomCalendarPicker(
                              initialDate:
                                  DateTime.tryParse(dateController.text) ??
                                  DateTime.now(),
                              onDateSelected: (date) {
                                setDialogState(() {
                                  dateController.text =
                                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                });
                              },
                              onCancel: () => Navigator.pop(context),
                              onConfirm: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              if (title.isEmpty) return;

                              // Date validation
                              final selectedDate = DateTime.tryParse(
                                dateController.text,
                              );
                              if (selectedDate != null &&
                                  selectedDate.isBefore(
                                    DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                    ),
                                  )) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a current or future date.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              _editAnnouncement(
                                announcement.id,
                                title,
                                description,
                                dateController.text,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Remove Announcement',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Are you sure you want to remove this announcement from the timeline?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          _deleteAnnouncement(announcement.id);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Manage',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Announcements',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              margin: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                onPressed: _showAddDialog,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: FutureBuilder<List<Announcement>>(
          future: _announcementsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No announcements yet',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final announcements = snapshot.data!;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: announcements.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ann = entry.value;
                          final isLast = index == announcements.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.announcementCardBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ann.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ann.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    ann.date,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            _showEditDialog(ann, index),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () => _showDeleteDialog(ann),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }
}
