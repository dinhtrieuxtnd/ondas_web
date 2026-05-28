import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/playlists/domain/entities/playlist.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_event.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_state.dart';
import 'package:ondas_web/features/playlists/presentation/widgets/playlist_table_widget.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _pageSize = AppConstants.defaultPageSize;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final query = _searchController.text.trim();
    context.read<PlaylistBloc>().add(
      PlaylistLoadListEvent(
        page: _currentPage,
        size: _pageSize,
        query: query.isEmpty ? null : query,
        owner: true,
      ),
    );
  }

  Future<void> _onAdd() async {
    final result = await context.push<bool>(
      '${AppConstants.routePlaylists}/new',
    );
    if (result == true && mounted) _load();
  }

  Future<void> _onEdit(Playlist playlist) async {
    final result = await context.push<bool>(
      '${AppConstants.routePlaylists}/${playlist.id}/edit',
    );
    if (result == true && mounted) _load();
  }

  void _onDelete(Playlist playlist) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translate('ui.playlists.delete_title')),
        content: Text(
          context.translate('ui.playlists.delete_message', {'name': playlist.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.translate('ui.common.cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorLight,
              foregroundColor: AppColors.pureWhite,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PlaylistBloc>().add(
                PlaylistDeleteEvent(id: playlist.id),
              );
            },
            child: Text(context.translate('ui.common.delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistBloc, PlaylistState>(
      listener: (context, state) {
        if (state is PlaylistOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          _load();
        } else if (state is PlaylistOperationError ||
            state is PlaylistListError) {
          final message = state is PlaylistOperationError
              ? state.message
              : (state as PlaylistListError).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: _PlaylistsContent(
        searchController: _searchController,
        currentPage: _currentPage,
        onSearch: (_) {
          setState(() => _currentPage = 0);
          _load();
        },
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          _load();
        },
        onAdd: _onAdd,
        onEdit: _onEdit,
        onDelete: _onDelete,
      ),
    );
  }
}

class _PlaylistsContent extends StatelessWidget {
  final TextEditingController searchController;
  final int currentPage;
  final void Function(String) onSearch;
  final void Function(int) onPageChanged;
  final VoidCallback onAdd;
  final void Function(Playlist) onEdit;
  final void Function(Playlist) onDelete;

  const _PlaylistsContent({
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
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;

    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        final playlists = state is PlaylistListLoaded
            ? state.playlists
            : <Playlist>[];
        final totalPages = state is PlaylistListLoaded ? state.totalPages : 1;
        final totalElements = state is PlaylistListLoaded
            ? state.totalElements
            : 0;
        final isLoading =
            state is PlaylistListLoading ||
            state is PlaylistOperationInProgress;

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
                      Text(
                        context.translate('ui.playlists.title'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        totalElements == 1
                            ? context.translate('ui.playlists.count_single', {'count': totalElements})
                            : context.translate('ui.playlists.count_plural', {'count': totalElements}),
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.translate('ui.playlists.add')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(fontSize: 14, color: textPrimary),
                      decoration: InputDecoration(
                        hintText: context.translate('ui.playlists.search_hint'),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      onSubmitted: onSearch,
                      onChanged: (value) {
                        if (value.isEmpty) onSearch('');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PlaylistTableWidget(
                        playlists: playlists,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
              ),
              if (totalPages > 1) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 0
                          ? () => onPageChanged(currentPage - 1)
                          : null,
                    ),
                    Text(
                      context.translate(
                        'ui.pagination.page',
                        {
                          'current': currentPage + 1,
                          'total': totalPages,
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages - 1
                          ? () => onPageChanged(currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
