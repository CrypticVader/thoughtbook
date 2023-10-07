import 'dart:async' show unawaited;
import 'dart:developer' show log;
import 'dart:math' show min, max;

import 'package:animations/animations.dart';
import 'package:entry/entry.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/error_dialog.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
          child: UnconstrainedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.note_add_48_filled,
                  size: 150,
                  color: context.theme.colorScheme.onSecondaryContainer.withAlpha(150),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Center(
                  child: Text(
                    context.loc.notes_view_create_note_to_see_here,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.onSecondaryContainer.withAlpha(220),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return MasonryGridView.count(
        key: ValueKey<int>(_getLayoutColumnCount(context)),
        primary: true,
        itemCount: widget.notesData.length,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        crossAxisCount: _getLayoutColumnCount(context),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final noteData = widget.notesData.elementAt(index);
          return NoteItem(
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
          );
        },
      );
    }
  }
}

class NoteItem extends StatefulWidget {
  final PresentableNoteData noteData;
  final bool isSelected;
  final NoteDataCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final bool enableDismissible;
  final int index;

  const NoteItem({
    Key? key,
    required this.noteData,
    required this.isSelected,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.enableDismissible,
    required this.index,
  }) : super(key: key);

  @override
  State<NoteItem> createState() => _NoteItemState();
}

