// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/features/artists/domain/entities/artist.dart';

class ArtistFormWidget extends StatefulWidget {
  final Artist? initialArtist;
  final bool isLoading;
  final void Function({
    required String name,
    String? slug,
    String? bio,
    String? country,
    List<int>? avatarBytes,
    String? avatarFileName,
  })
  onSubmit;

  const ArtistFormWidget({
    super.key,
    this.initialArtist,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<ArtistFormWidget> createState() => _ArtistFormWidgetState();
}

class _ArtistFormWidgetState extends State<ArtistFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _countryCtrl;

  List<int>? _avatarBytes;
  String? _avatarFileName;
  Uint8List? _avatarPreview;

  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initialArtist;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _slugCtrl = TextEditingController(text: a?.slug ?? '');
    _bioCtrl = TextEditingController(text: a?.bio ?? '');
    _countryCtrl = TextEditingController(text: a?.country ?? '');
    // Slug has been set from existing data — treat as manually edited.
    _slugEdited = a?.slug != null && a!.slug!.isNotEmpty;
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _bioCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _pickAvatar() {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    input.onChange.listen((event) {
      final file = input.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = reader.result as Uint8List;
        setState(() {
          _avatarBytes = bytes.toList();
          _avatarFileName = file.name;
          _avatarPreview = bytes;
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

  static String _toSlug(String name) {
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
    var s = name.toLowerCase();
    s = s.split('').map((c) => viMap[c] ?? c).join();
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.trim().replaceAll(RegExp(r'\s+'), '-');
    s = s.replaceAll(RegExp(r'-+'), '-');
    return s;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      name: _nameCtrl.text.trim(),
      slug: _slugCtrl.text.trim().isEmpty ? null : _slugCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty
          ? null
          : _countryCtrl.text.trim(),
      avatarBytes: _avatarBytes,
      avatarFileName: _avatarFileName,
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
          // ── 2-column layout ────────────────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: main fields
                Expanded(
                  child: _FieldsCard(
                    nameCtrl: _nameCtrl,
                    slugCtrl: _slugCtrl,
                    bioCtrl: _bioCtrl,
                    countryCtrl: _countryCtrl,
                    textPrimary: textPrimary,
                    borderColor: borderColor,
                    bgCard: bgCard,
                    onSlugChanged: () => setState(() => _slugEdited = true),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                // Right: avatar upload
                SizedBox(
                  width: 200,
                  child: _AvatarCard(
                    previewBytes: _avatarPreview,
                    networkUrl: widget.initialArtist?.avatarUrl,
                    fileName: _avatarFileName,
                    name: _nameCtrl.text,
                    isLoading: widget.isLoading,
                    borderColor: borderColor,
                    bgCard: bgCard,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onPick: _pickAvatar,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Actions ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                key: const Key('artistForm_backButton'),
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
                key: const Key('artistForm_submitButton'),
                onPressed: widget.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.nearBlack,
                  foregroundColor: AppColors.pureWhite,
                  disabledBackgroundColor: AppColors.darkBorderStrong,
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
                        widget.initialArtist != null
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

// ─── Fields card ──────────────────────────────────────────────────────────────

class _FieldsCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController slugCtrl;
  final TextEditingController bioCtrl;
  final TextEditingController countryCtrl;
  final Color textPrimary;
  final Color borderColor;
  final Color bgCard;
  final VoidCallback onSlugChanged;

  const _FieldsCard({
    required this.nameCtrl,
    required this.slugCtrl,
    required this.bioCtrl,
    required this.countryCtrl,
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
            context.translate('ui.artists.basic_info'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FormField(
            key: const Key('artistForm_nameField'),
            label: context.translate('ui.artists.name_label'),
            controller: nameCtrl,
            hintText: context.translate('ui.artists.name_hint'),
            textColor: textPrimary,
            borderColor: borderColor,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? context.translate('ui.common.not_null')
                : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormField(
                  key: const Key('artistForm_countryField'),
                  label: context.translate('ui.artists.country_label'),
                  controller: countryCtrl,
                  hintText: context.translate('ui.artists.country_hint'),
                  textColor: textPrimary,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: _FormField(
                  key: const Key('artistForm_slugField'),
                  label: 'Slug',
                  controller: slugCtrl,
                  hintText: 'son-tung-m-tp',
                  textColor: textPrimary,
                  borderColor: borderColor,
                  onChanged: (_) => onSlugChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _FormField(
            key: const Key('artistForm_bioField'),
            label: context.translate('ui.artists.bio_label'),
            controller: bioCtrl,
            hintText: context.translate('ui.artists.bio_hint'),
            textColor: textPrimary,
            borderColor: borderColor,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

// ─── Avatar card ──────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final Uint8List? previewBytes;
  final String? networkUrl;
  final String? fileName;
  final String name;
  final bool isLoading;
  final Color borderColor;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onPick;

  const _AvatarCard({
    required this.previewBytes,
    required this.networkUrl,
    required this.fileName,
    required this.name,
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

    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.translate('ui.artists.avatar_label'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.darkSurfaceElevated,
              backgroundImage: image,
              child: image == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkTextSecondary,
                      ),
                    )
                  : null,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            key: const Key('artistForm_avatarPickButton'),
            onPressed: isLoading ? null : onPick,
            icon: const Icon(Icons.upload_outlined, size: 14),
            label: Text(context.translate('ui.artists.avatar_upload')),
            style: OutlinedButton.styleFrom(
              foregroundColor: textSecondary,
              side: BorderSide(color: borderColor),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
          if (fileName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              fileName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          Text(
            context.translate('ui.artists.avatar_hint'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: textSecondary, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Reusable form field ───────────────────────────────────────────────────────

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
            hintStyle: TextStyle(
              color: textColor.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.smMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
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
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                maxLines > 1 ? AppRadius.container : AppRadius.pill,
              ),
              borderSide: const BorderSide(color: AppColors.errorLight),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                maxLines > 1 ? AppRadius.container : AppRadius.pill,
              ),
              borderSide: const BorderSide(
                color: AppColors.errorLight,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
