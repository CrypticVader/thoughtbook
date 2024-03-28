import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/group_props.dart';

Future<void> showNoteGroupModePickerBottomSheet({
  required BuildContext context,
  required GroupParameter groupParameter,
  required GroupOrder groupOrder,
  required TagGroupLogic tagGroupLogic,
  required void Function(
    GroupParameter groupParameter,
    GroupOrder groupOrder,
    TagGroupLogic tagGroupLogic,
  ) onChangeProps,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => NoteGroupModePickerView(
      groupParameter: groupParameter,
      groupOrder: groupOrder,
      tagGroupLogic: tagGroupLogic,
      onChangeProps: (groupParameter, groupOrder, tagGroupLogic) => onChangeProps(
        groupParameter,
        groupOrder,
        tagGroupLogic,
      ),
    ),
  );
}

class NoteGroupModePickerView extends StatefulWidget {
  final GroupParameter groupParameter;
  final GroupOrder groupOrder;
  final TagGroupLogic tagGroupLogic;
  final void Function(
    GroupParameter groupParameter,
    GroupOrder groupOrder,
    TagGroupLogic tagGroupLogic,
  ) onChangeProps;

  const NoteGroupModePickerView({
    super.key,
    required this.groupParameter,
    required this.groupOrder,
    required this.tagGroupLogic,
    required this.onChangeProps,
  });

  @override
  State<NoteGroupModePickerView> createState() => _NoteGroupModePickerViewState();
}

class _NoteGroupModePickerViewState extends State<NoteGroupModePickerView> {
  late GroupParameter groupParameter;
  late GroupOrder groupOrder;
  late TagGroupLogic tagGroupLogic;
  late final void Function(
    GroupParameter groupParameter,
    TagGroupLogic tagGroupLogic,
  ) onChangeProps;

