import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:thoughtbook/src/features/authentication/domain/auth_user.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/features/note/note_sync/repository/syncable_exceptions.dart';

mixin SyncUtilsMixin {
  /// A getter which returns the device's current internet connection status
  Future<bool> get hasInternetConnection async => await InternetConnection().hasInternetAccess;

  /// A getter to return the currently logged in user
  AuthUser get currentUser => AuthService.firebase().currentUser!;

  void ensureUserIsSignedInOrThrow() {
    final currentUser = AuthService.firebase().currentUser;
    if (currentUser == null) {
      throw UserNotLoggedInSyncException();
    }
  }
}
