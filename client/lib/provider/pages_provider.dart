import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/juz_model.dart';
import 'package:halqati/provider/services_providers/pages_api_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/models/page_model.dart';


final pagesProvider = AsyncNotifierProvider<PagesNotifier, JuzModel?>(
      () => PagesNotifier(),
);

class PagesNotifier extends AsyncNotifier<JuzModel?> {
  @override
  FutureOr<JuzModel?> build() {
    return null; // No data until a chapter is selected
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch — only called on first expansion of a chapter tile.
  // Sets AsyncLoading here because the list is empty anyway at this point.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> fetchChapterPages(String chapter) async {
    final tokenValue = ref.read(tokenProvider).value;
    final studentId = ref.read(selectedStudentIdProvider) ?? "0";

    print("studentId: ${studentId}");

    if (tokenValue == null || studentId == null) {
      state = AsyncError("Auth or Student missing", StackTrace.current);
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard<JuzModel?>(() async {
      return ref.read(pagesApiProvider).getPagesByChapter(
        token: tokenValue,
        studentId: studentId,
        chapter: chapter,
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Toggle memorized — OPTIMISTIC update, never touches AsyncLoading.
  // The ExpansionTile stays open because state stays as AsyncData.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> togglePageMemorized({
    required int pageNumber,
    required String classId,
    required bool isCurrentlySelected,
  }) async {
    final api = ref.read(pagesApiProvider);
    final tokenValue = ref.read(tokenProvider).value;
    final studentId = ref.read(selectedStudentIdProvider);
    final currentJuz = state.value;

    if (tokenValue == null || studentId == null || currentJuz == null) return;

    // ── 1. Optimistic UI update ───────────────────────────────────────────
    final optimisticJuz = isCurrentlySelected
        ? _removePage(currentJuz, pageNumber)        // unselect → remove
        : _addPage(currentJuz, pageNumber, classId); // select   → add placeholder

    // Push new state WITHOUT going through AsyncLoading
    state = AsyncData(optimisticJuz);

    // ── 2. Real API call ──────────────────────────────────────────────────
    try {
      bool success;
      if (isCurrentlySelected) {
        success = await api.unselectMemorizedPage(
          token: tokenValue,
          studentId: studentId,
          pageNumber: pageNumber,
        );
      } else {
        success = await api.addMemorizedPage(
          token: tokenValue,
          studentId: studentId,
          pageNumber: pageNumber,
          classId: classId,
        );
      }

      // ── 3. Sync with real server data (still no AsyncLoading) ─────────
      if (success) {
        final fresh = await api.getPagesByChapter(
          token: tokenValue,
          studentId: studentId,
          chapter: currentJuz.chapter.toString(),
        );
        if (fresh != null) state = AsyncData(fresh);
      }
    } catch (e) {
      // ── 4. Rollback on failure ────────────────────────────────────────
      state = AsyncData(currentJuz);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update review date — OPTIMISTIC update so the color changes immediately.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updatePageReview(int pageNumber, String classId) async {
    final api = ref.read(pagesApiProvider);
    final tokenValue = ref.read(tokenProvider).value;
    final studentId = ref.read(selectedStudentIdProvider);
    final currentJuz = state.value;

    if (tokenValue == null || studentId == null || currentJuz == null) return;

    // ── 1. Optimistic: stamp reviewDate = now ─────────────────────────────
    final now = DateTime.now();
    final updatedPages = currentJuz.memorizedPages.map((p) {
      if (p.pageNumber == pageNumber) {
        return p.copyWith(reviewDate: now);
      }
      return p;
    }).toList();

    state = AsyncData(currentJuz.copyWith(memorizedPages: updatedPages));

    // ── 2. Real API call ──────────────────────────────────────────────────
    try {
      await api.updateReviewDate(
        token: tokenValue,
        studentId: studentId,
        pageNumber: pageNumber,
        classId: classId,
      );
      // API succeeded — optimistic state is already correct, nothing to do.
    } catch (e) {
      // Rollback to original state on failure
      state = AsyncData(currentJuz);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers for optimistic list manipulation
  // ─────────────────────────────────────────────────────────────────────────

  /// Remove a page from memorizedPages and decrement count
  JuzModel _removePage(JuzModel juz, int pageNumber) {
    final updated =
    juz.memorizedPages.where((p) => p.pageNumber != pageNumber).toList();
    return juz.copyWith(
      memorizedPages: updated,
      memorizedCount: updated.length,
    );
  }

  /// Add a placeholder PageProgressModel so the page immediately shows as memorized.
  /// The real data (teacher, class, dates) comes back from the server sync in step 3.
  JuzModel _addPage(JuzModel juz, int pageNumber, String classId) {
    final placeholder = PageProgressModel(
      id: 'optimistic-$pageNumber', // non-empty → treated as memorized
      pageNumber: pageNumber,
      markingDate: DateTime.now(),
      reviewDate: DateTime.now(),
      teacher: null,
      classData: null,
    );
    final updated = [...juz.memorizedPages, placeholder];
    return juz.copyWith(
      memorizedPages: updated,
      memorizedCount: updated.length,
    );
  }
}