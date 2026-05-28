import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/utils/audio_metadata_parser.dart';
import 'package:ondas_web/features/lyrics/domain/entities/lyrics.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_event.dart';

class LyricsDraft {
  final String? language;
  final String? plainText;
  final List<Map<String, dynamic>>? syncedLines;

  const LyricsDraft({
    this.language,
    this.plainText,
    this.syncedLines,
  });
}

class LyricsFormWidget extends StatefulWidget {
  final String songId;
  final Lyrics? existingLyrics;
  final List<SyncedLyricsLineDraft>? prefilledSyncedLines;
  final String? prefilledPlainText;
  final bool isSaving;
  final bool allowSubmit;
  final bool allowDelete;

  const LyricsFormWidget({
    super.key,
    required this.songId,
    this.existingLyrics,
    this.prefilledSyncedLines,
    this.prefilledPlainText,
    this.isSaving = false,
    this.allowSubmit = true,
    this.allowDelete = true,
  });

  @override
  State<LyricsFormWidget> createState() => LyricsFormWidgetState();
}

class LyricsFormWidgetState extends State<LyricsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _languageController = TextEditingController();
  final _plainTextController = TextEditingController();
  bool _hasSynced = false;
  List<_SyncedLineData> _syncedLines = [];

  bool get _isEditing => widget.existingLyrics != null;

  bool hasDraftContent() => _hasAnyContent();

  LyricsDraft? buildDraft({bool showValidationErrors = true}) {
    if (!_hasAnyContent()) return null;
    if (!_validateSyncedLines(showValidationErrors: showValidationErrors)) {
      return null;
    }

    final syncedLines = _buildSyncedLines();
    return LyricsDraft(
      language: _trimOrNull(_languageController.text),
      plainText: _hasSynced ? null : _trimOrNull(_plainTextController.text),
      syncedLines: syncedLines,
    );
  }

  @override
  void initState() {
    super.initState();
    final lyrics = widget.existingLyrics;
    if (lyrics != null) {
      _applyExistingLyrics(lyrics);
    } else if (widget.prefilledSyncedLines != null &&
        widget.prefilledSyncedLines!.isNotEmpty) {
      _applyPrefill(widget.prefilledSyncedLines!);
    } else if (widget.prefilledPlainText != null &&
        widget.prefilledPlainText!.trim().isNotEmpty) {
      _applyPlainPrefill(widget.prefilledPlainText!);
    }
  }

  @override
  void didUpdateWidget(covariant LyricsFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.existingLyrics != oldWidget.existingLyrics &&
        widget.existingLyrics != null) {
      setState(() => _applyExistingLyrics(widget.existingLyrics!));
      return;
    }

    if (widget.existingLyrics == null &&
        widget.prefilledSyncedLines != oldWidget.prefilledSyncedLines &&
        _canApplyPrefill(widget.prefilledSyncedLines)) {
      setState(() => _applyPrefill(widget.prefilledSyncedLines!));
      return;
    }

    if (widget.existingLyrics == null &&
        widget.prefilledPlainText != oldWidget.prefilledPlainText &&
        _canApplyPlainPrefill(widget.prefilledPlainText)) {
      setState(() => _applyPlainPrefill(widget.prefilledPlainText!));
    }
  }

  @override
  void dispose() {
    _languageController.dispose();
    _plainTextController.dispose();
    for (final line in _syncedLines) {
      line.dispose();
    }
    super.dispose();
  }

  void _addLine({int? afterIndex}) {
    setState(() {
      String? startMsPrefill;
      if (_syncedLines.isNotEmpty) {
        final int sourceIndex = (afterIndex != null &&
                afterIndex >= 0 &&
                afterIndex < _syncedLines.length)
            ? afterIndex
            : _syncedLines.length - 1;
        final sourceEndMs =
            _syncedLines[sourceIndex].endMsController.text.trim();
        if (sourceEndMs.isNotEmpty) {
          startMsPrefill = sourceEndMs;
        }
      }
      final newLine = _SyncedLineData(
        startMsController: TextEditingController(text: startMsPrefill ?? ''),
        endMsController: TextEditingController(),
        lineTextController: TextEditingController(),
      );
      if (afterIndex != null && afterIndex < _syncedLines.length) {
        _syncedLines.insert(afterIndex + 1, newLine);
      } else {
        _syncedLines.add(newLine);
      }
    });
  }

  void _applyExistingLyrics(Lyrics lyrics) {
    _languageController.text = lyrics.language ?? '';
    _plainTextController.text = lyrics.plainText ?? '';
    _hasSynced = lyrics.hasSynced;
    _setSyncedLines(
      lyrics.syncedLines
          .map((e) => _SyncedLineData(
                startMsController:
                    TextEditingController(text: _formatMsToTime(e.startMs)),
                endMsController: TextEditingController(
                  text: _formatMsToTime(e.endMs),
                ),
                lineTextController: TextEditingController(text: e.lineText),
              ))
          .toList(),
    );
  }

  void _applyPrefill(List<SyncedLyricsLineDraft> lines) {
    if (lines.isEmpty) return;
    _hasSynced = true;
    _plainTextController.text = '';
    _setSyncedLines(
      lines
          .map((line) => _SyncedLineData(
                startMsController: TextEditingController(
                  text: _formatMsToTime(line.startMs),
                ),
                endMsController: TextEditingController(
                  text: _formatMsToTime(line.endMs),
                ),
                lineTextController:
                    TextEditingController(text: line.lineText),
              ))
          .toList(),
    );
  }

  void _applyPlainPrefill(String text) {
    _hasSynced = false;
    _plainTextController.text = text.trim();
    _setSyncedLines(const []);
  }

  void _setSyncedLines(List<_SyncedLineData> lines) {
    for (final line in _syncedLines) {
      line.dispose();
    }
    _syncedLines = lines;
  }

  bool _canApplyPrefill(List<SyncedLyricsLineDraft>? lines) {
    if (lines == null || lines.isEmpty) return false;
    if (_hasUserInput()) return false;
    return true;
  }

  bool _canApplyPlainPrefill(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    if (_hasUserInput()) return false;
    return true;
  }

  bool _hasUserInput() {
    if (_languageController.text.trim().isNotEmpty) return true;
    if (_plainTextController.text.trim().isNotEmpty) return true;
    for (final line in _syncedLines) {
      if (line.lineTextController.text.trim().isNotEmpty) return true;
      if (line.startMsController.text.trim().isNotEmpty) return true;
      if (line.endMsController.text.trim().isNotEmpty) return true;
    }
    return false;
  }

  void _removeLine(int index) {
    setState(() {
      _syncedLines[index].dispose();
      _syncedLines.removeAt(index);
    });
  }

  bool _hasAnyContent() {
    if (_hasSynced) {
      for (final line in _syncedLines) {
        if (line.lineTextController.text.trim().isNotEmpty) return true;
        if (line.startMsController.text.trim().isNotEmpty) return true;
        if (line.endMsController.text.trim().isNotEmpty) return true;
      }
      return false;
    }
    return _plainTextController.text.trim().isNotEmpty;
  }

  bool _validateSyncedLines({required bool showValidationErrors}) {
    if (!_hasSynced) return true;
    for (int i = 0; i < _syncedLines.length; i++) {
      final line = _syncedLines[i];
      if (line.lineTextController.text.trim().isEmpty) {
        if (showValidationErrors) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate('ui.lyrics.error.empty_row'))),
          );
        }
        return false;
      }
      final startSeconds = _parseTimeToSeconds(line.startMsController.text);
      if (startSeconds == null || startSeconds < 0) {
        if (showValidationErrors) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.translate('ui.lyrics.error.invalid_start', {'index': i + 1}),
              ),
            ),
          );
        }
        return false;
      }
      final endText = line.endMsController.text.trim();
      if (endText.isNotEmpty) {
        final endSeconds = _parseTimeToSeconds(endText);
        if (endSeconds == null || endSeconds < 0) {
          if (showValidationErrors) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.translate('ui.lyrics.error.invalid_end', {'index': i + 1}),
                ),
              ),
            );
          }
          return false;
        }
      }
    }
    return true;
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatMsToTime(int? ms) {
    if (ms == null) return '';
    final minutes = ms ~/ 60000;
    final remainingMs = ms % 60000;
    final seconds = remainingMs / 1000;
    final secondsFixed = seconds.toStringAsFixed(3);
    final parts = secondsFixed.split('.');
    final secondsInt = parts[0].padLeft(2, '0');
    final secondsFrac =
        parts.length > 1 ? parts[1].replaceFirst(RegExp(r'0+$'), '') : '';
    final secondsText =
        secondsFrac.isEmpty ? secondsInt : '$secondsInt.$secondsFrac';
    return '${minutes.toString().padLeft(2, '0')}:$secondsText';
  }

  double? _parseTimeToSeconds(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final parts = normalized.split(':');
    if (parts.length != 2) return null;
    final minutesText = parts[0].trim();
    final secondsText = parts[1].trim();
    if (minutesText.isEmpty || secondsText.isEmpty) return null;
    final minutes = int.tryParse(minutesText);
    final seconds = double.tryParse(secondsText);
    if (minutes == null || seconds == null) return null;
    if (minutes < 0 || seconds < 0 || seconds >= 60) return null;
    return (minutes * 60) + seconds;
  }

  int _secondsToMs(double seconds) => (seconds * 1000).round();

  List<Map<String, dynamic>>? _buildSyncedLines() {
    if (!_hasSynced) return null;
    if (_syncedLines.isEmpty) return [];
    return List.generate(_syncedLines.length, (i) {
      final line = _syncedLines[i];
      final startSeconds =
          _parseTimeToSeconds(line.startMsController.text) ?? 0;
      final map = <String, dynamic>{
        'startMs': _secondsToMs(startSeconds),
        'lineText': line.lineTextController.text,
        'lineIndex': i,
      };
      final endMsText = line.endMsController.text.trim();
      if (endMsText.isNotEmpty) {
        final endSeconds = _parseTimeToSeconds(endMsText);
        if (endSeconds != null) {
          map['endMs'] = _secondsToMs(endSeconds);
        }
      }
      return map;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final draft = buildDraft();
    if (draft == null) return;
    final bloc = context.read<LyricsBloc>();

    if (_isEditing) {
      bloc.add(LyricsUpdateEvent(
        songId: widget.songId,
        language: draft.language,
        plainText: draft.plainText,
        syncedLines: draft.syncedLines,
      ));
    } else {
      bloc.add(LyricsCreateEvent(
        songId: widget.songId,
        language: draft.language,
        plainText: draft.plainText,
        syncedLines: draft.syncedLines,
      ));
    }
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.translate('ui.lyrics.delete_title')),
        content: Text(context.translate('ui.lyrics.delete_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.translate('ui.common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<LyricsBloc>()
                  .add(LyricsDeleteEvent(songId: widget.songId));
            },
            child: Text(
              context.translate('ui.common.delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isSaving = widget.isSaving;
    final isLight = theme.brightness == Brightness.light;
    final bgCard = isLight ? AppColors.snow : AppColors.darkSurface;
    final fieldBg = isLight ? AppColors.pureWhite : AppColors.darkSurface;
    final borderColor = isLight ? AppColors.borderLight : AppColors.darkBorder;
    final textPrimary =
        isLight ? AppColors.nearBlack : AppColors.darkTextPrimary;
    final textSecondary =
        isLight ? AppColors.stone : AppColors.darkTextSecondary;

    return Form(
      key: _formKey,
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
              context.translate('ui.lyrics.title'),
              style: textTheme.titleMedium?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.translate('ui.lyrics.subtitle'),
              style: textTheme.bodySmall?.copyWith(color: textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Language ──────────────────────────────────────────────
            TextFormField(
              key: const Key('lyricsForm_languageField'),
              controller: _languageController,
              decoration: InputDecoration(
                labelText: context.translate('ui.lyrics.language_label'),
                hintText: context.translate('ui.lyrics.language_hint'),
                prefixIcon: const Icon(Icons.language),
                filled: true,
                fillColor: fieldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.container),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  borderSide: const BorderSide(color: AppColors.nearBlack),
                ),
              ),
              enabled: !isSaving,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Synced toggle ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(AppRadius.container),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: SwitchListTile(
                key: const Key('lyricsForm_syncedToggle'),
                contentPadding: EdgeInsets.zero,
                title: Text(context.translate('ui.lyrics.synced_label')),
                subtitle: Text(
                  _hasSynced
                      ? context.translate('ui.lyrics.synced_desc_on')
                      : context.translate('ui.lyrics.synced_desc_off'),
                  style: textTheme.bodySmall?.copyWith(color: textSecondary),
                ),
                value: _hasSynced,
                onChanged:
                    isSaving ? null : (val) => setState(() => _hasSynced = val),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Plain text or Synced lines ────────────────────────────
            if (_hasSynced)
              _buildSyncedEditor(
                theme,
                textTheme,
                isSaving,
                borderColor: borderColor,
                fieldBg: fieldBg,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              )
            else
              _buildPlainTextEditor(
                theme,
                isSaving,
                borderColor: borderColor,
                fieldBg: fieldBg,
                textPrimary: textPrimary,
              ),

            const SizedBox(height: AppSpacing.xl),

            // ── Actions ───────────────────────────────────────────────
            if (widget.allowSubmit || widget.allowDelete)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_isEditing && widget.allowDelete)
                    OutlinedButton.icon(
                      key: const Key('lyricsForm_deleteButton'),
                      onPressed: isSaving ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorLight,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(context.translate('ui.lyrics.delete_button')),
                    ),
                  if (_isEditing && widget.allowDelete)
                    const SizedBox(width: AppSpacing.sm),
                  if (widget.allowSubmit)
                    ElevatedButton.icon(
                      key: const Key('lyricsForm_saveButton'),
                      onPressed: isSaving ? null : _submit,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(
                        _isEditing
                            ? context.translate('ui.lyrics.update_button')
                            : context.translate('ui.lyrics.create_button'),
                      ),
                    ),
                  if (isSaving && widget.allowSubmit) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlainTextEditor(
    ThemeData theme,
    bool disabled, {
    required Color borderColor,
    required Color fieldBg,
    required Color textPrimary,
  }) {
    return TextFormField(
      key: const Key('lyricsForm_plainTextField'),
      controller: _plainTextController,
      minLines: 8,
      maxLines: 14,
      decoration: InputDecoration(
        labelText: context.translate('ui.lyrics.plain_label'),
        hintText: context.translate('ui.lyrics.plain_hint'),
        alignLabelWithHint: true,
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.container),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.container),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.container),
          borderSide: const BorderSide(color: AppColors.nearBlack),
        ),
      ),
      style: TextStyle(color: textPrimary, height: 1.4),
      enabled: !disabled,
    );
  }

  Widget _buildSyncedEditor(
    ThemeData theme,
    TextTheme textTheme,
    bool disabled,
    {
    required Color borderColor,
    required Color fieldBg,
    required Color textPrimary,
    required Color textSecondary,
  }
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.translate('ui.lyrics.synced_list_title'),
              style: textTheme.titleSmall?.copyWith(color: textPrimary),
            ),
            const Spacer(),
            OutlinedButton.icon(
              key: const Key('lyricsForm_addLineButton'),
              onPressed: disabled ? null : () => _addLine(),
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.translate('ui.lyrics.add_row')),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_syncedLines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                context.translate('ui.lyrics.empty_rows'),
                style: textTheme.bodyMedium?.copyWith(color: textSecondary),
              ),
            ),
          )
        else
          ...List.generate(_syncedLines.length, (index) {
            final line = _syncedLines[index];
            return _SyncedLineRow(
              key: ValueKey('synced_line_$index'),
              index: index,
              line: line,
              disabled: disabled,
              onRemove: () => _removeLine(index),
              onInsert: () => _addLine(afterIndex: index),
              borderColor: borderColor,
              fieldBg: fieldBg,
              textPrimary: textPrimary,
            );
          }),
      ],
    );
  }
}

