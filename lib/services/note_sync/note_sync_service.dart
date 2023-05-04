/// Service used to keep the local and cloud databases up to date with the latest changes in notes.
/// Used only when a user is signed in to the application.
class NoteSyncService {
  /// Runs after the first user login to retrieve notes from the cloud database
  Future<void> initLocalNotes() async {
    _ensureUserIsSignedIn();
  }

  /// Responsible for syncing any pending changes in the local database with the cloud.
  /// Subscribes/Watches to changes within the local database.
  ///
  /// Runs when the application is in foreground.
  Future<void> syncPendingLocalToCloud() async {
    _ensureUserIsSignedIn();
  }

  /// Responsible for retrieving changes from the cloud to the local database.
  ///
  /// Runs when the application is in foreground,
  /// runs on the start of every application session,
  /// and also runs as a background service.
  ///
  /// Can be triggered manuallly by the user within the application
  /// and can be prevented from running in the background by the user.
  Future<void> syncPendingCloudToLocal() async {
    _ensureUserIsSignedIn();
  }

  void _ensureUserIsSignedIn() {}
}
