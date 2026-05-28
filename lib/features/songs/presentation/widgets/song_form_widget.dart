// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/utils/audio_metadata_parser.dart';
import 'package:ondas_web/features/songs/domain/entities/song.dart';

class SongFormOption<T> {
  final T value;
  final String label;

  const SongFormOption({required this.value, required this.label});
}

class SongFormWidget extends StatefulWidget {
  final Song? initialSong;
  final bool isLoading;
  final bool optionsLoading;
  final String? optionsError;
  final List<SongFormOption<String>> artistOptions;
  final List<SongFormOption<int>> genreOptions;
  final List<SongFormOption<String>> albumOptions;
  final List<SongFormOption<int>> tagOptions;
  final Set<int>? initialTagIds;
  final Future<void> Function()? onReloadOptions;
  final ValueChanged<AudioMetadata>? onAudioMetadata;
  final void Function({
    required String title,
    String? albumId,
    int? trackNumber,
    String? releaseDate,
    required List<String> artistIds,
    required List<int> genreIds,
    required List<int> tagIds,
    required List<int> audioBytes,
    required String audioFileName,
    List<int>? coverBytes,
    String? coverFileName,
    bool? active,
  })
  onSubmit;

  const SongFormWidget({
    super.key,
    this.initialSong,
    required this.isLoading,
    required this.optionsLoading,
    required this.optionsError,
    required this.artistOptions,
    required this.genreOptions,
    required this.albumOptions,
    required this.tagOptions,
    this.initialTagIds,
    this.onReloadOptions,
    this.onAudioMetadata,
    required this.onSubmit,
  });

  @override
  State<SongFormWidget> createState() => _SongFormWidgetState();
}

