import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/constants/routes.dart';
import 'package:thoughtbook/enums/menu_action.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/services/auth/auth_service.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/styles/text_styles.dart';
import 'package:thoughtbook/utilities/dialogs/delete_dialog.dart';
import 'package:thoughtbook/utilities/dialogs/logout_dialog.dart';
import 'package:thoughtbook/views/notes/notes_list_view.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/services/cloud/firebase_cloud_storage.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  List<CloudNote> _selectedNotes = [];

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  void _onTapNote(CloudNote note) async {
    if (_selectedNotes.contains(note)) {
      setState(
        () {
          _selectedNotes.remove(note);
        },
      );
      return;
    } else if (_selectedNotes.isNotEmpty) {
      setState(
        () {
          _selectedNotes.add(note);
        },
      );
    } else {
      Navigator.of(context).pushNamed(
        createOrUpdateNoteRoute,
        arguments: note,
      );
    }
  }

  void _onLongPressNote(CloudNote note) {
    if (_selectedNotes.contains(note)) {
      setState(
        () {
          _selectedNotes.remove(note);
        },
      );
    } else {
      setState(
        () {
          _selectedNotes.add(note);
        },
      );
    }
  }

  Future<void> _onCopyNote({
    required BuildContext context,
    required CloudNote note,
  }) async {
    await Clipboard.setData(
      ClipboardData(text: note.text),
    ).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              context.loc.note_copied,
            ),
            dismissDirection: DismissDirection.startToEnd,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteNotes({
    required BuildContext context,
    required List<CloudNote> notes,
  }) async {
    final shouldDelete = await showDeleteDialog(context);
    //TODO: State changes aren't being notified properly here
    if (shouldDelete) {
      for (var note in notes) {
        await _notesService.deleteNote(
          documentId: note.documentId,
        );
        _selectedNotes.remove(note);
      }
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      context.read<AuthBloc>().add(const AuthEventLogOut());
    }
  }

  void _onClearSelectedNotes() {
    setState(
      () => _selectedNotes = [],
    );
  }

  void _onSelectAllNotes() async {
    final allNotes = await _notesService.allNotes(ownerUserId: userId).first;
    setState(() {
      for (var element in allNotes) {
        if (!_selectedNotes.contains(element)) {
          _selectedNotes.add(element);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.notes_title(
            _selectedNotes.length,
            context.loc.app_title,
          ),
          style: CustomTextStyle(context).appBarTitle,
        ),
        actions: [
          // TODO: Use valueListenableBuilder to update the actions depending on the number of items in SelectedNotes
          if (_selectedNotes.isEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 28,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      context.loc.note,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedNotes.isNotEmpty)
            IconButton(
              tooltip: context.loc.select_all_notes,
              onPressed: _onSelectAllNotes,
              icon: const Icon(Icons.select_all_rounded),
            ),
          if (_selectedNotes.isNotEmpty)
            IconButton(
              tooltip: context.loc.clear_selection,
              onPressed: _onClearSelectedNotes,
              icon: const Icon(Icons.clear_all_rounded),
            ),
          PopupMenuButton<MenuAction>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  await _onLogout(context);
                  break;
                case MenuAction.share:
                  Share.share(_selectedNotes.first.text);
                  break;
                case MenuAction.delete:
                  // TODO: Broken when deleting multiple notes
                  await _onDeleteNotes(
                    context: context,
                    notes: _selectedNotes,
                  );
                  break;
                case MenuAction.copy:
                  await _onCopyNote(
                    context: context,
                    note: _selectedNotes.first,
                  );
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                if (_selectedNotes.isEmpty)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          context.loc.logout_button,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedNotes.length == 1)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.share,
                    child: Row(
                      children: [
                        const Icon(Icons.share_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          context.loc.share_note,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedNotes.length == 1)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.copy,
                    child: Row(
                      children: [
                        const Icon(Icons.copy_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          context.loc.copy_text,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedNotes.isNotEmpty)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.delete,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_rounded),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          context.loc.delete,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  selectedNotes: _selectedNotes,
                  onDeleteNote: (notes) => _onDeleteNotes(
                    notes: notes,
                    context: context,
                  ),
                  onCopyNote: (note) => _onCopyNote(
                    note: note,
                    context: context,
                  ),
                  onTap: _onTapNote,
                  onLongPress: _onLongPressNote,
                );
              } else {
                return Center(
                  child: Text(
                    context.loc.notes_view_create_note_to_see_here,
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
      ),
    );
  }
}
