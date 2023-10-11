import 'dart:math' show max;

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/note_tile.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';

typedef NoteCallback = void Function(LocalNote note);
typedef NoteDataCallback = void Function(PresentableNoteData noteData);

class NotesListView extends StatefulWidget {
  final bool isDismissible;
  final String layoutPreference;

  final List<PresentableNoteData> notesData;
  final Set<LocalNote> selectedNotes;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;

  const NotesListView({
    Key? key,
    this.isDismissible = true,
    required this.layoutPreference,
    required this.notesData,
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
      return max(2, count);
    } else {
      showErrorDialog(
        context: context,
        text: context.loc.notes_list_view_invalid_layout_error,
      );
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notesData.isEmpty) {
      return Center(
        child: Ink(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.themeColors.secondaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                FluentIcons.notebook_error_24_regular,
                size: 150,
                color: context.theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Oops! Could not find any notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSecondaryContainer.withAlpha(220),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final crossAxisCount = _getLayoutColumnCount(context);
      if (crossAxisCount == 1) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: _buildGridView(),
          ),
        );
      } else {
        return _buildGridView();
      }
    }
  }

  Widget _buildGridView() {
    return MasonryGridView.count(
      key: ValueKey<int>(_getLayoutColumnCount(context)),
      primary: true,
      itemCount: widget.notesData.length,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      crossAxisCount: _getLayoutColumnCount(context),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final noteData = widget.notesData.elementAt(index);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: NoteTile(
            key: ValueKey<int>(noteData.note.isarId),
            noteData: noteData,
            isSelected: widget.selectedNotes.contains(noteData.note),
            onTap: (note, openContainer) => widget.onTap(note, openContainer),
            onLongPress: (note) => widget.onLongPress(note),
            onDeleteNote: (noteData) {
              setState(() {
                widget.notesData.remove(noteData);
              });
              widget.onDeleteNote(noteData.note);
            },
            enableDismissible: widget.selectedNotes.isEmpty && widget.isDismissible,
            index: index,
          ),
        );
      },
    );
  }
}

