import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/presentation/forgot_password_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/login_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/register_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/verify_email_view.dart';
import 'package:thoughtbook/src/features/authentication/repository/firebase_auth_provider.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/notes_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/helpers/loading/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AppPreferenceService().initPrefs());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black.withOpacity(0.002),
    ),
  );

  runApp(
    const ThoughtbookApp(),
  );
}

class ThoughtbookApp extends StatefulWidget {
  const ThoughtbookApp({Key? key}) : super(key: key);

  @override
  State<ThoughtbookApp> createState() => _ThoughtbookAppState();
}

class _ThoughtbookAppState extends State<ThoughtbookApp> {
  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.pinkAccent,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.pinkAccent,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          debugShowCheckedModeBanner: false,
          title: 'Thoughtbook',
          theme: ThemeData(
            fontFamily:
                (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                    ? 'Roboto'
                    : 'Montserrat',
            fontFamilyFallback: const ['Roboto'],
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            splashFactory: InkSparkle.splashFactory,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily:
                (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                    ? 'Roboto'
                    : 'Montserrat',
            fontFamilyFallback: const ['Roboto'],
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            splashFactory: InkSparkle.splashFactory,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: BlocProvider(
            create: (context) => AuthBloc(FirebaseAuthProvider()),
            child: const HomePage(),
          ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Widget _getMainLayout({
    required AuthState state,
    required BuildContext context,
  }) {
    if (state is AuthStateLoggedIn) {
      return BlocProvider<NoteBloc>(
        create: (context) => NoteBloc(),
        child: const NotesView(),
      );
    } else if (state is AuthStateForgotPassword) {
      return const ForgotPasswordView();
    } else if (state is AuthStateNeedsVerification) {
      return const VerifyEmailView();
    } else if (state is AuthStateLoggedOut) {
      return const LoginView();
    } else if (state is AuthStateRegistering) {
      return const RegisterView();
    } else {
      return Scaffold(
        body: Center(
          child: SpinKitDoubleBounce(
            color: context.theme.colorScheme.primary,
            size: 60,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? context.loc.please_wait,
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _getMainLayout(
            state: state,
            context: context,
          ),
        );
      },
    );
  }
}
