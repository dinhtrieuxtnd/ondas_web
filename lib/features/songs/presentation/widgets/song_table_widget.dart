import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/songs/domain/entities/song.dart';

// ─── Column sizing constants ────────────────────────────────────────────────
const _kAvatarWidth = 52.0;
const _kTitleFlex = 30;
const _kArtistFlex = 24;
const _kGenreFlex = 22;
const _kDurationWidth = 100.0;
const _kStatusWidth = 120.0;
const _kActionsWidth = 80.0;

class SongTableWidget extends StatelessWidget {
  final List<Song> songs;
  final bool isLoading;
  final void Function(Song song) onEdit;
  final void Function(Song song) onDelete;

  const SongTableWidget({
    super.key,
    required this.songs,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final textSecondary =
        isLight ? AppColors.stone : AppColors.darkTextSecondary;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isLight ? AppColors.snow : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.music_note_outlined,
                size: 32,
                color: AppColors.silver,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.translate('ui.songs.empty'),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isLight
                        ? AppColors.nearBlack
                        : AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              context.translate('ui.songs.empty_subtitle'),
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.container),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SongTableHeader(
            isLight: isLight,
            borderColor: borderColor,
            textSecondary: textSecondary,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) => _SongTableRow(
                song: songs[index],
                isEven: index.isEven,
                isLight: isLight,
                isLast: index == songs.length - 1,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _SongTableHeader extends StatelessWidget {
  final bool isLight;
  final Color borderColor;
  final Color textSecondary;

  const _SongTableHeader({
    required this.isLight,
    required this.borderColor,
    required this.textSecondary,
  });

  Widget _cell(String label) => Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textSecondary,
          letterSpacing: 0.6,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final headerColor =
        isLight ? AppColors.snow : AppColors.darkSurfaceElevated;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          const SizedBox(width: _kAvatarWidth),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: _kTitleFlex, child: _cell(context.translate('ui.songs.column_title'))),
          Expanded(flex: _kArtistFlex, child: _cell(context.translate('ui.songs.column_artist'))),
          Expanded(flex: _kGenreFlex, child: _cell(context.translate('ui.songs.column_genre'))),
          SizedBox(width: _kDurationWidth, child: _cell(context.translate('ui.songs.column_duration'))),
          SizedBox(width: _kStatusWidth, child: _cell(context.translate('ui.songs.column_status'))),
          SizedBox(width: _kActionsWidth, child: _cell(context.translate('ui.songs.column_actions'))),
        ],
      ),
    );
  }
}

// ─── Row ────────────────────────────────────────────────────────────────────

class _SongTableRow extends StatefulWidget {
  final Song song;
  final bool isEven;
  final bool isLight;
  final bool isLast;
  final void Function(Song) onEdit;
  final void Function(Song) onDelete;

  const _SongTableRow({
    required this.song,
    required this.isEven,
    required this.isLight,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SongTableRow> createState() => _SongTableRowState();
}

class _SongTableRowState extends State<_SongTableRow> {
  bool _hovered = false;

  Color _rowBg() {
    if (_hovered) {
      return widget.isLight
          ? AppColors.lightGray.withValues(alpha: 0.45)
          : AppColors.darkSurfaceElevated;
    }
    if (!widget.isEven) {
      return widget.isLight ? AppColors.snow : AppColors.darkSurface;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = widget.isLight;
    final textPrimary =
        isLight ? AppColors.nearBlack : AppColors.darkTextPrimary;
    final textSecondary =
        isLight ? AppColors.stone : AppColors.darkTextSecondary;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _rowBg(),
          border: widget.isLast
              ? null
              : Border(bottom: BorderSide(color: borderColor, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.smMd,
        ),
        child: Row(
          children: [
            SizedBox(
              width: _kAvatarWidth,
              child: _CoverThumb(
                coverUrl: widget.song.coverUrl,
                label: widget.song.title,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: _kTitleFlex,
              child: _SongTitleCell(
                song: widget.song,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),
            Expanded(
              flex: _kArtistFlex,
              child: Text(
                widget.song.artistNames.isEmpty
                    ? '—'
                    : widget.song.artistNames.join(', '),
                style: TextStyle(fontSize: 13, color: textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: _kGenreFlex,
              child: Text(
                widget.song.genreNames.isEmpty
                    ? '—'
                    : widget.song.genreNames.join(', '),
                style: TextStyle(fontSize: 13, color: textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: _kDurationWidth,
              child: Text(
                _durationText(widget.song.durationSeconds),
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
            ),
            SizedBox(
              width: _kStatusWidth,
              child: _StatusBadge(active: widget.song.active),
            ),
            SizedBox(
              width: _kActionsWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIconButton(
                    key: Key('songTable_editButton_${widget.song.id}'),
                    icon: Icons.edit_outlined,
                    tooltip: context.translate('ui.common.edit'),
                    color: textSecondary,
                    hoverColor: AppColors.nearBlack,
                    isLight: isLight,
                    onTap: () => widget.onEdit(widget.song),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  _ActionIconButton(
                    key: Key('songTable_deleteButton_${widget.song.id}'),
                    icon: Icons.delete_outline,
                    tooltip: context.translate('ui.common.delete'),
                    color: AppColors.silver,
                    hoverColor: AppColors.errorLight,
                    isLight: isLight,
                    onTap: () => widget.onDelete(widget.song),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationText(int? durationSeconds) {
    if (durationSeconds == null || durationSeconds <= 0) return '—';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ─── Action Icon Button ──────────────────────────────────────────────────────

class _ActionIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color hoverColor;
  final bool isLight;
  final VoidCallback onTap;

  const _ActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.hoverColor,
    required this.isLight,
    required this.onTap,
  });

  @override
  State<_ActionIconButton> createState() => _ActionIconButtonState();
}

class _ActionIconButtonState extends State<_ActionIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgHover = widget.isLight
        ? widget.hoverColor.withValues(alpha: 0.08)
        : widget.hoverColor.withValues(alpha: 0.15);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 600),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _hovered ? bgHover : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.container),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered ? widget.hoverColor : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Song Title Cell ─────────────────────────────────────────────────────────

class _SongTitleCell extends StatelessWidget {
  final Song song;
  final Color textPrimary;
  final Color textSecondary;

  const _SongTitleCell({
    required this.song,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          song.slug ?? '—',
          style: TextStyle(fontSize: 12, color: textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Status Badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool active;

  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.successLight : AppColors.stone;
    final bg = active
        ? AppColors.successLight.withValues(alpha: 0.10)
        : AppColors.lightGray;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active
                ? AppColors.successLight.withValues(alpha: 0.25)
                : AppColors.borderLight,
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xxs + 1),
            Text(
              active
                  ? context.translate('ui.songs.status_active')
                  : context.translate('ui.songs.status_inactive'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cover Thumbnail ─────────────────────────────────────────────────────────

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
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.container),
        color: AppColors.lightGray,
      ),
      alignment: Alignment.center,
      child: Text(
        label.isEmpty ? '?' : label[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.stone,
        ),
      ),
    );
  }
}
