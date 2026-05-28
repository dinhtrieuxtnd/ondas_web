import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/artists/domain/entities/artist.dart';

class ArtistTableWidget extends StatelessWidget {
  final List<Artist> artists;
  final bool isLoading;
  final void Function(Artist artist) onEdit;
  final void Function(Artist artist) onDelete;

  const ArtistTableWidget({
    super.key,
    required this.artists,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerColor =
        isLight ? AppColors.snow : AppColors.darkSurfaceElevated;
    final borderColor =
        isLight ? AppColors.lightGray : AppColors.darkBorder;
    final textPrimary =
        isLight ? AppColors.nearBlack : AppColors.darkTextPrimary;
    final textSecondary =
        isLight ? AppColors.stone : AppColors.darkTextSecondary;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (artists.isEmpty) {
      return Center(
        child: Text(
          context.translate('ui.artists.empty'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.container),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(56),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FixedColumnWidth(120),
        },
        children: [
          _buildHeader(context, headerColor, borderColor, textSecondary),
          ...artists.asMap().entries.map(
                (entry) => _buildRow(
                  context,
                  entry.value,
                  entry.key.isEven,
                  isLight,
                  textPrimary,
                  textSecondary,
                  borderColor,
                ),
              ),
        ],
      ),
    );
  }

  TableRow _buildHeader(
    BuildContext context,
    Color headerColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      children: [
        _headerCell('', textSecondary),
        _headerCell(context.translate('ui.artists.column_artist'), textSecondary),
        _headerCell(context.translate('ui.artists.column_country'), textSecondary),
        _headerCell('Slug', textSecondary),
        _headerCell(context.translate('ui.artists.column_actions'), textSecondary),
      ],
    );
  }

  Widget _headerCell(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smMd,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildRow(
    BuildContext context,
    Artist artist,
    bool isEven,
    bool isLight,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final rowBg = isEven
        ? Colors.transparent
        : (isLight ? AppColors.snow : AppColors.darkSurface);

    return TableRow(
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      children: [
        // Avatar
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: _AvatarCell(avatarUrl: artist.avatarUrl, name: artist.name),
        ),
        // Name
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            artist.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Country
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            artist.country ?? '—',
            style: TextStyle(fontSize: 14, color: textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Slug
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            artist.slug ?? '—',
            style: TextStyle(fontSize: 13, color: textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: Key('artistTable_editButton_${artist.id}'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: context.translate('ui.common.edit'),
                onPressed: () => onEdit(artist),
                color: textSecondary,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                key: Key('artistTable_deleteButton_${artist.id}'),
                icon: const Icon(Icons.delete_outline, size: 18),
                tooltip: context.translate('ui.common.delete'),
                onPressed: () => onDelete(artist),
                color: AppColors.errorLight,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCell extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _AvatarCell({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.lightGray,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.stone,
        ),
      ),
    );
  }
}
