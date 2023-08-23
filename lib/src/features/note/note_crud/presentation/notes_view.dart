import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocConsumer, BlocProvider, ReadContext;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_filter_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_group_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_sort_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_tag_editor_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/common_widgets/tonal_chip.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/menu_action.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/notes_list_view.dart';
import 'package:thoughtbook/src/features/settings/presentation/settings_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/logout_dialog.dart';

class NotesView extends StatelessWidget {
  const NotesView({Key? key}) : super(key: key);

  Future<void> _onLogout(BuildContext context) async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      context.read<AuthBloc>().add(const AuthEventLogOut());
    }
  }

  Color? _getTileColor({
    required BuildContext context,
    required NoteInitializedState state,
  }) {
    if (state.selectedNotes.isNotEmpty) {
      return Color.alphaBlend(
        context.themeColors.primaryContainer.withAlpha(100),
        context.themeColors.background,
      );
    }
    return null;
  }

  SliverAppBar _getDefaultAppBar(
    BuildContext context,
    NoteInitializedState state,
    bool isScrolled,
  ) {
    final layoutPreference = state.layoutPreference;

    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      backgroundColor: Color.alphaBlend(
        context.themeColors.surfaceVariant.withAlpha(isScrolled ? 85 : 0),
        context.themeColors.background,
      ),
      surfaceTintColor: Colors.transparent,
      key: ValueKey<bool>(state.selectedNotes.isEmpty),
      leadingWidth: kMinInteractiveDimension,
      titleSpacing: 16.0,
      automaticallyImplyLeading: false,
      title: TextField(
        onChanged: (value) =>
            context.read<NoteBloc>().add(NoteSearchEvent(query: value)),
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: context.themeColors.onSecondaryContainer,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: context.themeColors.onSecondaryContainer.withAlpha(150),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.all(12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              strokeAlign: BorderSide.strokeAlignInside,
              width: 1,
              color: context.themeColors.onBackground.withAlpha(80),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide.none,
          ),
          fillColor: Color.alphaBlend(
            context.themeColors.primary.withAlpha(isScrolled ? 40 : 25),
            context.themeColors.background,
          ),
          filled: true,
          prefixIconColor: context.themeColors.secondary,
          suffixIconColor: context.themeColors.secondary,
          prefixIcon: IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded),
          ),
          suffixIcon: IconButton(
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
          hintText: 'Search your notes & tags',
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kMinInteractiveDimension + 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 16.0,
                ),
                TonalChip(
                  onTap: () async =>
                      await showNoteFilterPickerBottomSheet(context),
                  label: 'All notes',
                  iconData: Icons.filter_list_rounded,
                ),
                const SizedBox(
                  width: 8,
                ),
                TonalChip(
                  onTap: () async =>
                      await showNoteSortModePickerBottomSheet(context),
                  label: 'Date created',
                  iconData: Icons.sort_rounded,
                ),
                const SizedBox(
                  width: 8,
                ),
                TonalChip(
                  onTap: () async =>
                      await showNoteGroupModePickerBottomSheet(context),
                  label: 'Ungrouped',
                  iconData: Icons.category_rounded,
                ),
                const SizedBox(
                  width: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotesSelectedAppBar(
      BuildContext context, NoteInitializedState state) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      key: ValueKey<bool>(state.selectedNotes.isEmpty),
      // snap: true,
      // floating: true,
      pinned: true,
      backgroundColor: _getTileColor(context: context, state: state),
      title: Text(
        context.loc.notes_title(
          state.selectedNotes.length,
          context.loc.app_title,
        ),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: context.themeColors.onBackground,
        ),
      ),
      leading: IconButton(
        tooltip: context.loc.close,
        onPressed: () =>
            context.read<NoteBloc>().add(const NoteUnselectAllEvent()),
        icon: const Icon(Icons.close_rounded),
      ),
      actions: [
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
                final noteBloc = context.read<NoteBloc>();
                final color = await showColorPickerModalBottomSheet(
                  context: context,
                  currentColor: currentColor,
                );
                noteBloc.add(
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
              backgroundColor: context.themeColors.tertiary,
              content: Text(
                state.snackBarText!,
                style: TextStyle(
                  color: context.themeColors.onTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              dismissDirection: DismissDirection.startToEnd,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(32),
              ),
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
              backgroundColor: context.themeColors.tertiary,
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  Text(
                    context.loc.note_deleted,
                    style: TextStyle(
                      color: context.themeColors.onTertiary,
                      fontWeight: FontWeight.w500,
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
                            color: context.themeColors.onTertiary,
                          ),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            context.loc.undo,
                            style: TextStyle(
                              color: context.themeColors.onTertiary,
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
              shape: RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.circular(32),
              ),
              margin: const EdgeInsets.all(8.0),
            );
            final noteBloc = context.read<NoteBloc>();
            await ScaffoldMessenger.of(context)
                .showSnackBar(snackBar)
                .closed
                .then((value) => confirmDelete);
            if (!confirmDelete) {
              noteBloc.add(
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
              floatingActionButton: state.selectedNotes.isEmpty
                  ? OpenContainer(
                      tappable: false,
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionType: ContainerTransitionType.fadeThrough,
                      // Using the openBuilder's context results in scope error
                      // when accessing the NoteBloc
                      openBuilder: (_, __) => BlocProvider<NoteEditorBloc>(
                        create: (context) => NoteEditorBloc(),
                        child: NoteEditorView(
                          note: null,
                          shouldAutoFocusContent: true,
                          onDeleteNote: (note) => context
                              .read<NoteBloc>()
                              .add(NoteDeleteEvent(notes: [note])),
                        ),
                      ),
                      closedElevation: 8.0,
                      closedShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      closedColor: context.themeColors.primaryContainer,
                      middleColor: context.themeColors.secondaryContainer,
                      openColor: context.themeColors.secondaryContainer,
                      closedBuilder: (context, openContainer) {
                        return FloatingActionButton(
                          elevation: 0.0,
                          focusElevation: 0.0,
                          hoverElevation: 0.0,
                          highlightElevation: 0.0,
                          onPressed: openContainer,
                          tooltip: context.loc.new_note,
                          backgroundColor: Colors.transparent,
                          foregroundColor:
                              context.themeColors.onPrimaryContainer,
                          child: const Icon(
                            Icons.add_rounded,
                            size: 44,
                          ),
                        );
                      },
                    )
                  : null,
              drawer: Drawer(
                child: Stack(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 32.0, 12.0, 32.0),
                      child: Column(
                        children: [
                          const Spacer(
                            flex: 1,
                          ),
                          if (state.user != null)
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: context.themeColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(28.0),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.person_rounded,
                                        size: 28.0,
                                        color: context.theme.colorScheme
                                            .onTertiaryContainer,
                                      ),
                                      const SizedBox(
                                        width: 8.0,
                                      ),
                                      Expanded(
                                        child: Text(
                                          state.user?.email ?? '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: context.theme.colorScheme
                                                .onTertiaryContainer,
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
                                    ),
                                    style: FilledButton.styleFrom(
                                        backgroundColor:
                                            context.themeColors.tertiary,
                                        foregroundColor: context
                                            .theme.colorScheme.onTertiary,
                                        minimumSize:
                                            const Size.fromHeight(44.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                  ),
                                ],
                              ),
                            ),
                          if (state.user == null)
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthEventLogOut());
                              },
                              label: Text(
                                context.loc.login,
                              ),
                              icon: const Icon(
                                Icons.login_rounded,
                              ),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(44.0),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 128),
                      child: ListView(
                        shrinkWrap: true,
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 32.0, 12.0, 0.0),
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 32.0),
                            child: Text(
                              context.loc.app_title,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: context.themeColors.onBackground,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              ListTile(
                                onTap: () async =>
                                    await showNoteTagEditorModalBottomSheet(
                                  context: context,
                                  tags: () => state.noteTags(),
                                  onCreateTag: (tagName) => context
                                      .read<NoteBloc>()
                                      .add(NoteCreateTagEvent(name: tagName)),
                                  onEditTag: (tag, newName) => context
                                      .read<NoteBloc>()
                                      .add(NoteEditTagEvent(
                                        tag: tag,
                                        newName: newName,
                                      )),
                                  onDeleteTag: (tag) => context
                                      .read<NoteBloc>()
                                      .add(NoteDeleteTagEvent(tag: tag)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                tileColor: context.themeColors.primaryContainer,
                                splashColor: context
                                    .theme.colorScheme.inversePrimary
                                    .withAlpha(200),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                leading: Icon(
                                  Icons.label_important_rounded,
                                  color: context
                                      .theme.colorScheme.onPrimaryContainer,
                                ),
                                title: Text(
                                  'Labels',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              ListTile(
                                onTap: () {},
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                tileColor: context.themeColors.primaryContainer,
                                splashColor: context
                                    .theme.colorScheme.inversePrimary
                                    .withAlpha(150),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                    bottomLeft: Radius.circular(28),
                                    bottomRight: Radius.circular(28),
                                  ),
                                ),
                                leading: Icon(
                                  Icons.book_rounded,
                                  color: context
                                      .theme.colorScheme.onPrimaryContainer,
                                ),
                                title: Text(
                                  'Notebooks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () {},
                                  borderRadius: BorderRadius.circular(32),
                                  splashColor: context
                                      .theme.colorScheme.primaryContainer
                                      .withAlpha(200),
                                  child: Ink(
                                    padding: const EdgeInsets.all(4.0),
                                    decoration: BoxDecoration(
                                      color: context.themeColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<AuthBloc>(),
                                        child: const SettingsView(),
                                      ),
                                    ),
                                  );
                                },
                                tileColor: context
                                    .theme.colorScheme.secondaryContainer,
                                splashColor:
                                    context.themeColors.secondary.withAlpha(50),
                                leading: Icon(
                                  Icons.settings_rounded,
                                  color: context
                                      .theme.colorScheme.onSecondaryContainer,
                                ),
                                title: Text(
                                  'Settings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: context
                                        .theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              body: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    (state.selectedNotes.isEmpty)
                        ? _getDefaultAppBar(context, state, innerBoxIsScrolled)
                        : _getNotesSelectedAppBar(context, state),
                  ];
                },
                body: StreamBuilder<List<PresentableNoteData>>(
                  stream: state.noteData(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.done:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotesData = snapshot.data!;
                          return BlocProvider<NoteBloc>.value(
                            value: context.read<NoteBloc>(),
                            child: NotesListView(
                              layoutPreference: state.layoutPreference,
                              // notes: allNotes,
                              noteData: allNotesData,
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
                              onLongPress: (LocalNote note) => context
                                  .read<NoteBloc>()
                                  .add(NoteLongPressEvent(
                                    note: note,
                                    selectedNotes: state.selectedNotes,
                                  )),
                            ),
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
                            color: context.themeColors.primary,
                            size: 60,
                          ),
                        );
                    }
                  },
                ),
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
