import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/constants/routes.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
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
              (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                  ? 'Roboto'
                  : 'Montserrat',
          fontFamilyFallback: const ['Roboto'],
          colorScheme: lightColorScheme ?? _defaultLightColorScheme,
          splashFactory:
              (kIsWeb) ? InkRipple.splashFactory : InkSparkle.splashFactory,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          fontFamily:
              (kIsWeb && Theme.of(context).platform == TargetPlatform.android)
                  ? 'Roboto'
                  : 'Montserrat',
          fontFamilyFallback: const ['Roboto'],
          colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
          splashFactory:
              (kIsWeb) ? InkRipple.splashFactory : InkSparkle.splashFactory,
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

  Widget _getMainLayout({
    required AuthState state,
    required BuildContext context,
  }) {
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
        return Container(
          color: context.theme.colorScheme.background,
          child: AnimatedSwitcher(
            switchInCurve: Curves.easeInOutQuad,
            switchOutCurve: Curves.easeInOutQuad,
            duration: const Duration(milliseconds: 400),
            reverseDuration: const Duration(milliseconds: 1200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return Stack(
                children: [
                  SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: const Offset(1, 0.0),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  ),
                ],
              );
            },
            child: _getMainLayout(
              state: state,
              context: context,
            ),
          ),
        );
      },
    );
  }
}
