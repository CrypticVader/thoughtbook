import 'dart:developer' show log;

import 'package:animations/animations.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/dateTime/custom_format.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/tag_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/utilities/common_widgets/tonal_chip.dart';
import 'package:thoughtbook/src/utilities/dialogs/generic_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

typedef NoteCallback = void Function(LocalNote note);

class NoteEditorPage extends StatelessWidget {
  final LocalNote? note;
  final void Function(LocalNote) onDeleteNote;
  final bool shouldAutoFocusContent;

  const NoteEditorPage({
    super.key,
    required this.note,
    required this.onDeleteNote,
    required this.shouldAutoFocusContent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteEditorBloc>(
      create: (_) => NoteEditorBloc(),
      child: NoteEditorView(
        note: note,
        shouldAutoFocusContent: shouldAutoFocusContent,
        onDeleteNote: (note) => onDeleteNote(note),
      ),
    );
  }
}

class NoteEditorView extends StatefulWidget {
  /// This note is used to initialize the state of the [NoteEditorBloc]
  /// and it should not be used anywhere else.
  final LocalNote? note;
  final bool shouldAutoFocusContent;

  /// This callback, provided by [NotesView], will facilitate showing a [SnackBar]
  /// to undo the deletion, by adding a [NoteDeleteEvent] to the [NoteBloc] which is
  /// not accessible from this view's [context]
  final NoteCallback onDeleteNote;

  const NoteEditorView({
    required this.note,
    required this.shouldAutoFocusContent,
    required this.onDeleteNote,
    super.key,
  });

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late NoteEditorBloc noteEditorBloc;
  late final ScrollController _scrollController;
  late bool _isEditable;
  bool _showChipRow = true;
  bool _showAppBars = true;
  ColorScheme _noteColors = ColorScheme.fromSeed(
    seedColor: Colors.lime,
    brightness: SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
        ? Brightness.dark
        : Brightness.light,
  );

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _isEditable = widget.shouldAutoFocusContent;
    _scrollController = ScrollController();
    _scrollController.addListener(() => _scrollControllerListener());
  }

  void _scrollControllerListener() {
    final scrollOffset = _scrollController.offset;
    log(scrollOffset.toString());
    if (scrollOffset > 56.0 && _showChipRow) {
      setState(() {
        _showChipRow = false;
      });
    } else if (scrollOffset < 56.0 && !_showChipRow) {
      setState(() {
        _showChipRow = true;
      });
    }
  }

  Future<void> _updateNoteColor(LocalNote note) async {
    final currentColor = (note.color != null) ? Color(note.color!) : null;
    final newColor = await showColorPickerModalBottomSheet(
      context: context,
      currentColor: currentColor,
      colorScheme: _noteColors,
    );
    noteEditorBloc.add(NoteEditorUpdateColorEvent(newColor: newColor));
  }

