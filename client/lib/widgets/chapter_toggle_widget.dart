import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/juz_model.dart';
import 'package:halqati/models/page_model.dart';
import 'package:halqati/provider/pages_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';

class ChapterToggleWidget extends ConsumerWidget {
  final int chapterNumber;
  final String title;
  final bool isMemorized;
  final bool isStudent;

  const ChapterToggleWidget({
    required this.chapterNumber,
    required this.title,
    required this.isMemorized,
    this.isStudent = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesState = ref.watch(pagesProvider);
    final classId = ref.watch(selectedClassIdProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMemorized
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        leading: Icon(
          isMemorized ? Icons.verified : Icons.menu_book,
          color: isMemorized ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isMemorized) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "completed".tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10),
                ),
              )
            ]
          ],
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            ref
                .read(pagesProvider.notifier)
                .fetchChapterPages(chapterNumber.toString());
          }
        },
        children: [
          pagesState.when(
            data: (juz) {
              if (juz == null || juz.chapter != chapterNumber) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }

              final memorizedCount = juz.memorizedPages.length;
              final totalPages = juz.totalPages;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.auto_stories,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          "$memorizedCount / $totalPages ${"pages_memorized".tr()}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: totalPages == 0
                                  ? 0
                                  : memorizedCount / totalPages,
                              backgroundColor: Colors.grey.shade200,
                              color: Theme.of(context).colorScheme.primary,
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: juz.totalPages,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final currentPage = juz.startPage + index;
                      final detail = juz.memorizedPages.firstWhere(
                            (m) => m.pageNumber == currentPage,
                        orElse: () => PageProgressModel.empty(),
                      );

                      return PageGridItem(
                        pageNumber: currentPage,
                        detail: detail,
                        isStudent: isStudent,
                        onTap: isStudent == false?() {
                          final isPageMemorized =
                              detail.id != null && detail.id!.isNotEmpty;
                          ref
                              .read(pagesProvider.notifier)
                              .togglePageMemorized(
                            pageNumber: currentPage,
                            classId: classId ?? "0",
                            isCurrentlySelected: isPageMemorized,
                          );
                          return ref.invalidate(studentsProvider);
                        }:(){},
                        onReview: () {
                          ref.read(pagesProvider.notifier).updatePageReview(
                            currentPage,
                            classId ?? "0",
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
            error: (e, stack) {
              if (e is UnauthorizedException) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomErrorWidget(
                providerToInvalidate: pagesProvider,
              );
            },
            loading: () => LoadingWidget(),
          ),
        ],
      ),
    );
  }
}

class PageGridItem extends StatelessWidget {
  final int pageNumber;
  final PageProgressModel detail;
  final bool isStudent;
  final VoidCallback onTap;
  final VoidCallback onReview;

  const PageGridItem({
    required this.pageNumber,
    required this.onTap,
    required this.onReview,
    this.isStudent = false,
    required this.detail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMemorized = detail.id != null && detail.id!.isNotEmpty;
    final bool hasReview = isMemorized && detail.reviewDate != null;

    final Color statusColor =
    HelperMethods.getPageColor(isMemorized ? detail.reviewDate : null);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isMemorized ? statusColor.withOpacity(0.07) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMemorized ? statusColor : Colors.grey.shade300,
          width: isMemorized ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: isMemorized
            ? () => _showPageDetailsSheet(context, statusColor)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${"page".tr()} $pageNumber",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isMemorized
                                  ? statusColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (isMemorized) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "memorized".tr(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (isMemorized) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (detail.teacher?.name != null) ...[
                            Icon(Icons.person_outline,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                detail.teacher!.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (detail.classData?.name != null) ...[
                            Icon(Icons.group_outlined,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                detail.classData!.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (detail.markingDate != null) ...[
                            Icon(Icons.bookmark_added_outlined,
                                size: 13, color: Colors.grey.shade400),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                _formatDate(detail.markingDate!),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (hasReview) ...[
                            Icon(Icons.refresh,
                                size: 13, color: Colors.blue.shade300),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                _formatDate(detail.reviewDate!),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade400,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ] else ...[
                            Icon(Icons.hourglass_empty,
                                size: 13, color: Colors.orange.shade300),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                "not_reviewed_yet".tr(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.orange.shade400),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (isMemorized && !isStudent)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: OutlinedButton.icon(
                    onPressed: onReview,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: Text("review".tr(),
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPageDetailsSheet(BuildContext context, Color statusColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Icon(Icons.menu_book, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    "${"page".tr()} $pageNumber",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      "memorized".tr(),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),

              _DetailRow(
                icon: Icons.person_outline,
                label: "teacher".tr(),
                value: detail.teacher?.name ?? "—",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.group_outlined,
                label: "class".tr(),
                value: detail.classData?.name ?? "—",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.bookmark_added_outlined,
                label: "marking_date".tr(),
                value: detail.markingDate != null
                    ? _formatDateLong(detail.markingDate!)
                    : "—",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.refresh_outlined,
                label: "last_review".tr(),
                value: detail.reviewDate != null
                    ? _formatDateLong(detail.reviewDate!)
                    : "not_reviewed_yet".tr(),
                valueColor:
                detail.reviewDate != null ? Colors.blue : Colors.orange,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _formatDateLong(dynamic date) {
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('MMM d, yyyy – HH:mm').format(dt);
    } catch (_) {
      return date.toString();
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
              color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}