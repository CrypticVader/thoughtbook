String getFirestoreNotesCollectionPath(String id) =>
    'thoughtbookData/$id/notes';

String getFirestoreNoteTagsCollectionPath(String id) =>
    'thoughtbookData/$id/noteTags';

const ownerUserIdFieldName = 'user_id';
const nameFieldName = 'name';
const contentFieldName = 'content';
const titleFieldName = 'title';
const tagDocumentIdsFieldName = 'tagDocumentIds';
const colorFieldName = 'color';
const createdFieldName = 'created';
const modifiedFieldName = 'modified';
const isTrashedFieldName = 'isTrashed';
