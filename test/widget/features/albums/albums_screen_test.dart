import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/features/albums/data/models/album_model.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_bloc.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_event.dart';
import 'package:ondas_web/features/albums/presentation/bloc/album_state.dart';
import 'package:ondas_web/features/albums/presentation/screens/albums_screen.dart';
import 'package:ondas_web/features/albums/presentation/widgets/album_card_grid_widget.dart';

class MockAlbumBloc extends MockBloc<AlbumEvent, AlbumState>
    implements AlbumBloc {}

void main() {
  late MockAlbumBloc mockBloc;

  const tAlbum = AlbumModel(
    id: 'album-1',
    title: 'Hoàng',
    albumType: 'ALBUM',
    artistNames: ['Đen Vâu'],
    artistIds: ['artist-1'],
  );

  final tListLoaded = AlbumListLoaded(
    albums: [tAlbum],
    page: 0,
    totalPages: 1,
    totalElements: 1,
  );

  setUpAll(() {
    registerFallbackValue(const AlbumLoadListEvent(page: 0, size: 20));
    registerFallbackValue(const AlbumSearchEvent(query: ''));
    registerFallbackValue(const AlbumDeleteEvent(id: 'album-1'));
  });

  setUp(() {
    mockBloc = MockAlbumBloc();
  });

  /// Render với kích thước desktop để GridView hiển thị đủ cards
  Widget buildSubject() => MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1280, 900)),
          child: Scaffold(
            body: SizedBox(
              width: 1280,
              height: 900,
              child: BlocProvider<AlbumBloc>.value(
                value: mockBloc,
                child: const AlbumsScreen(),
              ),
            ),
          ),
        ),
      );

  // ── Loading state ──────────────────────────────────────────────────────────

  testWidgets(
    'shows CircularProgressIndicator when state is AlbumListLoading',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(const AlbumListLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  // ── Loaded state ───────────────────────────────────────────────────────────

  testWidgets('shows AlbumCardGridWidget when list is loaded', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(AlbumCardGridWidget), findsOneWidget);
  });

  testWidgets('shows album title when state is AlbumListLoaded',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    // Title xuất hiện ở cả ảnh placeholder lẫn phần info
    expect(find.text('Hoàng', skipOffstage: false), findsWidgets);
  });

  testWidgets('shows total album count in header', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.text('1 album'), findsOneWidget);
  });

  // ── Empty state ────────────────────────────────────────────────────────────

  testWidgets('shows empty message when list is empty', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(
      const AlbumListLoaded(
        albums: [],
        page: 0,
        totalPages: 0,
        totalElements: 0,
      ),
    );

    await tester.pumpWidget(buildSubject());

    expect(find.text('Không có album nào.'), findsOneWidget);
  });

  // ── UI elements ────────────────────────────────────────────────────────────

  testWidgets('shows add button', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('albumsScreen_addButton')), findsOneWidget);
  });

  testWidgets('shows search field', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());

    expect(find.byKey(const Key('albumsScreen_searchField')), findsOneWidget);
  });

  // ── Events ─────────────────────────────────────────────────────────────────

  testWidgets('adds AlbumLoadListEvent on initState', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(const AlbumListLoading());

    await tester.pumpWidget(buildSubject());

    verify(
      () => mockBloc.add(const AlbumLoadListEvent(page: 0, size: 20)),
    ).called(1);
  });

  testWidgets(
    'adds AlbumLoadListEvent with query when search is submitted',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(tListLoaded);

      await tester.pumpWidget(buildSubject());

      final searchField = find.byKey(const Key('albumsScreen_searchField'));
      await tester.tap(searchField);
      await tester.enterText(searchField, 'hoang');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(
        () => mockBloc.add(
          const AlbumLoadListEvent(page: 0, size: 20, query: 'hoang'),
        ),
      ).called(1);
    },
  );

  testWidgets('shows edit and delete buttons for each album card',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(
      find.byKey(const Key('albumCard_editButton_album-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('albumCard_deleteButton_album-1')),
      findsOneWidget,
    );
  });

  testWidgets('shows delete confirm dialog when delete button is tapped',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('albumCard_deleteButton_album-1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Confirm delete'), findsOneWidget);
    expect(find.byKey(const Key('deleteDialog_cancelButton')), findsOneWidget);
    expect(find.byKey(const Key('deleteDialog_confirmButton')), findsOneWidget);
  });

  testWidgets('dismisses dialog when cancel button is tapped', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(tListLoaded);

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('albumCard_deleteButton_album-1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteDialog_cancelButton')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'adds AlbumDeleteEvent and dismisses dialog when confirm button is tapped',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockBloc.state).thenReturn(tListLoaded);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('albumCard_deleteButton_album-1')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('deleteDialog_confirmButton')));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(const AlbumDeleteEvent(id: 'album-1')),
      ).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  // ── SnackBar ───────────────────────────────────────────────────────────────

  testWidgets('shows success SnackBar when state is AlbumOperationSuccess',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    whenListen(
      mockBloc,
      Stream.fromIterable([
        const AlbumOperationSuccess(message: 'Album đã được xóa thành công.'),
      ]),
      initialState: tListLoaded,
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Album đã được xóa thành công.'), findsOneWidget);
  });

  testWidgets('shows error SnackBar when state is AlbumOperationError',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    whenListen(
      mockBloc,
      Stream.fromIterable([
        const AlbumOperationError(message: 'Có lỗi xảy ra.'),
      ]),
      initialState: tListLoaded,
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Có lỗi xảy ra.'), findsOneWidget);
  });
}
