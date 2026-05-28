import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ondas_web/features/auth/data/models/auth_response_model.dart';
import 'package:ondas_web/features/auth/data/models/user_model.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_web/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

void main() {
  late MockAuthBloc mockBloc;

  final tUser = UserModel(
    id: 'uuid-1',
    email: 'admin@example.com',
    displayName: 'Admin',
    role: 'ADMIN',
  );

  final tAuthResponse = AuthResponseModel(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    user: tUser,
  );

  setUpAll(() {
    registerFallbackValue(
      const LoginSubmitted(email: 'fallback@test.com', password: 'fallback'),
    );
  });

  setUp(() {
    mockBloc = MockAuthBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders form fields and submit button', (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());
      await tester.pumpWidget(buildSubject());

      expect(find.byKey(const Key('loginForm_emailField')), findsOneWidget);
      expect(find.byKey(const Key('loginForm_passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginForm_submitButton')), findsOneWidget);
      // Both the screen heading and button label say 'Sign In'
      expect(find.text('Sign In'), findsNWidgets(2));
    });

    testWidgets('shows loading indicator when state is AuthLoading',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthLoading());
      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // The screen heading 'Sign In' is still visible; only the button label is gone
      expect(
        find.descendant(
          of: find.byKey(const Key('loginForm_submitButton')),
          matching: find.text('Sign In'),
        ),
        findsNothing,
      );
    });

    testWidgets('shows error banner when state is AuthFailure', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const AuthFailure(message: 'Email hoặc mật khẩu không đúng'),
      );
      await tester.pumpWidget(buildSubject());

      expect(
        find.text('Email hoặc mật khẩu không đúng'),
        findsOneWidget,
      );
    });

    testWidgets('dispatches LoginSubmitted on valid form submission',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byKey(const Key('loginForm_emailField')),
        'admin@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('loginForm_passwordField')),
        'password123',
      );

      await tester.ensureVisible(
        find.byKey(const Key('loginForm_submitButton')),
      );
      await tester.tap(find.byKey(const Key('loginForm_submitButton')));
      await tester.pump();

      verify(
        () => mockBloc.add(
          const LoginSubmitted(
            email: 'admin@example.com',
            password: 'password123',
          ),
        ),
      ).called(1);
    });

    testWidgets('shows validation errors on empty form submission',
        (tester) async {
      when(() => mockBloc.state).thenReturn(const AuthInitial());
      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(
        find.byKey(const Key('loginForm_submitButton')),
      );
      await tester.tap(find.byKey(const Key('loginForm_submitButton')));
      await tester.pump();

      expect(find.text('Email không được để trống'), findsOneWidget);
      expect(find.text('Mật khẩu không được để trống'), findsOneWidget);
      verifyNever(() => mockBloc.add(any()));
    });

    testWidgets('navigates to dashboard on AuthSuccess', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const AuthLoading(),
          AuthSuccess(authResponse: tAuthResponse),
        ]),
        initialState: const AuthInitial(),
      );

      final router = GoRouter(
        initialLocation: '/admin/login',
        routes: [
          GoRoute(
            path: '/admin/login',
            builder: (_, __) => BlocProvider<AuthBloc>.value(
              value: mockBloc,
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const Scaffold(body: Text('Dashboard')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}