// ─── Synced line data holder ──────────────────────────────────────────────────

class _SyncedLineData {
  final TextEditingController startMsController;
  final TextEditingController endMsController;
  final TextEditingController lineTextController;

  _SyncedLineData({
    required this.startMsController,
    required this.endMsController,
    required this.lineTextController,
  });

  void dispose() {
    startMsController.dispose();
    endMsController.dispose();
    lineTextController.dispose();
  }
}

class _CleanedInput {
  final String text;
  final int cursor;

  const _CleanedInput(this.text, this.cursor);
}

class _TimeTextInputFormatter extends TextInputFormatter {
  const _TimeTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final cleaned = _cleanInput(newValue.text, newValue.selection.end);
    if (cleaned.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formattedResult = _formatWithCursor(cleaned.text, cleaned.cursor);
    final formattedText = formattedResult.text;
    var formattedCursor = formattedResult.cursor;
    if (formattedCursor < 0) {
      formattedCursor = 0;
    } else if (formattedCursor > formattedText.length) {
      formattedCursor = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedCursor),
    );
  }

  _CleanedInput _cleanInput(String input, int cursorIndex) {
    final buffer = StringBuffer();
    var cursor = 0;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (_isAllowed(ch)) {
        final normalized = ch == ',' ? '.' : ch;
        buffer.write(normalized);
        if (i < cursorIndex) {
          cursor++;
        }
      }
    }
    return _CleanedInput(buffer.toString(), cursor);
  }

  _CleanedInput _formatWithCursor(String input, int cursor) {
    if (input.contains(':')) {
      final firstColon = input.indexOf(':');
      final before = input.substring(0, firstColon);
      final after = input.substring(firstColon + 1);
      final minutes = before.replaceAll(RegExp(r'[^0-9]'), '');
      final seconds = after.replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(':', '');

      var newCursor = cursor;
      if (cursor <= firstColon) {
        newCursor = _countDigits(input.substring(0, cursor));
      } else {
        final beforeDigits = _countDigits(before);
        final afterRaw = input.substring(firstColon + 1, cursor);
        final afterFiltered =
            afterRaw.replaceAll(RegExp(r'[^0-9.]'), '').replaceAll(':', '');
        newCursor = beforeDigits + 1 + afterFiltered.length;
      }
      return _CleanedInput('$minutes:$seconds', newCursor);
    }

    final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
    final digitsCursor = _countDigits(input.substring(0, cursor));
    if (digitsOnly.length > 2) {
      final text = '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
      final newCursor = digitsCursor > 2 ? digitsCursor + 1 : digitsCursor;
      return _CleanedInput(text, newCursor);
    }
    return _CleanedInput(digitsOnly, digitsCursor);
  }

  bool _isAllowed(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 48 && code <= 57) || ch == ':' || ch == '.' || ch == ',';
  }

  int _countDigits(String input) {
    var count = 0;
    for (var i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        count++;
      }
    }
    return count;
  }
}

