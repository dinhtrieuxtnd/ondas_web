import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/genres/domain/entities/genre.dart';

class GenreTableWidget extends StatelessWidget {
  final List<Genre> genres;
  final bool isLoading;
  final void Function(Genre genre) onEdit;
  final void Function(Genre genre) onDelete;

  const GenreTableWidget({
    super.key,
    required this.genres,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (genres.isEmpty) {
      return Center(
        child: Text(
          context.translate('ui.genres.empty'),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: genres.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return _GenreCard(
          genre: genres[index],
          borderColor: borderColor,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _GenreCard extends StatelessWidget {
  final Genre genre;
  final Color borderColor;
  final void Function(Genre genre) onEdit;
  final void Function(Genre genre) onDelete;

  const _GenreCard({
    required this.genre,
    required this.borderColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppColors.snow : AppColors.darkSurface;
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _CoverThumb(coverUrl: genre.coverUrl, label: genre.name),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genre.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  genre.slug ?? context.translate('ui.common.no_slug'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  genre.description ?? context.translate('ui.common.no_description'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            children: [
              OutlinedButton.icon(
                key: Key('genreTable_editButton_${genre.id}'),
                onPressed: () => onEdit(genre),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(context.translate('ui.common.edit')),
              ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                key: Key('genreTable_deleteButton_${genre.id}'),
                onPressed: () => onDelete(genre),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(context.translate('ui.common.delete')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorLight,
                  side: const BorderSide(color: AppColors.errorLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? coverUrl;
  final String label;

  const _CoverThumb({required this.coverUrl, required this.label});

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.container),
        child: Image.network(
          coverUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.container),
        color: AppColors.lightGray,
      ),
      alignment: Alignment.center,
      child: Text(
        label.isEmpty ? '?' : label[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.stone,
        ),
      ),
    );
  }
}
