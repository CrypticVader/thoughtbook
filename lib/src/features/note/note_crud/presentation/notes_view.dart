import 'dart:math';

import 'package:animations/animations.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocConsumer, BlocProvider, ReadContext;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/iterable/null_check.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/enums/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/enums/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_trash_bloc/note_trash_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/bottom_sheets/note_filter_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/bottom_sheets/note_group_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/bottom_sheets/note_sort_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/common_widgets/bottom_sheets/tag_editor_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_editor_view.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/note_trash_view.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/notes_list_view.dart';
import 'package:thoughtbook/src/features/settings/presentation/settings_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/common_widgets/tonal_chip.dart';
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

  SliverAppBar _buildDefaultAppBar(
    BuildContext context,
    NoteInitializedState state,
    bool isScrolled,
  ) {
    final layoutPreference = state.layoutPreference;
    final groupChipLabel = switch (state.groupProps.groupParameter) {
      GroupParameter.dateModified => 'Date modified',
      GroupParameter.dateCreated => 'Date created',
      GroupParameter.tag => 'Tag',
      GroupParameter.none => 'Ungrouped',
    };

    // String tagChipLabel() {
    //   final props = state.filterProps;
    //   if (props == FilterProps.noFilters()) {
    //     return 'All notes';
    //   } else {
    //     final tagCount = props.filterTagIds.length;
    //     final colorCount = props.filterColors.length;
    //     final hasCreated = props.createdRange.isNotNull;
    //     final hasModified = props.modifiedRange.isNotNull;
    //     return '$tagCount tag selected';
    //   }
    // }

    final targetPlatform = ScrollConfiguration.of(context).getPlatform(context);
    final isDesktop = {
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }.contains(targetPlatform);

    return SliverAppBar(
      pinned: true,
      snap: true,
      floating: true,
      backgroundColor: Color.alphaBlend(
        context.themeColors.surfaceVariant.withAlpha(isScrolled ? 85 : 0),
        context.themeColors.background,
      ),
      surfaceTintColor: Colors.transparent,
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      toolbarHeight: isDesktop ? 70 : 56,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Open navigation menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              FluentIcons.line_horizontal_3_20_filled,
              color: context.themeColors.onSecondaryContainer,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(10),
              iconSize: 26,
              backgroundColor: context.themeColors.secondaryContainer,
              foregroundColor: context.themeColors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          LimitedBox(
            maxWidth: min(MediaQuery.of(context).size.width - 120, 720),
            child: TextField(
              onChanged: (value) => context.read<NoteBloc>().add(NoteSearchEvent(query: value)),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: context.themeColors.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                    color: context.themeColors.onSecondaryContainer.withAlpha(180),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontStyle: FontStyle.italic),
                contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 0.75,
                    color: context.themeColors.onSurfaceVariant.withAlpha(100),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Color.alphaBlend(
                  context.themeColors.secondaryContainer.withAlpha(170),
                  context.themeColors.background,
                ),
                filled: true,
                hintText: 'Search your notes & tags',
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  color: context.themeColors.onSecondaryContainer.withAlpha(200),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () => context.read<NoteBloc>().add(const NoteToggleLayoutEvent()),
            icon: AnimatedSwitcher(
              switchOutCurve: Curves.easeInQuad,
              switchInCurve: Curves.easeOutQuad,
              duration: 300.milliseconds,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: Icon(
                (layoutPreference == LayoutPreference.list.value)
                    ? FluentIcons.grid_28_filled
                    : FluentIcons.list_28_filled,
                key: ValueKey<String>(layoutPreference),
                color: context.themeColors.onSecondaryContainer,
              ),
            ),
            tooltip: (layoutPreference == LayoutPreference.list.value)
                ? context.loc.notes_view_grid_layout
                : context.loc.notes_view_list_layout,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(10),
              iconSize: 26,
              backgroundColor: context.themeColors.secondaryContainer,
              foregroundColor: context.themeColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
            child: Row(
              children: [
                TonalChip(
                  onTap: () async => await showNoteFilterPickerBottomSheet(
                    context: context,
                    allTags: state.noteTags,
                    allColors: kNoteColors,
                    filterProps: state.filterProps,
                    onChange: (newProps) =>
                        context.read<NoteBloc>().add(NoteModifyFilterEvent(props: newProps)),
                  ),
                  label: state.filterProps.filterTagIds.isNullOrEmpty
                      ? 'All notes'
                      : '${state.filterProps.filterTagIds.length} '
                          'tag${(state.filterProps.filterTagIds.length > 1) ? 's' : ''} selected',
                  iconData: FluentIcons.filter_24_filled,
                  backgroundColor: state.filterProps.filterTagIds.isNotNullAndNotEmpty
                      ? context.themeColors.primaryContainer
                      : context.themeColors.secondaryContainer.withAlpha(200),
                  foregroundColor: state.filterProps.filterTagIds.isNotNullAndNotEmpty
                      ? context.themeColors.onPrimaryContainer
                      : context.themeColors.onSecondaryContainer,
                  borderColor: state.filterProps.filterTagIds.isNotNullAndNotEmpty
                      ? Colors.transparent
                      : context.themeColors.onSecondaryContainer.withAlpha(25),
                ),
                const SizedBox(width: 8),
                TonalChip(
                  onTap: () async => await showNoteSortModePickerBottomSheet(
                    context: context,
                    sortMode: state.sortProps.mode,
                    sortOrder: state.sortProps.order,
                    onSelect: (sortOrder, sortMode) =>
                        context.read<NoteBloc>().add(NoteModifySortEvent(
                              sortMode: sortMode,
                              sortOrder: sortOrder,
                            )),
                  ),
                  label: state.sortProps.mode == SortMode.dateCreated
                      ? 'Date created'
                      : 'Date modified',
                  iconData: FluentIcons.arrow_sort_24_filled,
                  backgroundColor: context.themeColors.secondaryContainer.withAlpha(200),
                  foregroundColor: context.themeColors.onSecondaryContainer,
                  borderColor: context.themeColors.onSecondaryContainer.withAlpha(25),
                ),
                const SizedBox(width: 8),
                TonalChip(
                  onTap: () async => await showNoteGroupModePickerBottomSheet(
                    context: context,
                    groupParameter: state.groupProps.groupParameter,
                    groupOrder: state.groupProps.groupOrder,
                    tagGroupLogic: state.groupProps.tagGroupLogic,
                    onChangeProps: (groupParameter, groupOrder, tagGroupLogic) =>
                        context.read<NoteBloc>().add(NoteModifyGroupPropsEvent(
                              groupParameter: groupParameter,
                              groupOrder: groupOrder,
                              tagGroupLogic: tagGroupLogic,
                            )),
                  ),
                  label: groupChipLabel,
                  iconData: FluentIcons.group_24_filled,
                  backgroundColor: context.themeColors.secondaryContainer.withAlpha(200),
                  foregroundColor: context.themeColors.onSecondaryContainer,
                  borderColor: context.themeColors.onSecondaryContainer.withAlpha(25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSelectionToolbar(
    BuildContext context,
    Set<LocalNote> selectedNotes,
  ) {
    final noteBloc = context.read<NoteBloc>();
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
      child: (selectedNotes.isNotEmpty)
          ? Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
                          onPressed: () => noteBloc.add(const NoteUnselectAllEvent()),
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
                              selectedNotes.length,
                              context.loc.app_title,
                            ),
                            key: ValueKey<int>(selectedNotes.length),
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
                                duration: 200.milliseconds,
                                switchOutCurve: Curves.easeInOutQuad,
                                switchInCurve: Curves.easeInOutQuad,
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    axis: Axis.horizontal,
                                    sizeFactor: animation,
                                    child: child,
                                  ),
                                ),
                                child: (selectedNotes.length == 1)
                                    ? Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              final note = selectedNotes.first;
                                              final currentColor =
                                                  (note.color != null) ? Color(note.color!) : null;
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
                                            },
                                            icon: Icon(
                                              FluentIcons.color_24_filled,
                                              color: context.themeColors.onPrimaryContainer,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              final note = selectedNotes.first;
                                              noteBloc.add(NoteShareEvent(note));
                                            },
                                            icon: Icon(
                                              FluentIcons.share_24_filled,
                                              color: context.themeColors.onPrimaryContainer,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              final note = selectedNotes.first;
                                              noteBloc.add(NoteCopyEvent(note));
                                            },
                                            icon: Icon(
                                              FluentIcons.copy_24_filled,
                                              color: context.themeColors.onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(
                                        width: 0,
                                      ),
                              ),
                              IconButton(
                                onPressed: () {
                                  noteBloc.add(
                                    NoteDeleteEvent(
                                      notes: selectedNotes,
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
                        const SizedBox(
                          width: 8.0,
                        ),
                        IconButton(
                          tooltip: context.loc.select_all_notes,
                          onPressed: () async => noteBloc.add(
                            const NoteSelectAllEvent(),
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

  Widget _buildDrawerWidget(
    BuildContext context,
    NoteInitializedState state,
  ) {
    return Drawer(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 32.0, 12.0, 32.0),
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
                              color: context.theme.colorScheme.onTertiaryContainer,
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
                                  color: context.theme.colorScheme.onTertiaryContainer,
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
                            backgroundColor: context.themeColors.tertiary,
                            foregroundColor: context.theme.colorScheme.onTertiary,
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
                      context.read<AuthBloc>().add(const AuthEventLogOut());
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
                      foregroundColor: context.themeColors.onTertiaryContainer,
                      backgroundColor: context.themeColors.tertiaryContainer,
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
              padding: const EdgeInsets.fromLTRB(12.0, 32.0, 12.0, 0.0),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 32.0),
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
                      onTap: () async => await showNoteTagEditorModalBottomSheet(
                        context: context,
                        tags: () => state.noteTags(),
                        onCreateTag: (tagName) =>
                            context.read<NoteBloc>().add(NoteCreateTagEvent(name: tagName)),
                        onEditTag: (tag, newName) => context.read<NoteBloc>().add(NoteEditTagEvent(
                              tag: tag,
                              newName: newName,
                            )),
                        onDeleteTag: (tag) =>
                            context.read<NoteBloc>().add(NoteDeleteTagEvent(tag: tag)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      tileColor: context.themeColors.primaryContainer,
                      splashColor: context.theme.colorScheme.inversePrimary.withAlpha(200),
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
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                      title: Text(
                        'Tags',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 2.0,
                    ),
                    ListTile(
                      onTap: () {},
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      tileColor: context.themeColors.primaryContainer,
                      splashColor: context.theme.colorScheme.inversePrimary.withAlpha(200),
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
                        color: context.theme.colorScheme.onPrimaryContainer,
                      ),
                      title: Text(
                        'Notebooks',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(32),
                        splashColor: context.theme.colorScheme.primaryContainer.withAlpha(200),
                        child: Ink(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: context.themeColors.surfaceTint,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            FluentIcons.caret_down_24_filled,
                            color: context.theme.colorScheme.primaryContainer,
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
                      onTap: () async {
                        Navigator.of(context).pop();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => NoteTrashBloc(),
                              child: const NoteTrashView(),
                            ),
                          ),
                        );
                      },
                      tileColor: context.theme.colorScheme.secondaryContainer,
                      splashColor: context.themeColors.secondary.withAlpha(50),
                      leading: Icon(
                        FluentIcons.delete_24_filled,
                        size: 26,
                        color: context.theme.colorScheme.onSecondaryContainer,
                      ),
                      title: Text(
                        'Trash',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSecondaryContainer,
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
                      tileColor: context.theme.colorScheme.secondaryContainer,
                      splashColor: context.themeColors.secondary.withAlpha(50),
                      leading: Icon(
                        FluentIcons.settings_24_filled,
                        size: 26,
                        color: context.theme.colorScheme.onSecondaryContainer,
                      ),
                      title: Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSecondaryContainer,
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
    );
  }

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black.withOpacity(0.002),
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );
    super.didChangeDependencies();
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
              noteBloc.add(NoteUndoDeleteEvent(deletedNotes: state.deletedNotes ?? {}));
            }
          }
        }
      },
      builder: (context, state) {
        final noteBloc = context.read<NoteBloc>();
        if (state is NoteUninitializedState) {
          noteBloc.add(const NoteInitializeEvent());
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is NoteInitializedState) {
          return WillPopScope(
            onWillPop: () async {
              if (!(state.hasSelectedNotes)) {
                return true;
              } else {
                noteBloc.add(const NoteUnselectAllEvent());
                return false;
              }
            },
            child: Scaffold(
              floatingActionButton: !(state.hasSelectedNotes)
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
                              onDeleteNote: (note) =>
                                  context.read<NoteBloc>().add(NoteDeleteEvent(notes: {note})),
                            ),
                          ),
                          closedElevation: 8.0,
                          closedShape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          closedColor: context.themeColors.primaryContainer,
                          middleColor: context.themeColors.secondaryContainer,
                          openColor: context.themeColors.secondaryContainer,
                          closedBuilder: (context, openContainer) {
                            return IconButton(
                              onPressed: openContainer,
                              tooltip: context.loc.new_note,
                              style: IconButton.styleFrom(
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                padding: const EdgeInsets.all(10.0),
                                backgroundColor: Colors.transparent,
                                foregroundColor: context.themeColors.onPrimaryContainer,
                              ),
                              icon: const Icon(
                                FluentIcons.note_add_48_filled,
                                size: 46,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : null,
              drawer: _buildDrawerWidget(context, state),
              body: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    _buildDefaultAppBar(context, state, innerBoxIsScrolled),
                  ];
                },
                body: StreamBuilder(
                  stream: Rx.combineLatest2(
                    state.notesData(),
                    state.selectedNotes(),
                    (notesData, selectedNotes) => (notesData, selectedNotes),
                  ).shareValue(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.done:
                      case ConnectionState.active:
                        if (snapshot.hasData && snapshot.data!.$1.isNotEmpty) {
                          final notes = snapshot.data!.$1;
                          final selectedNotes = snapshot.data!.$2;

                          return BlocProvider<NoteBloc>.value(
                            value: noteBloc,
                            child: Stack(
                              children: [
                                NotificationListener<UserScrollNotification>(
                                  onNotification: (notification) {
                                    ScrollDirection direction = notification.direction;
                                    if (direction == ScrollDirection.forward) {
                                      if (_showFab != true) {
                                        setState(() {
                                          _showFab = true;
                                        });
                                      }
                                    } else if (direction == ScrollDirection.reverse) {
                                      if (_showFab != false) {
                                        setState(() {
                                          _showFab = false;
                                        });
                                      }
                                    }
                                    return true;
                                  },
                                  child: ListView(
                                    padding: EdgeInsets.all(10),
                                    children: notes.keys
                                        .map((header) => NoteGroup(
                                              key: ValueKey(header),
                                              state: state,
                                              notes: notes[header]!,
                                              groupHeader: header,
                                              selectedNotes: selectedNotes.intersection(
                                                  notes[header]!.map((e) => e.note).toSet()),
                                              onSelectGroup: (notes) =>
                                                  noteBloc.add(NoteSelectEvent(notes: notes)),
                                              onUnselectGroup: (notes) =>
                                                  noteBloc.add(NoteUnselectEvent(notes: notes)),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                _buildNoteSelectionToolbar(context, selectedNotes),
                                Column(
                                  children: [
                                    const Spacer(flex: 1),
                                    AbsorbPointer(
                                      child: Container(
                                        height: MediaQuery.of(context).padding.bottom,
                                        width: double.infinity,
                                        color: context.themeColors.background.withAlpha(120),
                                      ),
                                    ),
                                  ],
                                ),
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
          noteBloc.add(const NoteInitializeEvent());
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: -0.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
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
      child: InkWell(
        onTap: () {
          widget.onTapHeader();
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        splashColor: context.themeColors.inversePrimary.withAlpha(170),
        highlightColor: context.themeColors.inversePrimary,
        borderRadius: widget.isCollapsed
            ? BorderRadius.circular(26)
            : const BorderRadius.only(
                topRight: Radius.circular(26),
                topLeft: Radius.circular(26),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
        child: AnimatedContainer(
          duration: 250.milliseconds,
          curve: Curves.ease,
          padding: const EdgeInsets.fromLTRB(16, 1, 5, 1),
          decoration: BoxDecoration(
            color: context.themeColors.primaryContainer.withAlpha(widget.isSelected ? 220 : 120),
            border: Border.all(
              color: context.themeColors.primary.withAlpha(widget.isSelected ? 100 : 35),
              width: 0.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            borderRadius: widget.isCollapsed
                ? BorderRadius.circular(26)
                : const BorderRadius.only(
                    topRight: Radius.circular(26),
                    topLeft: Radius.circular(26),
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
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
                        color: context.themeColors.onSecondaryContainer.withAlpha(120),
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
              IconButton(
                onPressed: () {
                  if (widget.isSelected) {
                    widget.onUnselectGroup();
                  } else {
                    widget.onSelectGroup();
                  }
                },
                icon: const Icon(
                  Icons.check_rounded,
                  size: 24,
                ),
                visualDensity: const VisualDensity(horizontal: -1.75, vertical: -1.75),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.isCollapsed
                        ? const BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(24),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(22),
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                  ),
                  backgroundColor: widget.isSelected
                      ? context.themeColors.primary
                      : context.themeColors.primaryContainer,
                  foregroundColor: widget.isSelected
                      ? context.themeColors.onPrimary
                      : context.themeColors.onPrimaryContainer,
                ),
              ),
            ],
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
    required this.notes,
    required this.selectedNotes,
    required this.onSelectGroup,
    required this.onUnselectGroup,
  });

  final String groupHeader;
  final NoteInitializedState state;
  final List<PresentableNoteData> notes;
  final Set<LocalNote> selectedNotes;
  final void Function(Iterable<LocalNote> notes) onSelectGroup;
  final void Function(Iterable<LocalNote> notes) onUnselectGroup;

  @override
  State<NoteGroup> createState() => _NoteGroupState();
}

class _NoteGroupState extends State<NoteGroup> {
  bool isCollapsed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.groupHeader.isNotEmpty)
          NoteListGroupHeader(
            isSelected: (widget.selectedNotes.length == widget.notes.length),
            isCollapsed: isCollapsed,
            groupHeader: widget.groupHeader,
            onTapHeader: () => setState(() {
              isCollapsed = !isCollapsed;
            }),
            onSelectGroup: () => widget.onSelectGroup(widget.notes.map((e) => e.note)),
            onUnselectGroup: () => widget.onUnselectGroup(widget.notes.map((e) => e.note)),
          ),
        AnimatedSwitcher(
          duration: 650.milliseconds,
          switchInCurve: Curves.fastEaseInToSlowEaseOut,
          switchOutCurve: Curves.fastEaseInToSlowEaseOut.flipped,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                axis: Axis.vertical,
                axisAlignment: -1.0,
                sizeFactor: animation,
                child: child,
              ),
            );
          },
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: !isCollapsed
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: NotesListView(
                    layoutPreference: widget.state.layoutPreference,
                    notesData: widget.notes,
                    selectedNotes: widget.selectedNotes,
                    onDeleteNote: (LocalNote note) =>
                        context.read<NoteBloc>().add(NoteDeleteEvent(notes: {note})),
                    onTap: (note, openNote) {
                      if (!(widget.state.hasSelectedNotes)) {
                        openNote();
                      } else {
                        context.read<NoteBloc>().add(NoteTapEvent(note: note));
                      }
                    },
                    onLongPress: (note) =>
                        context.read<NoteBloc>().add(NoteLongPressEvent(note: note)),
                  ),
                )
              : const SizedBox(height: 10),
        ),
      ],
    );
  }
}
