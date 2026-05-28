import 'package:flutter/material.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/utils/date_formatter.dart';
import 'package:ondas_web/features/users/domain/entities/admin_user.dart';

class AdminUserTableWidget extends StatelessWidget {
  final List<AdminUser> users;
  final bool isLoading;
  final void Function(AdminUser user) onView;

  const AdminUserTableWidget({
    super.key,
    required this.users,
    required this.isLoading,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight
        ? AppColors.snow
        : AppColors.darkSurfaceElevated;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final textPrimary = isLight
        ? AppColors.nearBlack
        : AppColors.darkTextPrimary;
    final textSecondary = isLight
        ? AppColors.stone
        : AppColors.darkTextSecondary;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          context.translate('ui.users.empty'),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppRadius.container),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(56),
          1: FlexColumnWidth(2.8),
          2: FlexColumnWidth(2.2),
          3: FixedColumnWidth(120),
          4: FixedColumnWidth(140),
          5: FixedColumnWidth(140),
          6: FixedColumnWidth(90),
        },
        children: [
          _buildHeader(context, headerColor, borderColor, textSecondary),
          ...users.asMap().entries.map(
            (entry) => _buildRow(
              context,
              entry.value,
              entry.key.isEven,
              isLight,
              textPrimary,
              textSecondary,
              borderColor,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildHeader(
    BuildContext context,
    Color headerColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      children: [
        _headerCell('', textSecondary),
        _headerCell(context.translate('ui.users.column_user'), textSecondary),
        _headerCell(context.translate('ui.users.column_role'), textSecondary),
        _headerCell(context.translate('ui.users.column_status'), textSecondary),
        _headerCell(context.translate('ui.users.column_last_login'), textSecondary),
        _headerCell(context.translate('ui.users.column_created_at'), textSecondary),
        _headerCell(context.translate('ui.users.column_actions'), textSecondary),
      ],
    );
  }

  Widget _headerCell(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smMd,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildRow(
    BuildContext context,
    AdminUser user,
    bool isEven,
    bool isLight,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    final rowBg = isEven
        ? Colors.transparent
        : (isLight ? AppColors.snow : AppColors.darkSurface);

    return TableRow(
      decoration: BoxDecoration(
        color: rowBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: _Avatar(avatarUrl: user.avatarUrl, name: user.displayName),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: _UserInfoCell(
            user: user,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            _roleLabel(context, user.role),
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.smMd,
          ),
          child: _StatusBadge(active: user.active),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            _formatDateTime(user.lastLoginAt),
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          child: Text(
            _formatDateTime(user.createdAt),
            style: TextStyle(fontSize: 13, color: textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          child: IconButton(
            key: Key('adminUserTable_viewButton_${user.id}'),
            icon: const Icon(Icons.open_in_new, size: 18),
            tooltip: context.translate('ui.users.tooltip_details'),
            onPressed: () => onView(user),
            color: textSecondary,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String? value) {
    final parsed = DateFormatter.parseApiDate(value);
    if (parsed == null) return '—';
    return DateFormatter.formatDateTime(parsed);
  }

  String _roleLabel(BuildContext context, String? role) {
    switch (role) {
      case 'ADMIN':
        return context.translate('ui.users.role_admin');
      case 'CONTENT_MANAGER':
        return context.translate('ui.users.role_content_manager');
      case 'USER':
        return context.translate('ui.users.role_user');
      default:
        return role ?? '—';
    }
  }
}

class _UserInfoCell extends StatelessWidget {
  final AdminUser user;
  final Color textPrimary;
  final Color textSecondary;

  const _UserInfoCell({
    required this.user,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.displayName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          user.email,
          style: TextStyle(fontSize: 12, color: textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _Avatar({required this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'U'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((e) => e[0].toUpperCase())
              .join();

    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.darkSurfaceElevated,
      foregroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
          ? NetworkImage(avatarUrl!)
          : null,
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? null
          : Text(
              initials,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkTextPrimary,
              ),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;

  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final labelText = active
        ? context.translate('ui.users.status_active')
        : context.translate('ui.users.status_locked');
    final bgColor = active ? AppColors.successLight : AppColors.errorLight;
    final textColor = active ? AppColors.pureWhite : AppColors.pureWhite;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
