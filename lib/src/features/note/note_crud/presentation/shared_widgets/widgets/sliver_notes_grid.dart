import 'dart:math' show max, min;

import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/curves/material_3.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/note_tile.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
    super.key,
    this.isCollapsed = false,
    this.isDismissible = true,
    required this.layoutPreference,
    required this.notesData,
    required this.selectedNotes,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
  });

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
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: M3Easings.emphasized,
      reverseCurve: M3Easings.emphasizedAccelerate,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _childCount = widget.notesData.length;
  }

  @override
  void didUpdateWidget(covariant SliverNotesGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCollapsed != widget.isCollapsed) {
      // childCount is set here to avoid a 'jump' in the grid view when the group is expanded
      // The jump happens when the NoteGroup provides the grid with the entire list of notes unlike
      // the sublist that is provided when the group is collapsed
      if (widget.isCollapsed) {
        setChildCount(min(10, widget.notesData.length));
        _controller.forward();
      } else {
        setChildCount(min(10, widget.notesData.length));
        _controller.reverse().then((value) => setChildCount(widget.notesData.length));
      }
    } else {
      setChildCount(widget.notesData.length);
    }
  }

  void setChildCount(int count) {
    if (_childCount != count) {
      setState(() {
        _childCount = count;
      });
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
    return SliverWaterfallFlow(
      key: ValueKey<int>(_getLayoutColumnCount(context)),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getLayoutColumnCount(context),
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 0.0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: _childCount,
        (context, index) {
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
      ),
    );
  }
}
