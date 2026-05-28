import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/albums/domain/entities/album.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_bloc.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_event.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_state.dart';
import 'package:ondas_web/features/albums/presentation/widgets/album_form_widget.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_bloc.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_event.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_state.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_bloc.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_event.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_state.dart';

class AlbumFormScreen extends StatefulWidget {
  final String? albumId;

  const AlbumFormScreen({super.key, this.albumId});

  bool get isEditing => albumId != null;

  @override
  State<AlbumFormScreen> createState() => _AlbumFormScreenState();
}

class _AlbumFormScreenState extends State<AlbumFormScreen> {
  Album? _cachedAlbum; // giữ album qua các state transitions

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      context.read<AlbumBloc>().add(AlbumLoadDetailEvent(id: widget.albumId!));
    }
    context.read<ArtistBloc>().add(
      const ArtistLoadListEvent(page: 0, size: 100),
    );
    context.read<SongBloc>().add(const SongLoadListEvent(page: 0, size: 200));
  }

  void _onSubmit({
    required String title,
    String? slug,
    String? releaseDate,
    String? albumType,
    String? description,
    required List<String> artistIds,
    List<int>? coverBytes,
    String? coverFileName,
    required List<String> songIds,
  }) {
    if (widget.isEditing) {
      // previousSongIds = tracklist bài hát hiện tại của album
      final prevIds = _cachedAlbum?.tracklist.map((t) => t.id).toList() ?? [];
      context.read<AlbumBloc>().add(
        AlbumUpdateEvent(
          id: widget.albumId!,
          title: title,
          slug: slug,
          releaseDate: releaseDate,
          albumType: albumType,
          description: description,
          artistIds: artistIds,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
          songIds: songIds,
          previousSongIds: prevIds,
        ),
      );
    } else {
      context.read<AlbumBloc>().add(
        AlbumCreateEvent(
          title: title,
          slug: slug,
          releaseDate: releaseDate,
          albumType: albumType,
          description: description,
          artistIds: artistIds,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
          songIds: songIds,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppColors.pureWhite : AppColors.darkBackground;
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;

    return MultiBlocListener(
      listeners: [
        BlocListener<AlbumBloc, AlbumState>(
          listener: (context, state) {
            if (state is AlbumDetailLoaded) {
              // Cache album để giữ qua các state transitions
              _cachedAlbum = state.album;
            } else if (state is AlbumOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translateErrorCode(state.message)),
                  backgroundColor: AppColors.successLight,
                ),
              );
              context.pop(true);
            } else if (state is AlbumOperationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translateErrorCode(state.message)),
                  backgroundColor: AppColors.errorLight,
                ),
              );
            }
          },
        ),
      ],
      child: ColoredBox(
        color: bgColor,
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            final isOperationLoading = state is AlbumOperationInProgress;
            final isDetailLoading = state is AlbumDetailLoading;

            // Dùng _cachedAlbum để không mất dữ liệu khi state chuyển sang
            // AlbumOperationInProgress hay các state khác
            if (state is AlbumDetailLoaded) {
              _cachedAlbum = state.album;
            }
            final initialAlbum = _cachedAlbum;

            return BlocBuilder<ArtistBloc, ArtistState>(
              builder: (context, artistState) {
                return BlocBuilder<SongBloc, SongState>(
                  builder: (context, songState) {
                    final artists = artistState is ArtistListLoaded
                        ? artistState.artists
                        : [];
                    final songs = songState is SongListLoaded
                        ? songState.songs
                        : [];
                    final optionsLoading =
                        artistState is ArtistListLoading ||
                        songState is SongListLoading;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                key: const Key('albumForm_backButton'),
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => context.pop(),
                                color: textPrimary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                widget.isEditing
                                    ? context.translate(
                                        'ui.albums.edit',
                                      )
                                    : context.translate(
                                        'ui.albums.create',
                                      ),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          if (isDetailLoading && initialAlbum == null)
                            const Center(child: CircularProgressIndicator())
                          else
                            AlbumFormWidget(
                              key: ValueKey(initialAlbum?.id ?? 'new'),
                              initialAlbum: initialAlbum,
                              isLoading: isOperationLoading,
                              optionsLoading: optionsLoading,
                              artistOptions: artists
                                  .map(
                                    (a) => AlbumFormOption<String>(
                                      value: a.id,
                                      label: a.name,
                                    ),
                                  )
                                  .toList(),
                              songOptions: songs
                                  .map(
                                    (s) => AlbumFormOption<String>(
                                      value: s.id,
                                      label: s.title,
                                      albumId: s.albumId,
                                    ),
                                  )
                                  .toList(),
                              onSubmit: _onSubmit,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