// ─── Single synced line row ───────────────────────────────────────────────────

class _SyncedLineRow extends StatelessWidget {
  final int index;
  final _SyncedLineData line;
  final bool disabled;
  final VoidCallback onRemove;
  final VoidCallback onInsert;
  final Color borderColor;
  final Color fieldBg;
  final Color textPrimary;

  const _SyncedLineRow({
    super.key,
    required this.index,
    required this.line,
    required this.disabled,
    required this.onRemove,
    required this.onInsert,
    required this.borderColor,
    required this.fieldBg,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.container);
    final baseBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(
        color: AppColors.nearBlack,
        width: 1.3,
      ),
    );
    InputDecoration squareDecoration({String? hintText}) => InputDecoration(
          hintText: hintText,
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: focusedBorder,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line number
          SizedBox(
            width: 32,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('ui.lyrics.start_label'),
                            style: TextStyle(color: textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            key: Key('syncedLine_${index}_startMs'),
                            controller: line.startMsController,
                            decoration:
                                squareDecoration(hintText: '01:18.5'),
                            keyboardType: TextInputType.text,
                            inputFormatters: const [_TimeTextInputFormatter()],
                            enabled: !disabled,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.translate('ui.lyrics.end_label'),
                            style: TextStyle(color: textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            key: Key('syncedLine_${index}_endMs'),
                            controller: line.endMsController,
                            decoration:
                                squareDecoration(hintText: '01:18.5'),
                            keyboardType: TextInputType.text,
                            inputFormatters: const [_TimeTextInputFormatter()],
                            enabled: !disabled,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: Key('syncedLine_${index}_insertButton'),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          tooltip: context.translate('ui.lyrics.insert_row_tooltip'),
                          onPressed: disabled ? null : onInsert,
                        ),
                        IconButton(
                          key: Key('syncedLine_${index}_deleteButton'),
                          icon: Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: context.translate('ui.lyrics.delete_row_tooltip'),
                          onPressed: disabled ? null : onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.translate('ui.lyrics.row_label', {'index': index + 1}),
                  style: TextStyle(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  key: Key('syncedLine_${index}_lineText'),
                  controller: line.lineTextController,
                  decoration: squareDecoration(hintText: context.translate('ui.lyrics.row_hint')),
                  minLines: 2,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  enabled: !disabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
