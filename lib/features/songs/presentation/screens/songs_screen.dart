import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/songs/domain/entities/song.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_bloc.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_event.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_state.dart';
import 'package:ondas_web/features/songs/presentation/widgets/song_table_widget.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _pageSize = AppConstants.defaultPageSize;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSongs() {
    final query = _searchController.text.trim();
    context.read<SongBloc>().add(
      SongLoadListEvent(
        page: _currentPage,
        size: _pageSize,
        query: query.isEmpty ? null : query,
      ),
    );
  }

  void _onSearch(String query) {
    setState(() => _currentPage = 0);
    context.read<SongBloc>().add(
      SongLoadListEvent(
        page: 0,
        size: _pageSize,
        query: query.trim().isEmpty ? null : query.trim(),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadSongs();
  }

  Future<void> _onAdd() async {
    final result = await context.push<bool>('${AppConstants.routeSongs}/new');
    if (result == true && mounted) {
      _loadSongs();
    }
  }

  Future<void> _onEdit(Song song) async {
    final result = await context.push<bool>(
      '${AppConstants.routeSongs}/${song.id}/edit',
    );
    if (result == true && mounted) {
      _loadSongs();
    }
  }

  void _onDelete(Song song) {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        songTitle: song.title,
        onConfirm: () {
          context.read<SongBloc>().add(SongDeleteEvent(id: song.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SongBloc, SongState>(
      listener: (context, state) {
        if (state is SongOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          _loadSongs();
        } else if (state is SongOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: _SongsContent(
        searchController: _searchController,
        currentPage: _currentPage,
        onSearch: _onSearch,
        onPageChanged: _onPageChanged,
        onAdd: _onAdd,
        onEdit: _onEdit,
        onDelete: _onDelete,
      ),
    );
  }
}

class _SongsContent extends StatelessWidget {
  final TextEditingController searchController;
  final int currentPage;
  final void Function(String) onSearch;
  final void Function(int) onPageChanged;
  final VoidCallback onAdd;
  final void Function(Song) onEdit;
  final void Function(Song) onDelete;

  const _SongsContent({
    required this.searchController,
    required this.currentPage,
    required this.onSearch,
    required this.onPageChanged,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppColors.pureWhite : AppColors.darkBackground;
    final textPrimary =
        isLight ? AppColors.nearBlack : AppColors.darkTextPrimary;
    final textSecondary =
        isLight ? AppColors.stone : AppColors.darkTextSecondary;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;

    return BlocBuilder<SongBloc, SongState>(
      builder: (context, state) {
        final songs = state is SongListLoaded ? state.songs : <Song>[];
        final totalPages = state is SongListLoaded ? state.totalPages : 1;
        final totalElements = state is SongListLoaded ? state.totalElements : 0;
        final isLoading =
            state is SongListLoading || state is SongOperationInProgress;

        return Container(
          color: bgColor,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.translate('ui.songs.title'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (totalElements > 0) ...
                            [
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm + 2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isLight
                                      ? AppColors.lightGray
                                      : AppColors.darkSurfaceElevated,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  '$totalElements',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                  ),
                                ),
                              ),
                            ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        totalElements == 0
                            ? context.translate('ui.songs.empty')
                            : (totalElements == 1
                                ? context.translate('ui.songs.count_single', {'count': totalElements})
                                : context.translate('ui.songs.count_plural', {'count': totalElements})),
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    key: const Key('songsScreen_addButton'),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.translate('ui.songs.add')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('songsScreen_searchField'),
                  controller: searchController,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: context.translate('ui.songs.search_hint'),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.smMd,
                    ),
                  ),
                  onSubmitted: onSearch,
                  onChanged: (value) {
                    if (value.isEmpty) onSearch('');
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SongTableWidget(
                  songs: songs,
                  isLoading: isLoading,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (totalPages > 1)
                _PaginationBar(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;
  final Color textSecondary;
  final Color borderColor;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('songsScreen_prevPageButton'),
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          color: textSecondary,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            context.translate(
              'ui.pagination.page',
              {
                'current': currentPage + 1,
                'total': totalPages,
              },
            ),
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        IconButton(
          key: const Key('songsScreen_nextPageButton'),
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages - 1
              ? () => onPageChanged(currentPage + 1)
              : null,
          color: textSecondary,
        ),
      ],
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String songTitle;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({
    required this.songTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('ui.songs.delete_title')),
      content: Text(
        context.translate('ui.songs.delete_message', {'title': songTitle}),
      ),
      actions: [
        TextButton(
          key: const Key('deleteDialog_cancelButton'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.translate('ui.common.cancel')),
        ),
        ElevatedButton(
          key: const Key('deleteDialog_confirmButton'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorLight,
            foregroundColor: AppColors.pureWhite,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(context.translate('ui.common.delete')),
        ),
      ],
    );
  }
}
