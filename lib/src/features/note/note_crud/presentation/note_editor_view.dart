import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/show_color_picker_bottom_sheet.dart';

typedef NoteCallback = void Function(LocalNote note);

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
    Key? key,
  }) : super(key: key);

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late final TextEditingController _noteContentController;
  late final TextEditingController _noteTitleController;
  late NoteEditorBloc noteEditorBlocAccess;
  ColorScheme noteColors = ColorScheme.fromSeed(
    seedColor: Colors.grey,
    brightness:
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? Brightness.dark
            : Brightness.light,
  );

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void initState() {
    super.initState();
    _noteContentController =
        TextEditingController(text: widget.note?.content ?? '');
    _noteTitleController =
        TextEditingController(text: widget.note?.title ?? '');
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
        if (state.snackBarText.isNotEmpty) {
          final snackBar = SnackBar(
            backgroundColor: context.theme.colorScheme.tertiary,
            content: Text(state.snackBarText),
            dismissDirection: DismissDirection.startToEnd,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is NoteEditorDeletedState) {
          Navigator.of(context).pop();
          widget.onDeleteNote(state.deletedNote);
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
          log('Editor bloc initialized');

          return StreamBuilder<LocalNote>(
            stream: state.noteStream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final LocalNote note = snapshot.data!;
                    final bool isEditable = state.isEditable;
                    noteColors = ColorScheme.fromSeed(
                      seedColor: getNoteColor(context, note),
                      brightness:
                          _isDarkMode ? Brightness.dark : Brightness.light,
                    );

                    log('Note stream event');
                    return Scaffold(
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: AnimatedContainer(
                          color: noteColors.primaryContainer.withAlpha(200),
                          duration: const Duration(milliseconds: 500),
                          child: AppBar(
                            iconTheme: IconThemeData(
                              color: noteColors.onBackground.withAlpha(200),
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
                      floatingActionButton: FloatingActionButton.extended(
                        onPressed: () => context.read<NoteEditorBloc>().add(
                              NoteEditorChangeViewTypeEvent(
                                wasEditable: isEditable,
                              ),
                            ),
                        backgroundColor: noteColors.tertiaryContainer,
                        tooltip: isEditable ? 'Preview Note' : 'Edit note',
                        label: isEditable
                            ? const Text('Preview')
                            : const Text('Edit'),
                        foregroundColor: noteColors.onTertiaryContainer,
                        icon: Icon(
                          isEditable
                              ? Icons.preview_rounded
                              : Icons.edit_rounded,
                          color: noteColors.onTertiaryContainer,
                        ),
                      ),
                      body: AnimatedContainer(
                        color: noteColors.primaryContainer.withAlpha(200),
                        constraints: const BoxConstraints.expand(),
                        duration: const Duration(milliseconds: 500),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 54),
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
                                            color: noteColors.onBackground
                                                .withAlpha(220),
                                          ),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            note.modified.customFormat(),
                                            style: TextStyle(
                                              color: noteColors.onBackground
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
                                            color: noteColors.onBackground
                                                .withAlpha(220),
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            note.isSyncedWithCloud
                                                ? 'Synced with the cloud'
                                                : 'Not synced with the cloud',
                                            style: TextStyle(
                                              color: noteColors.onBackground
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
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.ease,
                                  switchOutCurve: Curves.ease,
                                  child: isEditable
                                      ? NoteEditableView(
                                          key: const ValueKey<bool>(true),
                                          textColor:
                                              noteColors.onSecondaryContainer,
                                          titleController: _noteTitleController,
                                          contentController:
                                              _noteContentController,
                                          shouldAutofocusContent:
                                              widget.shouldAutoFocusContent,
                                        )
                                      : NoteReadableView(
                                          key: const ValueKey<bool>(false),
                                          title: note.title,
                                          content: note.content,
                                          textColor:
                                              noteColors.onSecondaryContainer,
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

class NoteEditableView extends StatelessWidget {
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
            color: textColor,
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
          autofocus: shouldAutofocusContent,
          controller: contentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            color: textColor,
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
  final Color textColor;

  const NoteReadableView({
    super.key,
    required this.title,
    required this.content,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 25.0,
            ),
          ),
        ),
        const SizedBox(
          height: 8.0,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
          child: MarkdownBody(
            data: content,
            selectable: true,
            softLineBreak: true,
            imageBuilder: (uri, title, alt) {
              // final asset = FadeInImage.assetNetwork(placeholder: placeholder, image: image)
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: kElevationToShadow[2]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    uri.toString(),
                    filterQuality: FilterQuality.high,
                  ),
                ),
              );
            },
            checkboxBuilder: (value) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Checkbox(
                  value: value,
                  activeColor: textColor,
                  onChanged: (value) {
                    value = !value!;
                  },
                  checkColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: textColor,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      width: 10,
                    ),
                  ),
                ),
              );
            },
            styleSheet: MarkdownStyleSheet(
              code: TextStyle(
                color: textColor,
                backgroundColor: Colors.transparent,
                fontSize: 14.0,
                height: 1.3,
              ),
              codeblockDecoration: BoxDecoration(
                color: Colors.black.withAlpha(70),
                borderRadius: BorderRadius.circular(16),
              ),
              codeblockPadding: const EdgeInsets.all(12.0),
              p: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                height: 1.5,
              ),
              h1: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 22.0,
                height: 1.5,
              ),
              h2: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 20.0,
                height: 1.5,
              ),
              h3: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 18.0,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
