import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';

typedef NoteCallback = void Function(LocalNote note);

class NotesListView extends StatefulWidget {
  final String layoutPreference;
  final List<LocalNote> notes;
  final List<LocalNote> selectedNotes;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;

  const NotesListView({
    Key? key,
    required this.layoutPreference,
    required this.notes,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  int _getLayoutColumnCount(context) {
    if (widget.layoutPreference == LayoutPreference.list.value) {
      return 1;
    } else if (widget.layoutPreference == LayoutPreference.grid.value) {
      final width = MediaQuery.of(context).size.width;
      if (width < 150) {
        return 1;
      }
      int count = (width / 280).round();
      if (count < 2) {
        return 2;
      } else {
        return count;
      }
    } else {
      showErrorDialog(
        context,
        context.loc.notes_list_view_invalid_layout_error,
      );
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notes.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 140,
            color: context.theme.colorScheme.primary,
          ),
          Center(
            child: Text(
              context.loc.notes_view_create_note_to_see_here,
              style: TextStyle(
                fontSize: 15,
                color: context.theme.colorScheme.onBackground,
              ),
            ),
          ),
        ],
      );
    } else {
      return MasonryGridView.count(
        key: ValueKey<int>(_getLayoutColumnCount(context)),
        primary: true,
        itemCount: widget.notes.length,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        crossAxisCount: _getLayoutColumnCount(context),
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
        itemBuilder: (BuildContext context, int index) {
          final note = widget.notes.elementAt(index);
          return NoteItem(
            key: ValueKey<LocalNote>(note),
            note: note,
            isSelected: widget.selectedNotes.contains(note),
            onTap: (note, openContainer) => widget.onTap(note, openContainer),
            onLongPress: (note) => widget.onLongPress(note),
            onDeleteNote: (note) {
              setState(() {
                widget.notes.remove(note);
              });
              widget.onDeleteNote(note);
            },
            enableDismissible: widget.selectedNotes.isEmpty,
          );
        },
      );
    }
  }
}

class NoteItem extends StatefulWidget {
  final LocalNote note;
  final bool isSelected;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final bool enableDismissible;

  const NoteItem({
    Key? key,
    required this.note,
    required this.isSelected,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.enableDismissible,
  }) : super(key: key);

  @override
  State<NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<NoteItem> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;
  ColorScheme noteColors = ColorScheme.fromSeed(
    seedColor: Colors.grey,
    brightness:
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? Brightness.dark
            : Brightness.light,
  );

  Color getNoteColor(BuildContext context, LocalNote? note) {
    if (note != null) {
      if (note.color != null) {
        return Color(note.color!);
      } else {
        return Theme.of(context).colorScheme.primary;
      }
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    noteColors = ColorScheme.fromSeed(
      seedColor: getNoteColor(context, widget.note),
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    return Dismissible(
      key: ValueKey<LocalNote>(widget.note),
      onUpdate: (details) async {
        if (details.progress > 0.34 && details.progress < 0.36) {
          await HapticFeedback.lightImpact();
        }
        setState(() {
          _noteOpacity = 1 - details.progress;
        });
      },
      direction: widget.enableDismissible
          ? DismissDirection.horizontal
          : DismissDirection.none,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.35,
        DismissDirection.endToStart: 0.35,
      },
      onDismissed: (direction) {
        widget.onDeleteNote(widget.note);
        setState(() {
          _noteOpacity = 1.0;
        });
      },
      child: Opacity(
        opacity: _noteOpacity,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onLongPress: () => widget.onLongPress(widget.note),
          onTap: () => widget.onTap(widget.note, _openContainer),
          splashColor: noteColors.primary.withAlpha(170),
          child: OpenContainer(
            tappable: false,
            transitionDuration: const Duration(milliseconds: 250),
            transitionType: ContainerTransitionType.fadeThrough,
            closedElevation: 0,
            openElevation: 0,
            closedColor: noteColors.primaryContainer.withAlpha(170),
            middleColor: noteColors.primaryContainer.withAlpha(170),
            openColor: noteColors.primaryContainer.withAlpha(170),
            useRootNavigator: true,
            closedShape: RoundedRectangleBorder(
              side: widget.isSelected
                  ? BorderSide(
                      width: 3,
                      color: context.theme.colorScheme.tertiary.withAlpha(220),
                    )
                  : BorderSide(
                      width: 0.8,
                      color: noteColors.primary.withAlpha(40),
                      strokeAlign: -1.0,
                    ),
              borderRadius: BorderRadius.circular(24),
            ),
            closedBuilder: (context, openContainer) {
              _openContainer = openContainer;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.note.title.isNotEmpty)
                      Text(
                        widget.note.title,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: noteColors.onSecondaryContainer,
                          fontSize: 19.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (widget.note.title.isNotEmpty &&
                        widget.note.content.isNotEmpty)
                      const SizedBox(
                        height: 8.0,
                      ),
                    if (widget.note.content.isNotEmpty)
                      LimitedBox(
                        maxHeight: 200,
                        child: SingleChildScrollView(
                          controller: null,
                          physics: const NeverScrollableScrollPhysics(),
                          child: MarkdownBody(
                            data:
                                '${widget.note.content.substring(0, min(250, widget.note.content.length))}}',
                            softLineBreak: true,
                            shrinkWrap: true,
                            fitContent: true,
                            extensionSet: md.ExtensionSet.gitHubFlavored,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: noteColors.onSecondaryContainer,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                              h1: TextStyle(
                                color: noteColors.onSecondaryContainer,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                              h2: TextStyle(
                                color: noteColors.onSecondaryContainer,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                              ),
                              h3: TextStyle(
                                color: noteColors.onSecondaryContainer,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Divider(
                      color: noteColors.onPrimaryContainer.withAlpha(100),
                      indent: 8.0,
                      endIndent: 8.0,
                      thickness: 1.0,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: noteColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 18,
                            color: noteColors.onPrimaryContainer.withAlpha(220),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'tags',
                            style: TextStyle(
                              color:
                                  noteColors.onPrimaryContainer.withAlpha(200),
                              fontWeight: FontWeight.w500,
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            openBuilder: (context, closeContainer) {
              return BlocProvider<NoteEditorBloc>(
                create: (context) => NoteEditorBloc(),
                child: NoteEditorView(
                  note: widget.note,
                  shouldAutoFocusContent: false,
                  onDeleteNote: (note) async {
                    widget.onDeleteNote(note);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
