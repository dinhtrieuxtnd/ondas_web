import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/features/songs/data/models/song_model.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_bloc.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_event.dart';
import 'package:ondas_web/features/songs/presentation/bloc/song_state.dart';
import 'package:ondas_web/features/songs/presentation/screens/songs_screen.dart';

class MockSongBloc extends MockBloc<SongEvent, SongState> implements SongBloc {}

void main() {
  late MockSongBloc mockBloc;

  const tSong = SongModel(
    id: 'uuid-1',
    title: 'Noi nay co anh',
    slug: 'noi-nay-co-anh',
    artistNames: ['Son Tung M-TP'],
    genreNames: ['V-Pop'],
    active: true,
  );

  const tListLoaded = SongListLoaded(
    songs: [tSong],
    page: 0,
    totalPages: 1,
    totalElements: 1,
  );

  setUpAll(() {
    registerFallbackValue(const SongLoadListEvent(page: 0, size: 20));
    registerFallbackValue(const SongDeleteEvent(id: 'uuid-1'));
  });

  setUp(() {
    mockBloc = MockSongBloc();
  });

  Widget buildSubject() => MaterialApp(
        home: Scaffold(
          body: BlocProvider<SongBloc>.value(
            value: mockBloc,
            child: const SongsScreen(),
          ),
        ),
      );

  testWidgets('shows CircularProgressIndicator when state is SongListLoading',
      (tester) async {
    when(() => mockBloc.state).thenReturn(const SongListLoading());

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows songs table when state is SongListLoaded', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.text('Noi nay co anh'), findsOneWidget);
    expect(find.text('Son Tung M-TP'), findsOneWidget);
  });

  testWidgets('shows empty state when list is empty', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const SongListLoaded(
        songs: [],
        page: 0,
        totalPages: 0,
        totalElements: 0,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('No songs yet'), findsWidgets);
  });

  testWidgets('adds SongLoadListEvent on initState', (tester) async {
    when(() => mockBloc.state).thenReturn(const SongListLoading());

    await tester.pumpWidget(buildSubject());

    verify(() => mockBloc.add(const SongLoadListEvent(page: 0, size: 20)))
        .called(1);
  });

  testWidgets('shows add button', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('songsScreen_addButton')), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('songsScreen_searchField')), findsOneWidget);
  });

  testWidgets('adds SongLoadListEvent with query when search is submitted',
      (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    final searchField = find.byKey(const Key('songsScreen_searchField'));
    await tester.tap(searchField);
    await tester.enterText(searchField, 'son tung');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(
      () => mockBloc
          .add(const SongLoadListEvent(page: 0, size: 20, query: 'son tung')),
    ).called(1);
  });

  testWidgets('does not show error SnackBar for SongListError state only',
      (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([const SongListError(message: 'Server error')]),
      initialState: const SongListLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
