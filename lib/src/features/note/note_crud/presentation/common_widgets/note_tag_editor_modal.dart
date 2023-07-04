import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/note_tag.dart';

typedef NoteTagCreateCallback = void Function(String tagName);
typedef NoteTagEditCallback = void Function(
  NoteTag tag,
  String newName,
);
typedef NoteTagDeleteCallback = void Function(NoteTag tag);

showNoteTagEditorModalBottomSheet({
  required BuildContext context,
  required Stream<List<NoteTag>> Function() tags,
  required NoteTagCreateCallback onCreateTag,
  required NoteTagEditCallback onEditTag,
  required NoteTagDeleteCallback onDeleteTag,
}) async {
  await showModalBottomSheet(
    context: context,
    isDismissible: true,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (context) {
      final newTagTextFieldController = TextEditingController();

      return DraggableScrollableSheet(
        expand: false,
        snap: true,
        initialChildSize: 0.9,
        minChildSize: 0.15,
        maxChildSize: 1.0,
        snapSizes: const [0.5, 0.75],
        snapAnimationDuration: const Duration(microseconds: 150),
        builder: (BuildContext context, ScrollController scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(85),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.surfaceVariant,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
                        child: Center(
                          child: Container(
                            height: 6.0,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: context.theme.colorScheme.onSurfaceVariant
                                  .withAlpha(100),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Edit tags',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
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
                    children: [
                      TextField(
                        controller: newTagTextFieldController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20.0),
                          hintText: 'Create a new tag',
                          prefixIcon: Icon(
                            Icons.new_label_rounded,
                            color: context.theme.colorScheme.onBackground,
                          ),
                          suffixIcon: IconButton.filledTonal(
                            onPressed: () {
                              onCreateTag(newTagTextFieldController.text);
                              newTagTextFieldController.text = '';
                            },
                            icon: const Icon(
                              Icons.done_rounded,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 12.0),
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
                      StreamBuilder<List<NoteTag>>(
                        stream: tags(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                            case ConnectionState.active:
                            case ConnectionState.waiting:
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                final noteTags = snapshot.data!;
                                log(
                                  'noteTags.toString()',
                                  name: 'TagEditor',
                                );
                                return ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final tag = noteTags[index];

                                    return ListTile(
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
                                      splashColor: Colors.transparent,
                                      onTap: () {},
                                      leading: const Icon(Icons.label_rounded),
                                      title: Text(
                                        tag.name,
                                        // style: const TextStyle(fontSize: 16),
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
    },
  );
}
