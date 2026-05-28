import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/genres/domain/entities/genre.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_event.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_state.dart';
import 'package:ondas_web/features/genres/presentation/widgets/genre_form_widget.dart';

class GenreFormScreen extends StatefulWidget {
  final String? genreId;

  const GenreFormScreen({super.key, this.genreId});

  bool get isEditing => genreId != null;

  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  int? get _parsedGenreId => int.tryParse(widget.genreId ?? '');

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && _parsedGenreId != null) {
      context.read<GenreBloc>().add(GenreLoadDetailEvent(id: _parsedGenreId!));
    }
  }

  void _onSubmit({
    required String name,
    String? slug,
    String? description,
    String? coverUrl,
    List<int>? coverBytes,
    String? coverFileName,
  }) {
    if (widget.isEditing && _parsedGenreId != null) {
      context.read<GenreBloc>().add(
        GenreUpdateEvent(
          id: _parsedGenreId!,
          name: name,
          slug: slug,
          description: description,
          coverUrl: coverUrl,
          coverBytes: coverBytes,
          coverFileName: coverFileName,
        ),
      );
    } else {
      context.read<GenreBloc>().add(
        GenreCreateEvent(
          name: name,
          slug: slug,
          description: description,
          coverUrl: coverUrl,
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

    return BlocListener<GenreBloc, GenreState>(
      listener: (context, state) {
        if (state is GenreOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          context.pop(true);
        } else if (state is GenreOperationError) {
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
        child: BlocBuilder<GenreBloc, GenreState>(
          builder: (context, state) {
            final isOperationLoading = state is GenreOperationInProgress;
            final isDetailLoading = state is GenreDetailLoading;

            Genre? initialGenre;
            if (state is GenreDetailLoaded) {
              initialGenre = state.genre;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        key: const Key('genreForm_backButton'),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        color: textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.isEditing
                            ? context.translate('ui.genres.edit')
                            : context.translate('ui.genres.create'),
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
                  else
                    GenreFormWidget(
                      key: ValueKey(initialGenre?.id ?? 'new'),
                      initialGenre: initialGenre,
                      isLoading: isOperationLoading,
                      onSubmit: _onSubmit,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