//TODO: Use Boxy to find size of md body before build, & decide to paint the gradient
class _NoteItemState extends State<NoteItem> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;
  bool _hasVibrated = false;
  ColorScheme _noteColors = ColorScheme.fromSeed(seedColor: Colors.grey);
  bool _isVisible = true;
  bool _renderFade = false;

  @override
  Widget build(BuildContext context) {
    if (widget.noteData.note.color != null) {
      _noteColors = ColorScheme.fromSeed(
        seedColor: Color(widget.noteData.note.color!),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      );
    } else {
      if (_isDarkMode) {
        _noteColors = ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.dark,
        );
      } else {
        _noteColors = ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        );
      }
    }
    return Entry.all(
      visible: _isVisible,
      delay: Duration(milliseconds: min(250, 25 * widget.index + 10)),
      duration: const Duration(milliseconds: 220),
      opacity: 0,
      scale: 0.95,
      curve: Curves.easeInOutExpo,
      yOffset: 0.0,
      xOffset: 0.0,
      child: _buildDismissible(),
    );
  }

  Widget _buildDismissible() {
    return Dismissible(
      key: ValueKey<int>(widget.noteData.note.isarId),
      onUpdate: (details) async {
        setState(() {
          _noteOpacity = 1.0 - details.progress;
        });
        if (!_hasVibrated && details.progress >= 0.4) {
          unawaited(HapticFeedback.mediumImpact());
          _hasVibrated = true;
        } else if (_hasVibrated && details.progress < 0.4) {
          unawaited(HapticFeedback.mediumImpact());
          _hasVibrated = false;
        }
      },
      direction: widget.enableDismissible ? DismissDirection.horizontal : DismissDirection.none,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.4,
        DismissDirection.endToStart: 0.4,
      },
      onDismissed: (direction) {
        widget.onDeleteNote(widget.noteData);
        setState(() {
          _noteOpacity = 1.0;
        });
      },
      child: _buildAnimatedOpacity(),
    );
  }

  Widget _buildAnimatedOpacity() {
    return AnimatedOpacity(
      opacity: _noteOpacity,
      duration: const Duration(milliseconds: 15),
      child: _buildOpenContainer(),
    );
  }

  Widget _buildOpenContainer() {
    return OpenContainer(
      tappable: false,
      transitionDuration: const Duration(milliseconds: 250),
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor:
          Color.alphaBlend(_noteColors.primaryContainer.withAlpha(150), _noteColors.background),
      middleColor:
          Color.alphaBlend(_noteColors.primaryContainer.withAlpha(150), _noteColors.background),
      openColor:
          Color.alphaBlend(_noteColors.primaryContainer.withAlpha(150), _noteColors.background),
      useRootNavigator: true,
      closedShape: RoundedRectangleBorder(
        side: widget.isSelected
            ? BorderSide(
                width: 3,
                color: context.theme.colorScheme.tertiary,
                strokeAlign: BorderSide.strokeAlignInside,
              )
            : BorderSide(
                width: 1,
                color: _noteColors.primary.withAlpha(15),
                strokeAlign: BorderSide.strokeAlignInside,
              ),
        borderRadius: BorderRadius.circular(26),
      ),
      closedBuilder: (context, openContainer) {
        _openContainer = openContainer;
        return _buildInkWell();
      },
      openBuilder: (context, closeContainer) {
        return BlocProvider<NoteEditorBloc>(
          create: (context) => NoteEditorBloc(),
          child: NoteEditorView(
            note: widget.noteData.note,
            shouldAutoFocusContent: false,
            onDeleteNote: (_) async {
              await Future.delayed(const Duration(milliseconds: 200));
              setState(() {
                _isVisible = false;
              });
              await Future.delayed(const Duration(milliseconds: 150));
              widget.onDeleteNote(widget.noteData);
            },
          ),
        );
      },
    );
  }

  Widget _buildInkWell() {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onLongPress: () => widget.onLongPress(widget.noteData.note),
      onTap: () => widget.onTap(widget.noteData.note, _openContainer),
      splashColor: _noteColors.inversePrimary.withAlpha(120),
      highlightColor: _noteColors.surfaceVariant.withAlpha(120),
      child: _buildNoteBodyColumn(),
    );
  }

  Widget _buildNoteBodyColumn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.noteData.note.title.isNotEmpty)
            Text(
              widget.noteData.note.title,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: _noteColors.onPrimaryContainer,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w600,
                  height: 1.5),
            ),
          if (widget.noteData.note.title.isNotEmpty && widget.noteData.note.content.isNotEmpty)
            const SizedBox(height: 4.0),
          if (widget.noteData.note.content.isNotEmpty) _buildPaintedNoteContent(),
          if (widget.noteData.note.tagIds.isNotEmpty) const SizedBox(height: 8.0),
          if (widget.noteData.note.tagIds.isNotEmpty) _buildTagWrap(),
        ],
      ),
    );
  }

  Widget _buildPaintedNoteContent() {
    return CustomPaint(
      foregroundPainter: _renderFade
          ? BottomFadingGradient(
              color: Color.alphaBlend(
                  _noteColors.primaryContainer.withAlpha(135), _noteColors.background))
          : null,
      child: LimitedBox(
        maxHeight: 240,
        child: _buildMarkdown(),
      ),
    );
  }

  Widget _buildMarkdown() {
    return VisibilityDetector(
      key: ValueKey<int>(widget.noteData.note.isarId),
      onVisibilityChanged: (VisibilityInfo info) {
        log('title: ${widget.noteData.note.title}, size: ${info.size}');
        if (info.size.height == 240.0 && !_renderFade) {
          setState(() {
            _renderFade = true;
          });
        } else if (info.size.height < 240.0 && _renderFade) {
          setState(() {
            _renderFade = false;
          });
        }
      },
      child: Markdown(
        padding: EdgeInsets.zero,
        controller: null,
        physics: const NeverScrollableScrollPhysics(),
        data: widget.noteData.note.content
            .substring(0, min(600, widget.noteData.note.content.length)),
        softLineBreak: true,
        shrinkWrap: true,
        bulletBuilder: (index, style) {
          switch (style) {
            case BulletStyle.orderedList:
              return Text(
                '${(index + 1).toString()}.',
                style: TextStyle(
                  color: _noteColors.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            case BulletStyle.unorderedList:
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _noteColors.onPrimaryContainer,
                  ),
                ),
              );
          }
        },
        styleSheet: MarkdownStyleSheet(
          a: TextStyle(
            color: _noteColors.primary,
          ),
          code: const TextStyle(
            backgroundColor: Colors.transparent,
            fontSize: 12.0,
            height: 1.3,
          ),
          codeblockPadding: const EdgeInsets.all(12.0),
          codeblockDecoration: BoxDecoration(
            color: _noteColors.background.withAlpha(200),
            borderRadius: BorderRadius.circular(16),
          ),
          p: TextStyle(
            color: _noteColors.onPrimaryContainer,
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
          ),
          h1: TextStyle(
            color: _noteColors.onPrimaryContainer,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          h2: TextStyle(
            color: _noteColors.onPrimaryContainer,
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
          ),
          h3: TextStyle(
            color: _noteColors.onPrimaryContainer,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTagWrap() {
    return Wrap(
      spacing: 5.0,
      runSpacing: 5.0,
      crossAxisAlignment: WrapCrossAlignment.start,
      alignment: WrapAlignment.start,
      children: widget.noteData.noteTags
          .map<Widget>(
            (tag) => Ink(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: _noteColors.primaryContainer.withAlpha(170),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  strokeAlign: BorderSide.strokeAlignInside,
                  color: _noteColors.onPrimaryContainer.withAlpha(100),
                  width: 0.25,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      tag.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _noteColors.onPrimaryContainer,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class BottomFadingGradient extends CustomPainter {
  final Color color;

  const BottomFadingGradient({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(
      Offset(-16, size.height - 32.0),
      Offset(size.width + 16, size.height + 0.5),
    );
    LinearGradient lg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withAlpha(0),
        color,
      ],
    );
    Paint paint = Paint()..shader = lg.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(BottomFadingGradient oldDelegate) => false;
}