class _SongFormWidgetState extends State<SongFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _trackNumberCtrl;
  DateTime? _selectedReleaseDate;

  List<int>? _audioBytes;
  String? _audioFileName;
  List<int>? _coverBytes;
  String? _coverFileName;
  Uint8List? _coverPreview;
  bool _active = true;

  String? _selectedAlbumId;
  Set<String> _selectedArtistIds = <String>{};
  Set<int> _selectedGenreIds = <int>{};
  Set<int> _selectedTagIds = <int>{};

  bool get _isEditing => widget.initialSong != null;

  @override
  void initState() {
    super.initState();
    final song = widget.initialSong;
    _titleCtrl = TextEditingController(text: song?.title ?? '');
    _trackNumberCtrl = TextEditingController(
      text: song?.trackNumber == null ? '' : '${song!.trackNumber}',
    );
    // Parse ngày phát hành từ string 'yyyy-MM-dd'
    if (song?.releaseDate != null && song!.releaseDate!.isNotEmpty) {
      try {
        final parts = song.releaseDate!.split('-');
        _selectedReleaseDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        _selectedReleaseDate = null;
      }
    }
    _selectedAlbumId = song?.albumId;
    _selectedArtistIds = song == null ? <String>{} : song.artistIds.toSet();
    _selectedGenreIds = song == null ? <int>{} : song.genreIds.toSet();
    _selectedTagIds = Set<int>.from(widget.initialTagIds ?? const <int>{});
    _active = song?.active ?? true;
  }

  @override
  void didUpdateWidget(covariant SongFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTagIds != null &&
        widget.initialTagIds != oldWidget.initialTagIds) {
      setState(() {
        _selectedTagIds = Set<int>.from(widget.initialTagIds!);
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _trackNumberCtrl.dispose();
    super.dispose();
  }

  void _pickAudio() {
    final input = html.FileUploadInputElement()
      ..accept = 'audio/*'
      ..click();

    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = reader.result as Uint8List;
        setState(() {
          _audioBytes = bytes.toList();
          _audioFileName = file.name;
        });
        _applyAudioMetadata(bytes);
      });
    });
  }

  void _applyAudioMetadata(Uint8List bytes) {
    AudioMetadata metadata;
    try {
      metadata = parseAudioMetadata(bytes);
    } catch (_) {
      return;
    }

    final title = metadata.title?.trim();
    if (title != null && title.isNotEmpty && _titleCtrl.text.trim().isEmpty) {
      _titleCtrl.text = title;
    }

    final handler = widget.onAudioMetadata;
    if (handler != null) {
      handler(metadata);
    }
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

  Future<void> _pickArtists() async {
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _MultiSelectDialog<String>(
        title: context.translate('ui.songs.choose_artists'),
        options: widget.artistOptions,
        selectedValues: _selectedArtistIds,
      ),
    );
    if (selected != null) {
      setState(() => _selectedArtistIds = selected);
    }
  }

  Future<void> _pickGenres() async {
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (_) => _MultiSelectDialog<int>(
        title: context.translate('ui.songs.choose_genres'),
        options: widget.genreOptions,
        selectedValues: _selectedGenreIds,
      ),
    );
    if (selected != null) {
      setState(() => _selectedGenreIds = selected);
    }
  }

  Future<void> _pickTags() async {
    final selected = await showDialog<Set<int>>(
      context: context,
      builder: (_) => _MultiSelectDialog<int>(
        title: context.translate('ui.songs.choose_tags'),
        options: widget.tagOptions,
        selectedValues: _selectedTagIds,
      ),
    );
    if (selected != null) {
      setState(() => _selectedTagIds = selected);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedArtistIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('ui.songs.error.empty_artists')),
          backgroundColor: AppColors.errorLight,
        ),
      );
      return;
    }

    if (_selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('ui.songs.error.empty_genres')),
          backgroundColor: AppColors.errorLight,
        ),
      );
      return;
    }

    if (!_isEditing && (_audioBytes == null || _audioFileName == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('ui.songs.error.empty_audio')),
          backgroundColor: AppColors.errorLight,
        ),
      );
      return;
    }

    final trackNumberText = _trackNumberCtrl.text.trim();

    widget.onSubmit(
      title: _titleCtrl.text.trim(),
      albumId: _selectedAlbumId,
      trackNumber: trackNumberText.isEmpty
          ? null
          : int.tryParse(trackNumberText),
      releaseDate: _selectedReleaseDate == null
          ? null
          : '${_selectedReleaseDate!.year.toString().padLeft(4, '0')}-'
                '${_selectedReleaseDate!.month.toString().padLeft(2, '0')}-'
                '${_selectedReleaseDate!.day.toString().padLeft(2, '0')}',
      artistIds: _selectedArtistIds.toList(),
      genreIds: _selectedGenreIds.toList(),
      tagIds: _selectedTagIds.toList(),
      audioBytes: _audioBytes ?? const <int>[],
      audioFileName: _audioFileName ?? '',
      coverBytes: _coverBytes,
      coverFileName: _coverFileName,
      active: _active,
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
          if (widget.optionsError != null)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorSurfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(color: AppColors.errorLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppColors.errorLight,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      context.translateErrorCode(widget.optionsError!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.errorLight,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onReloadOptions,
                    child: Text(context.translate('ui.common.retry')),
                  ),
                ],
              ),
            ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FieldsCard(
                    titleCtrl: _titleCtrl,
                    trackNumberCtrl: _trackNumberCtrl,
                    selectedReleaseDate: _selectedReleaseDate,
                    onPickDate: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedReleaseDate ?? now,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        helpText: context.translate('ui.songs.release_date_picker_title'),
                        cancelText: context.translate('ui.common.cancel'),
                        confirmText: context.translate('ui.common.select'),
                      );
                      if (picked != null) {
                        setState(() => _selectedReleaseDate = picked);
                      }
                    },
                    selectedAlbumId: _selectedAlbumId,
                    selectedArtistIds: _selectedArtistIds,
                    selectedGenreIds: _selectedGenreIds,
                    selectedTagIds: _selectedTagIds,
                    albumOptions: widget.albumOptions,
                    artistOptions: widget.artistOptions,
                    genreOptions: widget.genreOptions,
                    tagOptions: widget.tagOptions,
                    optionsLoading: widget.optionsLoading,
                    onAlbumChanged: (value) =>
                        setState(() => _selectedAlbumId = value),
                    onPickArtists: _pickArtists,
                    onPickGenres: _pickGenres,
                    onPickTags: _pickTags,
                    active: _active,
                    onActiveChanged: (value) => setState(() => _active = value),
                    isEditing: _isEditing,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    borderColor: borderColor,
                    bgCard: bgCard,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                SizedBox(
                  width: 260,
                  child: _MediaCard(
                    coverPreview: _coverPreview,
                    coverUrl: widget.initialSong?.coverUrl,
                    audioFileName: _audioFileName,
                    coverFileName: _coverFileName,
                    isLoading: widget.isLoading,
                    borderColor: borderColor,
                    bgCard: bgCard,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onPickAudio: _pickAudio,
                    onPickCover: _pickCover,
                    isEditing: _isEditing,
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
                key: const Key('songForm_backButton'),
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
                key: const Key('songForm_submitButton'),
                onPressed: (widget.isLoading || widget.optionsLoading)
                    ? null
                    : _submit,
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
                        widget.initialSong != null
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
  final TextEditingController titleCtrl;
  final TextEditingController trackNumberCtrl;
  final DateTime? selectedReleaseDate;
  final VoidCallback onPickDate;
  final String? selectedAlbumId;
  final Set<String> selectedArtistIds;
  final Set<int> selectedGenreIds;
  final Set<int> selectedTagIds;
  final List<SongFormOption<String>> albumOptions;
  final List<SongFormOption<String>> artistOptions;
  final List<SongFormOption<int>> genreOptions;
  final List<SongFormOption<int>> tagOptions;
  final bool optionsLoading;
  final ValueChanged<String?> onAlbumChanged;
  final VoidCallback onPickArtists;
  final VoidCallback onPickGenres;
  final VoidCallback onPickTags;
  final bool active;
  final ValueChanged<bool> onActiveChanged;
  final bool isEditing;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final Color bgCard;

  const _FieldsCard({
    required this.titleCtrl,
    required this.trackNumberCtrl,
    required this.selectedReleaseDate,
    required this.onPickDate,
    required this.selectedAlbumId,
    required this.selectedArtistIds,
    required this.selectedGenreIds,
    required this.selectedTagIds,
    required this.albumOptions,
    required this.artistOptions,
    required this.genreOptions,
    required this.tagOptions,
    required this.optionsLoading,
    required this.onAlbumChanged,
    required this.onPickArtists,
    required this.onPickGenres,
    required this.onPickTags,
    required this.active,
    required this.onActiveChanged,
    required this.isEditing,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.bgCard,
  });

  @override
  Widget build(BuildContext context) {
    final safeAlbumValue = albumOptions.any((e) => e.value == selectedAlbumId)
        ? selectedAlbumId
        : null;

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
          Row(
            children: [
              Text(
                context.translate('ui.songs.basic_info'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (optionsLoading) ...[
                const SizedBox(width: AppSpacing.md),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _FormField(
            key: const Key('songForm_titleField'),
            label: context.translate('ui.songs.title_label'),
            controller: titleCtrl,
            hintText: context.translate('ui.songs.title_hint'),
            textColor: textPrimary,
            borderColor: borderColor,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? context.translate('ui.common.not_null') : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          DropdownButtonFormField<String?>(
            key: ValueKey<String?>('songForm_albumDropdown_$safeAlbumValue'),
            initialValue: safeAlbumValue,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.translate('ui.songs.no_album_option')),
              ),
              ...albumOptions.map(
                (option) => DropdownMenuItem<String?>(
                  value: option.value,
                  child: Text(option.label),
                ),
              ),
            ],
            onChanged: optionsLoading ? null : onAlbumChanged,
            decoration: InputDecoration(
              labelText: context.translate('ui.songs.album_label'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.container),
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
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  key: const Key('songForm_trackNumberField'),
                  label: context.translate('ui.songs.track_number_label'),
                  controller: trackNumberCtrl,
                  hintText: '1',
                  textColor: textPrimary,
                  borderColor: borderColor,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isEmpty) return null;
                    return int.tryParse(text) == null
                        ? context.translate('ui.songs.error.invalid_track_number')
                        : null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('ui.songs.release_date_label'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: onPickDate,
                      borderRadius: BorderRadius.circular(AppRadius.container),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.smMd,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppRadius.container,
                          ),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedReleaseDate == null
                                    ? context.translate('ui.songs.release_date_hint')
                                    : '${selectedReleaseDate!.day.toString().padLeft(2, '0')}/'
                                          '${selectedReleaseDate!.month.toString().padLeft(2, '0')}/'
                                          '${selectedReleaseDate!.year}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedReleaseDate == null
                                      ? textPrimary.withAlpha(100)
                                      : textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: textPrimary.withAlpha(150),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _MultiSelectField<String>(
            key: const Key('songForm_artistMultiSelect'),
            label: context.translate('ui.songs.artists_label'),
            options: artistOptions,
            selectedValues: selectedArtistIds,
            onTap: optionsLoading ? null : onPickArtists,
            borderColor: borderColor,
            textColor: textPrimary,
            hintText: context.translate('ui.songs.artists_hint'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MultiSelectField<int>(
            key: const Key('songForm_genreMultiSelect'),
            label: context.translate('ui.songs.genres_label'),
            options: genreOptions,
            selectedValues: selectedGenreIds,
            onTap: optionsLoading ? null : onPickGenres,
            borderColor: borderColor,
            textColor: textPrimary,
            hintText: context.translate('ui.songs.genres_hint'),
          ),
          const SizedBox(height: AppSpacing.xl),
          _MultiSelectField<int>(
            key: const Key('songForm_tagMultiSelect'),
            label: context.translate('ui.songs.tags_label'),
            options: tagOptions,
            selectedValues: selectedTagIds,
            onTap: optionsLoading ? null : onPickTags,
            borderColor: borderColor,
            textColor: textPrimary,
            hintText: context.translate('ui.songs.tags_hint'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Checkbox(
                value: active,
                onChanged: isEditing
                    ? (value) => onActiveChanged(value ?? true)
                    : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('Active', style: TextStyle(color: textPrimary)),
              const SizedBox(width: AppSpacing.sm),
              if (!isEditing)
                Text(
                  context.translate('ui.songs.active_edit_only_hint'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MultiSelectField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final List<SongFormOption<T>> options;
  final Set<T> selectedValues;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color textColor;

  const _MultiSelectField({
    super.key,
    required this.label,
    required this.hintText,
    required this.options,
    required this.selectedValues,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final selectedLabels = options
        .where((option) => selectedValues.contains(option.value))
        .map((option) => option.label)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor)),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.container),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.container),
              border: Border.all(color: borderColor),
            ),
            child: selectedLabels.isEmpty
                ? Text(
                    hintText,
                    style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                  )
                : Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: selectedLabels
                        .map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoSurfaceLight,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.infoLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  final String title;
  final List<SongFormOption<T>> options;
  final Set<T> selectedValues;

  const _MultiSelectDialog({
    required this.title,
    required this.options,
    required this.selectedValues,
  });

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late Set<T> _working;
  String _searchQuery = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _working = Set<T>.from(widget.selectedValues);
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((o) =>
            o.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.translate('ui.songs.search_hint'),
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: filtered
                    .map(
                      (option) => CheckboxListTile(
                        value: _working.contains(option.value),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _working.add(option.value);
                            } else {
                              _working.remove(option.value);
                            }
                          });
                        },
                        title: Text(option.label),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.translate('ui.common.cancel')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_working),
          child: Text(context.translate('ui.common.done')),
        ),
      ],
    );
  }
}

class _MediaCard extends StatelessWidget {
  final Uint8List? coverPreview;
  final String? coverUrl;
  final String? audioFileName;
  final String? coverFileName;
  final bool isLoading;
  final Color borderColor;
  final Color bgCard;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onPickAudio;
  final VoidCallback onPickCover;
  final bool isEditing;

  const _MediaCard({
    required this.coverPreview,
    required this.coverUrl,
    required this.audioFileName,
    required this.coverFileName,
    required this.isLoading,
    required this.borderColor,
    required this.bgCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.onPickAudio,
    required this.onPickCover,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (coverPreview != null) {
      image = MemoryImage(coverPreview!);
    } else if (coverUrl != null && coverUrl!.isNotEmpty) {
      image = NetworkImage(coverUrl!);
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
            context.translate('ui.songs.media_title'),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.container),
                color: AppColors.lightGray,
                image: image == null
                    ? null
                    : DecorationImage(image: image, fit: BoxFit.cover),
              ),
              alignment: Alignment.center,
              child: image == null
                  ? const Icon(Icons.image_outlined, color: AppColors.stone)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('songForm_coverPickButton'),
            onPressed: isLoading ? null : onPickCover,
            icon: const Icon(Icons.upload_outlined, size: 14),
            label: Text(context.translate('ui.songs.cover_upload')),
            style: OutlinedButton.styleFrom(
              foregroundColor: textSecondary,
              side: BorderSide(color: borderColor),
              shape: const StadiumBorder(),
            ),
          ),
          if (coverFileName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              coverFileName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('songForm_audioPickButton'),
            onPressed: isLoading ? null : onPickAudio,
            icon: const Icon(Icons.audiotrack, size: 14),
            label: Text(
              isEditing
                  ? context.translate('ui.songs.audio_replace')
                  : context.translate('ui.songs.audio_upload'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: textSecondary,
              side: BorderSide(color: borderColor),
              shape: const StadiumBorder(),
            ),
          ),
          if (audioFileName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              audioFileName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ] else if (!isEditing) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.translate('ui.songs.audio_required_hint'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.errorLight),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          Text(
            context.translate('ui.songs.api_data_hint'),
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

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final Color borderColor;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.borderColor,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textColor)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          key: key,
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
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
