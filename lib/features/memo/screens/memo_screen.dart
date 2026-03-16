import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/auth/providers/auth_provider.dart';
import 'package:palette_michi/features/auth/providers/firestore_service_provider.dart';
import 'package:palette_michi/widgets/palette_app_bar.dart';

class MemoScreen extends ConsumerWidget {
  const MemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final memosAsync = ref.watch(memosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaletteAppBar(title: '메모장', dark: true),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 64, color: AppColors.textTertiary),
                  SizedBox(height: 16),
                  Text(
                    '로그인 후 이용할 수 있어요',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return memosAsync.when(
            data: (memos) {
              return Stack(
                children: [
                  memos.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '메모가 없어요',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '여행 관련 메모를 자유롭게 남겨보세요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: memos.length,
                          itemBuilder: (context, index) {
                            final memo = memos[index];
                            final content = memo['content'] as String? ?? '';
                            final memoId = memo['id'] as String;
                            final createdAt = memo['createdAt'] as Timestamp?;

                            return Dismissible(
                              key: Key(memoId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(firestoreServiceProvider)
                                    .deleteMemo(user.uid, memoId);
                              },
                              child: GestureDetector(
                                onTap: () => _showMemoDialog(
                                  context,
                                  ref,
                                  user.uid,
                                  existingId: memoId,
                                  existingContent: content,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: AppColors.divider),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (createdAt != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          _formatDate(createdAt.toDate()),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, _) =>
                const Center(child: Text('오류가 발생했습니다.')),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, _) => const SizedBox.shrink(),
      ),
      floatingActionButton: authState.value != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () =>
                  _showMemoDialog(context, ref, authState.value!.uid),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showMemoDialog(
    BuildContext context,
    WidgetRef ref,
    String uid, {
    String? existingId,
    String? existingContent,
  }) {
    final controller = TextEditingController(text: existingContent ?? '');
    final isEdit = existingId != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? '메모 수정' : '새 메모',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 6,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: '여행 관련 메모를 자유롭게 적어보세요...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    if (isEdit) {
                      await ref
                          .read(firestoreServiceProvider)
                          .updateMemo(uid, existingId, text);
                    } else {
                      await ref
                          .read(firestoreServiceProvider)
                          .addMemo(uid, text);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(isEdit ? '수정 완료' : '저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
