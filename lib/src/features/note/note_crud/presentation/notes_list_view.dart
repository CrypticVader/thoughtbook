import 'dart:async';
import 'dart:math';

import 'package:after_layout/after_layout.dart';
import 'package:animations/animations.dart';
import 'package:entry/entry.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
            borderRadius:
                SmoothBorderRadius(cornerRadius: 40, cornerSmoothing: 1),
          ),
          child: UnconstrainedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.note_add_48_filled,
                  size: 150,
                  color: context.theme.colorScheme.onSecondaryContainer
                      .withAlpha(150),
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
                      color: context.theme.colorScheme.onSecondaryContainer
                          .withAlpha(220),
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
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 16.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final noteData = widget.notesData.elementAt(index);
          return NoteItem(
            // key: ValueKey<int>(noteData.note.isarId),
            noteData: noteData,
            isSelected: widget.selectedNotes.contains(noteData.note),
            onTap: (note, openContainer) => widget.onTap(note, openContainer),
            onLongPress: (note) => widget.onLongPress(note),
            onDeleteNote: (noteData) {
              setState(() {
                widget.notesData.remove(noteData); /**/
              });
              widget.onDeleteNote(noteData.note);
            },
            enableDismissible:
                widget.selectedNotes.isEmpty && widget.isDismissible,
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

class _NoteItemState extends State<NoteItem> with AfterLayoutMixin<NoteItem> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;
  bool hasVibrated = false;
  ColorScheme noteColors = ColorScheme.fromSeed(
    seedColor: Colors.grey,
    brightness:
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? Brightness.dark
            : Brightness.light,
  );
  bool isVisible = true;
  GlobalKey mdKey = GlobalKey();
  bool _renderFade = false;

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
  FutureOr<void> afterFirstLayout(BuildContext context) {
    debugPrint((mdKey.currentContext?.size?.height).toString());
    final renderFade =
        (((mdKey.currentContext?.size?.height) ?? 0) >= 240) ? true : false;
    setState(() {
      _renderFade = renderFade;
    });
  }

  @override
  Widget build(BuildContext context) {
    noteColors = ColorScheme.fromSeed(
      seedColor: getNoteColor(context, widget.noteData.note),
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    return Entry.all(
      visible: isVisible,
      delay: Duration(milliseconds: min(250, 25 * widget.index + 10)),
      duration: const Duration(milliseconds: 220),
      opacity: 0,
      scale: 0.95,
      curve: Curves.easeInOutExpo,
      yOffset: 0.0,
      xOffset: 0.0,
      child: Dismissible(
        key: ValueKey<int>(widget.noteData.note.isarId),
        onUpdate: (details) async {
          setState(() {
            _noteOpacity = 1.0 - details.progress;
          });
          if (!hasVibrated && details.progress >= 0.4) {
            unawaited(HapticFeedback.mediumImpact());
            hasVibrated = true;
          } else if (hasVibrated && details.progress < 0.4) {
            unawaited(HapticFeedback.mediumImpact());
            hasVibrated = false;
          }
        },
        direction: widget.enableDismissible
            ? DismissDirection.horizontal
            : DismissDirection.none,
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
        child: AnimatedOpacity(
          opacity: _noteOpacity,
          duration: const Duration(milliseconds: 15),
          child: OpenContainer(
            tappable: false,
            transitionDuration: const Duration(milliseconds: 250),
            transitionType: ContainerTransitionType.fadeThrough,
            closedElevation: 0,
            openElevation: 0,
            closedColor: Color.alphaBlend(
                noteColors.primaryContainer.withAlpha(135),
                noteColors.background),
            middleColor: Color.alphaBlend(
                noteColors.primaryContainer.withAlpha(135),
                noteColors.background),
            openColor: Color.alphaBlend(
                noteColors.primaryContainer.withAlpha(135),
                noteColors.background),
            useRootNavigator: true,
            closedShape: RoundedRectangleBorder(
              side: widget.isSelected
                  ? BorderSide(
                      width: 3,
                      color: context.theme.colorScheme.tertiary,
                    )
                  : BorderSide.none,
              borderRadius:
                  BorderRadius.circular(24),
            ),
            closedBuilder: (context, openContainer) {
              _openContainer = openContainer;
              return InkWell(
                borderRadius:
                BorderRadius.circular(24),
                onLongPress: () => widget.onLongPress(widget.noteData.note),
                onTap: () => widget.onTap(widget.noteData.note, _openContainer),
                splashColor: noteColors.inversePrimary.withAlpha(135),
                highlightColor: noteColors.inversePrimary.withAlpha(170),
                child: Ink(
                  padding: const EdgeInsets.all(16.0),
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
                            color: noteColors.onPrimaryContainer,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (widget.noteData.note.title.isNotEmpty &&
                          widget.noteData.note.content.isNotEmpty)
                        const SizedBox(
                          height: 8.0,
                        ),
                      if (widget.noteData.note.content.isNotEmpty)
                        CustomPaint(
                          foregroundPainter: _renderFade
                              ? FadingEffect(
                                  color: Color.alphaBlend(
                                      noteColors.primaryContainer
                                          .withAlpha(135),
                                      noteColors.background),
                                )
                              : null,
                          child: LimitedBox(
                            maxHeight: 240,
                            child: Markdown(
                              key: mdKey,
                              padding: EdgeInsets.zero,
                              controller: null,
                              physics: const NeverScrollableScrollPhysics(),
                              data: widget.noteData.note.content.substring(
                                  0,
                                  min(650,
                                      widget.noteData.note.content.length)),
                              softLineBreak: true,
                              shrinkWrap: true,
                              bulletBuilder: (index, style) {
                                switch (style) {
                                  case BulletStyle.orderedList:
                                    return Text(
                                      '${(index + 1).toString()}.',
                                      style: TextStyle(
                                        color: noteColors.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  case BulletStyle.unorderedList:
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 12, 10, 8),
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: noteColors.onPrimaryContainer,
                                        ),
                                      ),
                                    );
                                }
                              },
                              styleSheet: MarkdownStyleSheet(
                                a: TextStyle(
                                  color: noteColors.primary,
                                ),
                                code: const TextStyle(
                                  backgroundColor: Colors.transparent,
                                  fontSize: 12.0,
                                  height: 1.3,
                                ),
                                codeblockPadding: const EdgeInsets.all(12.0),
                                codeblockDecoration: BoxDecoration(
                                  color: noteColors.background.withAlpha(200),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                p: TextStyle(
                                  color: noteColors.onPrimaryContainer,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                ),
                                h1: TextStyle(
                                  color: noteColors.onPrimaryContainer,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                h2: TextStyle(
                                  color: noteColors.onPrimaryContainer,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                h3: TextStyle(
                                  color: noteColors.onPrimaryContainer,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.noteData.note.tagIds.isNotEmpty)
                        const SizedBox(
                          height: 8.0,
                        ),
                      if (widget.noteData.note.tagIds.isNotEmpty)
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          alignment: WrapAlignment.start,
                          children: widget.noteData.noteTags
                              .map<Widget>(
                                (tag) => Ink(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: noteColors.tertiaryContainer
                                        .withAlpha(200),
                                    borderRadius: SmoothBorderRadius(
                                        cornerRadius: 12, cornerSmoothing: 1),
                                    border: Border.all(
                                      strokeAlign: BorderSide.strokeAlignInside,
                                      color: noteColors.onTertiaryContainer
                                          .withAlpha(60),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 120),
                                        child: Text(
                                          tag.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color:
                                                noteColors.onTertiaryContainer,
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
                        ),
                    ],
                  ),
                ),
              );
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
                      isVisible = false;
                    });
                    await Future.delayed(const Duration(milliseconds: 150));
                    widget.onDeleteNote(widget.noteData);
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

class FadingEffect extends CustomPainter {
  final Color color;

  const FadingEffect({
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
  bool shouldRepaint(FadingEffect oldDelegate) => false;
}
