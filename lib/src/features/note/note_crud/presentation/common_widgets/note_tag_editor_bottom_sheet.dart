import 'dart:math';

import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/note_tag_rename_dialog.dart';
import 'package:thoughtbook/src/utilities/dialogs/delete_dialog.dart';

typedef NoteTagCreateCallback = void Function(String tagName);
typedef NoteTagEditCallback = void Function(
  LocalNoteTag tag,
  String newName,
);
typedef NoteTagDeleteCallback = void Function(LocalNoteTag tag);

Future<void> showNoteTagEditorModalBottomSheet({
  required BuildContext context,
  required Stream<List<LocalNoteTag>> Function() tags,
  required NoteTagCreateCallback onCreateTag,
  required NoteTagEditCallback onEditTag,
  required NoteTagDeleteCallback onDeleteTag,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (context) => NoteTagEditorView(
      tags: () => tags(),
      onCreateTag: (String tagName) => onCreateTag(tagName),
      onEditTag: (LocalNoteTag tag, String newName) => onEditTag(tag, newName),
      onDeleteTag: (LocalNoteTag tag) => onDeleteTag(tag),
    ),
  );
}

class NoteTagEditorView extends StatefulWidget {
  const NoteTagEditorView({
    super.key,
    required this.tags,
    required this.onCreateTag,
    required this.onEditTag,
    required this.onDeleteTag,
  });

  final Stream<List<LocalNoteTag>> Function() tags;
  final NoteTagCreateCallback onCreateTag;
  final NoteTagEditCallback onEditTag;
  final NoteTagDeleteCallback onDeleteTag;

  @override
  State<NoteTagEditorView> createState() => _NoteTagEditorViewState();
}

class _NoteTagEditorViewState extends State<NoteTagEditorView> {
  late TextEditingController newTagTextFieldController;

  @override
  void initState() {
    newTagTextFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    newTagTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.25,
      maxChildSize: 1.0,
      snapAnimationDuration: const Duration(microseconds: 150),
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(86),
              child: AppBar(
                leading: null,
                automaticallyImplyLeading: false,
                toolbarHeight: 80,
                centerTitle: true,
                title: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                      child: Ink(
                        height: 6.0,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: context.theme.colorScheme.onSurfaceVariant
                              .withAlpha(100),
                        ),
                      ),
                    ),
                    Text(
                      'Edit tags',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: context.theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: TextField(
                            onSubmitted: (_) {
                              widget.onCreateTag(newTagTextFieldController.text);
                              newTagTextFieldController.text = '';
                            },
                            textInputAction: TextInputAction.done,
                            controller: newTagTextFieldController,
                            maxLines: 1,
                            // maxLength: 20,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: context
                                  .theme.colorScheme.secondaryContainer
                                  .withAlpha(200),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              contentPadding: const EdgeInsets.all(16.0),
                              hintText: 'Create a new tag',
                              prefixIcon: Icon(
                                Icons.new_label_rounded,
                                color: context
                                    .theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: context
                                  .theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 16.0,
                        ),
                        IconButton.filled(
                          tooltip: 'Create tag',
                          onPressed: () {
                            widget.onCreateTag(newTagTextFieldController.text);
                            newTagTextFieldController.text = '';
                          },
                          icon: const Icon(
                            Icons.done_rounded,
                            size: 32,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                context.theme.colorScheme.secondary,
                            foregroundColor:
                                context.theme.colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            color: context.theme.colorScheme.onBackground
                                .withAlpha(200),
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            'Your tags',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: context.theme.colorScheme.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<List<LocalNoteTag>>(
                      stream: widget.tags(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                              final noteTags = snapshot.data!;

                              return ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final tag = noteTags[index];

                                  return Entry.all(
                                    delay: Duration(
                                        milliseconds: min(200, 35 * index)),
                                    duration: const Duration(milliseconds: 100),
                                    opacity: 0,
                                    scale: 0.75,
                                    yOffset: 0,
                                    xOffset: 0,
                                    curve: Curves.easeInOut,
                                    child: Card(
                                      borderOnForeground: false,
                                      margin: EdgeInsets.zero,
                                      color: Colors.transparent,
                                      elevation: 0,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                16.0, 0.0, 8.0, 0.0),
                                        tileColor: context
                                            .theme.colorScheme.primaryContainer
                                            .withAlpha(150),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: (index == 0)
                                                ? const Radius.circular(24)
                                                : const Radius.circular(4),
                                            topRight: (index == 0)
                                                ? const Radius.circular(24)
                                                : const Radius.circular(4),
                                            bottomLeft:
                                                (index == (noteTags.length - 1))
                                                    ? const Radius.circular(24)
                                                    : const Radius.circular(4),
                                            bottomRight:
                                                (index == (noteTags.length - 1))
                                                    ? const Radius.circular(24)
                                                    : const Radius.circular(4),
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.label_rounded,
                                          color: context.theme.colorScheme
                                              .onPrimaryContainer,
                                        ),
                                        title: Text(
                                          tag.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: context.theme.colorScheme
                                                .onPrimaryContainer,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  showNoteTagRenameDialog(
                                                context: context,
                                                tag: tag,
                                                onEditTag: (tag, newName) =>
                                                    widget.onEditTag(
                                                  tag,
                                                  newName,
                                                ),
                                              ),
                                              splashColor: context.theme
                                                  .colorScheme.onBackground
                                                  .withAlpha(200),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(24),
                                                bottomLeft: Radius.circular(24),
                                                topRight: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(24),
                                                    bottomLeft:
                                                        Radius.circular(24),
                                                    topRight:
                                                        Radius.circular(4),
                                                    bottomRight:
                                                        Radius.circular(4),
                                                  ),
                                                  color: context.theme
                                                      .colorScheme.background
                                                      .withAlpha(200),
                                                ),
                                                child: const Icon(
                                                  Icons.edit_rounded,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 2.0,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                final shouldDelete =
                                                    await showDeleteDialog(
                                                  context: context,
                                                  content:
                                                      'Are you sure you want to delete this label? '
                                                      'It will be removed from every note.',
                                                );
                                                if (shouldDelete) {
                                                  widget.onDeleteTag(tag);
                                                }
                                              },
                                              splashColor: context.theme
                                                  .colorScheme.onBackground
                                                  .withAlpha(200),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                bottomLeft: Radius.circular(4),
                                                topRight: Radius.circular(24),
                                                bottomRight:
                                                    Radius.circular(24),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    bottomLeft:
                                                        Radius.circular(4),
                                                    topRight:
                                                        Radius.circular(24),
                                                    bottomRight:
                                                        Radius.circular(24),
                                                  ),
                                                  color: context.theme
                                                      .colorScheme.background
                                                      .withAlpha(200),
                                                ),
                                                child: const Icon(
                                                    Icons.delete_rounded),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 2.0,
                                  );
                                },
                                itemCount: noteTags.length,
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withAlpha(90),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.label_off_rounded,
                                          size: 42,
                                          color: context.theme.colorScheme
                                              .onPrimaryContainer
                                              .withAlpha(200),
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Text(
                                          'Nothing here',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: context.theme.colorScheme
                                                .onPrimaryContainer
                                                .withAlpha(200),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          default:
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha(90),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.label_off_rounded,
                                        size: 42,
                                        color: context.theme.colorScheme
                                            .onPrimaryContainer
                                            .withAlpha(200),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        'Nothing here',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: context.theme.colorScheme
                                              .onPrimaryContainer
                                              .withAlpha(200),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
