import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentInfoList extends StatelessWidget {
  final String name;
  final String? profilePicUrl;
  final double cumulativeGpa;
  final int totalPoints;
  final String phone;
  final int chaptersMemorized;
  final String? studentId;
  final String? grade;
  final String? section;

  const StudentInfoList({
    super.key,
    required this.name,
    required this.cumulativeGpa,
    required this.totalPoints,
    required this.phone,
    required this.chaptersMemorized,
    this.profilePicUrl,
    this.studentId,
    this.grade,
    this.section,
  });

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _call() async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _whatsapp() async {
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ── GPA color ────────────────────────────────────────────────────────────────

  Color _gpaColor(double gpa) {
    if (gpa >= 18.5) return const Color(0xFF2E7D32);
    if (gpa >= 10.5) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gpaColor = _gpaColor(cumulativeGpa);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.secondaryContainer, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(name: name, imageUrl: profilePicUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (studentId != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'ID: $studentId',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                      if (grade != null || section != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          [if (grade != null) grade!, if (section != null) section!].join(' · '),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
                // Active badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

          // ── Stats row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.auto_graph_rounded,
                    label: 'cumulative_grade'.tr(),
                    value: cumulativeGpa.toStringAsFixed(2),
                    color: gpaColor,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.scale_rounded,
                    label: 'total_weight'.tr(),
                    value: totalPoints.toString(),
                    color: theme.colorScheme.primary,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.menu_book_rounded,
                    label: 'juz'.tr(),
                    value: chaptersMemorized.toString(),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),

          // ── Phone row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(phone, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          // ── Action buttons ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'call'.tr(),
                    icon: Icons.phone_rounded,
                    color: theme.colorScheme.primary,
                    onTap: _call,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'whatsapp'.tr(),
                    icon: Icons.chat_rounded,
                    color: const Color(0xFF25D366),
                    onTap: _whatsapp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF97D5DD), width: 2),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _InitialCircle(initial: initial))
            : _InitialCircle(initial: initial),
      ),
    );
  }
}

class _InitialCircle extends StatelessWidget {
  final String initial;
  const _InitialCircle({required this.initial});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCell({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 44,
    color: Theme.of(context).colorScheme.secondaryContainer,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}