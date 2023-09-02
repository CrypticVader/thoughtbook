import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/common_widgets/tonal_chip.dart';

Future<void> showNoteFilterPickerBottomSheet({
  required BuildContext context,
  required ValueStream<List<LocalNoteTag>> Function() allTags,
  required Set<int> currentFilter,
  required bool requireEntireFilter,
  required void Function(int? tagId, bool requireEntireFilter) onSelect,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => NoteFilterPickerView(
      allTags: allTags,
      currentFilter: currentFilter,
      requireEntireFilter: requireEntireFilter,
      onSelect: (tagId, requireEntireFilter) => onSelect(
        tagId,
        requireEntireFilter,
      ),
    ),
  );
}

class NoteFilterPickerView extends StatefulWidget {
  const NoteFilterPickerView({
    super.key,
    required this.allTags,
    required this.currentFilter,
    required this.requireEntireFilter,
    required this.onSelect,
  });

  final ValueStream<List<LocalNoteTag>> Function() allTags;
  final Set<int> currentFilter;
  final bool requireEntireFilter;
  final void Function(int? tagId, bool requireEntireFilter) onSelect;

  @override
  State<NoteFilterPickerView> createState() => _NoteFilterPickerViewState();
}

class _NoteFilterPickerViewState extends State<NoteFilterPickerView> {
  late Set<int> filterIds;
  late bool requireEntireFilter;

  @override
  void initState() {
    filterIds = widget.currentFilter;
    requireEntireFilter = widget.requireEntireFilter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        topLeft: Radius.circular(28),
      ),
      child: DraggableScrollableSheet(
        maxChildSize: 0.75,
        initialChildSize: 0.35,
        minChildSize: 0.35,
        expand: false,
        builder: (context, scrollController) {
          return Scaffold(
            backgroundColor: Color.alphaBlend(
              context.themeColors.surfaceTint.withAlpha(25),
              context.themeColors.background,
            ),
            appBar: AppBar(
              backgroundColor: Color.alphaBlend(
                context.themeColors.surfaceTint.withAlpha(25),
                context.themeColors.background,
              ),
              leading: null,
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              centerTitle: true,
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    child: Ink(
                      height: 6.0,
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color:
                            context.themeColors.onSurfaceVariant.withAlpha(100),
                      ),
                    ),
                  ),
                  Text(
                    'Filter your notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color.alphaBlend(
                        context.themeColors.surfaceTint.withAlpha(25),
                        context.themeColors.onBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder(
                  stream: widget.allTags(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final children = snapshot.data!
                          .map<Widget>((tag) => UnconstrainedBox(
                                child: TonalChip(
                                  padding: const EdgeInsets.all(12.0),
                                  borderRadius: BorderRadius.circular(18),
                                  textStyle: TextStyle(
                                    color: filterIds.contains(tag.isarId)
                                        ? context.themeColors.onPrimaryContainer
                                        : context
                                            .themeColors.onSecondaryContainer
                                            .withAlpha(220),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.0,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (filterIds.contains(tag.isarId)) {
                                        filterIds.remove(tag.isarId);
                                      } else {
                                        filterIds.add(tag.isarId);
                                      }
                                    });
                                    widget.onSelect(
                                        tag.isarId, requireEntireFilter);
                                  },
                                  label: tag.name,
                                  iconData: null,
                                  backgroundColor: filterIds
                                          .contains(tag.isarId)
                                      ? context.themeColors.inversePrimary
                                      : context.themeColors.secondaryContainer
                                          .withAlpha(200),
                                ),
                              ))
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                requireEntireFilter = !requireEntireFilter;
                              });
                              widget.onSelect(null, requireEntireFilter);
                            },
                            splashColor:
                                context.themeColors.tertiary.withAlpha(40),
                            highlightColor:
                                context.themeColors.tertiary.withAlpha(40),
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: context.themeColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                      color: context
                                          .themeColors.onTertiaryContainer,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0)),
                                    activeColor: context.themeColors.tertiary,
                                    checkColor: context.themeColors.onTertiary,
                                    value: requireEntireFilter,
                                    onChanged: (_) {
                                      setState(() {
                                        requireEntireFilter =
                                            !requireEntireFilter;
                                      });
                                      widget.onSelect(
                                          null, requireEntireFilter);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 12.0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Show only the notes with all of the selected tags.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: context
                                              .themeColors.onTertiaryContainer,
                                          fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            indent: 16,
                            endIndent: 16,
                            height: 36,
                          ),
                          Row(
                            children: [
                              Icon(
                                FluentIcons.tag_multiple_24_filled,
                                color: Color.alphaBlend(
                                  context.themeColors.surfaceTint.withAlpha(40),
                                  context.themeColors.onBackground,
                                ),
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                'Select tags to view notes from',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.alphaBlend(
                                      context.themeColors.surfaceTint
                                          .withAlpha(40),
                                      context.themeColors.onBackground,
                                    ),
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12.0,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                alignment: WrapAlignment.start,
                                runAlignment: WrapAlignment.start,
                                runSpacing: 10.0,
                                spacing: 10.0,
                                children: children,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Placeholder();
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
