import 'dart:math' show max, min;

import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/note_tile.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';

typedef NoteCallback = void Function(LocalNote note);
typedef NoteDataCallback = void Function(PresentableNoteData noteData);

class SliverNotesGrid extends StatefulWidget {
  final bool isCollapsed;
  final bool isDismissible;
  final String layoutPreference;

  final List<PresentableNoteData> notesData;
  final Set<LocalNote> selectedNotes;
  final NoteCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;

  const SliverNotesGrid({
    Key? key,
    this.isCollapsed = false,
    this.isDismissible = true,
    required this.layoutPreference,
    required this.notesData,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<SliverNotesGrid> createState() => _SliverNotesGridState();
}

class _SliverNotesGridState extends State<SliverNotesGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _childCount;

  @override
  void initState() {
    super.initState();
    _childCount = widget.notesData.length;
    _controller = AnimationController(
      vsync: this,
      duration: 500.milliseconds,
      reverseDuration: 500.milliseconds,
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void didUpdateWidget(covariant SliverNotesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCollapsed != widget.isCollapsed) {
      // childCount is set here to avoid a 'jump' in the grid view when the group is expanded
      // the jump happens when the NoteGroup provides the grid with the entire list of notes unlike
      // the sublist that is provided when the group is collapsed
      if (widget.isCollapsed) {
        setChildCount(min(10, widget.notesData.length));
        _controller.forward();
      } else {
        setChildCount(min(10, widget.notesData.length));
        _controller.reverse().then((value) => setChildCount(widget.notesData.length));
      }
    }
  }

  void setChildCount(int count) {
    if (_childCount != count) {
      _childCount = count;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

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
      return SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: false,
        child: UnconstrainedBox(
          child: Ink(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.themeColors.secondaryContainer.withAlpha(120),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
        ),
      );
    } else {
      final crossAxisCount = _getLayoutColumnCount(context);
      if (crossAxisCount == 1) {
        return SliverCrossAxisConstrained(
          maxCrossAxisExtent: 768,
          child: _buildSliverGrid(),
        );
      } else {
        return _buildSliverGrid();
      }
    }
  }

  Widget _buildSliverGrid() {
    return SliverMasonryGrid.count(
      key: ValueKey<int>(_getLayoutColumnCount(context)),
      crossAxisSpacing: (widget.isCollapsed || widget.layoutPreference == 'list') ? 0 : 8.0,
      mainAxisSpacing: (widget.isCollapsed || widget.layoutPreference == 'list') ? 0 : 8.0,
      crossAxisCount: _getLayoutColumnCount(context),
      childCount: _childCount,
      itemBuilder: (BuildContext context, int index) {
        final noteData = widget.notesData.elementAt(index);
        return NoteTile(
          key: ValueKey<int>(noteData.note.isarId),
          animation: _animation,
          noteData: noteData,
          isVisible: !(widget.isCollapsed),
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
          gridCrossAxisCount: _getLayoutColumnCount(context),
        );
      },
    );
  }
}
