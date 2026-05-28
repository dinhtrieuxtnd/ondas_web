import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/core/network/api_response.dart';
import 'package:ondas_web/features/artists/data/models/artist_model.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_bloc.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_event.dart';
import 'package:ondas_web/features/artists/presentation/bloc/artist_state.dart';
import 'package:ondas_web/features/artists/presentation/screens/artists_screen.dart';

class MockArtistBloc extends MockBloc<ArtistEvent, ArtistState>
    implements ArtistBloc {}

void main() {
  late MockArtistBloc mockBloc;

  const tArtist = ArtistModel(
    id: 'uuid-1',
    name: 'Sơn Tùng M-TP',
    country: 'Vietnam',
  );

  final tListLoaded = ArtistListLoaded(
    artists: [tArtist],
    page: 0,
    totalPages: 1,
    totalElements: 1,
  );

  setUpAll(() {
    registerFallbackValue(const ArtistLoadListEvent(page: 0, size: 20));
    registerFallbackValue(const ArtistSearchEvent(query: ''));
    registerFallbackValue(const ArtistDeleteEvent(id: 'uuid-1'));
  });

  setUp(() {
    mockBloc = MockArtistBloc();
  });

  Widget buildSubject() => MaterialApp(
        home: Scaffold(
          body: BlocProvider<ArtistBloc>.value(
            value: mockBloc,
            child: const ArtistsScreen(),
          ),
        ),
      );

  testWidgets('shows CircularProgressIndicator when state is ArtistListLoading',
      (tester) async {
    when(() => mockBloc.state).thenReturn(const ArtistListLoading());

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows artists table when state is ArtistListLoaded',
      (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.text('Sơn Tùng M-TP'), findsOneWidget);
    expect(find.text('Vietnam'), findsOneWidget);
  });

  testWidgets('shows "Không có nghệ sĩ nào." when list is empty',
      (tester) async {
    when(() => mockBloc.state).thenReturn(
      const ArtistListLoaded(
        artists: [],
        page: 0,
        totalPages: 0,
        totalElements: 0,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('No artists yet.'), findsOneWidget);
  });

  testWidgets('adds ArtistLoadListEvent on initState', (tester) async {
    when(() => mockBloc.state).thenReturn(const ArtistListLoading());

    await tester.pumpWidget(buildSubject());

    verify(
      () => mockBloc.add(const ArtistLoadListEvent(page: 0, size: 20)),
    ).called(1);
  });

  testWidgets('shows add button', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('artistsScreen_addButton')), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('artistsScreen_searchField')), findsOneWidget);
  });

  testWidgets('adds ArtistLoadListEvent with query when search is submitted', (tester) async {
    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    final searchField = find.byKey(const Key('artistsScreen_searchField'));
    await tester.tap(searchField);
    await tester.enterText(searchField, 'son tung');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(
      () => mockBloc.add(const ArtistLoadListEvent(page: 0, size: 20, query: 'son tung')),
    ).called(1);
  });

  testWidgets('shows error SnackBar when state is ArtistListError',
      (tester) async {
    whenListen(
      mockBloc,
      Stream.fromIterable([
        const ArtistListError(message: 'Server error'),
      ]),
      initialState: const ArtistListLoading(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });
}
