import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_provider.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/cloud_storable/cloud_store.dart';
import 'package:thoughtbook/src/features/note/note_crud/repository/local_storable/local_store.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/synchronizer.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/app_preference_service.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_keys.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthInitial(isLoading: true)) {
    // forgot password
    on<AuthForgotPasswordEvent>(
      (event, emit) async {
        emit(
          const AuthForgotPassword(
            exception: null,
            hasSentEmail: false,
            isLoading: false,
          ),
        );
        final email = event.email;
        if (email == null) {
          return; // user just wants to go to forgot password screen
        }
        // user actually wants to send a forgot password email
        emit(
          const AuthForgotPassword(
            exception: null,
            hasSentEmail: false,
            isLoading: true,
          ),
        );

        bool didSendEmail;
        Exception? exception;
        try {
          await provider.sendPasswordReset(toEmail: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }

        emit(
          AuthForgotPassword(
            exception: exception,
            hasSentEmail: didSendEmail,
            isLoading: false,
          ),
        );
      },
    );

    // send verification email
    on<AuthSendEmailVerificationEvent>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    // register
    on<AuthRegisterEvent>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          emit(
            const AuthRegistering(
              exception: null,
              isLoading: true,
            ),
          );
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(
            AuthRegistering(
              exception: e,
              isLoading: false,
            ),
          );
        }
      },
    );

    // initialize
    on<AuthInitializeEvent>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          final isUserGuest = AppPreferenceService().isUserLoggedInAsGuest;
          if (isUserGuest) {
            if (kIsWeb) {
              await AppPreferenceService().setPreference(
                key: PreferenceKey.isGuest,
                value: false,
              );
              emit(const AuthLoggedOut(exception: null, isLoading: false));
            } else {
              emit(const AuthLoggedIn(
                isLoading: false,
                isUserGuest: true,
                user: null,
              ));
            }
          } else {
            emit(const AuthLoggedOut(exception: null, isLoading: false));
          }
        } else {
          await AppPreferenceService().setPreference(
            key: PreferenceKey.isGuest,
            value: false,
          );
          if (kIsWeb) {
            await provider.logOut();
            emit(const AuthLoggedOut(exception: null, isLoading: false));
            return;
          }
          if (!user.isEmailVerified) {
            emit(
              const AuthNeedsVerification(
                isLoading: false,
              ),
            );
          } else {
            emit(
              AuthLoggedIn(
                user: user,
                isLoading: false,
                isUserGuest: false,
              ),
            );
          }
        }
      },
    );

    // log in
    on<AuthLogInEvent>(
      (event, emit) async {
        emit(
          const AuthLoggedOut(
            exception: null,
            isLoading: true,
          ),
        );
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          await AppPreferenceService().setPreference(
            key: PreferenceKey.isGuest,
            value: false,
          );
          if (!user.isEmailVerified) {
            emit(
              const AuthLoggedOut(
                exception: null,
                isLoading: false,
                loadingText: 'Trying to log you in',
              ),
            );
            emit(const AuthNeedsVerification(isLoading: false));
          } else {
            emit(const AuthLoggedOut(
              exception: null,
              isLoading: true,
            ));

            // After logging in, retrieve all the notes belonging to the user from
            // the Firestore collection to the local database
            await CloudStore.open();
            await LocalStore.open();

            final Stream<int> noteTagLoadProgress = Synchronizer.noteTag.initLocalFromCloud();
            await for (int progress in noteTagLoadProgress) {
              log('CloudNoteTag retrieval progress: ${progress.toString()}%');
            }
            log('Successfully retrieved all note tags from Firestore');
            final Stream<int> noteLoadProgress = Synchronizer.note.initLocalFromCloud();
            await for (int progress in noteLoadProgress) {
              log('CloudNote retrieval progress: ${progress.toString()}%');
            }
            log('Successfully retrieved all notes from Firestore');

            emit(AuthLoggedIn(
              user: user,
              isLoading: false,
              isUserGuest: false,
            ));
          }
        } on Exception catch (e) {
          emit(AuthLoggedOut(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );

    // log in as guest
    on<AuthLoginAsGuestEvent>(
      (event, emit) async {
        emit(const AuthLoggedOut(
          exception: null,
          isLoading: true,
        ));
        await AppPreferenceService().setPreference(
          key: PreferenceKey.isGuest,
          value: true,
        );
        await CloudStore.open();
        await LocalStore.open();
        emit(const AuthLoggedIn(
          isLoading: false,
          isUserGuest: true,
          user: null,
        ));
      },
    );

    // should register
    on<AuthShouldRegisterEvent>(
      (event, emit) {
        emit(
          const AuthRegistering(
            exception: null,
            isLoading: false,
          ),
        );
      },
    );

    // log out
    on<AuthLogOutEvent>(
      (event, emit) async {
        try {
          await provider.logOut();
          emit(
            const AuthLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(
            AuthLoggedOut(
              exception: e,
              isLoading: false,
            ),
          );
        } finally {
          await LocalStore.close(clearData: true);
          await CloudStore.close();
        }
      },
    );
  }
}
