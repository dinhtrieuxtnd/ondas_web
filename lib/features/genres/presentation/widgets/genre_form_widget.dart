// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/genres/domain/entities/genre.dart';

class GenreFormWidget extends StatefulWidget {
  final Genre? initialGenre;
  final bool isLoading;
  final void Function({
    required String name,
    String? slug,
    String? description,
    String? coverUrl,
    List<int>? coverBytes,
    String? coverFileName,
  })
  onSubmit;

  const GenreFormWidget({
    super.key,
    this.initialGenre,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<GenreFormWidget> createState() => _GenreFormWidgetState();
}

class _GenreFormWidgetState extends State<GenreFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _coverUrlCtrl;

  List<int>? _coverBytes;
  String? _coverFileName;
  Uint8List? _coverPreview;
  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGenre;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _slugCtrl = TextEditingController(text: g?.slug ?? '');
    _descriptionCtrl = TextEditingController(text: g?.description ?? '');
    _coverUrlCtrl = TextEditingController(text: g?.coverUrl ?? '');
    _slugEdited = g?.slug != null && g!.slug!.isNotEmpty;
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descriptionCtrl.dispose();
    _coverUrlCtrl.dispose();
    super.dispose();
  }

  void _pickCover() {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = reader.result as Uint8List;
        setState(() {
          _coverBytes = bytes.toList();
          _coverFileName = file.name;
          _coverPreview = bytes;
        });
      });
    });
  }

  void _onNameChanged() {
    if (_slugEdited) return;
    final generated = _toSlug(_nameCtrl.text);
    if (_slugCtrl.text != generated) {
      _slugCtrl.value = _slugCtrl.value.copyWith(
        text: generated,
        selection: TextSelection.collapsed(offset: generated.length),
      );
    }
  }

  static String _toSlug(String source) {
    const viMap = {
      'à': 'a',
      'á': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'â': 'a',
      'ầ': 'a',
      'ấ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'ă': 'a',
      'ằ': 'a',
      'ắ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'è': 'e',
      'é': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ề': 'e',
      'ế': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'ì': 'i',
      'í': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ò': 'o',
      'ó': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ồ': 'o',
      'ố': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ờ': 'o',
      'ớ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ù': 'u',
      'ú': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ừ': 'u',
      'ứ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ỳ': 'y',
      'ý': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };
    var s = source.toLowerCase();
    s = s.split('').map((c) => viMap[c] ?? c).join();
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.trim().replaceAll(RegExp(r'\s+'), '-');
    return s.replaceAll(RegExp(r'-+'), '-');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      name: _nameCtrl.text.trim(),
      slug: _slugCtrl.text.trim().isEmpty ? null : _slugCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      coverUrl: _coverUrlCtrl.text.trim().isEmpty
          ? null
          : _coverUrlCtrl.text.trim(),
      coverBytes: _coverBytes,
      coverFileName: _coverFileName,
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FieldsCard(
                    nameCtrl: _nameCtrl,
                    slugCtrl: _slugCtrl,
                    descriptionCtrl: _descriptionCtrl,
                    coverUrlCtrl: _coverUrlCtrl,
                    textPrimary: textPrimary,
                    borderColor: borderColor,
                    bgCard: bgCard,
                    onSlugChanged: () => setState(() => _slugEdited = true),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                SizedBox(
                  width: 260,
                  child: _CoverCard(
                    previewBytes: _coverPreview,
                    networkUrl: widget.initialGenre?.coverUrl,
                    fileName: _coverFileName,
                    isLoading: widget.isLoading,
                    borderColor: borderColor,
                    bgCard: bgCard,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onPick: _pickCover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                key: const Key('genreForm_backButton'),
                onPressed: widget.isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: textSecondary,
                  side: BorderSide(color: borderColor),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.smMd,
                  ),
                ),
                child: Text(context.translate('ui.common.cancel')),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                key: const Key('genreForm_submitButton'),
                onPressed: widget.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nearBlack,
                  foregroundColor: AppColors.pureWhite,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.smMd,
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pureWhite,
                        ),
                      )
                    : Text(
                        widget.initialGenre != null
                            ? context.translate('ui.common.update')
                            : context.translate('ui.common.create'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldsCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController slugCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController coverUrlCtrl;
  final Color textPrimary;
  final Color borderColor;
  final Color bgCard;
  final VoidCallback onSlugChanged;

  const _FieldsCard({
    required this.nameCtrl,
    required this.slugCtrl,
    required this.descriptionCtrl,
    required this.coverUrlCtrl,
    required this.textPrimary,
    required this.borderColor,
    required this.bgCard,
    required this.onSlugChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            context.translate('ui.genres.basic_info'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FormField(
            key: const Key('genreForm_nameField'),
            label: context.translate('ui.genres.name_label'),
            controller: nameCtrl,
            hintText: context.translate('ui.genres.name_hint'),
            textColor: textPrimary,
            borderColor: borderColor,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? context.translate('ui.common.not_null') : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  key: const Key('genreForm_slugField'),
                  label: 'Slug',
                  controller: slugCtrl,
                  hintText: 'v-pop',
                  textColor: textPrimary,
                  borderColor: borderColor,
                  onChanged: (_) => onSlugChanged(),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: _FormField(
                  key: const Key('genreForm_coverUrlField'),
                  label: 'Cover URL',
                  controller: coverUrlCtrl,
                  hintText: 'https://...',
                  textColor: textPrimary,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _FormField(
            key: const Key('genreForm_descriptionField'),
            label: context.translate('ui.genres.description_label'),
            controller: descriptionCtrl,
            hintText: context.translate('ui.genres.description_hint'),
            textColor: textPrimary,
            borderColor: borderColor,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  final Uint8List? previewBytes;
  final String? networkUrl;
  final String? fileName;
  final bool isLoading;
  final Color borderColor;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onPick;

  const _CoverCard({
    required this.previewBytes,
    required this.networkUrl,
    required this.fileName,
    required this.isLoading,
    required this.borderColor,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (previewBytes != null) {
      image = MemoryImage(previewBytes!);
    } else if (networkUrl != null && networkUrl!.isNotEmpty) {
      image = NetworkImage(networkUrl!);
    }

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.translate('ui.genres.cover_label'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.container),
                image: image != null
                    ? DecorationImage(image: image, fit: BoxFit.cover)
                    : null,
              ),
              child: image == null
                  ? Icon(Icons.image_outlined, size: 40, color: textSecondary)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            key: const Key('genreForm_coverPickButton'),
            onPressed: isLoading ? null : onPick,
            icon: const Icon(Icons.upload_outlined, size: 14),
            label: Text(context.translate('ui.genres.cover_upload')),
            style: OutlinedButton.styleFrom(
              foregroundColor: textSecondary,
              side: BorderSide(color: borderColor),
              shape: const StadiumBorder(),
            ),
          ),
          if (fileName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              fileName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final Color borderColor;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _FormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.borderColor,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.smMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                maxLines > 1 ? AppRadius.container : AppRadius.pill,
              ),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                maxLines > 1 ? AppRadius.container : AppRadius.pill,
              ),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                maxLines > 1 ? AppRadius.container : AppRadius.pill,
              ),
              borderSide: const BorderSide(
                color: AppColors.nearBlack,
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
