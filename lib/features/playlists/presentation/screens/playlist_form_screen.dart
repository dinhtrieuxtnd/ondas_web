import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/playlists/domain/entities/playlist.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_event.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_state.dart';
import 'package:ondas_web/features/playlists/presentation/widgets/playlist_form_widget.dart';
import 'package:ondas_web/features/playlists/presentation/widgets/playlist_songs_section_widget.dart';

class PlaylistFormScreen extends StatefulWidget {
  final String? playlistId;

  const PlaylistFormScreen({super.key, this.playlistId});

  bool get isEditing => playlistId != null;

  @override
  State<PlaylistFormScreen> createState() => _PlaylistFormScreenState();
}

class _PlaylistFormScreenState extends State<PlaylistFormScreen> {
  Playlist? _cachedPlaylist;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      context.read<PlaylistBloc>().add(
        PlaylistLoadDetailEvent(id: widget.playlistId!),
      );
    }
  }

  void _submit({
    required String name,
    String? description,
    required bool isPublic,
    List<int>? coverBytes,
    String? coverFileName,
  }) {
    if (widget.isEditing) {
      context.read<PlaylistBloc>().add(
        PlaylistUpdateEvent(
          id: widget.playlistId!,
          name: name,
          description: description,
          isPublic: isPublic,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
        ),
      );
    } else {
      context.read<PlaylistBloc>().add(
        PlaylistCreateEvent(
          name: name,
          description: description,
          isPublic: isPublic,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
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

    return BlocListener<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state is PlaylistDetailLoaded && state.snackbarMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translateErrorCode(state.snackbarMessage!),
              ),
              backgroundColor: AppColors.errorLight,
            ),
          );
        } else if (state is PlaylistOperationSuccess) {
          final createdId = state.createdPlaylistId;
          if (createdId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.translateErrorCode(state.message)),
                backgroundColor: AppColors.successLight,
              ),
            );
            context.go('${AppConstants.routePlaylists}/$createdId/edit');
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          context.pop(true);
        } else if (state is PlaylistOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: ColoredBox(
        color: bgColor,
        child: BlocBuilder<PlaylistBloc, PlaylistState>(
          builder: (context, state) {
            if (state is PlaylistDetailLoaded) {
              _cachedPlaylist = state.playlist;
            }

            final detailState = state is PlaylistDetailLoaded ? state : null;
            final playlist = detailState?.playlist ?? _cachedPlaylist;
            final isMetadataLoading = state is PlaylistOperationInProgress;
            final isDetailLoading = state is PlaylistDetailLoading;
            final isSongsMutating = detailState?.isSongsMutating ?? false;
            final showSongsSection =
                widget.isEditing && playlist != null && !isDetailLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        color: textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.isEditing
                            ? context.translate('ui.playlists.edit')
                            : context.translate('ui.playlists.create'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (isDetailLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    PlaylistFormWidget(
                      key: ValueKey(playlist?.id ?? 'new'),
                      initialPlaylist: playlist,
                      isLoading: isMetadataLoading,
                      onSubmit: _submit,
                    ),
                    if (showSongsSection) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      PlaylistSongsSectionWidget(
                        key: ValueKey('songs_${playlist.id}_${playlist.songs.length}'),
                        playlistId: playlist.id,
                        songs: playlist.songs,
                        isMutating: isSongsMutating,
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
