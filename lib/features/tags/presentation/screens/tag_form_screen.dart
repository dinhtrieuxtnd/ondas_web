import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/tags/presentation/bloc/tag_bloc.dart';
import 'package:ondas_web/features/tags/presentation/bloc/tag_event.dart';
import 'package:ondas_web/features/tags/presentation/bloc/tag_state.dart';
import 'package:ondas_web/features/tags/presentation/widgets/tag_form_widget.dart';

class TagFormScreen extends StatefulWidget {
  final String? tagId;

  const TagFormScreen({super.key, this.tagId});

  bool get isEditing => tagId != null;

  @override
  State<TagFormScreen> createState() => _TagFormScreenState();
}

class _TagFormScreenState extends State<TagFormScreen> {
  int? get _parsedTagId => int.tryParse(widget.tagId ?? '');

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && _parsedTagId != null) {
      context.read<TagBloc>().add(TagLoadDetailEvent(id: _parsedTagId!));
    }
  }

  void _submit(String name, String? type, String? colorHex) {
    if (widget.isEditing && _parsedTagId != null) {
      context.read<TagBloc>().add(
        TagUpdateEvent(
          id: _parsedTagId!,
          name: name,
          type: type,
          colorHex: colorHex,
        ),
      );
    } else {
      context.read<TagBloc>().add(
        TagCreateEvent(name: name, type: type, colorHex: colorHex),
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

    return BlocListener<TagBloc, TagState>(
      listener: (context, state) {
        if (state is TagOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translateErrorCode(state.message)),
              backgroundColor: AppColors.successLight,
            ),
          );
          context.pop(true);
        } else if (state is TagOperationError) {
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
        child: BlocBuilder<TagBloc, TagState>(
          builder: (context, state) {
            final isLoading = state is TagOperationInProgress;
            final isDetailLoading = state is TagDetailLoading;
            final tag = state is TagDetailLoaded ? state.tag : null;

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
                            ? context.translate('ui.tags.edit')
                            : context.translate('ui.tags.create'),
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
                    TagFormWidget(
                      key: ValueKey(tag?.id ?? 'new'),
                      initialTag: tag,
                      isLoading: isLoading,
                      onSubmit: _submit,
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
