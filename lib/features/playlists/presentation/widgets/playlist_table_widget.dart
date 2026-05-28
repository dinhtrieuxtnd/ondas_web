import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/utils/date_formatter.dart';
import 'package:ondas_web/features/playlists/domain/entities/playlist.dart';

class PlaylistTableWidget extends StatelessWidget {
  final List<Playlist> playlists;
  final void Function(Playlist) onEdit;
  final void Function(Playlist) onDelete;

  const PlaylistTableWidget({
    super.key,
    required this.playlists,
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

    if (playlists.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppRadius.container),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(child: Text(context.translate('ui.playlists.empty'))),
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
                  const SizedBox(width: 56),
                  Expanded(child: Text(context.translate('ui.playlists.column_playlist'))),
                  SizedBox(
                    width: 120,
                    child: Text(
                      context.translate('ui.playlists.column_songs'),
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: Text(
                      context.translate('ui.playlists.column_updated'),
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
                itemCount: playlists.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        _PlaylistCover(url: playlist.coverUrl),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                playlist.isPublic
                                    ? context.translate('ui.playlists.visibility_public')
                                    : context.translate('ui.playlists.visibility_private'),
                                style: TextStyle(color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            playlist.totalSongs == 1
                                ? context.translate('ui.playlists.song_count_single', {'count': playlist.totalSongs})
                                : context.translate('ui.playlists.song_count_plural', {'count': playlist.totalSongs}),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: Text(
                            playlist.updatedAt != null
                                ? DateFormatter.formatDateTime(
                                    playlist.updatedAt!,
                                  )
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
                              onPressed: () => onEdit(playlist),
                            ),
                            IconButton(
                              tooltip: context.translate('ui.common.delete'),
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => onDelete(playlist),
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
}

class _PlaylistCover extends StatelessWidget {
  final String? url;

  const _PlaylistCover({this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.container),
        image: hasUrl
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: hasUrl ? null : const Icon(Icons.queue_music_outlined, size: 22),
    );
  }
}
