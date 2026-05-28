import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/core/error/failures.dart';
import 'package:ondas_web/core/network/api_response.dart';
import 'package:ondas_web/features/albums/domain/entities/album.dart';
import 'package:ondas_web/features/albums/domain/usecases/create_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/delete_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_album_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/get_albums_usecase.dart';
import 'package:ondas_web/features/albums/domain/usecases/update_album_usecase.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_bloc.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_event.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_state.dart';
import 'package:ondas_web/features/songs/domain/entities/song.dart';
import 'package:ondas_web/features/songs/domain/usecases/update_song_usecase.dart';

class MockGetAlbumsUseCase extends Mock implements GetAlbumsUseCase {}
class MockGetAlbumUseCase extends Mock implements GetAlbumUseCase {}
class MockCreateAlbumUseCase extends Mock implements CreateAlbumUseCase {}
class MockUpdateAlbumUseCase extends Mock implements UpdateAlbumUseCase {}
class MockDeleteAlbumUseCase extends Mock implements DeleteAlbumUseCase {}
class MockUpdateSongUseCase extends Mock implements UpdateSongUseCase {}

void main() {
  late AlbumBloc bloc;
  late MockGetAlbumsUseCase mockGetAlbumsUseCase;
  late MockGetAlbumUseCase mockGetAlbumUseCase;
  late MockCreateAlbumUseCase mockCreateAlbumUseCase;
  late MockUpdateAlbumUseCase mockUpdateAlbumUseCase;
  late MockDeleteAlbumUseCase mockDeleteAlbumUseCase;
  late MockUpdateSongUseCase mockUpdateSongUseCase;

  final tAlbum = Album(
    id: 'album-1',
    title: 'Test Album',
    slug: 'test-album',
    albumType: 'ALBUM',
    artistNames: ['Artist 1'],
    artistIds: ['artist-1'],
    tracklist: const [AlbumTrack(id: 'track-1', title: 'Track One')],
    totalTracks: 1,
  );

  const tSong = Song(
    id: 'song-1',
    title: 'Test Song',
  );

  final tPage = PageResultDto<Album>(
    items: [tAlbum],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
  );

  AlbumBloc buildBloc() => AlbumBloc(
        getAlbumsUseCase: mockGetAlbumsUseCase,
        getAlbumUseCase: mockGetAlbumUseCase,
        createAlbumUseCase: mockCreateAlbumUseCase,
        updateAlbumUseCase: mockUpdateAlbumUseCase,
        deleteAlbumUseCase: mockDeleteAlbumUseCase,
        updateSongUseCase: mockUpdateSongUseCase,
      );

  setUpAll(() {
    registerFallbackValue(const GetAlbumsParams(page: 0, size: 20));
    registerFallbackValue(const GetAlbumParams(id: 'album-1'));
    registerFallbackValue(
        const CreateAlbumParams(title: 'Test', artistIds: ['artist-1']));
    registerFallbackValue(
        const UpdateAlbumParams(id: 'album-1', title: 'Test', artistIds: ['artist-1']));
    registerFallbackValue(const DeleteAlbumParams(id: 'album-1'));
    registerFallbackValue(
        const UpdateSongParams(id: 'song-1', albumId: 'album-1'));
  });

  setUp(() {
    mockGetAlbumsUseCase = MockGetAlbumsUseCase();
    mockGetAlbumUseCase = MockGetAlbumUseCase();
    mockCreateAlbumUseCase = MockCreateAlbumUseCase();
    mockUpdateAlbumUseCase = MockUpdateAlbumUseCase();
    mockDeleteAlbumUseCase = MockDeleteAlbumUseCase();
    mockUpdateSongUseCase = MockUpdateSongUseCase();
    bloc = buildBloc();
  });

  tearDown(() => bloc.close());

  // ── Initial state ──────────────────────────────────────────────────────────

  test('initial state is AlbumInitial', () {
    expect(bloc.state, const AlbumInitial());
  });

  // ── AlbumLoadListEvent ─────────────────────────────────────────────────────

  group('AlbumLoadListEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumListLoading, AlbumListLoaded] when successful',
      build: () {
        when(() => mockGetAlbumsUseCase(any()))
            .thenAnswer((_) async => Right(tPage));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumLoadListEvent(page: 0, size: 20)),
      expect: () => [
        const AlbumListLoading(),
        AlbumListLoaded(
          albums: tPage.items,
          page: tPage.page,
          totalPages: tPage.totalPages,
          totalElements: tPage.totalElements,
        ),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumListLoading, AlbumListError] when load fails',
      build: () {
        when(() => mockGetAlbumsUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Server error', statusCode: 500)),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumLoadListEvent(page: 0, size: 20)),
      expect: () => [
        const AlbumListLoading(),
        const AlbumListError(message: 'Server error'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumListLoading, AlbumListLoaded] with query when searching',
      build: () {
        when(() => mockGetAlbumsUseCase(any()))
            .thenAnswer((_) async => Right(tPage));
        return buildBloc();
      },
      act: (b) =>
          b.add(const AlbumLoadListEvent(page: 0, size: 20, query: 'test')),
      expect: () => [
        const AlbumListLoading(),
        AlbumListLoaded(
          albums: tPage.items,
          page: tPage.page,
          totalPages: tPage.totalPages,
          totalElements: tPage.totalElements,
          query: 'test',
        ),
      ],
    );
  });

  // ── AlbumSearchEvent ───────────────────────────────────────────────────────

  group('AlbumSearchEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumListLoading, AlbumListLoaded] with query on search',
      build: () {
        when(() => mockGetAlbumsUseCase(any()))
            .thenAnswer((_) async => Right(tPage));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumSearchEvent(query: 'test album')),
      expect: () => [
        const AlbumListLoading(),
        AlbumListLoaded(
          albums: tPage.items,
          page: tPage.page,
          totalPages: tPage.totalPages,
          totalElements: tPage.totalElements,
          query: 'test album',
        ),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumListLoading, AlbumListError] when search fails',
      build: () {
        when(() => mockGetAlbumsUseCase(any())).thenAnswer(
          (_) async =>
              const Left(NetworkFailure(message: 'No internet connection')),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumSearchEvent(query: 'fail')),
      expect: () => [
        const AlbumListLoading(),
        const AlbumListError(message: 'No internet connection'),
      ],
    );
  });

  // ── AlbumLoadDetailEvent ───────────────────────────────────────────────────

  group('AlbumLoadDetailEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumDetailLoading, AlbumDetailLoaded] when load succeeds',
      build: () {
        when(() => mockGetAlbumUseCase(any()))
            .thenAnswer((_) async => Right(tAlbum));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumLoadDetailEvent(id: 'album-1')),
      expect: () => [
        const AlbumDetailLoading(),
        AlbumDetailLoaded(album: tAlbum),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumDetailLoading, AlbumOperationError] when load fails',
      build: () {
        when(() => mockGetAlbumUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Album not found', statusCode: 404)),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumLoadDetailEvent(id: 'album-1')),
      expect: () => [
        const AlbumDetailLoading(),
        const AlbumOperationError(message: 'Album not found'),
      ],
    );
  });

  // ── AlbumCreateEvent ───────────────────────────────────────────────────────

  group('AlbumCreateEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationSuccess] without songs',
      build: () {
        when(() => mockCreateAlbumUseCase(any()))
            .thenAnswer((_) async => Right(tAlbum));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumCreateEvent(
        title: 'Test Album',
        artistIds: ['artist-1'],
        songIds: [],
      )),
      verify: (_) {
        verify(() => mockCreateAlbumUseCase(any())).called(1);
        verifyNever(() => mockUpdateSongUseCase(any()));
      },
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationSuccess(message: 'Album đã được tạo thành công.'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationSuccess] and updates songs when successful',
      build: () {
        when(() => mockCreateAlbumUseCase(any()))
            .thenAnswer((_) async => Right(tAlbum));
        when(() => mockUpdateSongUseCase(any()))
            .thenAnswer((_) async => const Right(tSong));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumCreateEvent(
        title: 'Test Album',
        artistIds: ['artist-1'],
        songIds: ['song-1', 'song-2'],
      )),
      verify: (_) {
        verify(() => mockCreateAlbumUseCase(any())).called(1);
        verify(() => mockUpdateSongUseCase(any())).called(2);
      },
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationSuccess(
            message:
                'Album đã được tạo thành công và đã cập nhật danh sách bài hát.'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationError] when create fails',
      build: () {
        when(() => mockCreateAlbumUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Validation error', statusCode: 400)),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumCreateEvent(
        title: 'Test',
        artistIds: ['artist-1'],
        songIds: [],
      )),
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationError(message: 'Validation error'),
      ],
    );
  });

  // ── AlbumUpdateEvent ───────────────────────────────────────────────────────

  group('AlbumUpdateEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationSuccess] without song update',
      build: () {
        when(() => mockUpdateAlbumUseCase(any()))
            .thenAnswer((_) async => Right(tAlbum));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumUpdateEvent(
        id: 'album-1',
        title: 'Updated',
        artistIds: ['artist-1'],
        songIds: [],
      )),
      verify: (_) {
        verify(() => mockUpdateAlbumUseCase(any())).called(1);
        verifyNever(() => mockUpdateSongUseCase(any()));
      },
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationSuccess(
            message: 'Album đã được cập nhật thành công.'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationSuccess] and updates songs when provided',
      build: () {
        when(() => mockUpdateAlbumUseCase(any()))
            .thenAnswer((_) async => Right(tAlbum));
        when(() => mockUpdateSongUseCase(any()))
            .thenAnswer((_) async => const Right(tSong));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumUpdateEvent(
        id: 'album-1',
        title: 'Updated',
        artistIds: ['artist-1'],
        songIds: ['song-1'],
      )),
      verify: (_) {
        verify(() => mockUpdateAlbumUseCase(any())).called(1);
        verify(() => mockUpdateSongUseCase(any())).called(1);
      },
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationSuccess(
            message: 'Album đã được cập nhật thành công.'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationError] when update fails',
      build: () {
        when(() => mockUpdateAlbumUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Not found', statusCode: 404)),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumUpdateEvent(
        id: 'album-1',
        title: 'Updated',
      )),
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationError(message: 'Not found'),
      ],
    );
  });

  // ── AlbumDeleteEvent ───────────────────────────────────────────────────────

  group('AlbumDeleteEvent', () {
    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationSuccess] when successful',
      build: () {
        when(() => mockDeleteAlbumUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      act: (b) => b.add(const AlbumDeleteEvent(id: 'album-1')),
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationSuccess(
            message: 'Album đã được xóa thành công.'),
      ],
    );

    blocTest<AlbumBloc, AlbumState>(
      'emits [AlbumOperationInProgress, AlbumOperationError] when delete fails',
      build: () {
        when(() => mockDeleteAlbumUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Forbidden', statusCode: 403)),
        );
        return buildBloc();
      },
      act: (b) => b.add(const AlbumDeleteEvent(id: 'album-1')),
      expect: () => [
        const AlbumOperationInProgress(),
        const AlbumOperationError(message: 'Forbidden'),
      ],
    );
  });
}
