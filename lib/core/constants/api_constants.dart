abstract class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // Profile
  static const String profile = '/api/profile';
  static const String profilePassword = '/api/profile/password';

  // Songs
  static const String songs = '/api/songs';
  static String songById(String id) => '/api/songs/$id';
  static String songTags(String id) => '/api/songs/$id/tags';

  // Albums
  static const String albums = '/api/albums';
  static String albumById(String id) => '/api/albums/$id';

  // Artists
  static const String artists = '/api/artists';
  static String artistById(String id) => '/api/artists/$id';

  // Genres
  static const String genres = '/api/genres';
  static const String genresSearch = '/api/genres/search';
  static String genreById(int id) => '/api/genres/$id';

  // Tags / Moods
  static const String tags = '/api/tags';
  static const String tagsSearch = '/api/tags/search';
  static String tagById(int id) => '/api/tags/$id';

  // Playlists
  static const String playlists = '/api/playlists';
  static String playlistById(String id) => '/api/playlists/$id';
  static String playlistSongs(String id) => '/api/playlists/$id/songs';
  static String playlistSongById(String id, String songId) =>
      '/api/playlists/$id/songs/$songId';
  static String playlistSongsReorder(String id) =>
      '/api/playlists/$id/songs/reorder';
  static const String adminSystemPlaylists = '/api/admin/system-playlists';
  static String adminSystemPlaylistById(String id) =>
      '/api/admin/system-playlists/$id';
  static String adminSystemPlaylistSongs(String id) =>
      '/api/admin/system-playlists/$id/songs';
  static String adminSystemPlaylistSongById(String id, String songId) =>
      '/api/admin/system-playlists/$id/songs/$songId';
  static String adminSystemPlaylistSongsReorder(String id) =>
      '/api/admin/system-playlists/$id/songs/reorder';

  // Admin users
  static const String adminUsers = '/api/admin/users';
  static String adminUserById(String id) => '/api/admin/users/$id';
  static String adminUserBan(String id) => '/api/admin/users/$id/ban';
  static String adminUserUnban(String id) => '/api/admin/users/$id/unban';

  // Lyrics
  static String songLyrics(String songId) => '/api/songs/$songId/lyrics';

  // Admin activity logs
  static const String adminActivityLogs = '/api/admin/activity-logs';

  // Admin statistics
  static const String adminStatsTopSongs = '/api/admin/stats/top-songs';
  static const String adminStatsTopArtists = '/api/admin/stats/top-artists';
  static const String adminStatsPlaysDaily = '/api/admin/stats/plays-daily';
  static const String adminStatsDauMau = '/api/admin/stats/dau-mau';
}
