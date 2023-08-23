import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_exceptions.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';
import 'package:thoughtbook/src/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetEmailSentDialog(context);
          }
          if (state.exception != null) {
            if (state.exception is EmptyCredentialsAuthException) {
              await showErrorDialog(
                context,
                context.loc.error_empty_email,
              );
            } else if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(
                context,
                context.loc.login_error_cannot_find_user,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context,
                context.loc.register_error_invalid_email,
              );
            } else {
              await showErrorDialog(
                context,
                context.loc.forgot_password_view_generic_error,
              );
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.loc.forgot_password,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: context.theme.colorScheme.tertiaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            size: 26,
                            color:
                                context.theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            'Info',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color:
                                  context.theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        context.loc.forgot_password_view_prompt,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofocus: true,
                    controller: _controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(200),
                      filled: true,
                      prefixIconColor: Theme.of(context).colorScheme.primary,
                      prefixIcon: const Icon(
                        Icons.email_rounded,
                      ),
                      hintText: context.loc.email_text_field_placeholder,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      final email = _controller.text;
                      context
                          .read<AuthBloc>()
                          .add(AuthEventForgotPassword(email: email));
                    },
                    label: Text(
                      context.loc.forgot_password_view_send_me_link,
                    ),
                    icon: const Icon(Icons.link_rounded),
                  ),
                ],
              ),
              const Spacer(
                flex: 1,
              ),
              FilledButton.tonalIcon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                label: Text(
                  context.loc.forgot_password_view_back_to_login,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
