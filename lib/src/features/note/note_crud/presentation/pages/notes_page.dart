import 'dart:math' show min;

import 'package:animations/animations.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocConsumer, BlocProvider, ReadContext;
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/main.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/object/null_check.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/note_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/group_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/sort_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_trash_bloc/note_trash_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/pages/note_editor_page.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/pages/note_trash_page.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/note_filter_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/note_group_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/note_sort_mode_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/bottom_sheets/tag_editor_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/shared_widgets/widgets/notes_list_view.dart';
import 'package:thoughtbook/src/features/settings/presentation/settings_view.dart';
import 'package:thoughtbook/src/features/settings/services/app_preference/enums/preference_values.dart';
import 'package:thoughtbook/src/utilities/common_widgets/tonal_chip.dart';
import 'package:thoughtbook/src/utilities/dialogs/logout_dialog.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
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
    NoteInitialized state,
    bool isScrolled,
  ) {
    final layoutPreference = state.layoutPreference;
    final groupChipLabel = switch (state.groupProps.groupParameter) {
      GroupParameter.dateModified => 'Date modified',
      GroupParameter.dateCreated => 'Date created',
      GroupParameter.tag => 'Tag',
      GroupParameter.none => 'Ungrouped',
    };

    final hasFilters = (state.filterProps != FilterProps.noFilters());
    String filterChipLabel() {
      final props = state.filterProps;
      if (props ==
          (FilterProps.noFilters()..requireEntireTagFilter = props.requireEntireTagFilter)) {
        return 'All notes';
      } else {
        final tagCount = props.filterTagIds.length;
        final colorCount = props.filterColors.length;
        final hasCreatedRange = props.createdRange.isNotNull;
        final hasModifiedRange = props.modifiedRange.isNotNull;

        String chipLabel = '';
        if (tagCount > 0) {
          chipLabel += '$tagCount tag${(tagCount > 1) ? 's' : ''}';
        }
        if (colorCount > 0) {
          if (chipLabel.isNotEmpty) {
            chipLabel += ' • ';
          }
          chipLabel += '$colorCount color${(colorCount > 1) ? 's' : ''}';
        }
        if (hasCreatedRange) {
          if (chipLabel.length > 20) {
            chipLabel = 'Multiple filters';
          } else {
            if (chipLabel.isNotEmpty) chipLabel += ' • ';
            chipLabel += 'Created between';
          }
        }
        if (hasModifiedRange) {
          if (chipLabel.length > 20) {
            chipLabel = 'Multiple filters';
          } else {
            if (chipLabel.isNotEmpty) chipLabel += ' • ';
            chipLabel += 'Modified between';
          }
        }

        return chipLabel;
      }
    }

    final targetPlatform = ScrollConfiguration.of(context).getPlatform(context);
    final isDesktop = {
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }.contains(targetPlatform);

    final chipBackgroundColor = Color.alphaBlend(
      context.themeColors.inversePrimary.withAlpha(80),
      context.themeColors.surfaceVariant.withAlpha(80),
    );

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
              FluentIcons.line_horizontal_3_20_regular,
              color: context.themeColors.onSecondaryContainer,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              iconSize: 26,
              backgroundColor: context.themeColors.inversePrimary.withAlpha(50),
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
                  textBaseline: TextBaseline.alphabetic,
                  color: context.themeColors.onSecondaryContainer.withAlpha(150),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(
                    strokeAlign: BorderSide.strokeAlignInside,
                    width: 1,
                    color: context.themeColors.onSurfaceVariant.withAlpha(70),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Color.alphaBlend(
                  context.themeColors.inversePrimary.withAlpha(40),
                  context.themeColors.surfaceVariant.withAlpha(isScrolled ? 100 : 40),
                ),
                filled: true,
                hintText: 'Search your notes & tags',
                prefixIcon: Icon(
                  FluentIcons.search_24_regular,
                  color: context.themeColors.onSecondaryContainer.withAlpha(200),
                ),
                suffix: Tooltip(
                  message: 'Clear',
                  child: InkWell(
                    onTap: () {
                      context.read<NoteBloc>().add(const NoteSearchEvent(query: ''));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text(
                        '✕',
                        style: TextStyle(color: context.themeColors.onSecondaryContainer),
                      ),
                    ),
                  ),
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
                    ? FluentIcons.grid_28_regular
                    : FluentIcons.list_28_regular,
                key: ValueKey<String>(layoutPreference),
                color: context.themeColors.onSecondaryContainer,
              ),
            ),
            tooltip: (layoutPreference == LayoutPreference.list.value)
                ? context.loc.notes_view_grid_layout
                : context.loc.notes_view_list_layout,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              iconSize: 26,
              backgroundColor: context.themeColors.inversePrimary.withAlpha(40),
              foregroundColor: context.themeColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                label: filterChipLabel(),
                iconData: FluentIcons.filter_24_filled,
                backgroundColor:
                    hasFilters ? context.themeColors.tertiaryContainer : chipBackgroundColor,
                foregroundColor: hasFilters
                    ? context.themeColors.onTertiaryContainer
                    : context.themeColors.onSecondaryContainer,
                borderColor: Colors.transparent,
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
                label:
                    state.sortProps.mode == SortMode.dateCreated ? 'Date created' : 'Date modified',
                iconData: FluentIcons.arrow_sort_24_filled,
                backgroundColor: chipBackgroundColor,
                foregroundColor: context.themeColors.onSecondaryContainer,
                borderColor: Colors.transparent,
              ),
              const SizedBox(width: 8),
              TonalChip(
                onTap: null,
                // onTap: () async => await showNoteGroupModePickerBottomSheet(
                //   context: context,
                //   groupParameter: state.groupProps.groupParameter,
                //   groupOrder: state.groupProps.groupOrder,
                //   tagGroupLogic: state.groupProps.tagGroupLogic,
                //   onChangeProps: (groupParameter, groupOrder, tagGroupLogic) =>
                //       context.read<NoteBloc>().add(NoteModifyGroupPropsEvent(
                //             groupParameter: groupParameter,
                //             groupOrder: groupOrder,
                //             tagGroupLogic: tagGroupLogic,
                //           )),
                // ),
                label: groupChipLabel,
                iconData: FluentIcons.group_24_filled,
                backgroundColor: chipBackgroundColor,
                foregroundColor: context.themeColors.onSecondaryContainer,
                borderColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSelectionToolbar({
    required BuildContext context,
    required Set<LocalNote> selectedNotes,
    required void Function()? onSelectAll,
  }) {
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
                          onPressed: onSelectAll,
                          icon: const Icon(
                            FluentIcons.select_all_on_24_filled,
                          ),
                          style: IconButton.styleFrom(
                            disabledForegroundColor: context.themeColors.onPrimary.withAlpha(100),
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
    NoteInitialized state,
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
                              child: const NoteTrashPage(),
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
        if (state is NoteInitialized) {
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
        if (state is NoteUninitialized) {
          noteBloc.add(const NoteInitializeEvent());
          return const Scaffold(body: SplashScreen());
        } else if (state is NoteInitialized) {
          return PopScope(
            canPop: !(state.hasSelectedNotes),
            onPopInvoked: (didPop) {
              if (!didPop) noteBloc.add(const NoteUnselectAllEvent());
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
                            child: NoteEditorPage(
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
                                  child: NotesListView(
                                    layoutPreference: state.layoutPreference,
                                    notesData: notes['']!,
                                    selectedNotes: selectedNotes,
                                    onDeleteNote: (LocalNote note) => context
                                        .read<NoteBloc>()
                                        .add(NoteDeleteEvent(notes: {note})),
                                    onTap: (note, openNote) {
                                      if (!(state.hasSelectedNotes)) {
                                        openNote();
                                      } else {
                                        context.read<NoteBloc>().add(NoteTapEvent(note: note));
                                      }
                                    },
                                    onLongPress: (note) => context
                                        .read<NoteBloc>()
                                        .add(NoteLongPressEvent(note: note)),
                                  ),
                                  // child: Column(
                                  //   children: notes.keys
                                  //       .map((header) => NoteGroup(
                                  //             key: ValueKey(header),
                                  //             state: state,
                                  //             notes: notes[header]!,
                                  //             groupHeader: header,
                                  //             selectedNotes: selectedNotes.intersection(
                                  //                 notes[header]!.map((e) => e.note).toSet()),
                                  //             onSelectGroup: (notes) =>
                                  //                 noteBloc.add(NoteSelectEvent(notes: notes)),
                                  //             onUnselectGroup: (notes) =>
                                  //                 noteBloc.add(NoteUnselectEvent(notes: notes)),
                                  //           ))
                                  //       .toList(),
                                  // ),
                                ),
                                _buildNoteSelectionToolbar(
                                  context: context,
                                  selectedNotes: selectedNotes,
                                  onSelectAll: () {
                                    final visibleNotes =
                                        notes.values.flatten().map((noteData) => noteData.note);
                                    noteBloc.add(NoteSelectEvent(notes: visibleNotes));
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          final selectedNotes = snapshot.data?.$2 ?? {};
                          return Stack(
                            children: [
                              Center(
                                child: Ink(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: context.themeColors.secondaryContainer.withAlpha(120),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FluentIcons.notebook_24_filled,
                                        size: 150,
                                        color: context.theme.colorScheme.onSecondaryContainer
                                            .withAlpha(150),
                                      ),
                                      const SizedBox(height: 16.0),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 228,
                                        ),
                                        child: Text(
                                          'We did not find any notes.',
                                          maxLines: 3,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: context.theme.colorScheme.onSecondaryContainer
                                                .withAlpha(220),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _buildNoteSelectionToolbar(
                                context: context,
                                selectedNotes: selectedNotes,
                                onSelectAll: null,
                              ),
                            ],
                          );
                        }
                      default:
                        return const Scaffold(body: SplashScreen());
                    }
                  },
                ),
              ),
            ),
          );
        } else {
          noteBloc.add(const NoteInitializeEvent());
          return const Scaffold(body: SplashScreen());
        }
      },
    );
  }
}