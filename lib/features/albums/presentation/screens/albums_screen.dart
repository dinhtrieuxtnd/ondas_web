import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/albums/domain/entities/album.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_bloc.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_event.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_state.dart';
import 'package:ondas_web/features/albums/presentation/widgets/album_card_grid_widget.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
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
    context.read<AlbumBloc>().add(
      AlbumLoadListEvent(
        page: _currentPage,
        size: _pageSize,
        query: query.isEmpty ? null : query,
      ),
    );
  }

  void _onSearch(String query) {
    setState(() => _currentPage = 0);
    context.read<AlbumBloc>().add(
      AlbumLoadListEvent(
        page: 0,
        size: _pageSize,
        query: query.trim().isEmpty ? null : query.trim(),
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _load();
  }

  Future<void> _onAdd() async {
    final result = await context.push<bool>('${AppConstants.routeAlbums}/new');
    if (result == true && mounted) _load();
  }

  Future<void> _onEdit(Album album) async {
    final result = await context.push<bool>(
      '${AppConstants.routeAlbums}/${album.id}/edit',
    );
    if (result == true && mounted) _load();
  }

  void _onDelete(Album album) {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        albumTitle: album.title,
        onConfirm: () =>
            context.read<AlbumBloc>().add(AlbumDeleteEvent(id: album.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlbumBloc, AlbumState>(
      listener: (context, state) {
        if (state is AlbumOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          _load();
        } else if (state is AlbumOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: _AlbumsContent(
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

// ─── Content ──────────────────────────────────────────────────────────────────

class _AlbumsContent extends StatelessWidget {
  final TextEditingController searchController;
  final int currentPage;
  final void Function(String) onSearch;
  final void Function(int) onPageChanged;
  final VoidCallback onAdd;
  final void Function(Album) onEdit;
  final void Function(Album) onDelete;

  const _AlbumsContent({
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

    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) {
        final albums = state is AlbumListLoaded ? state.albums : <Album>[];
        final totalPages = state is AlbumListLoaded ? state.totalPages : 1;
        final totalElements = state is AlbumListLoaded
            ? state.totalElements
            : 0;
        final isLoading =
            state is AlbumListLoading || state is AlbumOperationInProgress;

        return Container(
          color: bgColor,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Albums',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          color: isLight
                              ? AppColors.snow
                              : AppColors.darkSurface,
                        ),
                        child: Text(
                          '$totalElements album',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    key: const Key('albumsScreen_addButton'),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.translate('ui.albums.create')),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Search bar ───────────────────────────────────────────────────
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('albumsScreen_searchField'),
                  controller: searchController,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: context.translate(
                      'ui.albums.search_hint',
                    ),
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

              // ── Card list ────────────────────────────────────────────────────
              Expanded(
                child: AlbumCardGridWidget(
                  albums: albums,
                  isLoading: isLoading,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),

              // ── Pagination ───────────────────────────────────────────────────
              if (totalPages > 1) ...[
                const SizedBox(height: AppSpacing.md),
                _PaginationBar(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                  textSecondary: textSecondary,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Pagination ───────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;
  final Color textSecondary;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('albumsScreen_prevPageButton'),
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 0
              ? () => onPageChanged(currentPage - 1)
              : null,
          color: textSecondary,
        ),
        Text(
          context.translate('ui.pagination.page', {
            'current': currentPage + 1,
            'total': totalPages,
          }),
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
        IconButton(
          key: const Key('albumsScreen_nextPageButton'),
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

// ─── Delete confirm dialog ────────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final String albumTitle;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({
    required this.albumTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('ui.albums.delete_title')),
      content: Text(
        context.translate('ui.albums.delete_message', {'name': albumTitle}),
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
