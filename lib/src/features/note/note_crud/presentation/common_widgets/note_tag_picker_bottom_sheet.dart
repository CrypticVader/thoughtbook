import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';

Future<void> showNoteTagPickerModalBottomSheet({
  required BuildContext context,
  required ValueStream<LocalNote> Function() noteStream,
  required ValueStream<List<LocalNoteTag>> Function() allNoteTags,
  required Function(LocalNoteTag tag) onTapTag,
  ColorScheme? colorScheme,
}) async {
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) {
      return NoteTagPickerView(
        onTapTag: (tag) => onTapTag(tag),
        noteStream: noteStream,
        allNoteTags: allNoteTags,
        colorScheme: colorScheme,
      );
    },
  );
}

class NoteTagPickerView extends StatefulWidget {
  final ValueStream<LocalNote> Function() noteStream;
  final ValueStream<List<LocalNoteTag>> Function() allNoteTags;
  final Function(LocalNoteTag tag) onTapTag;
  final ColorScheme? colorScheme;

  const NoteTagPickerView({
    super.key,
    required this.allNoteTags,
    required this.noteStream,
    required this.onTapTag,
    this.colorScheme,
  });

  @override
  State<NoteTagPickerView> createState() => _NoteTagPickerViewState();
}

class _NoteTagPickerViewState extends State<NoteTagPickerView> {
  double maxHeight = 1.0;
  bool hideHandle = false;
  late final DraggableScrollableController controller;

  @override
  void initState() {
    controller = DraggableScrollableController();
    controller.addListener(() {
      final size = controller.size;
      dev.log(size.toString());
      if (size == 1 && !hideHandle) {
        setState(() {
          hideHandle = true;
        });
      } else if (hideHandle) {
        setState(() {
          hideHandle = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(() {
      final size = controller.size;
      dev.log(size.toString());
      if (size == 1 && !hideHandle) {
        setState(() {
          hideHandle = true;
        });
      } else if (hideHandle) {
        setState(() {
          hideHandle = false;
        });
      }
    });
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme ?? context.theme.colorScheme;

    return StreamBuilder<(LocalNote, List<LocalNoteTag>)>(
      stream: Rx.combineLatest2(
        widget.noteStream(),
        widget.allNoteTags(),
        (note, noteTags) {
          dev.log('new combined value');
          return (note, noteTags);
        },
      ).shareValue(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data!.$2.isNotEmpty) {
              final noteTagIds = snapshot.data!.$1.tagIds;
              final allNoteTagList = snapshot.data!.$2;

              final screenHeight = MediaQuery.of(context).size.height;
              final itemHeight = allNoteTagList.length * 66 + 86 + 32;
              maxHeight = max(0.25, min(1, itemHeight / screenHeight));

              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(28),
                  topLeft: Radius.circular(28),
                ),
                child: DraggableScrollableSheet(
                  controller: controller,
                  expand: false,
                  initialChildSize: min(0.75, maxHeight),
                  maxChildSize: maxHeight,
                  builder: (context, scrollController) {
                    return Scaffold(
                      backgroundColor: Color.alphaBlend(
                        colorScheme.surfaceTint.withAlpha(25),
                        colorScheme.background,
                      ),
                      appBar: AppBar(
                        backgroundColor: Color.alphaBlend(
                          colorScheme.surfaceTint.withAlpha(25),
                          colorScheme.background,
                        ),
                        leading: null,
                        automaticallyImplyLeading: false,
                        toolbarHeight: 80,
                        centerTitle: true,
                        title: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 8.0, 0.0, 16.0),
                              child: Ink(
                                height: 6.0,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  color: colorScheme.onSurfaceVariant
                                      .withAlpha(hideHandle ? 0 : 100),
                                ),
                              ),
                            ),
                            Text(
                              'Edit tags',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final tag = allNoteTagList[index];
                                  final isSelected =
                                      noteTagIds.contains(tag.isarId);
                                  return ListTile(
                                    onTap: () => widget.onTapTag(tag),
                                    splashColor:
                                        colorScheme.secondary.withAlpha(100),
                                    tileColor: colorScheme.secondaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: index == 0
                                            ? const Radius.circular(24)
                                            : const Radius.circular(4),
                                        topRight: index == 0
                                            ? const Radius.circular(24)
                                            : const Radius.circular(4),
                                        bottomLeft:
                                            (index == allNoteTagList.length - 1)
                                                ? const Radius.circular(24)
                                                : const Radius.circular(4),
                                        bottomRight:
                                            (index == allNoteTagList.length - 1)
                                                ? const Radius.circular(24)
                                                : const Radius.circular(4),
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.label_rounded,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    title: Text(
                                      tag.name,
                                      style: TextStyle(
                                        color: colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Checkbox(
                                      side: BorderSide(
                                        color: colorScheme.secondary,
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0)),
                                      activeColor: colorScheme.secondary,
                                      checkColor: colorScheme.onPrimary,
                                      value: isSelected,
                                      onChanged: (value) =>
                                          widget.onTapTag(tag),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 2,
                                ),
                                itemCount: allNoteTagList.length,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                          color: context.theme.colorScheme.onPrimaryContainer
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
                            color: context.theme.colorScheme.onPrimaryContainer
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
                color: context.theme.colorScheme.primaryContainer.withAlpha(90),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.label_off_rounded,
                        size: 42,
                        color: context.theme.colorScheme.onPrimaryContainer
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
                          color: context.theme.colorScheme.onPrimaryContainer
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
    );
  }
}
