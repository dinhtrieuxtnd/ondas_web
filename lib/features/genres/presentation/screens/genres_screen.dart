import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/genres/domain/entities/genre.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_event.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_state.dart';
import 'package:ondas_web/features/genres/presentation/widgets/genre_card_widget.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({super.key});

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
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
    context.read<GenreBloc>().add(
      GenreLoadListEvent(
        page: _currentPage,
        size: _pageSize,
        query: query.isEmpty ? null : query,
      ),
    );
  }

  void _onSearch(String query) {
    setState(() => _currentPage = 0);
    context.read<GenreBloc>().add(
      GenreLoadListEvent(
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
    final result = await context.push<bool>('${AppConstants.routeGenres}/new');
    if (result == true && mounted) {
      _load();
    }
  }

  Future<void> _onEdit(Genre genre) async {
    final result = await context.push<bool>(
      '${AppConstants.routeGenres}/${genre.id}/edit',
    );
    if (result == true && mounted) {
      _load();
    }
  }

  void _onDelete(Genre genre) {
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        genreName: genre.name,
        onConfirm: () =>
            context.read<GenreBloc>().add(GenreDeleteEvent(id: genre.id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GenreBloc, GenreState>(
      listener: (context, state) {
        if (state is GenreOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          _load();
        } else if (state is GenreOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.errorLight,
            ),
          );
        }
      },
      child: _GenresContent(
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

class _GenresContent extends StatelessWidget {
  final TextEditingController searchController;
  final int currentPage;
  final void Function(String) onSearch;
  final void Function(int) onPageChanged;
  final VoidCallback onAdd;
  final void Function(Genre) onEdit;
  final void Function(Genre) onDelete;

  const _GenresContent({
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

    return BlocBuilder<GenreBloc, GenreState>(
      builder: (context, state) {
        final genres = state is GenreListLoaded ? state.genres : <Genre>[];
        final totalPages = state is GenreListLoaded ? state.totalPages : 1;
        final totalElements = state is GenreListLoaded
            ? state.totalElements
            : 0;
        final isLoading =
            state is GenreListLoading || state is GenreOperationInProgress;

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
                        context.translate('ui.genres.title'),
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
                          context.translate('ui.genres.count', {'count': totalElements}),
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    key: const Key('genresScreen_addButton'),
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.translate('ui.genres.create')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 360,
                child: TextField(
                  key: const Key('genresScreen_searchField'),
                  controller: searchController,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                  decoration: InputDecoration(
                    hintText: context.translate('ui.genres.search_hint'),
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
                child: GenreTableWidget(
                  genres: genres,
                  isLoading: isLoading,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
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
          key: const Key('genresScreen_prevPageButton'),
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
          key: const Key('genresScreen_nextPageButton'),
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
  final String genreName;
  final VoidCallback onConfirm;

  const _DeleteConfirmDialog({
    required this.genreName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('ui.common.confirm_delete')),
      content: Text(
        context.translate('ui.genres.delete_message', {'name': genreName}),
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
