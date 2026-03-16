import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/screens/login_screen.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';
import '../providers/plan_result_provider.dart';
import 'final_itinerary_screen.dart';

class SavedPlansScreen extends ConsumerWidget {
  const SavedPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '보관함'),
      body: currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text(
                    '로그인이 필요해요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('로그인하기'),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
                  .collection('itineraries')
                  .where('uid', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('${snapshot.error}');
            return const Center(
              child: Text(
                '데이터를 불러오지 못했습니다.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '저장된 일정이 없습니다.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final request = data['request'] as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        '일정 삭제',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: const Text('이 일정을 보관함에서 영구히 삭제할까요?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            '취소',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            '삭제',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await FirebaseFirestore.instance
                      .collection('itineraries')
                      .doc(doc.id)
                      .delete();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('일정이 삭제되었습니다.')),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? '${request['city']} 여행',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${request['city']} · ${request['days']}일',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      ref
                          .read(planResultProvider.notifier)
                          .loadItinerary(
                            data['itinerary'] as List<dynamic>,
                            accommodations:
                                (data['accommodations'] as List<dynamic>?) ??
                                [],
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FinalItineraryScreen(docId: doc.id),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
