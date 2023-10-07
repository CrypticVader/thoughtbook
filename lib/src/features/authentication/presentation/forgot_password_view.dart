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
                context: context,
                text: context.loc.error_empty_email,
                showTitle: false,
              );
            } else if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(
                context: context,
                text: context.loc.login_error_cannot_find_user,
                showTitle: false,
              );
            } else if (state.exception is InvalidEmailAuthException) {
              await showErrorDialog(
                context: context,
                text: context.loc.register_error_invalid_email,
                showTitle: false,
              );
            } else {
              await showErrorDialog(
                context: context,
                text: context.loc.forgot_password_view_generic_error,
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
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
                                color: context.theme.colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                'Info',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: context.theme.colorScheme.onTertiaryContainer,
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
                        onSubmitted: (_) {
                          final email = _controller.text;
                          context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                        },
                        textInputAction: TextInputAction.go,
                        autocorrect: false,
                        autofocus: true,
                        controller: _controller,
                        style: TextStyle(
                          color: context.theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: context.theme.colorScheme.onPrimaryContainer.withAlpha(200),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              width: 0.5,
                              color: context.theme.colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: context.theme.colorScheme.primaryContainer.withAlpha(200),
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
                      // FilledButton.icon(
                      //   onPressed: () {
                      //     final email = _controller.text;
                      //     context
                      //         .read<AuthBloc>()
                      //         .add(AuthEventForgotPassword(email: email));
                      //   },
                      //   label: Text(
                      //     context.loc.forgot_password_view_send_me_link,
                      //     style: const TextStyle(
                      //       fontWeight: FontWeight.w500,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      //   icon: const Icon(Icons.link_rounded),
                      //   style: FilledButton.styleFrom(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 28.0,
                      //       vertical: 16.0,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(26),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                            vertical: 16.0,
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          final email = _controller.text;
                          context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                        },
                        label: Text(
                          context.loc.forgot_password_view_send_me_link,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        icon: const Icon(Icons.link_rounded),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                            vertical: 16.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ],
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
