import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_web/core/di/injection.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/playlists/domain/entities/playlist_song.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_event.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_songs_usecase.dart';

class PlaylistSongsSectionWidget extends StatelessWidget {
  final String playlistId;
  final List<PlaylistSong> songs;
  final bool isMutating;

  const PlaylistSongsSectionWidget({
    super.key,
    required this.playlistId,
    required this.songs,
    required this.isMutating,
  });

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _openAddSongDialog(BuildContext context) async {
    final existingIds = songs.map((s) => s.id).toSet();
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => _AddSongDialog(existingSongIds: existingIds),
    );
    if (picked == null || !context.mounted) return;
    context.read<PlaylistBloc>().add(
      PlaylistAddSongEvent(playlistId: playlistId, songId: picked),
    );
  }

  void _onReorder(BuildContext context, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final reordered = List<PlaylistSong>.from(songs);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    context.read<PlaylistBloc>().add(
      PlaylistReorderSongsEvent(
        playlistId: playlistId,
        songIds: reordered.map((s) => s.id).toList(),
      ),
    );
  }

  void _onRemove(BuildContext context, String songId) {
    context.read<PlaylistBloc>().add(
      PlaylistRemoveSongEvent(playlistId: playlistId, songId: songId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;
    final borderColor = isLight ? AppColors.borderLight : AppColors.darkBorder;
    final bgCard = isLight ? AppColors.snow : AppColors.darkSurface;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.translate('ui.playlists.song_list_title'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isMutating)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _openAddSongDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.translate('ui.playlists.add_song')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textSecondary,
                    side: BorderSide(color: borderColor),
                    shape: const StadiumBorder(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.translate('ui.playlists.reorder_instruction', {'count': songs.length}),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (songs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  context.translate('ui.playlists.no_songs'),
                  style: TextStyle(color: textSecondary),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: songs.length,
              onReorder: isMutating
                  ? (_, _) {}
                  : (oldIndex, newIndex) =>
                        _onReorder(context, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final song = songs[index];
                return _SongRow(
                  key: ValueKey(song.id),
                  index: index,
                  song: song,
                  durationLabel: _formatDuration(song.durationSeconds),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  isMutating: isMutating,
                  onRemove: () => _onRemove(context, song.id),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  final int index;
  final PlaylistSong song;
  final String durationLabel;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final bool isMutating;
  final VoidCallback onRemove;

  const _SongRow({
    super.key,
    required this.index,
    required this.song,
    required this.durationLabel,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.isMutating,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.container),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              enabled: !isMutating,
              child: Icon(Icons.drag_handle, color: textSecondary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CoverThumb(coverUrl: song.coverUrl),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    durationLabel,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: isMutating ? null : onRemove,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.errorLight,
              tooltip: context.translate('ui.playlists.remove_from_playlist'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? coverUrl;

  const _CoverThumb({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.container),
      child: Container(
        width: 40,
        height: 40,
        color: AppColors.lightGray,
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? Image.network(coverUrl!, fit: BoxFit.cover)
            : const Icon(Icons.music_note, size: 18, color: AppColors.stone),
      ),
    );
  }
}

class _AddSongDialog extends StatefulWidget {
  final Set<String> existingSongIds;

  const _AddSongDialog({required this.existingSongIds});

  @override
  State<_AddSongDialog> createState() => _AddSongDialogState();
}

class _AddSongDialogState extends State<_AddSongDialog> {
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  String? _error;
  List<_SongOption> _options = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSongs({String? query}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await sl<GetSongsUseCase>()(
      GetSongsParams(
        page: 0,
        size: 100,
        query: query?.trim().isEmpty == true ? null : query?.trim(),
      ),
    );

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
        _options = const [];
      }),
      (page) => setState(() {
        _loading = false;
        _options = page.items
            .where((song) => !widget.existingSongIds.contains(song.id))
            .map((song) => _SongOption(id: song.id, title: song.title))
            .toList();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _options
        .where((o) => o.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text(context.translate('ui.playlists.add_to_playlist')),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: context.translate('ui.songs.search_hint'),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _query = value);
                _loadSongs(query: value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : filtered.isEmpty
                  ? Center(child: Text(context.translate('ui.playlists.no_matching_songs')))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        return ListTile(
                          dense: true,
                          title: Text(option.title),
                          trailing: const Icon(Icons.add, size: 18),
                          onTap: () => Navigator.of(context).pop(option.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.translate('ui.common.close')),
        ),
      ],
    );
  }
}

class _SongOption {
  final String id;
  final String title;

  const _SongOption({required this.id, required this.title});
}
