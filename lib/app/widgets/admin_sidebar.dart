import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/app/bloc/locale_cubit.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/di/injection.dart';
import 'package:ondas_web/core/localization/app_locales.dart';
import 'package:ondas_web/core/storage/secure_storage.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';

// ─── Nav items data ────────────────────────────────────────────────────────────

class AdminNavItem {
  final String label;
  final IconData icon;
  final String route;

  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const kAdminNavItems = [
  AdminNavItem(
    label: 'ui.dashboard.title',
    icon: Icons.dashboard_outlined,
    route: AppConstants.routeDashboard,
  ),
  AdminNavItem(
    label: 'ui.songs.title',
    icon: Icons.music_note_outlined,
    route: AppConstants.routeSongs,
  ),
  AdminNavItem(
    label: 'ui.artists.title',
    icon: Icons.person_outline,
    route: AppConstants.routeArtists,
  ),
  AdminNavItem(
    label: 'ui.albums.title',
    icon: Icons.album_outlined,
    route: AppConstants.routeAlbums,
  ),
  AdminNavItem(
    label: 'ui.genres.title',
    icon: Icons.category_outlined,
    route: AppConstants.routeGenres,
  ),
  AdminNavItem(
    label: 'ui.tags.title',
    icon: Icons.local_offer_outlined,
    route: AppConstants.routeTags,
  ),
  AdminNavItem(
    label: 'ui.playlists.title',
    icon: Icons.queue_music_outlined,
    route: AppConstants.routePlaylists,
  ),
  AdminNavItem(
    label: 'ui.users.title',
    icon: Icons.people_outline,
    route: AppConstants.routeUsers,
  ),
];

// ─── Sidebar ───────────────────────────────────────────────────────────────────

class AdminSidebar extends StatelessWidget {
  final String currentRoute;

  const AdminSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: sl<SecureStorage>().getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data;
        final items = role == AppConstants.roleAdmin
            ? kAdminNavItems
            : kAdminNavItems
                  .where((item) => item.route != AppConstants.routeUsers)
                  .toList();

        return Container(
          width: 220,
          decoration: const BoxDecoration(
            color: AppColors.darkestSurface,
            border: Border(right: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SidebarLogo(),
              const Divider(color: AppColors.darkBorder, height: 1),
              const SizedBox(height: AppSpacing.sm),
              ...items.map(
                (item) => _SidebarNavItem(
                  item: item,
                  isActive: currentRoute.startsWith(item.route),
                ),
              ),
              const Spacer(),
              const _LanguageSwitcher(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.graphic_eq,
            color: AppColors.darkTextPrimary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Ondas Admin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final AdminNavItem item;
  final bool isActive;

  const _SidebarNavItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final textColor = isActive
        ? AppColors.darkTextPrimary
        : AppColors.darkTextMuted;
    final bgColor = isActive
        ? AppColors.darkSurfaceElevated
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.container),
        hoverColor: AppColors.darkSurface,
        onTap: () => context.go(item.route),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.smMd,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.container),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: textColor),
              const SizedBox(width: AppSpacing.md),
              Text(
                context.translate(item.label),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final isVi = locale.languageCode == AppLocales.vi.languageCode;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.container),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.language,
                  size: 16,
                  color: AppColors.darkTextMuted,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: const Key('sidebar_languageDropdown'),
                      value: isVi ? 'vi' : 'en',
                      dropdownColor: AppColors.darkSurfaceElevated,
                      iconEnabledColor: AppColors.darkTextMuted,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.darkTextPrimary),
                      items: const [
                        DropdownMenuItem(value: 'vi', child: Text('VI')),
                        DropdownMenuItem(value: 'en', child: Text('EN')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        final target = value == 'vi'
                            ? AppLocales.vi
                            : AppLocales.en;
                        context.read<LocaleCubit>().setLocale(target);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
