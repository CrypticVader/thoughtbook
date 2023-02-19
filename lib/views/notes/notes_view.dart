import 'package:flutter/material.dart';
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
  List<CloudNote> selectedNotes = [];

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.loc.app_title,
          style: CustomTextStyle(context).appBarTitle,
        ),
        actions: [
          // TODO: Use valueListenableBuilder to update the actions depending on the number of items in SelectedNotes
          if (selectedNotes.isEmpty)
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
          PopupMenuButton<MenuAction>(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
                case MenuAction.share:
                  Share.share(selectedNotes.first.text);
              }
            },
            itemBuilder: (context) {
              return [
                if (selectedNotes.isEmpty)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.logout_rounded),
                        const SizedBox(
                          width: 6,
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
                if (selectedNotes.length == 1)
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.share,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Icons.share_rounded),
                        const SizedBox(
                          width: 6,
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
                  selectedNotes: selectedNotes,
                  onDeleteNote: (note) async {
                    _notesService.deleteNote(
                      documentId: note.documentId,
                    );
                  },
                  onTap: (note) {
                    if (selectedNotes.contains(note)) {
                      setState(
                        () {
                          selectedNotes.remove(note);
                        },
                      );
                      return;
                    } else {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    }
                  },
                  onLongPress: (note) {
                    if (selectedNotes.contains(note)) {
                      setState(
                        () {
                          selectedNotes.remove(note);
                        },
                      );
                    } else {
                      setState(
                        () {
                          selectedNotes.add(note);
                        },
                      );
                    }
                  },
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
