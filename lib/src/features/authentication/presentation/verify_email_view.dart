import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.verify_email,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: context.theme.colorScheme.primaryContainer.withAlpha(140),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.loc.verify_email_view_prompt,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthLogOutEvent(),
                            );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: context.theme.colorScheme.primary,
                        foregroundColor: context.theme.colorScheme.onPrimary,
                      ),
                      child: Text(
                        context.loc.verify_email_view_back_to_login,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      color: context.theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              context.loc.verify_email_view_resend_verification_prompt,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const AuthSendEmailVerificationEvent(),
                                    );
                              },
                              child: Text(
                                context.loc.verify_email_send_email_verification,
                                style: TextStyle(
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
