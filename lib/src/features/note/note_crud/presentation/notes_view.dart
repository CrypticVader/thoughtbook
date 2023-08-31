import 'package:animations/animations.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_filter_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_group_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_sort_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_tag_editor_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/common_widgets/tonal_chip.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/notes_list_view.dart';
import 'package:thoughtbook/src/features/settings/presentation/settings_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  bool _showFab = true;

  Future<void> _onLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      authBloc.add(const AuthEventLogOut());
    }
  }

  SliverAppBar _getDefaultAppBar(
    BuildContext context,
    NoteInitializedState state,
    bool isScrolled,
  ) {
    final layoutPreference = state.layoutPreference;
    final groupChipLabel = switch (state.groupProps.groupParameter) {
      GroupParameter.dateModified => 'Grouped by date modified',
      GroupParameter.dateCreated => 'Grouped by date created',
      GroupParameter.tag => 'Grouped by tag',
      GroupParameter.none => 'Ungrouped',
    };

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
            tooltip: 'Open navigation menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(FluentIcons.line_horizontal_3_20_filled),
          ),
          suffixIcon: IconButton(
            onPressed: () =>
                context.read<NoteBloc>().add(const NoteToggleLayoutEvent()),
            icon: Icon(
              (layoutPreference == LayoutPreference.list.value)
                  ? FluentIcons.grid_28_filled
                  : FluentIcons.list_28_filled,
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
                  onTap: () async => await showNoteFilterPickerBottomSheet(
                    context: context,
                    allTags: state.noteTags,
                    currentFilter: state.filterProps.filterSet,
                    requireEntireFilter: state.filterProps.requireEntireFilter,
                    onSelect: (tagId, requireEntireFilter) =>
                        context.read<NoteBloc>().add(NoteModifyFilteringEvent(
                              selectedTagId: tagId,
                              requireEntireFilter: requireEntireFilter,
                            )),
                  ),
                  label: state.filterProps.filterSet.isEmpty
                      ? 'All notes'
                      : '${state.filterProps.filterSet.length} '
                          'tag${(state.filterProps.filterSet.length > 1) ? 's' : ''} selected',
                  iconData: FluentIcons.filter_24_filled,
                  backgroundColor: state.filterProps.filterSet.isNotEmpty
                      ? context.themeColors.primaryContainer
                      : null,
                  foregroundColor: state.filterProps.filterSet.isNotEmpty
                      ? context.themeColors.onPrimaryContainer
                      : null,
                ),
                const SizedBox(
                  width: 8,
                ),
                TonalChip(
                  onTap: () async => await showNoteSortModePickerBottomSheet(
                    context: context,
                    sortMode: state.sortProps.mode,
                    sortOrder: state.sortProps.order,
                    onSelect: (sortOrder, sortMode) =>
                        context.read<NoteBloc>().add(NoteModifySortingEvent(
                              sortMode: sortMode,
                              sortOrder: sortOrder,
                            )),
                  ),
                  label: state.sortProps.mode == SortMode.dataCreated
                      ? 'Date created'
                      : 'Date modified',
                  iconData: FluentIcons.arrow_sort_24_filled,
                ),
                const SizedBox(
                  width: 8,
                ),
                TonalChip(
                  onTap: () async => await showNoteGroupModePickerBottomSheet(
                    context: context,
                    groupParameter: state.groupProps.groupParameter,
                    groupOrder: state.groupProps.groupOrder,
                    tagGroupLogic: state.groupProps.tagGroupLogic,
                    onChangeProps: (groupParameter, groupOrder,
                            tagGroupLogic) =>
                        context.read<NoteBloc>().add(NoteModifyGroupingEvent(
                              groupParameter: groupParameter,
                              groupOrder: groupOrder,
                              tagGroupLogic: tagGroupLogic,
                            )),
                  ),
                  label: groupChipLabel,
                  iconData: FluentIcons.group_24_filled,
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

  Widget _getNoteSelectionToolbar(
    BuildContext context,
    NoteInitializedState state,
  ) {
    return AnimatedSwitcher(
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      duration: const Duration(milliseconds: 250),
      child: (state.selectedNotes.isNotEmpty)
          ? Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        context.themeColors.primary,
                        context.themeColors.background,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: context.loc.close,
                          onPressed: () => context
                              .read<NoteBloc>()
                              .add(const NoteUnselectAllEvent()),
                          icon: const Icon(
                            FluentIcons.dismiss_24_filled,
                          ),
                          style: IconButton.styleFrom(
                            foregroundColor: context.themeColors.onPrimary,
                          ),
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        AnimatedSwitcher(
                          switchInCurve: Curves.easeInOutCubic,
                          switchOutCurve: Curves.easeInOutCubic,
                          duration: const Duration(milliseconds: 350),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            context.loc.notes_title(
                              state.selectedNotes.length,
                              context.loc.app_title,
                            ),
                            key: ValueKey<int>(state.selectedNotes.length),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: context.themeColors.onPrimary,
                            ),
                          ),
                        ),
                        const Spacer(
                          flex: 1,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: context.themeColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                switchOutCurve: Curves.easeInOutCubic,
                                switchInCurve: Curves.easeInOutCubic,
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: (state.selectedNotes.length == 1)
                                    ? IconButton(
                                        onPressed: () async {
                                          final note =
                                              state.selectedNotes.first;
                                          final currentColor =
                                              (note.color != null)
                                                  ? Color(note.color!)
                                                  : null;
                                          final noteBloc =
                                              context.read<NoteBloc>();
                                          final color =
                                              await showColorPickerModalBottomSheet(
                                            context: context,
                                            currentColor: currentColor,
                                          );
                                          noteBloc.add(
                                            NoteUpdateColorEvent(
                                              note: note,
                                              color: (color != null)
                                                  ? color.value
                                                  : null,
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          FluentIcons.color_24_filled,
                                          color: context
                                              .themeColors.onPrimaryContainer,
                                        ),
                                      )
                                    : null,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                switchOutCurve: Curves.easeInOutCubic,
                                switchInCurve: Curves.easeInOutCubic,
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: (state.selectedNotes.length == 1)
                                    ? IconButton(
                                        onPressed: () async {
                                          final note =
                                              state.selectedNotes.first;
                                          context
                                              .read<NoteBloc>()
                                              .add(NoteShareEvent(note));
                                        },
                                        icon: Icon(
                                          FluentIcons.share_24_filled,
                                          color: context
                                              .themeColors.onPrimaryContainer,
                                        ),
                                      )
                                    : null,
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                switchOutCurve: Curves.easeInOutCubic,
                                switchInCurve: Curves.easeInOutCubic,
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: (state.selectedNotes.length == 1)
                                    ? IconButton(
                                        onPressed: () {
                                          final note =
                                              state.selectedNotes.first;
                                          context
                                              .read<NoteBloc>()
                                              .add(NoteCopyEvent(note));
                                        },
                                        icon: Icon(
                                          FluentIcons.copy_24_filled,
                                          color: context
                                              .themeColors.onPrimaryContainer,
                                        ),
                                      )
                                    : null,
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<NoteBloc>().add(
                                        NoteDeleteEvent(
                                          notes: state.selectedNotes,
                                        ),
                                      );
                                },
                                icon: Icon(
                                  FluentIcons.delete_24_filled,
                                  color: context.themeColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const Spacer(
                        //   flex: 1,
                        // ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        IconButton(
                          tooltip: context.loc.select_all_notes,
                          onPressed: () async => context.read<NoteBloc>().add(
                                const NoteEventSelectAllNotes(),
                              ),
                          icon: const Icon(
                            FluentIcons.select_all_on_24_filled,
                          ),
                          style: IconButton.styleFrom(
                            foregroundColor: context.themeColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : null,
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
                  NoteUndoDeleteEvent(deletedNotes: state.deletedNotes ?? {}));
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
                  ? AnimatedOpacity(
                      opacity: _showFab ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: AnimatedScale(
                        scale: _showFab ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: OpenContainer(
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
                                  .add(NoteDeleteEvent(notes: {note})),
                            ),
                          ),
                          closedElevation: 8.0,
                          closedShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          closedColor: context.themeColors.primaryContainer,
                          middleColor: context.themeColors.secondaryContainer,
                          openColor: context.themeColors.secondaryContainer,
                          closedBuilder: (context, openContainer) {
                            return IconButton(
                              onPressed: openContainer,
                              tooltip: context.loc.new_note,
                              style: IconButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                backgroundColor: Colors.transparent,
                                foregroundColor:
                                    context.themeColors.onPrimaryContainer,
                              ),
                              icon: const Icon(
                                FluentIcons.note_add_48_filled,
                                size: 44,
                              ),
                            );
                          },
                        ),
                      ),
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
                                        FluentIcons.person_32_filled,
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
                                      FluentIcons.sign_out_24_regular,
                                    ),
                                    label: Text(
                                      context.loc.logout_button,
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          context.themeColors.tertiary,
                                      foregroundColor:
                                          context.theme.colorScheme.onTertiary,
                                      minimumSize: const Size.fromHeight(40.0),
                                    ),
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
                                FluentIcons.arrow_enter_20_filled,
                              ),
                              style: FilledButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                ),
                                foregroundColor:
                                    context.themeColors.onTertiaryContainer,
                                backgroundColor:
                                    context.themeColors.tertiaryContainer,
                                minimumSize: const Size.fromHeight(48.0),
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
                                fontWeight: FontWeight.w600,
                                color: context.themeColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              // Primary actions
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
                                  FluentIcons.tag_28_filled,
                                  color: context
                                      .theme.colorScheme.onPrimaryContainer,
                                ),
                                title: Text(
                                  'Tags',
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
                                  FluentIcons.book_20_filled,
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
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: context.themeColors.surfaceTint,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Icon(
                                      FluentIcons.caret_down_24_filled,
                                      color: context
                                          .theme.colorScheme.primaryContainer,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),

                              // Secondary actions
                              ListTile(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                onTap: () {},
                                tileColor: context
                                    .theme.colorScheme.secondaryContainer,
                                splashColor:
                                    context.themeColors.secondary.withAlpha(50),
                                leading: Icon(
                                  FluentIcons.archive_24_filled,
                                  size: 26,
                                  color: context
                                      .theme.colorScheme.onSecondaryContainer,
                                ),
                                title: Text(
                                  'Archive',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: context
                                        .theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onTap: () {},
                                tileColor: context
                                    .theme.colorScheme.secondaryContainer,
                                splashColor:
                                    context.themeColors.secondary.withAlpha(50),
                                leading: Icon(
                                  FluentIcons.delete_24_filled,
                                  size: 26,
                                  color: context
                                      .theme.colorScheme.onSecondaryContainer,
                                ),
                                title: Text(
                                  'Trash',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: context
                                        .theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              ListTile(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                    bottomLeft: Radius.circular(28),
                                    bottomRight: Radius.circular(28),
                                  ),
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
                                  FluentIcons.settings_24_filled,
                                  size: 26,
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
                    _getDefaultAppBar(
                      context,
                      state,
                      innerBoxIsScrolled,
                    ),
                  ];
                },
                body: StreamBuilder<Map<String, List<PresentableNoteData>>>(
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
                            child: Stack(
                              children: [
                                NotificationListener<UserScrollNotification>(
                                  onNotification: (notification) {
                                    ScrollDirection direction =
                                        notification.direction;
                                    if (direction == ScrollDirection.forward) {
                                      if (_showFab != true) {
                                        setState(() {
                                          _showFab = true;
                                        });
                                      }
                                    } else if (direction ==
                                        ScrollDirection.reverse) {
                                      if (_showFab != false) {
                                        setState(() {
                                          _showFab = false;
                                        });
                                      }
                                    }
                                    return true;
                                  },
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: allNotesData.keys
                                          .map((groupHeader) => NoteGroup(
                                                state: state,
                                                groupNotesData:
                                                    allNotesData[groupHeader]!,
                                                groupHeader: groupHeader,
                                                // TODO: notify bloc
                                                onSelectGroup: () {},
                                                onUnselectGroup: () {},
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                                _getNoteSelectionToolbar(context, state),
                              ],
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

class NoteListGroupHeader extends StatefulWidget {
  final String groupHeader;
  final bool isCollapsed;
  final bool isSelected;
  final void Function() onTapHeader;
  final void Function() onSelectGroup;
  final void Function() onUnselectGroup;

  const NoteListGroupHeader({
    super.key,
    required this.groupHeader,
    required this.isCollapsed,
    required this.isSelected,
    required this.onTapHeader,
    required this.onSelectGroup,
    required this.onUnselectGroup,
  });

  @override
  State<NoteListGroupHeader> createState() => _NoteListGroupHeaderState();
}

class _NoteListGroupHeaderState extends State<NoteListGroupHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: -0.5).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: InkWell(
          onTap: () {
            widget.onTapHeader();
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          splashColor: context.themeColors.surfaceVariant.withAlpha(120),
          highlightColor: context.themeColors.surfaceVariant,
          borderRadius: widget.isCollapsed
              ? BorderRadius.circular(26)
              : const BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(16, 2, 2, 2),
            decoration: BoxDecoration(
              color: context.themeColors.secondaryContainer.withAlpha(90),
              borderRadius: widget.isCollapsed
                  ? BorderRadius.circular(26)
                  : const BorderRadius.only(
                      topRight: Radius.circular(24),
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      RotationTransition(
                        turns: _animation,
                        child: Icon(
                          FluentIcons.chevron_down_24_filled,
                          size: 20,
                          color: context.themeColors.onSecondaryContainer
                              .withAlpha(120),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.groupHeader,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.themeColors.onSecondaryContainer,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  onPressed: () {
                    if (widget.isSelected) {
                      widget.onSelectGroup();
                    } else {
                      widget.onUnselectGroup();
                    }
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 24,
                  ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: widget.isCollapsed
                          ? const BorderRadius.only(
                              topRight: Radius.circular(22),
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(22),
                            )
                          : const BorderRadius.only(
                              topRight: Radius.circular(22),
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                    ),
                    backgroundColor: context.themeColors.inversePrimary
                        .withAlpha(widget.isSelected ? 250 : 150),
                    foregroundColor: context.themeColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoteGroup extends StatefulWidget {
  const NoteGroup({
    super.key,
    required this.groupHeader,
    required this.state,
    required this.groupNotesData,
    required this.onSelectGroup,
    required this.onUnselectGroup,
  });

  final String groupHeader;
  final NoteInitializedState state;
  final List<PresentableNoteData> groupNotesData;
  final void Function() onSelectGroup;
  final void Function() onUnselectGroup;

  @override
  State<NoteGroup> createState() => _NoteGroupState();
}

class _NoteGroupState extends State<NoteGroup> {
  bool isCollapsed = false;
  bool isSelected = false;

  @override
  void initState() {
    Iterable<int> selectedNoteIds =
        widget.state.selectedNotes.map((note) => note.isarId);
    isSelected = widget.groupNotesData
        .map((noteData) => noteData.note.isarId)
        .every((noteId) => selectedNoteIds.contains(noteId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.groupHeader.isNotEmpty)
          NoteListGroupHeader(
            isSelected: isSelected,
            isCollapsed: isCollapsed,
            groupHeader: widget.groupHeader,
            onTapHeader: () => setState(() {
              isCollapsed = !isCollapsed;
            }),
            onSelectGroup: () => widget.onSelectGroup(),
            onUnselectGroup: () => widget.onUnselectGroup(),
          ),
        AnimatedSwitcher(
          duration: 450.milliseconds,
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn.flipped,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                axis: Axis.vertical,
                sizeFactor: animation,
                child: child,
              ),
            );
          },
          child: !isCollapsed
              ? NotesListView(
                  layoutPreference: widget.state.layoutPreference,
                  notesData: widget.groupNotesData,
                  selectedNotes: widget.state.selectedNotes,
                  onDeleteNote: (LocalNote note) => context
                      .read<NoteBloc>()
                      .add(NoteDeleteEvent(notes: {note})),
                  onTap: (
                    LocalNote note,
                    void Function() openNote,
                  ) {
                    if (widget.state.selectedNotes.isEmpty) {
                      openNote();
                    } else {
                      context.read<NoteBloc>().add(NoteTapEvent(note: note));
                    }
                  },
                  onLongPress: (LocalNote note) => context
                      .read<NoteBloc>()
                      .add(NoteLongPressEvent(note: note)),
                )
              : const SizedBox(height: 10),
        ),
      ],
    );
  }
}
