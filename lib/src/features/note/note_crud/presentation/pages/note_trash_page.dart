import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_trash_bloc/note_trash_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/notes_list_view.dart';
import 'package:thoughtbook/src/utilities/dialogs/delete_dialog.dart';

class NoteTrashPage extends StatefulWidget {
  const NoteTrashPage({super.key});

  @override
  State<NoteTrashPage> createState() => _NoteTrashPageState();
}

class _NoteTrashPageState extends State<NoteTrashPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteTrashBloc, NoteTrashState>(
      builder: (context, state) {
        if (state is NoteTrashUninitialized) {
          context.read<NoteTrashBloc>().add(const NoteTrashInitializeEvent());
          return const Placeholder();
        } else if (state is NoteTrashInitialized) {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar.large(
                  iconTheme: IconThemeData(color: context.themeColors.onSurfaceVariant),
                  title: Text(
                    'Deleted notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.themeColors.onSurfaceVariant,
                    ),
                  ),
                  leading: IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(FluentIcons.arrow_left_24_filled),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      tooltip: state.layout == 'list' ? 'Grid layout' : 'List layout',
                      onPressed: () =>
                          context.read<NoteTrashBloc>().add(const NoteTrashToggleLayoutEvent()),
                      icon: Icon(state.layout == 'list'
                          ? FluentIcons.grid_24_filled
                          : FluentIcons.list_24_filled),
                    ),
                    IconButton(
                      tooltip: 'Select all notes',
                      onPressed: () =>
                          context.read<NoteTrashBloc>().add(const NoteTrashSelectAllEvent()),
                      icon: const Icon(FluentIcons.select_all_on_24_filled),
                    ),
                  ],
                ),
              ],
              body: StreamBuilder(
                stream: state.trashedNotes(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        final trashedNotes = snapshot.data!;
                        if (trashedNotes.isNotEmpty) {
                          final buttonWidth = MediaQuery.of(context).size.width / 2 - 24;
                          return Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    NotesListView(
                                      isDismissible: false,
                                      layoutPreference: state.layout,
                                      notesData: trashedNotes,
                                      selectedNotes: state.selectedNotes,
                                      onDeleteNote: (note) => context
                                          .read<NoteTrashBloc>()
                                          .add(NoteTrashDeleteEvent(notes: {note})),
                                      onTap: (note, openContainer) {
                                        context.read<NoteTrashBloc>().add(
                                            NoteTrashTapEvent(note: note, openNote: openContainer));
                                      },
                                      onLongPress: (note) => context
                                          .read<NoteTrashBloc>()
                                          .add(NoteTrashLongPressEvent(note: note)),
                                    ),
                                    const SizedBox(height: 192),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const Spacer(flex: 1),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                                    decoration: BoxDecoration(
                                      color: context.themeColors.surfaceVariant,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(40),
                                        topRight: Radius.circular(40),
                                      ),
                                    ),
                                    child: AbsorbPointer(
                                      absorbing: state.selectedNotes.isEmpty,
                                      child: AnimatedOpacity(
                                        opacity: state.selectedNotes.isEmpty ? 0.25 : 1,
                                        duration: 200.milliseconds,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              child: FilledButton.icon(
                                                onPressed: () => context.read<NoteTrashBloc>().add(
                                                    NoteTrashRestoreEvent(
                                                        notes: state.selectedNotes)),
                                                icon: const Icon(FluentIcons.arrow_reset_24_filled),
                                                label: const Text(
                                                  'Restore',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                style: FilledButton.styleFrom(
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(32),
                                                      bottomLeft: Radius.circular(32),
                                                      topRight: Radius.circular(4),
                                                      bottomRight: Radius.circular(4),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 20),
                                                  minimumSize: Size(buttonWidth, 44),
                                                  backgroundColor: context.themeColors.secondary,
                                                  foregroundColor: context.themeColors.onSecondary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              flex: 1,
                                              child: FilledButton.icon(
                                                onPressed: () async {
                                                  final shouldDelete = await showDeleteDialog(
                                                    context: context,
                                                    content:
                                                        'Are you sure you want to delete the selected notes forever?',
                                                  );
                                                  if (shouldDelete) {
                                                    context.read<NoteTrashBloc>().add(
                                                        NoteTrashDeleteEvent(
                                                            notes: state.selectedNotes));
                                                  }
                                                },
                                                icon: const Icon(
                                                    FluentIcons.delete_dismiss_24_filled),
                                                label: const Text(
                                                  'Delete forever',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                style: FilledButton.styleFrom(
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(4),
                                                      bottomLeft: Radius.circular(4),
                                                      topRight: Radius.circular(32),
                                                      bottomRight: Radius.circular(32),
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 20, vertical: 20),
                                                  minimumSize: Size(buttonWidth, 44),
                                                  backgroundColor: context.themeColors.primary,
                                                  foregroundColor: context.themeColors.onPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Ink(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: context.themeColors.secondaryContainer.withAlpha(120),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FluentIcons.bin_recycle_24_filled,
                                    size: 150,
                                    color: context.theme.colorScheme.onSecondaryContainer
                                        .withAlpha(150),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    'Nothing to see here',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.theme.colorScheme.onSecondaryContainer
                                          .withAlpha(220),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              ),
            ),
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
