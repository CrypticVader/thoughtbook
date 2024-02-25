import 'dart:async' show unawaited;
import 'dart:math' show min;

import 'package:animations/animations.dart';
import 'package:dartx/dartx.dart';
import 'package:entry/entry.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/curves/material_3.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/pages/note_editor_page.dart'
    show NoteEditorPage;
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/sliver_notes_grid.dart'
    show NoteCallback, NoteDataCallback;

class NoteTile extends StatefulWidget {
  final Animation<double> animation;
  final PresentableNoteData noteData;
  final bool isVisible;
  final bool isSelected;
  final NoteDataCallback onDeleteNote;
  final void Function(LocalNote note, void Function() openContainer) onTap;
  final NoteCallback onLongPress;
  final bool enableDismissible;
  final int gridCrossAxisCount;
  final int index;

  const NoteTile({
    super.key,
    required this.animation,
    required this.noteData,
    required this.isVisible,
    required this.isSelected,
    required this.onDeleteNote,
    required this.onTap,
    required this.onLongPress,
    required this.enableDismissible,
    required this.gridCrossAxisCount,
    required this.index,
  });

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  double _noteOpacity = 1.0;
  bool _hasVibrated = false;
  DismissDirection _dismissDirection = DismissDirection.endToStart;
  ColorScheme _noteColors = ColorScheme.fromSeed(seedColor: Colors.grey);

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