  @override
  void initState() {
    groupParameter = widget.groupParameter;
    tagGroupLogic = widget.tagGroupLogic;
    groupOrder = widget.groupOrder;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.themeColors;

    final targetPlatform = ScrollConfiguration.of(context).getPlatform(context);
    final isDesktop = {
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }.contains(targetPlatform);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        topLeft: Radius.circular(28),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: isDesktop?0.85:0.5,
        builder: (context, scrollController) {
          return Scaffold(
            backgroundColor: Color.alphaBlend(
              themeColors.surfaceTint.withAlpha(15),
              themeColors.surface,
            ),
            appBar: AppBar(
              backgroundColor: Color.alphaBlend(
                themeColors.surfaceTint.withAlpha(15),
                themeColors.surface,
              ),
              leading: null,
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              centerTitle: true,
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Ink(
                      height: 6.0,
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: themeColors.onSurfaceVariant.withAlpha(100),
                      ),
                    ),
                  ),
                  Text(
                    'Group your notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color.alphaBlend(
                        themeColors.surfaceTint.withAlpha(25),
                        themeColors.onSurface,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: (groupParameter == GroupParameter.dateCreated) ||
                              (groupParameter == GroupParameter.dateModified)
                          ? 1
                          : 0.25,
                      duration: 150.milliseconds,
                      child: Center(
                        child: SegmentedButton<GroupOrder>(
                          multiSelectionEnabled: false,
                          emptySelectionAllowed: false,
                          selected: {groupOrder},
                          showSelectedIcon: false,
                          onSelectionChanged: (order) {
                            setState(() {
                              groupOrder = order.first;
                            });
                            widget.onChangeProps(
                              groupParameter,
                              groupOrder,
                              tagGroupLogic,
                            );
                          },
                          segments: const [
                            ButtonSegment(
                              value: GroupOrder.ascending,
                              icon: Icon(FluentIcons.text_sort_ascending_24_filled),
                              label: Text(
                                'Ascending',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            ButtonSegment(
                              value: GroupOrder.descending,
                              icon: Icon(FluentIcons.text_sort_descending_24_filled),
                              label: Text(
                                'Descending',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Ink(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        color: themeColors.primaryContainer.withAlpha(70),
                        border: Border.all(
                          color: themeColors.primary.withAlpha(20),
                          strokeAlign: BorderSide.strokeAlignInside,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FluentIcons.group_24_filled,
                                  color: Color.alphaBlend(
                                    themeColors.surfaceTint.withAlpha(70),
                                    themeColors.onSurface,
                                  ),
                                  size: 22,
                                ),
                                const SizedBox(
                                  width: 12.0,
                                ),
                                Text(
                                  'Group notes by',
                                  style: TextStyle(
                                    color: Color.alphaBlend(
                                      themeColors.surfaceTint.withAlpha(70),
                                      themeColors.onSurface,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          ListTile(
                            onTap: () {
                              setState(() {
                                groupParameter = GroupParameter.dateCreated;
                              });
                              widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                            },
                            horizontalTitleGap: 8,
                            title: Text(
                              'Date created',
                              style: TextStyle(
                                color: themeColors.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            )),
                            tileColor: themeColors.primaryContainer,
                            splashColor: themeColors.inversePrimary,
                            leading: Radio(
                              value: GroupParameter.dateCreated,
                              groupValue: groupParameter,
                              onChanged: (_) {
                                setState(() {
                                  groupParameter = GroupParameter.dateCreated;
                                });
                                widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                              },
                              activeColor: themeColors.primary,
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return themeColors.secondary.withAlpha(100);
                                } else if (states.contains(MaterialState.selected)) {
                                  return themeColors.primary;
                                } else {
                                  return themeColors.secondary;
                                }
                              }),
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                groupParameter = GroupParameter.dateModified;
                              });
                              widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                            },
                            horizontalTitleGap: 8,
                            title: Text(
                              'Date modified',
                              style: TextStyle(
                                color: themeColors.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            )),
                            tileColor: themeColors.primaryContainer,
                            splashColor: themeColors.inversePrimary,
                            leading: Radio(
                              value: GroupParameter.dateModified,
                              groupValue: groupParameter,
                              onChanged: (_) {
                                setState(() {
                                  groupParameter = GroupParameter.dateModified;
                                });
                                widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                              },
                              activeColor: themeColors.primary,
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return themeColors.secondary.withAlpha(100);
                                } else if (states.contains(MaterialState.selected)) {
                                  return themeColors.primary;
                                } else {
                                  return themeColors.secondary;
                                }
                              }),
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                groupParameter = GroupParameter.tag;
                              });
                              widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                            },
                            horizontalTitleGap: 8,
                            title: Text(
                              'Tag',
                              style: TextStyle(
                                color: themeColors.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            )),
                            tileColor: themeColors.primaryContainer,
                            splashColor: themeColors.inversePrimary,
                            leading: Radio(
                              value: GroupParameter.tag,
                              groupValue: groupParameter,
                              onChanged: (_) {
                                setState(() {
                                  groupParameter = GroupParameter.tag;
                                });
                                widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                              },
                              activeColor: themeColors.primary,
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return themeColors.secondary.withAlpha(100);
                                } else if (states.contains(MaterialState.selected)) {
                                  return themeColors.primary;
                                } else {
                                  return themeColors.secondary;
                                }
                              }),
                            ),
                          ),
                          const SizedBox(
                            height: 2.0,
                          ),
                          ListTile(
                            onTap: () {
                              setState(() {
                                groupParameter = GroupParameter.none;
                              });
                              widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                            },
                            horizontalTitleGap: 8,
                            title: Text(
                              'None',
                              style: TextStyle(
                                color: themeColors.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(28),
                              bottomRight: Radius.circular(28),
                            )),
                            tileColor: themeColors.primaryContainer,
                            splashColor: themeColors.inversePrimary,
                            leading: Radio(
                              value: GroupParameter.none,
                              groupValue: groupParameter,
                              onChanged: (_) {
                                setState(() {
                                  groupParameter = GroupParameter.none;
                                });
                                widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                              },
                              activeColor: themeColors.primary,
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return themeColors.secondary.withAlpha(100);
                                } else if (states.contains(MaterialState.selected)) {
                                  return themeColors.primary;
                                } else {
                                  return themeColors.secondary;
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AbsorbPointer(
                      absorbing: groupParameter != GroupParameter.tag,
                      child: AnimatedOpacity(
                        duration: 150.milliseconds,
                        curve: Curves.ease,
                        opacity: (groupParameter != GroupParameter.tag) ? 0.25 : 1,
                        child: Ink(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            color: themeColors.secondaryContainer.withAlpha(70),
                            border: Border.all(
                              color: themeColors.secondary.withAlpha(20),
                              strokeAlign: BorderSide.strokeAlignInside,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      FluentIcons.options_24_filled,
                                      color: Color.alphaBlend(
                                        themeColors.surfaceTint.withAlpha(70),
                                        themeColors.onSurface,
                                      ),
                                      size: 24,
                                    ),
                                    const SizedBox(
                                      width: 12.0,
                                    ),
                                    Flexible(
                                      child: Text(
                                        'Choose the grouping preference for notes with multiple tags',
                                        style: TextStyle(
                                          color: Color.alphaBlend(
                                            themeColors.surfaceTint.withAlpha(70),
                                            themeColors.onSurface,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    tagGroupLogic = TagGroupLogic.separateCombinations;
                                  });
                                  widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                },
                                horizontalTitleGap: 8,
                                title: Text(
                                  'Separate each tag combination into a different group.',
                                  style: TextStyle(
                                    color: themeColors.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 12.0, 4.0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                )),
                                tileColor: themeColors.secondaryContainer,
                                splashColor: themeColors.secondary.withAlpha(70),
                                leading: Radio(
                                  value: TagGroupLogic.separateCombinations,
                                  groupValue: tagGroupLogic,
                                  onChanged: (_) {
                                    setState(() {
                                      tagGroupLogic = TagGroupLogic.separateCombinations;
                                    });
                                    widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                  },
                                  activeColor: themeColors.primary,
                                  fillColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return themeColors.secondary.withAlpha(100);
                                    } else if (states.contains(MaterialState.selected)) {
                                      return themeColors.primary;
                                    } else {
                                      return themeColors.secondary;
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    tagGroupLogic = TagGroupLogic.showInAll;
                                  });
                                  widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                },
                                horizontalTitleGap: 8,
                                title: Text(
                                  'Display note in the groups for all of its tags.',
                                  style: TextStyle(
                                    color: themeColors.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 12.0, 4.0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                )),
                                tileColor: themeColors.secondaryContainer,
                                splashColor: themeColors.secondary.withAlpha(70),
                                leading: Radio(
                                  value: TagGroupLogic.showInAll,
                                  groupValue: tagGroupLogic,
                                  onChanged: (_) {
                                    setState(() {
                                      tagGroupLogic = TagGroupLogic.showInAll;
                                    });
                                    widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                  },
                                  activeColor: themeColors.primary,
                                  fillColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return themeColors.secondary.withAlpha(100);
                                    } else if (states.contains(MaterialState.selected)) {
                                      return themeColors.primary;
                                    } else {
                                      return themeColors.secondary;
                                    }
                                  }),
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              ListTile(
                                onTap: () {
                                  setState(() {
                                    tagGroupLogic = TagGroupLogic.showInOne;
                                  });
                                  widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                },
                                horizontalTitleGap: 8,
                                title: Text(
                                  'Display note in a group for one of its tags.',
                                  style: TextStyle(
                                    color: themeColors.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 12.0, 4.0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                )),
                                tileColor: themeColors.secondaryContainer,
                                splashColor: themeColors.secondary.withAlpha(70),
                                leading: Radio(
                                  value: TagGroupLogic.showInOne,
                                  groupValue: tagGroupLogic,
                                  onChanged: (_) {
                                    setState(() {
                                      tagGroupLogic = TagGroupLogic.showInOne;
                                    });
                                    widget.onChangeProps(groupParameter, groupOrder, tagGroupLogic);
                                  },
                                  activeColor: themeColors.primary,
                                  fillColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.disabled)) {
                                      return themeColors.secondary.withAlpha(100);
                                    } else if (states.contains(MaterialState.selected)) {
                                      return themeColors.primary;
                                    } else {
                                      return themeColors.secondary;
                                    }
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
