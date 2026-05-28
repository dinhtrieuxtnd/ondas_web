import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/api_constants.dart';
import 'package:ondas_web/core/di/injection.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/network/dio_client.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/utils/audio_metadata_parser.dart';
import 'package:ondas_web/features/artists/domain/usecases/get_artists_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/get_genres_usecase.dart';
import 'package:ondas_web/features/lyrics/domain/entities/lyrics.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_event.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_state.dart';
import 'package:ondas_web/features/lyrics/presentation/widgets/lyrics_form_widget.dart';
import 'package:ondas_web/features/songs/domain/entities/song.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_bloc.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_event.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_song_tags_usecase.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_state.dart';
import 'package:ondas_web/features/songs/presentation/widgets/song_form_widget.dart';
import 'package:ondas_web/features/tags/domain/repositories/tag_repository.dart';

class SongFormScreen extends StatefulWidget {
  final String? songId;

  const SongFormScreen({super.key, this.songId});
  bool get isEditing => songId != null;

  @override
  State<SongFormScreen> createState() => _SongFormScreenState();
}

class _SongFormScreenState extends State<SongFormScreen> {
  final _lyricsFormKey = GlobalKey<LyricsFormWidgetState>();

  bool _isOptionsLoading = true;
  String? _optionsError;
  List<SongFormOption<String>> _artistOptions = const [];
  List<SongFormOption<int>> _genreOptions = const [];
  List<SongFormOption<int>> _tagOptions = const [];
  List<SongFormOption<String>> _albumOptions = const [];
  Set<int>? _initialTagIds;
  bool _isSongTagsLoading = false;
  String? _loadedSongTagsForId;

  /// Current lyrics data, if any, for the form widget.
  Lyrics? _currentLyrics;
  List<SyncedLyricsLineDraft>? _prefilledSyncedLines;
  String? _prefilledPlainText;
  LyricsDraft? _pendingLyricsDraft;
  bool _awaitingLyricsCreate = false;
  String? _pendingSongSuccessMessage;

