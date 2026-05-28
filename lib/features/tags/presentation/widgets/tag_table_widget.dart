import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/tags/domain/entities/tag.dart';

class TagTableWidget extends StatelessWidget {
  final List<Tag> tags;
  final void Function(Tag) onEdit;
  final void Function(Tag) onDelete;

  const TagTableWidget({
    super.key,
    required this.tags,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final headerBg = isLight ? AppColors.snow : AppColors.darkSurface;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;

    if (tags.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadius.container),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: Text(context.translate('ui.tags.empty'))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.container),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.container),
        child: Column(
          children: [
            Container(
              color: headerBg,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(child: Text(context.translate('ui.tags.column_tag'))),
                  SizedBox(
                    width: 160,
                    child: Text(
                      context.translate('ui.tags.column_type'),
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: Text(
                      context.translate('ui.tags.column_color'),
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  const SizedBox(width: 88),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: tags.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final color = _parseHex(tag.colorHex) ?? AppColors.stone;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            tag.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: Text(
                            tag.type?.isNotEmpty == true ? tag.type! : 'mood',
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text(
                            tag.colorHex?.isNotEmpty == true
                                ? tag.colorHex!
                                : '-',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: [
                            IconButton(
                              tooltip: context.translate('ui.common.edit'),
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => onEdit(tag),
                            ),
                            IconButton(
                              tooltip: context.translate('ui.common.delete'),
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => onDelete(tag),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseHex(String? value) {
    if (value == null || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
      return null;
    }
    return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
  }
}
