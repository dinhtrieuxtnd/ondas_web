// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/playlists/domain/entities/playlist.dart';

class PlaylistFormWidget extends StatefulWidget {
  final Playlist? initialPlaylist;
  final bool isLoading;
  final void Function({
    required String name,
    String? description,
    required bool isPublic,
    List<int>? coverBytes,
    String? coverFileName,
  })
  onSubmit;

  const PlaylistFormWidget({
    super.key,
    this.initialPlaylist,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<PlaylistFormWidget> createState() => _PlaylistFormWidgetState();
}

class _PlaylistFormWidgetState extends State<PlaylistFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late bool _isPublic;
  List<int>? _coverBytes;
  String? _coverFileName;
  Uint8List? _coverPreview;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialPlaylist?.name ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.initialPlaylist?.description ?? '',
    );
    _isPublic = widget.initialPlaylist?.isPublic ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      name: _nameCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      isPublic: false,
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
    final image = _coverPreview != null
        ? MemoryImage(_coverPreview!) as ImageProvider
        : (widget.initialPlaylist?.coverUrl?.isNotEmpty == true
              ? NetworkImage(widget.initialPlaylist!.coverUrl!)
              : null);

    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
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
                    context.translate('ui.playlists.basic_info'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _PlaylistTextField(
                    controller: _nameCtrl,
                    label: context.translate('ui.playlists.name_label'),
                    hintText: context.translate('ui.playlists.name_hint'),
                    textColor: textPrimary,
                    borderColor: borderColor,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.translate('ui.common.not_null')
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DescriptionField(
                    controller: _descriptionCtrl,
                    textColor: textPrimary,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: widget.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(context.translate('ui.common.cancel')),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: widget.isLoading ? null : _submit,
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.initialPlaylist == null
                                    ? context.translate('ui.common.create')
                                    : context.translate('ui.common.update'),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          SizedBox(
            width: 280,
            child: Container(
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
                    context.translate('ui.playlists.cover_label'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceElevated.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppRadius.container,
                        ),
                        image: image == null
                            ? null
                            : DecorationImage(image: image, fit: BoxFit.cover),
                      ),
                      child: image == null
                          ? Icon(
                              Icons.image_outlined,
                              size: 42,
                              color: textSecondary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: widget.isLoading ? null : _pickCover,
                    icon: const Icon(Icons.upload_outlined, size: 16),
                    label: Text(context.translate('ui.playlists.cover_upload')),
                  ),
                  if (_coverFileName != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _coverFileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final Color textColor;
  final Color borderColor;
  final String? Function(String?)? validator;

  const _PlaylistTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.textColor,
    required this.borderColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.smMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
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

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final Color textColor;
  final Color borderColor;

  const _DescriptionField({
    required this.controller,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translate('ui.playlists.description_label'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: context.translate('ui.playlists.description_hint'),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.smMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.container),
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
