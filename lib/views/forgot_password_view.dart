import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/services/auth/auth_exceptions.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/services/auth/bloc/auth_state.dart';
import 'package:thoughtbook/styles/text_styles.dart';
import 'package:thoughtbook/utilities/dialogs/error_dialog.dart';
import 'package:thoughtbook/utilities/dialogs/password_reset_email_sent_dialog.dart';

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
    var theme = Theme.of(context);

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
            style: CustomTextStyle(context).appBarTitle,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.tertiaryContainer.withAlpha(70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        size: 36,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        child: Text(
                          context.loc.forgot_password_view_prompt,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        autofocus: false,
                        controller: _controller,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              width: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                          fillColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          filled: true,
                          prefixIconColor:
                              Theme.of(context).colorScheme.primary,
                          prefixIcon: const Icon(
                            Icons.email_rounded,
                          ),
                          hintText: context.loc.email_text_field_placeholder,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final email = _controller.text;
                          context
                              .read<AuthBloc>()
                              .add(AuthEventForgotPassword(email: email));
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          foregroundColor: theme.colorScheme.onPrimary,
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: Text(
                          context.loc.forgot_password_view_send_me_link,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: Text(
                  context.loc.forgot_password_view_back_to_login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
