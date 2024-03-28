import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/curves/material_3.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/presentation/forgot_password_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/login_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/register_view.dart';
import 'package:thoughtbook/src/features/authentication/presentation/verify_email_view.dart';
import 'package:thoughtbook/src/features/authentication/repository/firebase_auth_provider.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/pages/notes_page.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/helpers/loading/loading_screen.dart';
import 'package:thoughtbook/src/utilities/common_widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AppPreferenceService().initPrefs());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black.withOpacity(0.002),
  ));

  runApp(const ThoughtbookApp());
}

class ThoughtbookApp extends StatefulWidget {
  const ThoughtbookApp({super.key});

  @override
  State<ThoughtbookApp> createState() => _ThoughtbookAppState();
}

class _ThoughtbookAppState extends State<ThoughtbookApp> {
  late Image _appLogo;
  static final _defaultLightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.purple,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.purple,
    brightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    _appLogo = Image.asset(
      'assets/icon/icon.png',
      height: 192,
      width: 192,
      cacheHeight: 288,
      cacheWidth: 288,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_appLogo.image, context);
  }

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
            fontFamily: 'Montserrat',
            fontFamilyFallback: const ['NotoSans', 'Roboto'],
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            splashFactory: (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                ? InkRipple.splashFactory
                : InkSparkle.splashFactory,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Montserrat',
            fontFamilyFallback: const ['NotoSans', 'Roboto'],
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            splashFactory: (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                ? InkRipple.splashFactory
                : InkSparkle.splashFactory,
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
  const HomePage({super.key});

  Widget _getMainLayout({
    required AuthState state,
    required BuildContext context,
  }) {
    if (state is AuthLoggedIn) {
      return BlocProvider<NoteBloc>(
        create: (context) => NoteBloc(),
        child: const NotesPage(),
      );
    } else if (state is AuthForgotPassword) {
      return const ForgotPasswordView();
    } else if (state is AuthNeedsVerification) {
      return const VerifyEmailView();
    } else if (state is AuthLoggedOut) {
      return const LoginView();
    } else if (state is AuthRegistering) {
      return const RegisterView();
    } else {
      return const Scaffold(
        body: SplashScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthInitializeEvent());
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
          switchInCurve: M3Easings.emphasizedDecelerate,
          switchOutCurve: M3Easings.emphasized,
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
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
