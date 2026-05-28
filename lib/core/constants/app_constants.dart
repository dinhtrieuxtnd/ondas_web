abstract class AppConstants {
  static const String appName = 'Ondas Admin';
  static const String appVersion = '1.0.0';

  // Pagination defaults
  static const int defaultPage = 0;
  static const int defaultPageSize = 20;

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userDisplayNameKey = 'user_display_name';
  static const String userEmailKey = 'user_email';
  static const String languageCodeKey = 'language_code';

  // Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleContentManager = 'CONTENT_MANAGER';
  static const String roleUser = 'USER';

  // Routes
  static const String routeLogin = '/admin/login';
  static const String routeDashboard = '/admin/dashboard';
  static const String routeSongs = '/admin/songs';
  static const String routeArtists = '/admin/artists';
  static const String routeAlbums = '/admin/albums';
  static const String routeGenres = '/admin/genres';
  static const String routeTags = '/admin/tags';
  static const String routePlaylists = '/admin/playlists';
  static const String routeUsers = '/admin/users';
}
