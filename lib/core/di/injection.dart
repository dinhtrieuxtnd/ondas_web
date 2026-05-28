import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:ondas_web/app/bloc/locale_cubit.dart';
import 'package:ondas_web/core/network/dio_client.dart';
import 'package:ondas_web/core/network/jwt_interceptor.dart';
import 'package:ondas_web/core/storage/secure_storage.dart';
import 'package:ondas_web/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ondas_web/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:ondas_web/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ondas_web/features/auth/domain/repositories/auth_repository.dart';
import 'package:ondas_web/features/auth/domain/usecases/login_usecase.dart';
import 'package:ondas_web/features/auth/domain/usecases/login_usecase_impl.dart';
import 'package:ondas_web/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ondas_web/features/auth/domain/usecases/logout_usecase_impl.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_web/features/artists/data/datasources/artist_remote_datasource.dart';
import 'package:ondas_web/features/artists/data/datasources/artist_remote_datasource_impl.dart';
import 'package:ondas_web/features/artists/data/repositories/artist_repository_impl.dart';
import 'package:ondas_web/features/artists/domain/repositories/artist_repository.dart';
import 'package:ondas_web/features/artists/domain/usecases/create_artist_usecase.dart';
import 'package:ondas_web/features/artists/domain/usecases/create_artist_usecase_impl.dart';
import 'package:ondas_web/features/artists/domain/usecases/delete_artist_usecase.dart';
import 'package:ondas_web/features/artists/domain/usecases/delete_artist_usecase_impl.dart';
import 'package:ondas_web/features/artists/domain/usecases/get_artist_usecase.dart';
import 'package:ondas_web/features/artists/domain/usecases/get_artist_usecase_impl.dart';
import 'package:ondas_web/features/artists/domain/usecases/get_artists_usecase.dart';
import 'package:ondas_web/features/artists/domain/usecases/get_artists_usecase_impl.dart';
import 'package:ondas_web/features/artists/domain/usecases/update_artist_usecase.dart';
import 'package:ondas_web/features/artists/domain/usecases/update_artist_usecase_impl.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_bloc.dart';
import 'package:ondas_web/features/genres/data/datasources/genre_remote_datasource.dart';
import 'package:ondas_web/features/genres/data/datasources/genre_remote_datasource_impl.dart';
import 'package:ondas_web/features/genres/data/repositories/genre_repository_impl.dart';
import 'package:ondas_web/features/genres/domain/repositories/genre_repository.dart';
import 'package:ondas_web/features/genres/domain/usecases/create_genre_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/create_genre_usecase_impl.dart';
import 'package:ondas_web/features/genres/domain/usecases/delete_genre_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/delete_genre_usecase_impl.dart';
import 'package:ondas_web/features/genres/domain/usecases/get_genre_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/get_genre_usecase_impl.dart';
import 'package:ondas_web/features/genres/domain/usecases/get_genres_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/get_genres_usecase_impl.dart';
import 'package:ondas_web/features/genres/domain/usecases/update_genre_usecase.dart';
import 'package:ondas_web/features/genres/domain/usecases/update_genre_usecase_impl.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:ondas_web/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ondas_web/features/songs/data/datasources/song_remote_datasource.dart';
import 'package:ondas_web/features/songs/data/datasources/song_remote_datasource_impl.dart';
import 'package:ondas_web/features/songs/data/repositories/song_repository_impl.dart';
import 'package:ondas_web/features/songs/domain/repositories/song_repository.dart';
import 'package:ondas_web/features/songs/domain/usecases/create_song_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/create_song_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/delete_song_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/delete_song_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_song_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_song_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_songs_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_songs_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/update_song_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/update_song_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_song_tags_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/get_song_tags_usecase_impl.dart';
import 'package:ondas_web/features/songs/domain/usecases/replace_song_tags_usecase.dart';
import 'package:ondas_web/features/songs/domain/usecases/replace_song_tags_usecase_impl.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_bloc.dart';
import 'package:ondas_web/features/albums/data/datasources/album_remote_datasource.dart';
import 'package:ondas_web/features/albums/data/datasources/album_remote_datasource_impl.dart';
import 'package:ondas_web/features/albums/data/repositories/album_repository_impl.dart';
import 'package:ondas_web/features/albums/domain/repositories/album_repository.dart';
import 'package:ondas_web/features/albums/domain/usecases/create_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/create_album_usecase_impl.dart';
import 'package:ondas_web/features/albums/domain/usecases/delete_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/delete_album_usecase_impl.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_album_usecase_impl.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_albums_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_albums_usecase_impl.dart';
import 'package:ondas_web/features/albums/domain/usecases/update_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/update_album_usecase_impl.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_bloc.dart';
import 'package:ondas_web/features/users/data/datasources/admin_user_remote_datasource.dart';
import 'package:ondas_web/features/users/data/datasources/admin_user_remote_datasource_impl.dart';
import 'package:ondas_web/features/users/data/repositories/admin_user_repository_impl.dart';
import 'package:ondas_web/features/users/domain/repositories/admin_user_repository.dart';
import 'package:ondas_web/features/users/domain/usecases/ban_admin_user_usecase.dart';
import 'package:ondas_web/features/users/domain/usecases/ban_admin_user_usecase_impl.dart';
import 'package:ondas_web/features/users/domain/usecases/get_admin_user_usecase.dart';
import 'package:ondas_web/features/users/domain/usecases/get_admin_user_usecase_impl.dart';
import 'package:ondas_web/features/users/domain/usecases/get_admin_users_usecase.dart';
import 'package:ondas_web/features/users/domain/usecases/get_admin_users_usecase_impl.dart';
import 'package:ondas_web/features/users/domain/usecases/unban_admin_user_usecase.dart';
import 'package:ondas_web/features/users/domain/usecases/unban_admin_user_usecase_impl.dart';
import 'package:ondas_web/features/users/presentation/bloc/admin_user_bloc.dart';
import 'package:ondas_web/features/lyrics/data/datasources/lyrics_remote_datasource.dart';
import 'package:ondas_web/features/lyrics/data/datasources/lyrics_remote_datasource_impl.dart';
import 'package:ondas_web/features/lyrics/data/repositories/lyrics_repository_impl.dart';
import 'package:ondas_web/features/lyrics/domain/repositories/lyrics_repository.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/create_song_lyrics_usecase.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/create_song_lyrics_usecase_impl.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/delete_song_lyrics_usecase.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/delete_song_lyrics_usecase_impl.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/get_song_lyrics_usecase.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/get_song_lyrics_usecase_impl.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/update_song_lyrics_usecase.dart';
import 'package:ondas_web/features/lyrics/domain/usecases/update_song_lyrics_usecase_impl.dart';
import 'package:ondas_web/features/lyrics/presentation/bloc/lyrics_bloc.dart';
import 'package:ondas_web/features/playlists/data/datasources/playlist_remote_datasource.dart';
import 'package:ondas_web/features/playlists/data/datasources/playlist_remote_datasource_impl.dart';
import 'package:ondas_web/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:ondas_web/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:ondas_web/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:ondas_web/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:ondas_web/features/tags/data/datasources/tag_remote_datasource_impl.dart';
import 'package:ondas_web/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:ondas_web/features/tags/domain/repositories/tag_repository.dart';
import 'package:ondas_web/features/tags/presentation/bloc/tag_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Storage ────────────────────────────────────────────────────────────────
  const flutterSecureStorage = FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'ondas_admin', publicKey: 'ondas_admin'),
  );
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(flutterSecureStorage),
  );
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(storage: sl<SecureStorage>()),
  );

  // ── Network ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<JwtInterceptor>(
    () => JwtInterceptor(sl<SecureStorage>()),
  );
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<JwtInterceptor>()));

  // ── Auth Feature ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<SecureStorage>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCaseImpl(sl<AuthRepository>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(loginUseCase: sl<LoginUseCase>()),
  );
  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(
      logoutUseCase: sl<LogoutUseCase>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // ── Artists Feature ────────────────────────────────────────────────────────
  sl.registerLazySingleton<ArtistRemoteDataSource>(
    () => ArtistRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ArtistRepository>(
    () => ArtistRepositoryImpl(sl<ArtistRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetArtistsUseCase>(
    () => GetArtistsUseCaseImpl(sl<ArtistRepository>()),
  );
  sl.registerLazySingleton<GetArtistUseCase>(
    () => GetArtistUseCaseImpl(sl<ArtistRepository>()),
  );
  sl.registerLazySingleton<CreateArtistUseCase>(
    () => CreateArtistUseCaseImpl(sl<ArtistRepository>()),
  );
  sl.registerLazySingleton<UpdateArtistUseCase>(
    () => UpdateArtistUseCaseImpl(sl<ArtistRepository>()),
  );
  sl.registerLazySingleton<DeleteArtistUseCase>(
    () => DeleteArtistUseCaseImpl(sl<ArtistRepository>()),
  );
  sl.registerFactory<ArtistBloc>(
    () => ArtistBloc(
      getArtistsUseCase: sl<GetArtistsUseCase>(),
      getArtistUseCase: sl<GetArtistUseCase>(),
      createArtistUseCase: sl<CreateArtistUseCase>(),
      updateArtistUseCase: sl<UpdateArtistUseCase>(),
      deleteArtistUseCase: sl<DeleteArtistUseCase>(),
    ),
  );

  // ── Genres Feature ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<GenreRemoteDataSource>(
    () => GenreRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<GenreRepository>(
    () => GenreRepositoryImpl(sl<GenreRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetGenresUseCase>(
    () => GetGenresUseCaseImpl(sl<GenreRepository>()),
  );
  sl.registerLazySingleton<GetGenreUseCase>(
    () => GetGenreUseCaseImpl(sl<GenreRepository>()),
  );
  sl.registerLazySingleton<CreateGenreUseCase>(
    () => CreateGenreUseCaseImpl(sl<GenreRepository>()),
  );
  sl.registerLazySingleton<UpdateGenreUseCase>(
    () => UpdateGenreUseCaseImpl(sl<GenreRepository>()),
  );
  sl.registerLazySingleton<DeleteGenreUseCase>(
    () => DeleteGenreUseCaseImpl(sl<GenreRepository>()),
  );
  sl.registerFactory<GenreBloc>(
    () => GenreBloc(
      getGenresUseCase: sl<GetGenresUseCase>(),
      getGenreUseCase: sl<GetGenreUseCase>(),
      createGenreUseCase: sl<CreateGenreUseCase>(),
      updateGenreUseCase: sl<UpdateGenreUseCase>(),
      deleteGenreUseCase: sl<DeleteGenreUseCase>(),
    ),
  );

  // Tags / Moods Feature
  sl.registerLazySingleton<TagRemoteDataSource>(
    () => TagRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(sl<TagRemoteDataSource>()),
  );
  sl.registerFactory<TagBloc>(() => TagBloc(repository: sl<TagRepository>()));

  // Playlists Feature
  sl.registerLazySingleton<PlaylistRemoteDataSource>(
    () => PlaylistRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl<PlaylistRemoteDataSource>()),
  );
  sl.registerFactory<PlaylistBloc>(
    () => PlaylistBloc(repository: sl<PlaylistRepository>()),
  );

  // ── Songs Feature ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<SongRemoteDataSource>(
    () => SongRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(sl<SongRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetSongsUseCase>(
    () => GetSongsUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<GetSongUseCase>(
    () => GetSongUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<CreateSongUseCase>(
    () => CreateSongUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<UpdateSongUseCase>(
    () => UpdateSongUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<DeleteSongUseCase>(
    () => DeleteSongUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<GetSongTagsUseCase>(
    () => GetSongTagsUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerLazySingleton<ReplaceSongTagsUseCase>(
    () => ReplaceSongTagsUseCaseImpl(sl<SongRepository>()),
  );
  sl.registerFactory<SongBloc>(
    () => SongBloc(
      getSongsUseCase: sl<GetSongsUseCase>(),
      getSongUseCase: sl<GetSongUseCase>(),
      createSongUseCase: sl<CreateSongUseCase>(),
      updateSongUseCase: sl<UpdateSongUseCase>(),
      deleteSongUseCase: sl<DeleteSongUseCase>(),
      replaceSongTagsUseCase: sl<ReplaceSongTagsUseCase>(),
    ),
  );

  // ── Albums Feature ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AlbumRemoteDataSource>(
    () => AlbumRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AlbumRepository>(
    () => AlbumRepositoryImpl(sl<AlbumRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAlbumsUseCase>(
    () => GetAlbumsUseCaseImpl(sl<AlbumRepository>()),
  );
  sl.registerLazySingleton<GetAlbumUseCase>(
    () => GetAlbumUseCaseImpl(sl<AlbumRepository>()),
  );
  sl.registerLazySingleton<CreateAlbumUseCase>(
    () => CreateAlbumUseCaseImpl(sl<AlbumRepository>()),
  );
  sl.registerLazySingleton<UpdateAlbumUseCase>(
    () => UpdateAlbumUseCaseImpl(sl<AlbumRepository>()),
  );
  sl.registerLazySingleton<DeleteAlbumUseCase>(
    () => DeleteAlbumUseCaseImpl(sl<AlbumRepository>()),
  );
  sl.registerFactory<AlbumBloc>(
    () => AlbumBloc(
      getAlbumsUseCase: sl<GetAlbumsUseCase>(),
      getAlbumUseCase: sl<GetAlbumUseCase>(),
      createAlbumUseCase: sl<CreateAlbumUseCase>(),
      updateAlbumUseCase: sl<UpdateAlbumUseCase>(),
      deleteAlbumUseCase: sl<DeleteAlbumUseCase>(),
      updateSongUseCase: sl<UpdateSongUseCase>(),
    ),
  );

  // ── Admin Users Feature ───────────────────────────────────────────────────
  sl.registerLazySingleton<AdminUserRemoteDataSource>(
    () => AdminUserRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AdminUserRepository>(
    () => AdminUserRepositoryImpl(sl<AdminUserRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetAdminUsersUseCase>(
    () => GetAdminUsersUseCaseImpl(sl<AdminUserRepository>()),
  );
  sl.registerLazySingleton<GetAdminUserUseCase>(
    () => GetAdminUserUseCaseImpl(sl<AdminUserRepository>()),
  );
  sl.registerLazySingleton<BanAdminUserUseCase>(
    () => BanAdminUserUseCaseImpl(sl<AdminUserRepository>()),
  );
  sl.registerLazySingleton<UnbanAdminUserUseCase>(
    () => UnbanAdminUserUseCaseImpl(sl<AdminUserRepository>()),
  );
  sl.registerFactory<AdminUserBloc>(
    () => AdminUserBloc(
      getAdminUsersUseCase: sl<GetAdminUsersUseCase>(),
      getAdminUserUseCase: sl<GetAdminUserUseCase>(),
      banAdminUserUseCase: sl<BanAdminUserUseCase>(),
      unbanAdminUserUseCase: sl<UnbanAdminUserUseCase>(),
    ),
  );

  // ── Lyrics Feature ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<LyricsRemoteDataSource>(
    () => LyricsRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<LyricsRepository>(
    () => LyricsRepositoryImpl(sl<LyricsRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetSongLyricsUseCase>(
    () => GetSongLyricsUseCaseImpl(sl<LyricsRepository>()),
  );
  sl.registerLazySingleton<CreateSongLyricsUseCase>(
    () => CreateSongLyricsUseCaseImpl(sl<LyricsRepository>()),
  );
  sl.registerLazySingleton<UpdateSongLyricsUseCase>(
    () => UpdateSongLyricsUseCaseImpl(sl<LyricsRepository>()),
  );
  sl.registerLazySingleton<DeleteSongLyricsUseCase>(
    () => DeleteSongLyricsUseCaseImpl(sl<LyricsRepository>()),
  );
  sl.registerFactory<LyricsBloc>(
    () => LyricsBloc(
      getSongLyricsUseCase: sl<GetSongLyricsUseCase>(),
      createSongLyricsUseCase: sl<CreateSongLyricsUseCase>(),
      updateSongLyricsUseCase: sl<UpdateSongLyricsUseCase>(),
      deleteSongLyricsUseCase: sl<DeleteSongLyricsUseCase>(),
    ),
  );
}
