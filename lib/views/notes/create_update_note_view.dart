import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/auth/auth_service.dart';
import 'package:thoughtbook/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:thoughtbook/utilities/generics/get_arguments.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/services/cloud/firebase_cloud_storage.dart';
import 'package:thoughtbook/utilities/modals/show_color_picker_bottom_sheet.dart';

typedef NoteCallback = void Function(CloudNote note);

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _noteContentController;
  late final TextEditingController _noteTitleController;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _notesService = FirebaseCloudStorage();
    _noteContentController = TextEditingController();
    _noteTitleController = TextEditingController();
  }

  void _noteControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final title = _noteTitleController.text;
    final content = _noteContentController.text;
    await _notesService.updateNote(
      title: title,
      content: content,
      documentId: note.documentId,
      color: note.color,
    );
  }

  void _setupTextControllerListener() {
    _noteContentController.removeListener(_noteControllerListener);
    _noteContentController.addListener(_noteControllerListener);
    _noteTitleController.removeListener(_noteControllerListener);
    _noteTitleController.addListener(_noteControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final CloudNote? widgetNote = context.getArgument<Map>()!['note'];

    // widgetNote can be outdated & saveOnExit will end up updating the note to this outdated version
    // The below check prevents that
    if (_note == null) {
      if (widgetNote != null) {
        _note = widgetNote;
        _noteTitleController.text = widgetNote.title;
        _noteContentController.text = widgetNote.content;
        return widgetNote;
      }
    }
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_noteContentController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final title = _noteTitleController.text;
    final content = _noteContentController.text;
    if (note != null && content.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        content: content,
        title: title,
        color: note.color,
      );
    }
  }

  Color _getNoteColor(BuildContext context) {
    final note = _note;
    if (note != null) {
      if (note.color != null) {
        return Color(note.color!);
      }
    }
    return context.theme.colorScheme.surfaceVariant;
  }

  void _updateNoteColor() async {
    CloudNote note = _note!;
    final currentColor = (note.color != null) ? Color(note.color!) : null;
    final color = await showColorPickerModalBottomSheet(
      context: context,
      currentColor: currentColor,
    );
    note = await _notesService.updateNote(
          documentId: note.documentId,
          color: (color != null) ? color.value : null,
          title: note.title,
          content: note.content,
        ) ??
        note;
    setState(() {
      _note = note;
    });
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldAutofocus =
        context.getArgument<Map>()?['shouldAutofocus'] ?? true;
    _isDarkMode =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    return FutureBuilder(
      future: createOrGetExistingNote(context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.done:
            _setupTextControllerListener();

            return Scaffold(
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: _isDarkMode
                      ? Colors.white.withAlpha(200)
                      : Colors.black.withAlpha(200),
                ),
                backgroundColor: _getNoteColor(context).withAlpha(90),
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  // TODO: Use FadeTransition
                  Container(
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: context.loc.change_color,
                          onPressed: () => _updateNoteColor(),
                          icon: const Icon(Icons.palette_rounded),
                        ),
                        IconButton(
                          onPressed: () async {
                            final title = _noteTitleController.text;
                            final content = _noteContentController.text;
                            if (_note == null || content.isEmpty) {
                              await showCannotShareEmptyNoteDialog(context);
                            } else {
                              Share.share('$title\n$content');
                            }
                          },
                          icon: const Icon(Icons.share_rounded),
                          tooltip: context.loc.share_note,
                        ),
                        IconButton(
                          tooltip: context.loc.copy_text,
                          onPressed: () {},
                          icon: const Icon(Icons.copy_rounded),
                        ),
                        IconButton(
                          tooltip: context.loc.delete,
                          onPressed: () {},
                          icon: const Icon(Icons.delete_rounded),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                ],
              ),
              body: Container(
                color: _getNoteColor(context).withAlpha(90),
                constraints: const BoxConstraints.expand(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _noteTitleController,
                          textInputAction: TextInputAction.next,
                          autofocus: false,
                          maxLines: null,
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.white.withAlpha(220)
                                : Colors.black.withAlpha(220),
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
                          autofocus: shouldAutofocus,
                          controller: _noteContentController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.white.withAlpha(220)
                                : Colors.black.withAlpha(220),
                            fontWeight: FontWeight.w400,
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                            hintText: context.loc.start_typing_your_note,
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
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
  }
}
