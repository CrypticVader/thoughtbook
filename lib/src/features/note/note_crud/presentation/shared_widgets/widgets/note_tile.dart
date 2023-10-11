import 'dart:async';
import 'dart:math' show min;

import 'package:animations/animations.dart';
import 'package:entry/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/pages/note_editor_page.dart'
    show NoteEditorPage;
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/notes_list_view.dart'
    show NoteCallback, NoteDataCallback;

class NoteTile extends StatefulWidget {
  final PresentableNoteData noteData;
  final bool isSelected;
  final NoteDataCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final bool enableDismissible;
  final int index;

  const NoteTile({
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
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  late void Function() _openContainer;
  double _noteOpacity = 1.0;
  bool _hasVibrated = false;
  ColorScheme _noteColors = ColorScheme.fromSeed(seedColor: Colors.grey);
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (widget.noteData.note.color != null) {
      _noteColors = ColorScheme.fromSeed(
        seedColor: Color(widget.noteData.note.color!),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      );
    } else {
      _noteColors = context.themeColors;
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
        borderRadius: BorderRadius.circular(24),
      ),
      closedBuilder: (context, openContainer) {
        _openContainer = openContainer;
        return _buildInkWell();
      },
      openBuilder: (context, closeContainer) {
        return BlocProvider<NoteEditorBloc>(
          create: (context) => NoteEditorBloc(),
          child: NoteEditorPage(
            note: widget.noteData.note,
            shouldAutoFocusContent: false,
            onDeleteNote: (_) async {
              await Future.delayed(const Duration(milliseconds: 300));
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
      borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      key: ValueKey<int>(widget.noteData.note.isarId),
      shaderCallback: (Rect bounds) {
        const color = Colors.black;
        final lg = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withAlpha((bounds.height >= 240.0) ? 0 : 255)],
        );
        final shaderBounds = (bounds.height >= 240.0)
            ? Rect.fromLTRB(bounds.left, bounds.bottom - 32, bounds.right, bounds.bottom)
            : bounds;
        return lg.createShader(shaderBounds);
      },
      child: LimitedBox(
        maxHeight: 240,
        child: _buildMarkdown(),
      ),
    );
  }

  Widget _buildMarkdown() {
    return ClipRect(
      child: Markdown(
        padding: EdgeInsets.zero,
        controller: null,
        physics: const NeverScrollableScrollPhysics(),
        data:
            widget.noteData.note.content.substring(0, min(600, widget.noteData.note.content.length)),
        onTapLink: (_, __, ___) => widget.onTap(widget.noteData.note, _openContainer),
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
          blockquoteDecoration: BoxDecoration(
            color: _noteColors.primaryContainer.withAlpha(120),
            border: Border.all(
              color: _noteColors.onPrimaryContainer.withAlpha(70),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          blockquotePadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
          blockquote: TextStyle(
            color: _noteColors.onPrimaryContainer,
            height: 1.5,
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
