class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNoteException implements CloudStorageException {}

class CouldNotGetAllNotesException implements CloudStorageException {}

class CouldNotUpdateNoteException implements CloudStorageException {}

class CouldNotDeleteNoteException implements CloudStorageException {}
