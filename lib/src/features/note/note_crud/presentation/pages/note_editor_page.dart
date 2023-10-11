import 'dart:developer';

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

class NoteEditorPage extends StatefulWidget {
  /// This note is used to initialize the state of the [NoteEditorBloc]
  /// and it should not be used anywhere else.
  final LocalNote? note;
  final bool shouldAutoFocusContent;

  /// This callback, provided by [NotesView], will facilitate showing a [SnackBar]
  /// to undo the deletion, by adding a [NoteDeleteEvent] to the [NoteBloc] which is
  /// not accessible from this view's [context]
  final NoteCallback onDeleteNote;

  const NoteEditorPage({
    required this.note,
    required this.shouldAutoFocusContent,
    required this.onDeleteNote,
    Key? key,
  }) : super(key: key);

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _noteContentController;
  late final TextEditingController _noteTitleController;
  late NoteEditorBloc noteEditorBloc;
  late bool _isEditable;
  bool _showBottomBar = true;
  ColorScheme noteColors = ColorScheme.fromSeed(
    seedColor: Colors.grey,
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
    _noteContentController = TextEditingController(text: widget.note?.content ?? '');
    _noteTitleController = TextEditingController(text: widget.note?.title ?? '');
    _setupTextControllerListener();
  }

  void _noteControllerListener() {
    context.read<NoteEditorBloc>().add(
          NoteEditorUpdateEvent(
            newTitle: _noteTitleController.text,
            newContent: _noteContentController.text,
          ),
        );
  }

  void _setupTextControllerListener() {
    _noteContentController.removeListener(() => _noteControllerListener());
    _noteContentController.addListener(() => _noteControllerListener());
    _noteTitleController.removeListener(() => _noteControllerListener());
    _noteTitleController.addListener(() => _noteControllerListener());
  }

  Future<void> _updateNoteColor(LocalNote note) async {
    final currentColor = (note.color != null) ? Color(note.color!) : null;
    final editorBloc = context.read<NoteEditorBloc>();
    final newColor = await showColorPickerModalBottomSheet(
      context: context,
      currentColor: currentColor,
      colorScheme: noteColors,
    );
    editorBloc.add(NoteEditorUpdateColorEvent(newColor: newColor));
  }