  @override
  void didChangeDependencies() {
    noteEditorBloc = context.read<NoteEditorBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    noteEditorBloc.add(const NoteEditorCloseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteEditorBloc, NoteEditorState>(
      listener: (BuildContext context, NoteEditorState state) {
        if (state.snackBarText.isNotEmpty) {
          final snackBar = SnackBar(
            backgroundColor: _noteColors.tertiary,
            content: Text(
              state.snackBarText,
              style: TextStyle(
                color: _noteColors.onTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            dismissDirection: DismissDirection.startToEnd,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is NoteEditorDeleted) {
          Navigator.of(context).pop();
          widget.onDeleteNote(state.deletedNote);
        }
      },
      buildWhen: (previousState, currentState) {
        if ((currentState is NoteEditorInitialized) || (currentState is NoteEditorUninitialized)) {
          return true;
        } else {
          return false;
        }
      },
      builder: (BuildContext context, state) {
        if (state is NoteEditorUninitialized) {
          context.read<NoteEditorBloc>().add(NoteEditorInitializeEvent(note: widget.note));

          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is NoteEditorInitialized) {
          return StreamBuilder<PresentableNoteData>(
            stream: state.noteData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final PresentableNoteData noteData = snapshot.data!;
                    final note = noteData.note;
                    if (note.color != null) {
                      _noteColors = ColorScheme.fromSeed(
                        seedColor: Color(note.color!),
                        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
                      );
                    } else {
                      _noteColors = context.themeColors;
                    }

                    return Scaffold(
                      backgroundColor: Color.alphaBlend(
                        _noteColors.primaryContainer.withAlpha(70),
                        _noteColors.background,
                      ),
                      bottomNavigationBar: NoteEditorBottomAppBar(
                        state: state,
                        noteData: noteData,
                        colorScheme: _noteColors,
                        showWidget: _showAppBars,
                        isEditable: _isEditable,
                        onChangeColor: () async => _updateNoteColor(note),
                        onChangeEditorView: ({required bool isEditable}) => setState(() {
                          _isEditable = isEditable;
                        }),
                      ),
                      body: NestedScrollView(
                        floatHeaderSlivers: false,
                        physics: const NeverScrollableScrollPhysics(),
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            NoteEditorAppBar(
                              noteIsTrashed: note.isTrashed,
                              colorScheme: _noteColors,
                              showAppBar: _showAppBars,
                            ),
                            NoteEditorChipRow(
                              noteData: noteData,
                              state: state,
                              showWidget: _showAppBars && _showChipRow,
                              colorScheme: _noteColors,
                            ),
                          ];
                        },
                        body: AnimatedPadding(
                          duration: 300.milliseconds,
                          curve: Curves.ease,
                          padding: _showAppBars
                              ? const EdgeInsets.symmetric(horizontal: 10)
                              : EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius:
                                _showAppBars ? BorderRadius.circular(32) : BorderRadius.zero,
                            clipBehavior: Clip.hardEdge,
                            child: AnimatedContainer(
                              curve: Curves.ease,
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(
                                  _noteColors.primaryContainer.withAlpha(_isDarkMode ? 120 : 170),
                                  _noteColors.background,
                                ),
                              ),
                              constraints: const BoxConstraints.expand(),
                              duration: const Duration(milliseconds: 500),
                              child: NotificationListener<UserScrollNotification>(
                                onNotification: (notification) {
                                  ScrollDirection direction = notification.direction;
                                  if (notification.metrics.axis == Axis.horizontal) {
                                    return true;
                                  }
                                  if (direction == ScrollDirection.forward) {
                                    if (_showAppBars != true) {
                                      setState(() {
                                        _showAppBars = true;
                                      });
                                    }
                                  } else if (direction == ScrollDirection.reverse) {
                                    if (_showAppBars != false) {
                                      setState(() {
                                        _showAppBars = false;
                                      });
                                    }
                                  }
                                  return true;
                                },
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 48),
                                  controller: _scrollController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AnimatedPadding(
                                        duration: 300.milliseconds,
                                        curve: Curves.ease,
                                        padding: _showAppBars
                                            ? const EdgeInsets.symmetric(horizontal: 14)
                                            : const EdgeInsets.symmetric(horizontal: 24),
                                        child: AnimatedSwitcher(
                                          duration: 550.milliseconds,
                                          reverseDuration: 550.milliseconds,
                                          switchInCurve: Curves.fastOutSlowIn,
                                          switchOutCurve: Curves.fastOutSlowIn,
                                          layoutBuilder: (currentChild, previousChildren) {
                                            return Stack(
                                              alignment: Alignment.topLeft,
                                              children: <Widget>[
                                                ...previousChildren,
                                                if (currentChild != null) currentChild,
                                              ],
                                            );
                                          },
                                          transitionBuilder: (child, animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SizeTransition(
                                                axisAlignment: -1,
                                                sizeFactor: animation,
                                                axis: Axis.vertical,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: !_isEditable
                                              ? NoteReadableView(
                                                  title: note.title,
                                                  content: note.content,
                                                  noteColors: _noteColors,
                                                )
                                              : NoteEditableView(
                                                  initialData: (
                                                    title: note.title,
                                                    content: note.content
                                                  ),
                                                  updatedData: state.textFieldValues,
                                                  textColor: _noteColors.onSecondaryContainer,
                                                  shouldAutofocusContent:
                                                      widget.shouldAutoFocusContent,
                                                  onChange: ({required content, required title}) {
                                                    noteEditorBloc.add(NoteEditorUpdateEvent(
                                                      newTitle: title,
                                                      newContent: content,
                                                    ));
                                                  },
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 1,
                          ),
                          SpinKitDoubleBounce(
                            color: context.theme.colorScheme.primary,
                            size: 80,
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(
                            height: 48.0,
                          ),
                        ],
                      ),
                    );
                  }
                default:
                  return Center(
                    child: SpinKitDoubleBounce(
                      color: context.theme.colorScheme.primary,
                      size: 60,
                    ),
                  );
              }
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class NoteEditableView extends StatefulWidget {
  final ({String title, String content}) initialData;
  final ({String title, String content})? updatedData;
  final Color textColor;
  final bool shouldAutofocusContent;
  final void Function({
    required String content,
    required String title,
  }) onChange;

  const NoteEditableView({
    super.key,
    required this.textColor,
    required this.initialData,
    required this.updatedData,
    required this.shouldAutofocusContent,
    required this.onChange,
  });

  @override
  State<NoteEditableView> createState() => _NoteEditableViewState();
}

class _NoteEditableViewState extends State<NoteEditableView> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialData.title);
    contentController = TextEditingController(text: widget.initialData.content);

    titleController.addListener(() {
      widget.onChange(content: contentController.text, title: titleController.text);
    });
    contentController.addListener(() {
      widget.onChange(content: contentController.text, title: titleController.text);
    });
  }

  @override
  void didUpdateWidget(covariant NoteEditableView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.updatedData != null) && (widget.updatedData?.content != contentController.text)) {
      contentController.text = widget.updatedData!.content;
    }
    if ((widget.updatedData != null) && (widget.updatedData?.title != titleController.text)) {
      titleController.text = widget.updatedData!.title;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          autofocus: false,
          maxLines: null,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 26.0,
            height: 1.65,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Title',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 26.0,
              height: 1.65,
            ),
          ),
        ),
        TextField(
          autofocus: widget.shouldAutofocusContent,
          controller: contentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
            height: 1.5,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: context.loc.start_typing_your_note,
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}

class NoteReadableView extends StatelessWidget {
  final String title;
  final String content;
  final ColorScheme noteColors;

  const NoteReadableView({
    super.key,
    required this.title,
    required this.content,
    required this.noteColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
            child: Text(
              title,
              style: TextStyle(
                  color: noteColors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 26.0,
                  height: 1.65),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
          child: MarkdownBody(
            data: content,
            selectable: true,
            softLineBreak: true,
            onTapLink: (text, href, title) async {
              if (href != null) {
                await launchUrl(
                  Uri.parse(href),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            imageBuilder: (uri, title, alt) {
              // final asset = FadeInImage.assetNetwork(placeholder: placeholder, image: image)
              return OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 250),
                closedColor: Colors.transparent,
                closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                closedElevation: 4,
                openColor: noteColors.background,
                closedBuilder: (context, action) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      uri.toString(),
                      filterQuality: FilterQuality.low,
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        panEnabled: true,
                        scaleEnabled: true,
                        maxScale: 12,
                        minScale: 0.8,
                        child: Image.network(
                          uri.toString(),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        top: 48,
                        left: 12,
                        child: IconButton.filled(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            checkboxBuilder: (value) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 8, 0),
                child: Checkbox(
                  value: value,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    value = !value!;
                  },
                  checkColor: noteColors.onSecondary,
                  activeColor: noteColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(
                      color: noteColors.secondary,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      width: 10,
                    ),
                  ),
                ),
              );
            },
            bulletBuilder: (index, style) {
              switch (style) {
                case BulletStyle.orderedList:
                  return Text(
                    '${(index + 1).toString()}.',
                    style: TextStyle(
                      color: noteColors.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
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
                        color: noteColors.onSecondaryContainer,
                      ),
                    ),
                  );
              }
            },
            styleSheet: MarkdownStyleSheet(
              a: TextStyle(
                color: noteColors.primary,
                height: 1.5,
              ),
              code: const TextStyle(
                backgroundColor: Colors.transparent,
                fontSize: 14.0,
                height: 1.3,
              ),
              codeblockDecoration: BoxDecoration(
                color: noteColors.background.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
              ),
              codeblockPadding: const EdgeInsets.all(12.0),
              blockquoteDecoration: BoxDecoration(
                color: noteColors.primaryContainer.withAlpha(120),
                border: Border.all(
                  color: noteColors.onPrimaryContainer.withAlpha(70),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              blockquotePadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              p: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                height: 1.5,
              ),
              h1: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 22.0,
                height: 1.5,
              ),
              h2: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
                height: 1.5,
              ),
              h3: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                height: 1.5,
              ),
              blockquote: TextStyle(
                color: noteColors.onPrimaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NoteEditorAppBar extends StatelessWidget {
  final bool noteIsTrashed;
  final ColorScheme colorScheme;
  final bool showAppBar;

  const NoteEditorAppBar({
    super.key,
    required this.noteIsTrashed,
    required this.colorScheme,
    required this.showAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: 300.milliseconds,
        switchInCurve: Curves.easeInOutCirc,
        switchOutCurve: Curves.easeInOutCirc,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },
        child: showAppBar
            ? AppBar(
                surfaceTintColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: colorScheme.onSecondaryContainer,
                ),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  tooltip: 'Go back',
                  icon: const Icon(FluentIcons.chevron_left_28_filled),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.read<NoteEditorBloc>().add(const NoteEditorShareEvent()),
                        icon: const Icon(FluentIcons.share_24_regular),
                        tooltip: context.loc.share_note,
                      ),
                      IconButton(
                        tooltip: context.loc.copy_text,
                        onPressed: () =>
                            context.read<NoteEditorBloc>().add(const NoteEditorCopyEvent()),
                        icon: const Icon(FluentIcons.copy_24_regular),
                      ),
                      if (!(noteIsTrashed))
                        IconButton(
                          tooltip: context.loc.delete,
                          onPressed: () =>
                              context.read<NoteEditorBloc>().add(const NoteEditorDeleteEvent()),
                          icon: const Icon(FluentIcons.delete_24_regular),
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class NoteEditorBottomAppBar extends StatelessWidget {
  final PresentableNoteData noteData;
  final NoteEditorInitialized state;
  final ColorScheme colorScheme;
  final bool showWidget;
  final bool isEditable;
  final Future<void> Function() onChangeColor;
  final void Function({required bool isEditable}) onChangeEditorView;

  const NoteEditorBottomAppBar({
    super.key,
    required this.noteData,
    required this.state,
    required this.colorScheme,
    required this.showWidget,
    required this.isEditable,
    required this.onChangeColor,
    required this.onChangeEditorView,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 300.milliseconds,
      switchInCurve: Curves.easeInOutCirc,
      switchOutCurve: Curves.easeInOutCirc,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: showWidget
          ? BottomAppBar(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              elevation: 0,
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                    onPressed: state.canUndo
                        ? () => context.read<NoteEditorBloc>().add(NoteEditorUndoEvent(
                              currentTitle: noteData.note.title,
                              currentContent: noteData.note.content,
                            ))
                        : null,
                    icon: const Icon(FluentIcons.arrow_undo_24_filled),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      )),
                      disabledBackgroundColor: colorScheme.secondary.withAlpha(40),
                      backgroundColor: colorScheme.inversePrimary,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    onPressed: state.canRedo
                        ? () => context.read<NoteEditorBloc>().add(NoteEditorRedoEvent(
                              currentTitle: noteData.note.title,
                              currentContent: noteData.note.content,
                            ))
                        : null,
                    icon: const Icon(FluentIcons.arrow_redo_24_filled),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      )),
                      disabledBackgroundColor: colorScheme.secondary.withAlpha(40),
                      backgroundColor: colorScheme.inversePrimary,
                      foregroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(flex: 1),
                  IconButton(
                    tooltip: context.loc.change_color,
                    onPressed: noteData.note.isTrashed ? null : () async => await onChangeColor(),
                    icon: const Icon(FluentIcons.color_24_regular),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      foregroundColor: colorScheme.onSecondary,
                      backgroundColor: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    tooltip: 'Change tags',
                    onPressed: noteData.note.isTrashed
                        ? null
                        : () async => await showNoteTagPickerModalBottomSheet(
                              context: context,
                              noteStream: state.noteStream,
                              allNoteTags: state.allNoteTags,
                              onTapTag: (tag) => context
                                  .read<NoteEditorBloc>()
                                  .add(NoteEditorUpdateTagEvent(selectedTag: tag)),
                              colorScheme: colorScheme,
                            ),
                    icon: const Icon(FluentIcons.tag_24_regular),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      foregroundColor: colorScheme.onSecondary,
                      backgroundColor: colorScheme.secondary,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Opacity(
                    opacity: noteData.note.isTrashed ? 0.25 : 1,
                    child: IconButton.filled(
                      onPressed: noteData.note.isTrashed
                          ? null
                          : () => onChangeEditorView(isEditable: !isEditable),
                      tooltip: isEditable ? 'Read Note' : 'Edit note',
                      splashColor: colorScheme.inversePrimary.withAlpha(100),
                      icon: AnimatedSwitcher(
                        switchOutCurve: Curves.easeInQuad,
                        switchInCurve: Curves.easeOutQuad,
                        duration: 350.milliseconds,
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                        child: Icon(
                          isEditable
                              ? FluentIcons.notepad_28_filled
                              : FluentIcons.notepad_edit_20_filled,
                          key: ValueKey<bool>(isEditable),
                          size: 32,
                        ),
                      ),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}

class NoteEditorChipRow extends StatelessWidget {
  final PresentableNoteData noteData;
  final NoteEditorInitialized state;
  final ColorScheme colorScheme;
  final bool showWidget;

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  const NoteEditorChipRow({
    super.key,
    required this.noteData,
    required this.state,
    required this.colorScheme,
    required this.showWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: 300.milliseconds,
        switchInCurve: Curves.easeInOutCirc,
        switchOutCurve: Curves.easeInOutCirc,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: child,
            ),
          );
        },
        child: showWidget
            ? SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TonalChip(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onTap: () async {
                        if (!(noteData.note.isTrashed)) {
                          await showNoteTagPickerModalBottomSheet(
                            context: context,
                            noteStream: state.noteStream,
                            allNoteTags: state.allNoteTags,
                            onTapTag: (tag) => context
                                .read<NoteEditorBloc>()
                                .add(NoteEditorUpdateTagEvent(selectedTag: tag)),
                            colorScheme: colorScheme,
                          );
                        }
                      },
                      label: noteData.noteTags.isEmpty
                          ? 'No labels'
                          : noteData.noteTags.map((tag) => tag.name).join(', '),
                      textStyle: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontStyle: noteData.noteTags.isEmpty ? FontStyle.italic : FontStyle.normal,
                        fontWeight: FontWeight.w600,
                      ),
                      iconData: noteData.noteTags.isEmpty
                          ? FluentIcons.tag_dismiss_24_filled
                          : FluentIcons.tag_24_filled,
                      backgroundColor:
                          colorScheme.secondaryContainer.withAlpha(_isDarkMode ? 200 : 255),
                      borderColor: Colors.transparent,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      splashColor: colorScheme.secondary.withAlpha(50),
                    ),
                    const SizedBox(width: 8.0),
                    TonalChip(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onTap: () => showGenericDialog(
                        context: context,
                        title: 'Info',
                        icon: const Icon(
                          FluentIcons.book_clock_24_filled,
                          size: 40,
                        ),
                        body: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.themeColors.inversePrimary.withAlpha(100),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Last edited',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: context.themeColors.onPrimaryContainer.withAlpha(220),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    noteData.note.modified.customFormat(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.themeColors.onPrimaryContainer,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.themeColors.inversePrimary.withAlpha(100),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Created on',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: context.themeColors.onPrimaryContainer.withAlpha(220),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    noteData.note.created.customFormat(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.themeColors.onPrimaryContainer,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        optionsBuilder: () => {'OK': null},
                      ),
                      label: noteData.note.modified.customFormat(),
                      iconData: FluentIcons.book_clock_24_filled,
                      backgroundColor:
                          colorScheme.secondaryContainer.withAlpha(_isDarkMode ? 200 : 255),
                      foregroundColor: colorScheme.onSecondaryContainer,
                      borderColor: Colors.transparent,
                      splashColor: colorScheme.secondary.withAlpha(50),
                    ),
                    const SizedBox(width: 8.0),
                    TonalChip(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onTap: () => showGenericDialog(
                        context: context,
                        title: noteData.note.isSyncedWithCloud ? 'Backed Up' : 'Pending Sync',
                        icon: noteData.note.isSyncedWithCloud
                            ? const Icon(
                                Icons.cloud_done_rounded,
                                size: 40,
                              )
                            : const Icon(
                                Icons.cloud_upload_rounded,
                                size: 40,
                              ),
                        content: noteData.note.isSyncedWithCloud
                            ? 'This note is saved to the the '
                                'cloud & can be accessed'
                                ' by using your account.'
                            : 'Changes made to this note are '
                                'pending to be saved to the cloud, '
                                'but are safe on your device.'
                                ' We will save the changes when your '
                                'device is online.',
                        optionsBuilder: () => {'OK': null},
                      ),
                      label: noteData.note.isSyncedWithCloud ? 'Changes saved' : 'Changes unsaved',
                      iconData: noteData.note.isSyncedWithCloud
                          ? FluentIcons.cloud_checkmark_24_filled
                          : FluentIcons.cloud_arrow_up_24_filled,
                      backgroundColor:
                          colorScheme.secondaryContainer.withAlpha(_isDarkMode ? 200 : 255),
                      borderColor: Colors.transparent,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      splashColor: colorScheme.secondary.withAlpha(50),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
