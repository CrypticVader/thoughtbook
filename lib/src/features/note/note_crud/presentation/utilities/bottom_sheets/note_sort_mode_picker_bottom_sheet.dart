import 'dart:developer';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/enums/sort_type.dart';

Future<void> showNoteSortModePickerBottomSheet({
  required BuildContext context,
  required SortOrder sortOrder,
  required SortMode sortMode,
  required Function(SortOrder sortOrder, SortMode sortMode) onSelect,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => NoteSortModePickerView(
      sortOrder: sortOrder,
      onSelect: (SortOrder sortOrder, SortMode sortMode) => onSelect(
        sortOrder,
        sortMode,
      ),
      sortMode: sortMode,
    ),
  );
}

class NoteSortModePickerView extends StatefulWidget {
  final SortOrder sortOrder;
  final SortMode sortMode;
  final Function(SortOrder sortOrder, SortMode sortMode) onSelect;

  const NoteSortModePickerView({
    super.key,
    required this.sortOrder,
    required this.sortMode,
    required this.onSelect,
  });

  @override
  State<NoteSortModePickerView> createState() => _NoteSortModePickerViewState();
}

class _NoteSortModePickerViewState extends State<NoteSortModePickerView> {
  late SortOrder sortOrder;
  late SortMode sortMode;

  @override
  void initState() {
    sortOrder = widget.sortOrder;
    sortMode = widget.sortMode;
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
                    'Sort notes',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SegmentedButton(
                        multiSelectionEnabled: false,
                        emptySelectionAllowed: false,
                        selected: {sortOrder},
                        showSelectedIcon: false,
                        onSelectionChanged: (order) {
                          log(order.first.toString());
                          setState(() {
                            sortOrder = order.first;
                          });
                          widget.onSelect(sortOrder, sortMode);
                        },
                        segments: const [
                          ButtonSegment(
                            value: SortOrder.ascending,
                            icon:
                                Icon(FluentIcons.text_sort_ascending_24_filled),
                            label: Text(
                              'Ascending',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: SortOrder.descending,
                            icon: Icon(
                                FluentIcons.text_sort_descending_24_filled),
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
                    const SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.arrow_sort_24_filled,
                          color: Color.alphaBlend(
                            context.themeColors.surfaceTint.withAlpha(70),
                            context.themeColors.onBackground,
                          ),
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                        Text(
                          'Sort your notes by',
                          style: TextStyle(
                            color: Color.alphaBlend(
                              context.themeColors.surfaceTint.withAlpha(25),
                              context.themeColors.onBackground,
                            ),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    ListTile(
                      onTap: () {
                        setState(() {
                          sortMode = SortMode.dataCreated;
                          widget.onSelect(sortOrder, sortMode);
                        });
                      },
                      title: Text(
                        'Date created',
                        style: TextStyle(
                          color: context.themeColors.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      )),
                      tileColor: context.themeColors.primaryContainer,
                      splashColor: context.themeColors.inversePrimary,
                      leading: Radio(
                        value: SortMode.dataCreated,
                        groupValue: sortMode,
                        onChanged: (_) {
                          setState(() {
                            sortMode = SortMode.dataCreated;
                            widget.onSelect(sortOrder, sortMode);
                          });
                        },
                        activeColor: context.themeColors.primary,
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return context.themeColors.secondary.withAlpha(100);
                          } else if (states.contains(MaterialState.selected)) {
                            return context.themeColors.primary;
                          } else {
                            return context.themeColors.secondary;
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
                          sortMode = SortMode.dateModified;
                          widget.onSelect(sortOrder, sortMode);
                        });
                      },
                      title: Text(
                        'Date modified',
                        style: TextStyle(
                          color: context.themeColors.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      )),
                      tileColor: context.themeColors.primaryContainer,
                      splashColor: context.themeColors.inversePrimary,
                      leading: Radio(
                        value: SortMode.dateModified,
                        groupValue: sortMode,
                        onChanged: (_) {
                          setState(() {
                            sortMode = SortMode.dateModified;
                            widget.onSelect(sortOrder, sortMode);
                          });
                        },
                        activeColor: context.themeColors.primary,
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return context.themeColors.secondary.withAlpha(100);
                          } else if (states.contains(MaterialState.selected)) {
                            return context.themeColors.primary;
                          } else {
                            return context.themeColors.secondary;
                          }
                        }),
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