  @override
  void didChangeDependencies() {
    noteEditorBloc = context.read<NoteEditorBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();

    noteEditorBloc.add(const NoteEditorCloseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteEditorBloc, NoteEditorState>(
      listener: (BuildContext context, NoteEditorState state) {
        if (state is NoteEditorInitialized && state.textFieldValues != null) {
          _noteTitleController.text = state.textFieldValues!.title;
          _noteContentController.text = state.textFieldValues!.content;
        }
        if (state.snackBarText.isNotEmpty) {
          final snackBar = SnackBar(
            backgroundColor: noteColors.tertiary,
            content: Text(
              state.snackBarText,
              style: TextStyle(
                color: noteColors.onTertiary,
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
                    log('rebuilt');
                    final PresentableNoteData noteData = snapshot.data!;
                    final note = noteData.note;
                    final tags = noteData.noteTags;
                    if (note.color != null) {
                      noteColors = ColorScheme.fromSeed(
                        seedColor: Color(note.color!),
                        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
                      );
                    } else {
                      if (_isDarkMode) {
                        noteColors = ColorScheme.fromSeed(
                          seedColor: Colors.grey,
                          brightness: Brightness.dark,
                        );
                      } else {
                        noteColors = ColorScheme.fromSeed(
                          seedColor: Colors.grey,
                          brightness: Brightness.light,
                        );
                      }
                    }
                    return Scaffold(
                      bottomNavigationBar: AnimatedSwitcher(
                        duration: 350.milliseconds,
                        switchInCurve: Curves.fastOutSlowIn,
                        switchOutCurve: Curves.fastOutSlowIn,
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          );
                        },
                        child: _showBottomBar
                            ? BottomAppBar(
                                height: kBottomNavigationBarHeight + 28,
                                padding: EdgeInsets.zero,
                                elevation: 2,
                                color: Color.alphaBlend(
                                  noteColors.inversePrimary.withAlpha(100),
                                  noteColors.surface,
                                ),
                                child: AnimatedContainer(
                                  duration: 500.milliseconds,
                                  curve: Curves.easeIn,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                    color: noteColors.primary.withAlpha(50),
                                    width: 0.5,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ))),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: state.canUndo
                                              ? () => context
                                                  .read<NoteEditorBloc>()
                                                  .add(NoteEditorUndoEvent(
                                                    currentTitle: _noteTitleController.text,
                                                    currentContent: _noteContentController.text,
                                                  ))
                                              : null,
                                          icon: const Icon(FluentIcons.arrow_undo_24_filled),
                                          style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                              topLeft: Radius.circular(24),
                                              bottomLeft: Radius.circular(24),
                                            )),
                                            disabledBackgroundColor:
                                                noteColors.secondary.withAlpha(40),
                                            backgroundColor: noteColors.inversePrimary,
                                            foregroundColor: noteColors.onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          onPressed: state.canRedo
                                              ? () => context
                                                  .read<NoteEditorBloc>()
                                                  .add(NoteEditorRedoEvent(
                                                    currentTitle: _noteTitleController.text,
                                                    currentContent: _noteContentController.text,
                                                  ))
                                              : null,
                                          icon: const Icon(FluentIcons.arrow_redo_24_filled),
                                          style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(24),
                                              bottomRight: Radius.circular(24),
                                              topLeft: Radius.circular(4),
                                              bottomLeft: Radius.circular(4),
                                            )),
                                            disabledBackgroundColor:
                                                noteColors.secondary.withAlpha(40),
                                            backgroundColor: noteColors.inversePrimary,
                                            foregroundColor: noteColors.onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Spacer(flex: 1),
                                        IconButton(
                                          tooltip: context.loc.change_color,
                                          onPressed: note.isTrashed
                                              ? null
                                              : () async => await _updateNoteColor(note),
                                          icon: const Icon(FluentIcons.color_24_regular),
                                          style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                            foregroundColor: noteColors.onSecondary,
                                            backgroundColor: noteColors.secondary,
                                          ),
                                        ),
                                        const Spacer(flex: 1),
                                        Opacity(
                                          opacity: note.isTrashed ? 0.25 : 1,
                                          child: IconButton.filled(
                                            onPressed: note.isTrashed
                                                ? null
                                                : () => setState(() {
                                                      _isEditable = !_isEditable;
                                                    }),
                                            tooltip: _isEditable ? 'Read Note' : 'Edit note',
                                            splashColor: noteColors.inversePrimary.withAlpha(100),
                                            icon: AnimatedSwitcher(
                                              switchOutCurve: Curves.easeInQuad,
                                              switchInCurve: Curves.easeOutQuad,
                                              duration: 350.milliseconds,
                                              transitionBuilder: (child, animation) =>
                                                  ScaleTransition(
                                                scale: animation,
                                                child: FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                ),
                                              ),
                                              child: Icon(
                                                _isEditable
                                                    ? FluentIcons.notepad_28_filled
                                                    : FluentIcons.notepad_edit_20_filled,
                                                key: ValueKey<bool>(_isEditable),
                                                size: 32,
                                              ),
                                            ),
                                            style: IconButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(18)),
                                              padding: const EdgeInsets.all(12),
                                              backgroundColor: noteColors.primary,
                                              foregroundColor: noteColors.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      body: NestedScrollView(
                        floatHeaderSlivers: true,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: AnimatedContainer(
                                color: innerBoxIsScrolled
                                    ? Color.alphaBlend(
                                        context.theme.colorScheme.onSurfaceVariant.withAlpha(30),
                                        Color.alphaBlend(
                                          noteColors.inversePrimary.withAlpha(100),
                                          noteColors.surface,
                                        ),
                                      )
                                    : Color.alphaBlend(
                                        noteColors.inversePrimary.withAlpha(100),
                                        noteColors.surface,
                                      ),
                                duration: const Duration(milliseconds: 500),
                                child: AppBar(
                                  surfaceTintColor: Colors.transparent,
                                  iconTheme: IconThemeData(
                                    color: noteColors.onSecondaryContainer,
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
                                          onPressed: () => context
                                              .read<NoteEditorBloc>()
                                              .add(const NoteEditorShareEvent()),
                                          icon: const Icon(FluentIcons.share_24_regular),
                                          tooltip: context.loc.share_note,
                                        ),
                                        IconButton(
                                          tooltip: context.loc.copy_text,
                                          onPressed: () => context
                                              .read<NoteEditorBloc>()
                                              .add(const NoteEditorCopyEvent()),
                                          icon: const Icon(FluentIcons.copy_24_regular),
                                        ),
                                        if (!(note.isTrashed))
                                          IconButton(
                                            tooltip: context.loc.delete,
                                            onPressed: () => context
                                                .read<NoteEditorBloc>()
                                                .add(const NoteEditorDeleteEvent()),
                                            icon: const Icon(FluentIcons.delete_24_regular),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ];
                        },
                        body: AnimatedContainer(
                          color: Color.alphaBlend(
                            noteColors.inversePrimary.withAlpha(100),
                            noteColors.surface,
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
                                if (_showBottomBar != true) {
                                  setState(() {
                                    _showBottomBar = true;
                                  });
                                }
                              } else if (direction == ScrollDirection.reverse) {
                                if (_showBottomBar != false) {
                                  setState(() {
                                    _showBottomBar = false;
                                  });
                                }
                              }
                              return true;
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          TonalChip(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            onTap: () async {
                                              if (!(note.isTrashed)) {
                                                await showNoteTagPickerModalBottomSheet(
                                                  context: context,
                                                  noteStream: state.noteStream,
                                                  allNoteTags: state.allNoteTags,
                                                  onTapTag: (tag) => context
                                                      .read<NoteEditorBloc>()
                                                      .add(NoteEditorUpdateTagEvent(
                                                          selectedTag: tag)),
                                                  colorScheme: noteColors,
                                                );
                                              }
                                            },
                                            label: tags.isEmpty
                                                ? 'No labels'
                                                : tags.map((tag) => tag.name).join(', '),
                                            textStyle: TextStyle(
                                              color: noteColors.onSecondaryContainer,
                                              fontStyle: tags.isEmpty
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            iconData: tags.isEmpty
                                                ? FluentIcons.tag_dismiss_24_filled
                                                : FluentIcons.tag_24_filled,
                                            backgroundColor: noteColors.secondaryContainer,
                                            foregroundColor: noteColors.onSecondaryContainer,
                                            splashColor: noteColors.secondary,
                                          ),
                                          const SizedBox(width: 8.0),
                                          TonalChip(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
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
                                                      color: context.themeColors.inversePrimary
                                                          .withAlpha(100),
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(20),
                                                        topRight: Radius.circular(20),
                                                        bottomLeft: Radius.circular(4),
                                                        bottomRight: Radius.circular(4),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.stretch,
                                                      children: [
                                                        Text(
                                                          'Last edited',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            color: context
                                                                .themeColors.onPrimaryContainer
                                                                .withAlpha(220),
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          note.modified.customFormat(),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            color: context
                                                                .themeColors.onPrimaryContainer,
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
                                                      color: context.themeColors.inversePrimary
                                                          .withAlpha(100),
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(4),
                                                        topRight: Radius.circular(4),
                                                        bottomLeft: Radius.circular(20),
                                                        bottomRight: Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.stretch,
                                                      children: [
                                                        Text(
                                                          'Created on',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            color: context
                                                                .themeColors.onPrimaryContainer
                                                                .withAlpha(220),
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        Text(
                                                          note.created.customFormat(),
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            color: context
                                                                .themeColors.onPrimaryContainer,
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
                                            label: note.modified.customFormat(),
                                            iconData: FluentIcons.book_clock_24_filled,
                                            backgroundColor: noteColors.secondaryContainer,
                                            foregroundColor: noteColors.onSecondaryContainer,
                                            splashColor: noteColors.secondary,
                                          ),
                                          const SizedBox(width: 8.0),
                                          TonalChip(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            onTap: () => showGenericDialog(
                                              context: context,
                                              title: note.isSyncedWithCloud
                                                  ? 'Backed Up'
                                                  : 'Pending Sync',
                                              icon: note.isSyncedWithCloud
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
                                            label: note.isSyncedWithCloud
                                                ? 'Changes saved'
                                                : 'Changes unsaved',
                                            iconData: note.isSyncedWithCloud
                                                ? FluentIcons.cloud_checkmark_24_filled
                                                : FluentIcons.cloud_arrow_up_24_filled,
                                            backgroundColor: noteColors.secondaryContainer,
                                            foregroundColor: noteColors.onSecondaryContainer,
                                            splashColor: noteColors.secondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 48.0),
                                    child: AnimatedSwitcher(
                                      duration: 400.milliseconds,
                                      reverseDuration: 500.milliseconds,
                                      switchInCurve: Curves.fastOutSlowIn,
                                      switchOutCurve: Curves.fastOutSlowIn.flipped,
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
                                              noteColors: noteColors,
                                            )
                                          : NoteEditableView(
                                              textColor: noteColors.onSecondaryContainer,
                                              titleController: _noteTitleController,
                                              contentController: _noteContentController,
                                              shouldAutofocusContent: widget.shouldAutoFocusContent,
                                            ),
                                    ),
                                  ),
                                ],
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
  final Color textColor;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool shouldAutofocusContent;

  const NoteEditableView({
    super.key,
    required this.textColor,
    required this.titleController,
    required this.contentController,
    required this.shouldAutofocusContent,
  });

  @override
  State<NoteEditableView> createState() => _NoteEditableViewState();
}

class _NoteEditableViewState extends State<NoteEditableView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.titleController,
          textInputAction: TextInputAction.next,
          autofocus: false,
          maxLines: null,
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 25.0,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Title',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 25.0,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          autofocus: widget.shouldAutofocusContent,
          controller: widget.contentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
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
            padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
            child: Text(
              title,
              style: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 25.0,
              ),
            ),
          ),
        if (title.isNotEmpty)
          const SizedBox(
            height: 8.0,
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
