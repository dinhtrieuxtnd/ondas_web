import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ondas_web/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:ondas_web/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:ondas_web/features/dashboard/presentation/widgets/dashboard_stat_card_widget.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────

const _kStats = [
  _StatData(labelKey: 'ui.dashboard.stats.songs', value: '1,247', icon: Icons.music_note),
  _StatData(labelKey: 'ui.dashboard.stats.artists', value: '89', icon: Icons.person),
  _StatData(labelKey: 'ui.dashboard.stats.albums', value: '342', icon: Icons.album),
  _StatData(labelKey: 'ui.dashboard.stats.users', value: '12,830', icon: Icons.people),
];

const _kRecentSongs = [
  _SongRow(
    title: 'Nơi Này Có Anh',
    artist: 'Sơn Tùng M-TP',
    genre: 'V-Pop',
    plays: '3,241,000',
    dateAdded: '2026-04-20',
  ),
  _SongRow(
    title: 'Chúng Ta Của Hiện Tại',
    artist: 'Sơn Tùng M-TP',
    genre: 'V-Pop',
    plays: '2,890,500',
    dateAdded: '2026-04-18',
  ),
  _SongRow(
    title: 'Tâm 9',
    artist: 'Mỹ Tâm',
    genre: 'V-Pop',
    plays: '1,540,200',
    dateAdded: '2026-04-15',
  ),
  _SongRow(
    title: 'Người Lạ Ơi',
    artist: 'Karik, Orange',
    genre: 'R&B',
    plays: '987,000',
    dateAdded: '2026-04-10',
  ),
  _SongRow(
    title: 'Bình Yên',
    artist: 'Hà Anh Tuấn',
    genre: 'Acoustic',
    plays: '763,400',
    dateAdded: '2026-04-08',
  ),
];



// ─── Screen ───────────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardLogoutSuccess) {
          context.go(AppConstants.routeLogin);
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final loaded = state is DashboardLoaded ? state : null;
          return Column(
            children: [
              _TopBar(
                displayName: loaded?.displayName ?? '...',
                email: loaded?.email ?? '',
                role: loaded?.role ?? '',
                isLoggingOut: state is DashboardLoggingOut,
              ),
              const Expanded(child: _MainContent()),
            ],
          );
        },
      ),
    );
  }
}


// ─── TopBar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String displayName;
  final String email;
  final String role;
  final bool isLoggingOut;

  const _TopBar({
    required this.displayName,
    required this.email,
    required this.role,
    required this.isLoggingOut,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final bgColor = isLight ? AppColors.pureWhite : AppColors.darkSurface;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Text(
            context.translate('ui.dashboard.title'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          _UserDropdown(
            displayName: displayName,
            email: email,
            role: role,
            isLoggingOut: isLoggingOut,
          ),
        ],
      ),
    );
  }
}

class _UserDropdown extends StatelessWidget {
  final String displayName;
  final String email;
  final String role;
  final bool isLoggingOut;

  const _UserDropdown({
    required this.displayName,
    required this.email,
    required this.role,
    required this.isLoggingOut,
  });

  @override
  Widget build(BuildContext context) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'A';

    return PopupMenuButton<String>(
      key: const Key('dashboard_userDropdown'),
      enabled: !isLoggingOut,
      tooltip: '',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.container),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightGray
              : AppColors.darkBorder,
        ),
      ),
      elevation: 0,
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.stone,
                    ),
              ),
              const SizedBox(height: 4),
              _RoleBadge(role: role),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(context.translate('ui.dashboard.logout')),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          context.read<DashboardBloc>().add(const DashboardLogoutRequested());
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoggingOut)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.nearBlack,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            displayName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: AppSpacing.xxs),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        role,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.nearBlack,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppColors.snow : AppColors.darkBackground;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.translate('ui.dashboard.overview'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _StatCardsRow(),
            const SizedBox(height: AppSpacing.xxxl),
            const _RecentSongsTable(),
          ],
        ),
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: _kStats
          .map(
            (s) => DashboardStatCardWidget(
              label: context.translate(s.labelKey),
              value: s.value,
              icon: s.icon,
            ),
          )
          .toList(),
    );
  }
}

class _RecentSongsTable extends StatelessWidget {
  const _RecentSongsTable();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor = isLight ? AppColors.lightGray : AppColors.darkBorder;
    final bgColor = isLight ? AppColors.pureWhite : AppColors.darkSurface;
    final headerColor = isLight ? AppColors.stone : AppColors.darkTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              context.translate('ui.dashboard.recent_songs'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 48,
              dividerThickness: 1,
              columns: [
                DataColumn(
                  label: Text(
                    context.translate('ui.dashboard.table.title'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.translate('ui.dashboard.table.artist'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.translate('ui.dashboard.table.genre'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    context.translate('ui.dashboard.table.plays'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    context.translate('ui.dashboard.table.date_added'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: headerColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
              ],
              rows: _kRecentSongs
                  .map(
                    (song) => DataRow(
                      cells: [
                        DataCell(Text(song.title)),
                        DataCell(Text(song.artist)),
                        DataCell(_GenreChip(label: song.genre)),
                        DataCell(Text(song.plays)),
                        DataCell(
                          Text(
                            song.dateAdded,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isLight ? AppColors.stone : AppColors.darkTextSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;

  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.nearBlack,
            ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _StatData {
  final String labelKey;
  final String value;
  final IconData icon;

  const _StatData({required this.labelKey, required this.value, required this.icon});
}

class _SongRow {
  final String title;
  final String artist;
  final String genre;
  final String plays;
  final String dateAdded;

  const _SongRow({
    required this.title,
    required this.artist,
    required this.genre,
    required this.plays,
    required this.dateAdded,
  });
}
