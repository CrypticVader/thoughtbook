import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocConsumer, BlocProvider, ReadContext;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/note_crud/presentation/enums/menu_action.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/note_crud/presentation/notes_list_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/logout_dialog.dart';
import 'package:thoughtbook/src/utilities/modals/show_color_picker_bottom_sheet.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _onLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      bloc.add(const AuthEventLogOut());
    }
  }

  Color? _getTileColor({
    required BuildContext context,
    required NoteInitializedState state,
  }) {
    if (state.selectedNotes.isNotEmpty) {
      return context.theme.colorScheme.secondaryContainer;
    }
    return null;
  }

  AppBar _getDefaultAppBar(NoteInitializedState state) {
    final layoutPreference = state.layoutPreference;

    return AppBar(
      key: ValueKey<bool>(state.selectedNotes.isEmpty),
      toolbarHeight: kToolbarHeight,
      title: Text(
        context.loc.app_title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () =>
              context.read<NoteBloc>().add(const NoteToggleLayoutEvent()),
          icon: Icon(
            (layoutPreference == LayoutPreference.list.value)
                ? Icons.grid_view_rounded
                : Icons.list_rounded,
          ),
          tooltip: (layoutPreference == LayoutPreference.list.value)
              ? context.loc.notes_view_grid_layout
              : context.loc.notes_view_list_layout,
        ),
      ],
    );
  }

  AppBar _getNotesSelectedAppBar(NoteInitializedState state) {
    return AppBar(
      key: ValueKey<bool>(state.selectedNotes.isEmpty),
      toolbarHeight: kToolbarHeight,
      backgroundColor: _getTileColor(context: context, state: state),
      title: Text(
        context.loc.notes_title(
          state.selectedNotes.length,
          context.loc.app_title,
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      leading: IconButton(
        tooltip: context.loc.close,
        onPressed: () =>
            context.read<NoteBloc>().add(const NoteUnselectAllEvent()),
        icon: const Icon(Icons.close_rounded),
      ),
      actions: [
        // TODO: Use ValueListenableBuilder to update the actions depending on the number of items in SelectedNotes
        IconButton(
          tooltip: context.loc.select_all_notes,
          onPressed: () async => context.read<NoteBloc>().add(
                const NoteEventSelectAllNotes(),
              ),
          icon: const Icon(Icons.select_all_rounded),
        ),
        PopupMenuButton<MenuAction>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          onSelected: (value) async {
            switch (value) {
              case MenuAction.color:
                final note = state.selectedNotes.first;
                final currentColor =
                    (note.color != null) ? Color(note.color!) : null;
                final color = await showColorPickerModalBottomSheet(
                  context: context,
                  currentColor: currentColor,
                );
                context.read<NoteBloc>().add(
                      NoteUpdateColorEvent(
                        note: note,
                        color: (color != null) ? color.value : null,
                      ),
                    );
                break;
              case MenuAction.share:
                final note = state.selectedNotes.first;
                context.read<NoteBloc>().add(NoteShareEvent(note));
                break;
              case MenuAction.delete:
                context.read<NoteBloc>().add(
                      NoteDeleteEvent(
                        notes: state.selectedNotes,
                      ),
                    );
                break;
              case MenuAction.copy:
                final note = state.selectedNotes.first;
                context.read<NoteBloc>().add(NoteCopyEvent(note));
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) {
            return [
              if (state.selectedNotes.length == 1)
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
              if (state.selectedNotes.length == 1)
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
              if (state.selectedNotes.length == 1)
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
    return BlocConsumer<NoteBloc, NoteState>(
      listener: (context, state) async {
        if (state is NoteInitializedState) {
          // Show generic SnackBar
          if (state.snackBarText != null) {
            final snackBar = SnackBar(
              backgroundColor: context.theme.colorScheme.tertiary,
              content: Text(state.snackBarText!),
              dismissDirection: DismissDirection.startToEnd,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(4.0),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

          // Show SnackBar to undo note delete
          if (state.deletedNotes != null) {
            bool confirmDelete = true;

            final snackBar = SnackBar(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              backgroundColor: context.theme.colorScheme.tertiary,
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  Text(
                    context.loc.note_deleted,
                    style: TextStyle(
                      color: context.theme.colorScheme.onTertiary,
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(24.0),
                    onTap: () {
                      confirmDelete = false;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restore_rounded,
                            color: context.theme.colorScheme.onTertiary,
                            size: 22,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            context.loc.undo,
                            style: TextStyle(
                              color: context.theme.colorScheme.onTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              dismissDirection: DismissDirection.startToEnd,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(4.0),
            );
            await ScaffoldMessenger.of(context)
                .showSnackBar(snackBar)
                .closed
                .then((value) => confirmDelete);
            if (!confirmDelete) {
              context.read<NoteBloc>().add(
                  NoteUndoDeleteEvent(deletedNotes: state.deletedNotes ?? []));
            }
          }
        }
      },
      builder: (context, state) {
        if (state is NoteUninitializedState) {
          context.read<NoteBloc>().add(const NoteInitializeEvent());
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is NoteInitializedState) {
          return WillPopScope(
            onWillPop: () async {
              if (state.selectedNotes.isEmpty) {
                return true;
              } else {
                context.read<NoteBloc>().add(const NoteUnselectAllEvent());
                return false;
              }
            },
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: (state.selectedNotes.isEmpty)
                      ? _getDefaultAppBar(state)
                      : _getNotesSelectedAppBar(state),
                ),
              ),
              floatingActionButton: state.selectedNotes.isEmpty
                  ? OpenContainer(
                      tappable: false,
                      transitionDuration: const Duration(milliseconds: 320),
                      transitionType: ContainerTransitionType.fadeThrough,
                      openBuilder: (context, _) => BlocProvider<NoteEditorBloc>(
                        create: (BuildContext context) => NoteEditorBloc(),
                        child: NoteEditorView(
                            note: null,
                            shouldAutoFocusContent: true,
                            // TODO: This event will simply restore the note.
                            onNoteDelete: (note) => context
                                .read<NoteBloc>()
                                .add(NoteDeleteEvent(notes: [note]))),
                      ),
                      closedElevation: 6.0,
                      closedShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      closedColor: context.theme.colorScheme.primaryContainer,
                      openColor: Colors.grey,
                      closedBuilder: (context, openContainer) {
                        return FloatingActionButton(
                          elevation: 0.0,
                          onPressed: openContainer,
                          tooltip: context.loc.new_note,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 44,
                          ),
                        );
                      },
                    )
                  : null,
              drawer: Drawer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 48.0, 12.0, 32.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          context.loc.app_title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      if (state.user != null)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 28.0,
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(
                                    width: 8.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      state.user?.email ?? "",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w500,
                                        color: context.theme.colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              FilledButton.icon(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _onLogout(context);
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                ),
                                label: Text(
                                  context.loc.logout_button,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40.0)),
                              ),
                            ],
                          ),
                        ),
                      if (state.user == null)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context
                                .read<AuthBloc>()
                                .add(const AuthEventLogOut());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: context.theme.colorScheme.primary,
                            foregroundColor:
                                context.theme.colorScheme.onPrimary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login_rounded,
                              ),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                context.loc.login,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              body: StreamBuilder(
                stream: state.notes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.done:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data!;

                        return NotesListView(
                          layoutPreference: state.layoutPreference,
                          notes: allNotes,
                          selectedNotes: state.selectedNotes,
                          onDeleteNote: (LocalNote note) => context
                              .read<NoteBloc>()
                              .add(NoteDeleteEvent(notes: [note])),
                          onTap: (
                            LocalNote note,
                            void Function() openNote,
                          ) {
                            if (state.selectedNotes.isEmpty) {
                              openNote();
                            } else {
                              context.read<NoteBloc>().add(NoteTapEvent(
                                    note: note,
                                    selectedNotes: state.selectedNotes,
                                  ));
                            }
                          },
                          onLongPress: (LocalNote note) =>
                              context.read<NoteBloc>().add(NoteLongPressEvent(
                                    note: note,
                                    selectedNotes: state.selectedNotes,
                                  )),
                          onEditorNoteDelete: (note) => context
                              .read<NoteBloc>()
                              .add(NoteDeleteEvent(notes: [note])),
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
          context.read<NoteBloc>().add(const NoteInitializeEvent());
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
