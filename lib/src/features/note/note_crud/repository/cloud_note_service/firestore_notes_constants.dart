String getFirestoreNotesCollectionPath(String id) =>
    'thoughtbookData/$id/notes';

String getFirestoreNoteTagsCollectionPath(String id) =>
    'thoughtbookData/$id/noteTags';

const ownerUserIdFieldName = 'user_id';
const contentFieldName = 'content';
const titleFieldName = 'title';
const tagsFieldName = 'tags';
const colorFieldName = 'color';
const createdFieldName = 'created';
const modifiedFieldName = 'modified';
