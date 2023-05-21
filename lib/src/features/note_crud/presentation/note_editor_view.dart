import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/dateTime/custom_format.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/utilities/modals/show_color_picker_bottom_sheet.dart';

typedef NoteCallback = void Function(LocalNote note);

class NoteEditorView extends StatefulWidget {
  /// This note is used to initialize the state of the [NoteEditorBloc]
  /// and it should not be used anywhere else.
  final LocalNote? note;
  final bool shouldAutoFocusContent;

  /// This callback, provided by [NotesView], will facilitate showing a [SnackBar]
  /// to undo the deletion, by adding a [NoteDeleteEvent] to the [NoteBloc] which is
  /// not accessible from this view's [context]
  final NoteCallback onNoteDelete;

  const NoteEditorView({
    required this.note,
    required this.shouldAutoFocusContent,
    required this.onNoteDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late final TextEditingController _noteContentController;
  late final TextEditingController _noteTitleController;
  late NoteEditorBloc noteEditorBlocAccess;

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void initState() {
    super.initState();
    _noteContentController =
        TextEditingController(text: widget.note?.content ?? "");
    _noteTitleController =
        TextEditingController(text: widget.note?.title ?? "");
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

  Color _getNoteColor(BuildContext context, LocalNote note) {
    if (note.color != null) {
      return Color(note.color!);
    } else {
      return Colors.grey;
    }
  }

  Future<void> _updateNoteColor(LocalNote note) async {
    final currentColor = (note.color != null) ? Color(note.color!) : null;
    final newColor = await showColorPickerModalBottomSheet(
      context: context,
      currentColor: currentColor,
    );
    context
        .read<NoteEditorBloc>()
        .add(NoteEditorUpdateColorEvent(newColor: newColor));
  }

  Color _getNoteTextColor() {
    if (_isDarkMode) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  @override
  void didChangeDependencies() {
    noteEditorBlocAccess = context.read<NoteEditorBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();

    noteEditorBlocAccess.add(const NoteEditorCloseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteEditorBloc, NoteEditorState>(
      listener: (BuildContext context, NoteEditorState state) {
        if (state is NoteEditorWithSnackbarState) {
          final snackBar = SnackBar(
            backgroundColor: context.theme.colorScheme.tertiary,
            content: Text(state.snackBarText),
            dismissDirection: DismissDirection.startToEnd,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is NoteEditorDeletedState) {
          Navigator.of(context).pop();
          widget.onNoteDelete(state.deletedNote);
        }
      },
      buildWhen: (previousState, currentState) {
        if ((currentState is NoteEditorInitializedState) ||
            (currentState is NoteEditorUninitializedState)) {
          return true;
        } else {
          return false;
        }
      },
      builder: (BuildContext context, state) {
        if (state is NoteEditorUninitializedState) {
          context
              .read<NoteEditorBloc>()
              .add(NoteEditorInitializeEvent(note: widget.note));

          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is NoteEditorInitializedState) {
          log("Editor bloc initialized");

          return StreamBuilder<LocalNote>(
            stream: state.noteStream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final LocalNote note = snapshot.data!;
                    log("Note stream event");
                    return Scaffold(
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: AnimatedContainer(
                          color: _getNoteColor(context, note).withAlpha(90),
                          duration: const Duration(milliseconds: 300),
                          child: AppBar(
                            iconTheme: IconThemeData(
                              color: _getNoteTextColor().withAlpha(200),
                            ),
                            backgroundColor: Colors.transparent,
                            leading: IconButton(
                              icon: const Icon(CupertinoIcons.back),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            actions: [
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: context.loc.change_color,
                                    onPressed: () async =>
                                        await _updateNoteColor(note),
                                    icon: const Icon(Icons.palette_rounded),
                                  ),
                                  IconButton(
                                    onPressed: () => context
                                        .read<NoteEditorBloc>()
                                        .add(const NoteEditorShareEvent()),
                                    icon: const Icon(Icons.share_rounded),
                                    tooltip: context.loc.share_note,
                                  ),
                                  IconButton(
                                    tooltip: context.loc.copy_text,
                                    onPressed: () => context
                                        .read<NoteEditorBloc>()
                                        .add(const NoteEditorCopyEvent()),
                                    icon: const Icon(Icons.copy_rounded),
                                  ),
                                  IconButton(
                                    tooltip: context.loc.delete,
                                    onPressed: () => context
                                        .read<NoteEditorBloc>()
                                        .add(const NoteEditorDeleteEvent()),
                                    icon: const Icon(Icons.delete_rounded),
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
                      body: AnimatedContainer(
                        color: _getNoteColor(context, note).withAlpha(90),
                        constraints: const BoxConstraints.expand(),
                        duration: const Duration(milliseconds: 300),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isDarkMode
                                            ? Colors.black.withAlpha(40)
                                            : Colors.white.withAlpha(60),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.date_range_rounded,
                                            size: 16,
                                            color: _getNoteTextColor()
                                                .withAlpha(220),
                                          ),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            note.modified.customFormat(),
                                            style: TextStyle(
                                              color: _getNoteTextColor()
                                                  .withAlpha(200),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: _isDarkMode
                                            ? Colors.black.withAlpha(40)
                                            : Colors.white.withAlpha(60),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            note.isSyncedWithCloud
                                                ? Icons.sync_rounded
                                                : Icons.sync_disabled_rounded,
                                            size: 16,
                                            color: _getNoteTextColor()
                                                .withAlpha(220),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            note.isSyncedWithCloud
                                                ? "Synced with the cloud"
                                                : "Not synced with the cloud",
                                            style: TextStyle(
                                              color: _getNoteTextColor()
                                                  .withAlpha(220),
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                TextField(
                                  controller: _noteTitleController,
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  maxLines: null,
                                  style: TextStyle(
                                    color: _getNoteTextColor().withAlpha(220),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24.0,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Title',
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextField(
                                  autofocus: widget.shouldAutoFocusContent,
                                  controller: _noteContentController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  style: TextStyle(
                                    color: _getNoteTextColor().withAlpha(220),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        context.loc.start_typing_your_note,
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
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
