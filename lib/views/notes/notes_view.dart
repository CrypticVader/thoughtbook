import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thoughtbook/constants/preferences.dart';
import 'package:thoughtbook/constants/routes.dart';
import 'package:thoughtbook/enums/menu_action.dart';
import 'package:thoughtbook/extensions/buildContext/loc.dart';
import 'package:thoughtbook/extensions/buildContext/theme.dart';
import 'package:thoughtbook/helpers/preferences/layout_preferences.dart';
import 'package:thoughtbook/services/auth/auth_service.dart';
import 'package:thoughtbook/services/auth/bloc/auth_bloc.dart';
import 'package:thoughtbook/services/auth/bloc/auth_event.dart';
import 'package:thoughtbook/styles/text_styles.dart';
import 'package:thoughtbook/utilities/dialogs/delete_dialog.dart';
import 'package:thoughtbook/utilities/dialogs/logout_dialog.dart';
import 'package:thoughtbook/utilities/modals/show_color_picker_bottom_sheet.dart';
import 'package:thoughtbook/views/notes/notes_list_view.dart';
import 'package:thoughtbook/services/cloud/cloud_note.dart';
import 'package:thoughtbook/services/cloud/firestore_notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirestoreNoteService _notesService;

  String get userId => AuthService.firebase().currentUser!.id;
  List<CloudNote> _selectedNotes = [];

  @override
  void initState() {
    _notesService = FirestoreNoteService();
    LayoutPreferences.initLayoutPreference();
    super.initState();
  }

  Future<void> _onToggleLayout() async {
    setState(() {
      LayoutPreferences.toggleLayoutPreference();
    });
  }

  void _onTapNote(CloudNote note, void Function() openContainer) {
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
      return;
    } else {
      openContainer();
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

  Future<void> _onChangeNoteColor(CloudNote note, Color? color) async {
    await _notesService.updateNote(
      documentId: note.documentId,
      title: note.title,
      content: note.content,
      color: (color != null) ? color.value : null,
    );
  }

  Future<void> _onCopyNote({
    required BuildContext context,
    required CloudNote note,
  }) async {
    await Clipboard.setData(
      ClipboardData(text: '${note.title}\n${note.content}'),
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

  Future<void> _onDeleteNote({
    required BuildContext context,
    required CloudNote note,
  }) async {
    _notesService.deleteNote(
      documentId: note.documentId,
    );
    setState(
      () {
        _selectedNotes.remove(note);
      },
    );
  }

  Future<void> _onDeleteSelectedNotes() async {
    setState(
      () {
        for (var note in _selectedNotes) {
          _notesService.deleteNote(
            documentId: note.documentId,
          );
        }
        _selectedNotes = [];
      },
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      bloc.add(const AuthEventLogOut());
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

  Color? _getTileColor(BuildContext context) {
    if (_selectedNotes.isNotEmpty) {
      return context.theme.colorScheme.secondaryContainer;
    }
    return null;
  }

  AppBar _getDefaultAppBar(String layoutPreference) {
    return AppBar(
      key: ValueKey<bool>(_selectedNotes.isEmpty),
      toolbarHeight: 64,
      title: Text(
        context.loc.app_title,
        style: CustomTextStyle(context).appBarTitle,
      ),
      actions: [
        IconButton(
          onPressed: () => _onToggleLayout(),
          icon: Icon(
            (layoutPreference == listLayoutPref)
                ? Icons.grid_view_rounded
                : Icons.list_rounded,
          ),
          tooltip: layoutPreference == listLayoutPref
              ? context.loc.notes_view_grid_layout
              : context.loc.notes_view_list_layout,
        ),
        PopupMenuButton<MenuAction>(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                await _onLogout(context);
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded),
                    const SizedBox(
                      width: 16,
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
            ];
          },
        ),
      ],
    );
  }

  AppBar _getNotesSelectedAppBar() {
    return AppBar(
      key: ValueKey<bool>(_selectedNotes.isEmpty),
      toolbarHeight: 64,
      backgroundColor: _getTileColor(context),
      title: Text(
        context.loc.notes_title(
          _selectedNotes.length,
          context.loc.app_title,
        ),
        style: CustomTextStyle(context).appBarTitle,
      ),
      leading: IconButton(
        tooltip: context.loc.close,
        onPressed: () => _onClearSelectedNotes(),
        icon: const Icon(Icons.close_rounded),
      ),
      actions: [
        // TODO: Use valueListenableBuilder to update the actions depending on the number of items in SelectedNotes
        IconButton(
          tooltip: context.loc.select_all_notes,
          onPressed: _onSelectAllNotes,
          icon: const Icon(Icons.select_all_rounded),
        ),
        PopupMenuButton<MenuAction>(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(36.0)),
          onSelected: (value) async {
            switch (value) {
              case MenuAction.color:
                final note = _selectedNotes.first;
                final currentColor =
                    (note.color != null) ? Color(note.color!) : null;
                final color = await showColorPickerModalBottomSheet(
                  context: context,
                  currentColor: currentColor,
                );
                if (color != currentColor) {
                  _onChangeNoteColor(note, color);
                }
                setState(() {
                  _selectedNotes.removeAt(0);
                });
                break;
              case MenuAction.share:
                final note = _selectedNotes.first;
                Share.share(note.content);
                setState(() {
                  _selectedNotes.removeAt(0);
                });
                break;
              case MenuAction.delete:
                final shouldDelete = await showDeleteDialog(
                  context: context,
                  content: context.loc.delete_selected_notes_prompt(
                    _selectedNotes.length,
                  ),
                );
                if (shouldDelete) {
                  _onDeleteSelectedNotes();
                }
                break;
              case MenuAction.copy:
                final note = _selectedNotes.first;
                await _onCopyNote(
                  context: context,
                  note: note,
                );
                setState(() {
                  _selectedNotes.removeAt(0);
                });
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) {
            return [
              if (_selectedNotes.length == 1)
                PopupMenuItem<MenuAction>(
                  value: MenuAction.color,
                  child: Row(
                    children: [
                      const Icon(Icons.palette_rounded),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        context.loc.change_color,
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
                        width: 16,
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
                        width: 16,
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
              PopupMenuItem<MenuAction>(
                value: MenuAction.delete,
                child: Row(
                  children: [
                    const Icon(Icons.delete_rounded),
                    const SizedBox(
                      width: 16,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LayoutPreferences.getLayoutPreference(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData) {
              final layoutPref = snapshot.data!;
              return WillPopScope(
                onWillPop: () async {
                  if (_selectedNotes.isEmpty) {
                    return true;
                  } else {
                    _onClearSelectedNotes();
                    return false;
                  }
                },
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: (_selectedNotes.isEmpty)
                          ? _getDefaultAppBar(layoutPref)
                          : _getNotesSelectedAppBar(),
                    ),
                  ),
                  floatingActionButton: _selectedNotes.isEmpty
                      ? FloatingActionButton(
                          tooltip: context.loc.new_note,
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: {
                                'note': null,
                                'shouldAutofocus': true,
                              },
                            );
                          },
                          child: Icon(
                            Icons.add_rounded,
                            size: 42,
                            color: context.theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                  body: StreamBuilder(
                    stream: _notesService.allNotes(ownerUserId: userId),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes = snapshot.data!.toList();
                            return NotesListView(
                              layoutPreference: layoutPref,
                              notes: allNotes,
                              selectedNotes: _selectedNotes,
                              onDeleteNote: (note) => _onDeleteNote(
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
                ),
              );
            } else {
              return SpinKitChasingDots(
                color: context.theme.colorScheme.primary,
                size: 60,
              );
            }
          default:
            return SpinKitChasingDots(
              color: context.theme.colorScheme.primary,
              size: 60,
            );
        }
      },
    );
  }
}