    // Since grouping notes isn't possible in grid layout, there won't be any need for the transition
    if (widget.gridCrossAxisCount > 1) {
      return Entry.all(
        visible: true,
        delay: Duration(milliseconds: min(400, 50 * widget.index + 100)),
        duration: const Duration(milliseconds: 250),
        opacity: 0,
        scale: 0.9,
        curve: M3Easings.emphasized,
        yOffset: 0.0,
        xOffset: 0.0,
        child: _buildDismissible(),
      );
    } else {
      // This check is done as an optimization
      // Using transitions for every item slows the build significantly
      if (widget.index > 10) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Entry.all(
            visible: true,
            delay: Duration(milliseconds: min(400, 50 * widget.index + 100)),
            duration: const Duration(milliseconds: 250),
            opacity: 0,
            scale: 0.9,
            curve: M3Easings.emphasized,
            yOffset: 0.0,
            xOffset: 0.0,
            child: _buildDismissible(),
          ),
        );
      } else {
        return FadeTransition(
          opacity: widget.animation,
          child: SizeTransition(
            sizeFactor: widget.animation,
            axis: Axis.vertical,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 0),
              child: ClipRRect(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(24),
                child: Entry.all(
                  visible: true,
                  delay: Duration(milliseconds: min(400, 50 * widget.index + 100)),
                  duration: const Duration(milliseconds: 250),
                  opacity: 0,
                  scale: 0.9,
                  curve: M3Easings.emphasized,
                  yOffset: 0.0,
                  xOffset: 0.0,
                  child: _buildDismissible(),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  Widget _buildDismissible() {
    return Dismissible(
      key: ValueKey<int>(widget.noteData.note.isarId),
      onUpdate: (details) async {
        final direction = details.direction;
        if (_dismissDirection != direction) {
          setState(() {
            _dismissDirection = direction;
          });
        }
        setState(() {
          _noteOpacity = 1.0 - details.progress;
        });
        if (!_hasVibrated && details.progress >= 0.4) {
          unawaited(HapticFeedback.selectionClick());
          _hasVibrated = true;
        } else if (_hasVibrated && details.progress < 0.4) {
          unawaited(HapticFeedback.selectionClick());
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
      background: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 32),
            if (_dismissDirection == DismissDirection.startToEnd)
              AnimatedScale(
                duration: 250.milliseconds,
                curve: Curves.ease,
                scale: _noteOpacity < 0.6 ? 1.5 : 1,
                child: Icon(
                  FluentIcons.delete_32_filled,
                  color: _noteColors.error.withOpacity(_noteOpacity < 0.6 ? 1 : 0.5),
                  size: 36,
                ),
              ),
            const Spacer(flex: 1),
            if (_dismissDirection == DismissDirection.endToStart)
              AnimatedScale(
                duration: 250.milliseconds,
                curve: Curves.ease,
                scale: _noteOpacity < 0.6 ? 1.5 : 1,
                child: Icon(
                  FluentIcons.delete_32_filled,
                  color: _noteColors.error.withOpacity(_noteOpacity < 0.6 ? 1 : 0.5),
                  size: 36,
                ),
              ),
            const SizedBox(width: 32),
          ],
        ),
      ),
      child: _buildAnimatedOpacity(),
    );
  }

  Widget _buildAnimatedOpacity() {
    return AnimatedOpacity(
      opacity: _noteOpacity,
      duration: const Duration(milliseconds: 25),
      child: NoteOpenContainer(
        colorScheme: _noteColors,
        noteData: widget.noteData,
        isNoteSelected: widget.isSelected,
        onTap: (openContainer) => widget.onTap(widget.noteData.note, openContainer),
        onLongPress: () => widget.onLongPress(widget.noteData.note),
        onDeleteNote: () => widget.onDeleteNote(widget.noteData),
      ),
    );
  }
}

class NoteTagsWrap extends StatelessWidget {
  final List<LocalNoteTag> tags;
  final ColorScheme colorScheme;

  const NoteTagsWrap({
    super.key,
    required this.tags,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        children: tags
            .map<Widget>(
              (tag) => Ink(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceTint.withAlpha(25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        tag.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontSize: 14.0,
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
    );
  }
}

class NoteMaskedContent extends StatelessWidget {
  final LocalNote note;
  final ColorScheme colorScheme;
  final void Function() onTap;

  const NoteMaskedContent({
    super.key,
    required this.note,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      key: ValueKey<int>(note.isarId),
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
        child: Markdown(
          padding: EdgeInsets.zero,
          controller: null,
          physics: const NeverScrollableScrollPhysics(),
          data: note.content.substring(0, min(600, note.content.length)),
          onTapLink: (_, __, ___) => onTap(),
          softLineBreak: true,
          shrinkWrap: true,
          bulletBuilder: (index, style) {
            switch (style) {
              case BulletStyle.orderedList:
                return Text(
                  '${(index + 1).toString()}.',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
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
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                );
            }
          },
          imageBuilder: (uri, title, alt) {
            // final asset = FadeInImage.assetNetwork(placeholder: placeholder, image: image)
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                uri.toString(),
                filterQuality: FilterQuality.low,
              ),
            );
          },
          checkboxBuilder: (value) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
              child: Checkbox(
                value: value,
                visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (_) {},
                checkColor: colorScheme.onPrimary,
                activeColor: colorScheme.primary,
                side: BorderSide(width: 1.5, strokeAlign: -2, color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide.none,
                ),
              ),
            );
          },
          styleSheet: MarkdownStyleSheet(
            a: TextStyle(
              color: colorScheme.primary,
            ),
            code: const TextStyle(
              backgroundColor: Colors.transparent,
              fontSize: 12.0,
              height: 1.3,
            ),
            codeblockPadding: const EdgeInsets.all(12.0),
            codeblockDecoration: BoxDecoration(
              color: colorScheme.background.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
            ),
            blockquoteDecoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(120),
              border: Border.all(
                color: colorScheme.onPrimaryContainer.withAlpha(70),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            blockquotePadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            p: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
            h1: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
            h2: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
            ),
            h3: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            blockquote: TextStyle(
              color: colorScheme.onPrimaryContainer,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class NoteBody extends StatelessWidget {
  final ColorScheme colorScheme;
  final PresentableNoteData noteData;
  final void Function() onTap;

  const NoteBody(
      {super.key, required this.noteData, required this.colorScheme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (noteData.note.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                noteData.note.title,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 19.0,
                    fontWeight: FontWeight.w600,
                    height: 1.5),
              ),
            ),
          if (noteData.note.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: NoteMaskedContent(
                note: noteData.note,
                colorScheme: colorScheme,
                onTap: () => onTap(),
              ),
            ),
          if (noteData.note.tagIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: NoteTagsWrap(
                tags: noteData.noteTags,
                colorScheme: colorScheme,
              ),
            ),
        ],
      ),
    );
  }
}

class TappableNote extends StatelessWidget {
  final ColorScheme colorScheme;
  final PresentableNoteData noteData;
  final void Function() onTap;
  final void Function() onLongPress;

  const TappableNote({
    super.key,
    required this.colorScheme,
    required this.noteData,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onLongPress: () => onLongPress(),
      onTap: () => onTap(),
      splashColor: colorScheme.primary.withAlpha(30),
      highlightColor: Colors.transparent,
      child: NoteBody(
        noteData: noteData,
        colorScheme: colorScheme,
        onTap: () => onTap(),
      ),
    );
  }
}

class NoteOpenContainer extends StatelessWidget {
  final PresentableNoteData noteData;
  final ColorScheme colorScheme;
  final bool isNoteSelected;
  final void Function(void Function() openContainer) onTap;
  final void Function() onLongPress;
  final void Function() onDeleteNote;

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  const NoteOpenContainer({
    super.key,
    required this.colorScheme,
    required this.noteData,
    required this.isNoteSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      tappable: false,
      transitionDuration: const Duration(milliseconds: 300),
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: Color.alphaBlend(
        colorScheme.primaryContainer.withAlpha(_isDarkMode ? 120 : 170),
        context.themeColors.background,
      ),
      middleColor: Color.alphaBlend(
        colorScheme.primaryContainer.withAlpha(_isDarkMode ? 120 : 170),
        colorScheme.background,
      ),
      openColor: Color.alphaBlend(
        colorScheme.primaryContainer.withAlpha(_isDarkMode ? 120 : 170),
        colorScheme.background,
      ),
      useRootNavigator: true,
      closedShape: RoundedRectangleBorder(
        side: isNoteSelected
            ? BorderSide(
                width: 3,
                color: context.theme.colorScheme.tertiary,
                strokeAlign: BorderSide.strokeAlignInside,
              )
            : BorderSide.none,
        borderRadius: BorderRadius.circular(26),
      ),
      closedBuilder: (context, openContainer) {
        return TappableNote(
          colorScheme: colorScheme,
          noteData: noteData,
          onTap: () => onTap(openContainer),
          onLongPress: () => onLongPress(),
        );
      },
      openBuilder: (context, closeContainer) {
        return NoteEditorPage(
          note: noteData.note,
          shouldAutoFocusContent: false,
          onDeleteNote: (_) => onDeleteNote(),
        );
      },
    );
  }
}
