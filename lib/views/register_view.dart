import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/auth/auth_exceptions.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/services/auth/bloc/auth_state.dart';
import 'package:thoughtbook/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  bool _passwordMatches = true;

  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _passwordReEntered;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordReEntered = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordReEntered.dispose();
    super.dispose();
  }

  bool _isPasswordMatching() {
    if (_password.text == _passwordReEntered.text) {
      return true;
    } else {
      return false;
    }
  }

  void _passwordFieldListener() {
    setState(() {
      _passwordMatches = _isPasswordMatching();
    });
  }

  void _setupPasswordListener() {
    _password.removeListener(_passwordFieldListener);
    _password.addListener(_passwordFieldListener);

    _passwordReEntered.removeListener(_passwordFieldListener);
    _passwordReEntered.addListener(_passwordFieldListener);
  }

  @override
  Widget build(BuildContext context) {
    _setupPasswordListener();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is EmptyCredentialsAuthException) {
            await showErrorDialog(
              context,
              context.loc.error_empty_credentials,
            );
          } else if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_weak_password,
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_email_already_in_use,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.register_error_invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.auth_error_generic,
            );
          }
        }
      },
      child: Scaffold(
        body: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              baseColor: context.theme.colorScheme.secondary,
              spawnOpacity: 0.0,
              opacityChangeRate: 0.25,
              minOpacity: 0.1,
              maxOpacity: 0.4,
              spawnMinSpeed: 20.0,
              spawnMaxSpeed: 30.0,
              spawnMinRadius: 10.0,
              spawnMaxRadius: 20.0,
              particleCount: 26,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Text(
                    context.loc.welcome_to,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      color: context.theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    context.loc.app_title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: context.theme.colorScheme.primary,
                    ),
                  ).animate(adapter: ValueAdapter(0.5)).shimmer(
                    colors: [
                      context.theme.colorScheme.primary,
                      context.theme.colorScheme.tertiary,
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Text(
                    context.loc.register_view_prompt,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                width: 2,
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: context
                                .theme.colorScheme.primaryContainer
                                .withAlpha(200),
                            filled: true,
                            prefixIconColor: context.theme.colorScheme.primary,
                            prefixIcon: const Icon(
                              Icons.email_rounded,
                            ),
                            hintText: context.loc.email_text_field_placeholder,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: _password,
                          textInputAction: TextInputAction.next,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                width: 2,
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: context
                                .theme.colorScheme.primaryContainer
                                .withAlpha(200),
                            filled: true,
                            hintText:
                                context.loc.password_text_field_placeholder,
                            prefixIconColor: context.theme.colorScheme.primary,
                            prefixIcon: const Icon(
                              Icons.password_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: _passwordReEntered,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _passwordMatches
                                ? context.theme.colorScheme.primaryContainer
                                    .withAlpha(200)
                                : context.theme.colorScheme.errorContainer,
                            errorText: _passwordMatches
                                ? null
                                : context
                                    .loc.register_error_passwords_do_not_match,
                            contentPadding: const EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                width: 2,
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                              borderSide: BorderSide.none,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                width: 2,
                                color: context.theme.colorScheme.error,
                              ),
                            ),
                            hintText: context
                                .loc.reenter_password_text_field_placeholder,
                            prefixIconColor: _passwordMatches
                                ? context.theme.colorScheme.primary
                                : context.theme.colorScheme.error,
                            prefixIcon: const Icon(
                              Icons.password_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      if (_isPasswordMatching()) {
                        context.read<AuthBloc>().add(
                              AuthEventRegister(
                                email,
                                password,
                              ),
                            );
                      } else {
                        await showErrorDialog(
                          context,
                          context.loc.register_error_passwords_do_not_match,
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      foregroundColor: context.theme.colorScheme.onPrimary,
                      backgroundColor: context.theme.colorScheme.primary,
                    ),
                    child: Text(
                      context.loc.register,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          context.theme.colorScheme.surface.withOpacity(0.6),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: Text(
                      context.loc.register_view_already_registered,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
