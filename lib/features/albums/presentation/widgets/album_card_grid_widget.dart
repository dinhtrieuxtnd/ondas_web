import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/albums/domain/entities/album.dart';

class AlbumCardGridWidget extends StatelessWidget {
  final List<Album> albums;
  final bool isLoading;
  final void Function(Album album) onEdit;
  final void Function(Album album) onDelete;

  const AlbumCardGridWidget({
    super.key,
    required this.albums,
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

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.album_outlined,
              size: 56,
              color: textSecondary.withAlpha(80),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Không có album nào.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1400
            ? 5
            : constraints.maxWidth > 1050
            ? 4
            : constraints.maxWidth > 720
            ? 3
            : constraints.maxWidth > 440
            ? 2
            : 1;

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.78,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) => _AlbumCard(
            album: albums[index],
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        );
      },
    );
  }
}

// ─── Album card ───────────────────────────────────────────────────────────────

class _AlbumCard extends StatefulWidget {
  final Album album;
  final void Function(Album) onEdit;
  final void Function(Album) onDelete;

  const _AlbumCard({
    required this.album,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgCard = isLight ? AppColors.pureWhite : AppColors.darkSurface;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final borderHover = isLight ? AppColors.silver : AppColors.darkBorderStrong;
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;

    final album = widget.album;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(AppRadius.container),
          border: Border.all(
            color: _hovered ? borderHover : borderColor,
            width: 1.0,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.pureBlack.withAlpha(18),
                    blurRadius: 24,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.pureBlack.withAlpha(5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.container),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Cover with overlays ───────────────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverImage(coverUrl: album.coverUrl, title: album.title),

                    // Gradient scrim on hover (pointer-transparent)
                    IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(90),
                              ],
                              stops: const [0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Type badge — top left
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: _TypeBadge(albumType: album.albumType),
                    ),
                  ],
                ),
              ),

              // ── Info section ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.smMd,
                  AppSpacing.md,
                  AppSpacing.smMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      album.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),

                    // Artist
                    Text(
                      album.artistNames.isNotEmpty
                          ? album.artistNames.join(', ')
                          : context.translate('ui.albums.no_artist'),
                      style: TextStyle(fontSize: 12, color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Meta row: tracks · date | edit | delete
                    Row(
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 11,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${album.totalTracks}',
                          style: TextStyle(fontSize: 11, color: textSecondary),
                        ),
                        if (album.releaseDate != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              album.releaseDate!,
                              style: TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),

                        // Edit button
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            key: Key('albumCard_editButton_${album.id}'),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            tooltip: context.translate(
                              'ui.common.edit',
                            ),
                            onPressed: () => widget.onEdit(album),
                            color: textSecondary,
                            hoverColor: isLight
                                ? AppColors.snow
                                : AppColors.darkSurfaceElevated,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 2),

                        // Delete button
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: IconButton(
                            key: Key('albumCard_deleteButton_${album.id}'),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.delete_rounded, size: 14),
                            tooltip: context.translate(
                              'ui.common.delete',
                            ),
                            onPressed: () => widget.onDelete(album),
                            color: AppColors.errorLight,
                            hoverColor: AppColors.errorSurfaceLight,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Type badge ───────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String? albumType;

  const _TypeBadge({required this.albumType});

  Color _badgeColor() {
    switch (albumType?.toUpperCase()) {
      case 'SINGLE':
        return Colors.blue.shade700;
      case 'EP':
        return Colors.orange.shade700;
      default:
        return AppColors.midGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor().withAlpha(210),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        (albumType ?? 'ALBUM').toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Cover image ──────────────────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  final String? coverUrl;
  final String title;

  const _CoverImage({required this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final placeholderBg = isLight
        ? AppColors.lightGray
        : AppColors.darkSurfaceElevated;

    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _Placeholder(title: title, bg: placeholderBg),
      );
    }
    return _Placeholder(title: title, bg: placeholderBg);
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  final Color bg;

  const _Placeholder({required this.title, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.album_rounded,
            size: 52,
            color: AppColors.stone.withAlpha(70),
          ),
          if (title.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.stone,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
