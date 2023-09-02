class NoteSyncException implements Exception {}

class NoteFeedClosedSyncException extends NoteSyncException {}

class UserNotLoggedInSyncException extends NoteSyncException {}

class CouldNotDeleteChangeSyncException extends NoteSyncException {}

class InvalidSyncableTypeSyncException extends NoteSyncException {}

class CouldNotFindChangeException implements Exception {}
