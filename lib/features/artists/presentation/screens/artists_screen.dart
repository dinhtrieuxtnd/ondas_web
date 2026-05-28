import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/artists/domain/entities/artist.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_bloc.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_event.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_state.dart';
import 'package:ondas_web/features/artists/presentation/widgets/artist_table_widget.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({super.key});

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 0;
  static const int _pageSize = AppConstants.defaultPageSize;

  @override
  void initState() {
    super.initState();
    context.read<ArtistBloc>().add(
      ArtistLoadListEvent(page: _currentPage, size: _pageSize),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() => _currentPage = 0);
    final trimmed = query.trim();
    context.read<ArtistBloc>().add(
      ArtistLoadListEvent(
        page: 0,
        size: _pageSize,
        query: trimmed.isEmpty ? null : trimmed,
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    context.read<ArtistBloc>().add(
      ArtistLoadListEvent(
        page: page,
        size: _pageSize,
        query: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
    );
  }

  Future<void> _onAdd() async {
    final result = await context.push<bool>('${AppConstants.routeArtists}/new');
    if (result == true && mounted) {
      context.read<ArtistBloc>().add(
        ArtistLoadListEvent(page: _currentPage, size: _pageSize),
      );
    }
  }

  Future<void> _onEdit(Artist artist) async {
    final result = await context.push<bool>(
      '${AppConstants.routeArtists}/${artist.id}/edit',
    );
    if (result == true && mounted) {
      context.read<ArtistBloc>().add(
        ArtistLoadListEvent(page: _currentPage, size: _pageSize),
      );
    }
  }

  void _onDelete(Artist artist) {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        artistName: artist.name,
        onConfirm: () {
          context.read<ArtistBloc>().add(ArtistDeleteEvent(id: artist.id));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ArtistBloc, ArtistState>(
      listener: (context, state) {
        if (state is ArtistOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          context.read<ArtistBloc>().add(
            ArtistLoadListEvent(page: _currentPage, size: _pageSize),
          );
        } else if (state is ArtistOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: _ArtistsContent(
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

class _ArtistsContent extends StatelessWidget {
  final TextEditingController searchController;
  final int currentPage;
  final void Function(String) onSearch;
  final void Function(int) onPageChanged;
  final VoidCallback onAdd;
  final void Function(Artist) onEdit;
  final void Function(Artist) onDelete;

  const _ArtistsContent({
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

    return BlocBuilder<ArtistBloc, ArtistState>(
      builder: (context, state) {
        final artists = state is ArtistListLoaded ? state.artists : <Artist>[];
        final totalPages = state is ArtistListLoaded ? state.totalPages : 1;
        final totalElements = state is ArtistListLoaded
            ? state.totalElements
            : 0;
        final isLoading =
            state is ArtistListLoading || state is ArtistOperationInProgress;

        return Container(
          color: bgColor,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.translate('ui.artists.title'),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '$totalElements ${context.translate('ui.artists.title')}',
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    key: const Key('artistsScreen_addButton'),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      context.translate('ui.artists.create'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Search bar
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('artistsScreen_searchField'),
                  controller: searchController,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: context.translate(
                      'ui.artists.search_hint',
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
              // Table
              Expanded(
                child: ArtistTableWidget(
                  artists: artists,
                  isLoading: isLoading,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Pagination
              if (totalPages > 1)
                _PaginationBar(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                  textSecondary: textSecondary,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                ),
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
  final Color borderColor;
  final Color textPrimary;

  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.textSecondary,
    required this.borderColor,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('artistsScreen_prevPageButton'),
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
          key: const Key('artistsScreen_nextPageButton'),
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
  final String artistName;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({
    required this.artistName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('ui.common.confirm_delete')),
      content: Text(
        context.translate('ui.artists.confirm_delete', {'name': artistName}),
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