  String? get _songId {
    final id = widget.songId?.trim();
    if (id == null || id.isEmpty) return null;
    return id;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && _songId != null) {
      context.read<SongBloc>().add(SongLoadDetailEvent(id: _songId!));
      _loadLyrics();
    }
    _loadOptions();
  }

  void _loadLyrics() {
    if (_songId == null) return;
    context.read<LyricsBloc>().add(LyricsLoadEvent(songId: _songId!));
  }

  void _handleAudioMetadata(AudioMetadata metadata) {
    if (!mounted) return;
    if (_currentLyrics != null) return;

    if (metadata.syncedLyrics.isNotEmpty) {
      setState(() {
        _prefilledSyncedLines = List<SyncedLyricsLineDraft>.from(
          metadata.syncedLyrics,
        );
        _prefilledPlainText = null;
      });
      return;
    }

    final plainText = metadata.plainLyrics?.trim();
    if (plainText != null && plainText.isNotEmpty) {
      setState(() {
        _prefilledSyncedLines = null;
        _prefilledPlainText = plainText;
      });
    }
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isOptionsLoading = true;
      _optionsError = null;
    });

    String? error;

    final artistsResult = await sl<GetArtistsUseCase>()(
      const GetArtistsParams(page: 0, size: 200),
    );
    final artists = artistsResult.fold<List<SongFormOption<String>>>(
      (failure) {
        error ??= failure.message;
        return const <SongFormOption<String>>[];
      },
      (page) => page.items
          .map(
            (item) => SongFormOption<String>(value: item.id, label: item.name),
          )
          .toList(),
    );

    final genresResult = await sl<GetGenresUseCase>()(
      const GetGenresParams(page: 0, size: 200),
    );
    final genres = genresResult.fold<List<SongFormOption<int>>>(
      (failure) {
        error ??= failure.message;
        return const <SongFormOption<int>>[];
      },
      (page) => page.items
          .map((item) => SongFormOption<int>(value: item.id, label: item.name))
          .toList(),
    );

    final albums = await _loadAlbumOptions(
      context,
      onError: (message) {
        error ??= message;
      },
    );

    final tagsResult = await sl<TagRepository>().getTags(
      page: 0,
      size: 200,
    );
    final tags = tagsResult.fold<List<SongFormOption<int>>>(
      (failure) {
        error ??= failure.message;
        return const <SongFormOption<int>>[];
      },
      (page) => page.items
          .map(
            (item) => SongFormOption<int>(
              value: item.id,
              label: item.type?.isNotEmpty == true
                  ? '${item.name} (${item.type})'
                  : item.name,
            ),
          )
          .toList(),
    );

    if (!mounted) return;
    setState(() {
      _artistOptions = artists;
      _genreOptions = genres;
      _tagOptions = tags;
      _albumOptions = albums;
      _isOptionsLoading = false;
      _optionsError = error;
    });
  }

  Future<void> _loadSongTags(String songId) async {
    if (_loadedSongTagsForId == songId) return;

    setState(() {
      _isSongTagsLoading = true;
    });

    final result = await sl<GetSongTagsUseCase>()(
      GetSongTagsParams(songId: songId),
    );

    if (!mounted) return;
    setState(() {
      _isSongTagsLoading = false;
      _loadedSongTagsForId = songId;
      _initialTagIds = result.fold(
        (_) => <int>{},
        (tags) => tags.map((tag) => tag.id).toSet(),
      );
    });
  }

  Future<List<SongFormOption<String>>> _loadAlbumOptions(
    BuildContext context, {
    required void Function(String message) onError,
  }) async {
    try {
      final response = await sl<DioClient>().dio.get(
        ApiConstants.albums,
        queryParameters: {'page': 0, 'size': 200},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        onError(body['message'] as String? ?? context.translate('ui.songs.error.load_albums'));
        return const <SongFormOption<String>>[];
      }

      final data = body['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>?) ?? const <dynamic>[];
      return items
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => SongFormOption<String>(
              value: item['id']?.toString() ?? '',
              label: (item['title'] as String?) ?? 'Untitled album',
            ),
          )
          .where((item) => item.value.isNotEmpty)
          .toList();
    } catch (_) {
      onError(context.translate('ui.songs.error.load_albums'));
      return const <SongFormOption<String>>[];
    }
  }

  void _onSubmit({
    required String title,
    String? albumId,
    int? trackNumber,
    String? releaseDate,
    required List<String> artistIds,
    required List<int> genreIds,
    required List<int> tagIds,
    required List<int> audioBytes,
    required String audioFileName,
    List<int>? coverBytes,
    String? coverFileName,
    bool? active,
  }) {
    if (!widget.isEditing) {
      final lyricsState = _lyricsFormKey.currentState;
      if (lyricsState != null && lyricsState.hasDraftContent()) {
        final draft = lyricsState.buildDraft();
        if (draft == null) {
          return;
        }
        _pendingLyricsDraft = draft;
      } else {
        _pendingLyricsDraft = null;
      }
    }

    final hasNewAudio = audioBytes.isNotEmpty && audioFileName.isNotEmpty;

    if (widget.isEditing && _songId != null) {
      context.read<SongBloc>().add(
        SongUpdateEvent(
          id: _songId!,
          title: title,
          albumId: albumId,
          trackNumber: trackNumber,
          releaseDate: releaseDate,
          artistIds: artistIds,
          genreIds: genreIds,
          tagIds: tagIds,
          audioBytes: hasNewAudio ? audioBytes : null,
          audioFileName: hasNewAudio ? audioFileName : null,
          active: active,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
        ),
      );
    } else {
      context.read<SongBloc>().add(
        SongCreateEvent(
          title: title,
          albumId: albumId,
          trackNumber: trackNumber,
          releaseDate: releaseDate,
          artistIds: artistIds,
          genreIds: genreIds,
          tagIds: tagIds,
          audioBytes: audioBytes,
          audioFileName: audioFileName,
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
    final textPrimary = isLight ? AppColors.nearBlack : AppColors.darkTextPrimary;

    return MultiBlocListener(
      listeners: [
        BlocListener<SongBloc, SongState>(
          listener: (context, state) {
            if (state is SongDetailLoaded && _songId != null) {
              _loadSongTags(_songId!);
            } else if (state is SongOperationSuccess) {
              if (!widget.isEditing && state.song != null) {
                final draft = _pendingLyricsDraft;
                if (draft != null) {
                  setState(() {
                    _awaitingLyricsCreate = true;
                  });
                    _pendingSongSuccessMessage =
                      context.translateErrorCode(state.message);
                  context.read<LyricsBloc>().add(
                    LyricsCreateEvent(
                      songId: state.song!.id,
                      language: draft.language,
                      plainText: draft.plainText,
                      syncedLines: draft.syncedLines,
                    ),
                  );
                  return;
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translateErrorCode(state.message)),
                  backgroundColor: AppColors.successLight,
                ),
              );
              context.pop(true);
            } else if (state is SongOperationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translateErrorCode(state.message)),
                  backgroundColor: AppColors.errorLight,
                ),
              );
            }
          },
        ),
        BlocListener<LyricsBloc, LyricsState>(
          listener: (context, state) {
            if (state is LyricsLoaded) {
              _currentLyrics = state.lyrics;
              _prefilledSyncedLines = null;
              _prefilledPlainText = null;
            } else if (state is LyricsNotFound) {
              _currentLyrics = null;
            } else if (state is LyricsSaved) {
              _currentLyrics = state.lyrics;
              _prefilledSyncedLines = null;
              _prefilledPlainText = null;
              if (_awaitingLyricsCreate) {
                _awaitingLyricsCreate = false;
                _pendingLyricsDraft = null;
                final message = _pendingSongSuccessMessage ??
                    context.translate('ui.songs.success.create_song');
                _pendingSongSuccessMessage = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.successLight,
                  ),
                );
                context.pop(true);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translate('ui.lyrics.save_success')),
                  backgroundColor: AppColors.successLight,
                ),
              );
            } else if (state is LyricsDeleted) {
              _currentLyrics = null;
              _prefilledSyncedLines = null;
              _prefilledPlainText = null;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translate('ui.lyrics.delete_success')),
                  backgroundColor: AppColors.successLight,
                ),
              );
            } else if (state is LyricsError) {
              if (_awaitingLyricsCreate) {
                _awaitingLyricsCreate = false;
                _pendingLyricsDraft = null;
                final baseMessage = _pendingSongSuccessMessage ??
                    context.translate('ui.songs.success.create_song');
                _pendingSongSuccessMessage = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.translate('ui.songs.success.create_song_lyrics_failed', {
                        'message': baseMessage,
                        'error': context.translateErrorCode(state.message),
                      }),
                    ),
                    backgroundColor: AppColors.errorLight,
                  ),
                );
                context.pop(true);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.translate('ui.songs.error.lyrics_error', {
                      'error': context.translateErrorCode(state.message),
                    }),
                  ),
                  backgroundColor: AppColors.errorLight,
                ),
              );
            }
          },
        ),
      ],
      child: ColoredBox(
        color: bgColor,
        child: BlocBuilder<SongBloc, SongState>(
          builder: (context, state) {
            final isOperationLoading =
                state is SongOperationInProgress || _awaitingLyricsCreate;
            final isDetailLoading =
                state is SongDetailLoading || _isSongTagsLoading;

            Song? initialSong;
            if (state is SongDetailLoaded) {
              initialSong = state.song;
            }

            final formKey = widget.isEditing
                ? '${initialSong?.id ?? _songId}_tags_${_initialTagIds?.join('-') ?? 'loading'}'
                : 'new';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        key: const Key('songForm_backButton'),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        color: textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.isEditing
                            ? context.translate('ui.songs.edit')
                            : context.translate('ui.songs.create'),
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
                    SongFormWidget(
                      key: ValueKey(formKey),
                      initialSong: initialSong,
                      initialTagIds: _initialTagIds,
                      isLoading: isOperationLoading,
                      optionsLoading: _isOptionsLoading,
                      optionsError: _optionsError,
                      artistOptions: _artistOptions,
                      genreOptions: _genreOptions,
                      tagOptions: _tagOptions,
                      albumOptions: _albumOptions,
                      onReloadOptions: _loadOptions,
                      onAudioMetadata: _handleAudioMetadata,
                      onSubmit: _onSubmit,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (widget.isEditing && _songId != null)
                      _buildLyricsSection(context)
                    else
                      _buildLyricsDraftSection(context),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLyricsSection(BuildContext context) {
    return BlocBuilder<LyricsBloc, LyricsState>(
      builder: (context, state) {
        final isSaving = state is LyricsSaving;

        if (state is LyricsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LyricsError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.translate('ui.songs.error.load_failed', {
                      'error': context.translateErrorCode(state.message),
                    }),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: _loadLyrics,
                    child: Text(context.translate('ui.common.retry')),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            LyricsFormWidget(
              key: ValueKey('lyrics_form_$_songId'),
              songId: _songId!,
              existingLyrics: _currentLyrics,
              prefilledSyncedLines: _prefilledSyncedLines,
              prefilledPlainText: _prefilledPlainText,
              isSaving: isSaving,
            ),
            if (isSaving)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLyricsDraftSection(BuildContext context) {
    return BlocBuilder<LyricsBloc, LyricsState>(
      builder: (context, state) {
        final isSaving = state is LyricsSaving;
        return Stack(
          children: [
            LyricsFormWidget(
              key: _lyricsFormKey,
              songId: 'draft',
              existingLyrics: null,
              prefilledSyncedLines: _prefilledSyncedLines,
              prefilledPlainText: _prefilledPlainText,
              isSaving: isSaving,
              allowSubmit: false,
              allowDelete: false,
            ),
            if (isSaving)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
