import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/core/network/api_response.dart';
import 'package:ondas_web/features/genres/data/models/genre_model.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_bloc.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_event.dart';
import 'package:ondas_web/features/genres/presentation/bloc/genre_state.dart';
import 'package:ondas_web/features/genres/presentation/screens/genres_screen.dart';

class MockGenreBloc extends MockBloc<GenreEvent, GenreState>
    implements GenreBloc {}

void main() {
  late MockGenreBloc mockBloc;

  const tGenre = GenreModel(id: 1, name: 'V-Pop', description: 'Nhac Viet');

  final tListLoaded = GenreListLoaded(
    genres: [tGenre],
    page: 0,
    totalPages: 1,
    totalElements: 1,
  );

  setUpAll(() {
    registerFallbackValue(const GenreLoadListEvent(page: 0, size: 20));
    registerFallbackValue(const GenreSearchEvent(query: ''));
    registerFallbackValue(const GenreDeleteEvent(id: 1));
  });

  setUp(() {
    mockBloc = MockGenreBloc();
  });

  Widget buildSubject() => MaterialApp(
    home: Scaffold(
      body: BlocProvider<GenreBloc>.value(
        value: mockBloc,
        child: const GenresScreen(),
      ),
    ),
  );

  testWidgets(
    'shows CircularProgressIndicator when state is GenreListLoading',
    (tester) async {
      when(() => mockBloc.state).thenReturn(const GenreListLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('shows genres table when state is GenreListLoaded', (
    tester,
  ) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.text('V-Pop'), findsOneWidget);
    expect(find.text('Nhac Viet'), findsOneWidget);
  });

  testWidgets('shows empty state when list is empty', (tester) async {
    when(() => mockBloc.state).thenReturn(
      const GenreListLoaded(
        genres: [],
        page: 0,
        totalPages: 0,
        totalElements: 0,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('No genres yet.'), findsOneWidget);
  });

  testWidgets('adds GenreLoadListEvent on initState', (tester) async {
    when(() => mockBloc.state).thenReturn(const GenreListLoading());

    await tester.pumpWidget(buildSubject());

    verify(
      () => mockBloc.add(const GenreLoadListEvent(page: 0, size: 20)),
    ).called(1);
  });

  testWidgets('shows add button', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('genresScreen_addButton')), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('genresScreen_searchField')), findsOneWidget);
  });

  testWidgets('adds GenreLoadListEvent with query when search is submitted', (
    tester,
  ) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    final searchField = find.byKey(const Key('genresScreen_searchField'));
    await tester.tap(searchField);
    await tester.enterText(searchField, 'son tung');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(
      () => mockBloc.add(
        const GenreLoadListEvent(page: 0, size: 20, query: 'son tung'),
      ),
    ).called(1);
  });

  testWidgets('shows error SnackBar when state is GenreListError', (
    tester,
  ) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([const GenreListError(message: 'Server error')]),
      initialState: const GenreListLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
