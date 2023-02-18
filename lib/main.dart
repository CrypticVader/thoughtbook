import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/constants/routes.dart';
import 'package:thoughtbook/helpers/loading/loading_screen.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/services/auth/bloc/auth_state.dart';
import 'package:thoughtbook/services/auth/firebase_auth_provider.dart';
import 'package:thoughtbook/views/forgot_password_view.dart';
import 'package:thoughtbook/views/login_view.dart';
import 'package:thoughtbook/views/notes/create_update_note_view.dart';
import 'package:thoughtbook/views/notes/notes_view.dart';
import 'package:thoughtbook/views/register_view.dart';
import 'package:thoughtbook/views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    seedColor: Colors.cyan,
    brightness: Brightness.light,
  );

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.cyan,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily:
                  ? 'Roboto'
          fontFamilyFallback: const ['Roboto'],
          fontFamily: 'Montserrat',
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          splashFactory: InkSparkle.splashFactory,
          splashFactory:
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          fontFamilyFallback: const ['Roboto'],
          fontFamily: 'Montserrat',
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          splashFactory: (Theme.of(context).platform == TargetPlatform.android)
              ? InkSparkle.splashFactory
              : InkRipple.splashFactory,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const HomePage(),
        ),
        routes: {
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
        },
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
