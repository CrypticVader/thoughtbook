import 'dart:developer' show log;
import 'dart:math' show min;

import 'package:dartx/dartx.dart';
import 'package:entry/entry.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/object/null_check.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_bloc/types/filter_props.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note_tag.dart';
import 'package:thoughtbook/src/utilities/common_widgets/tonal_chip.dart';

typedef FilterPropsCallback = void Function(FilterProps newProps);

Future<void> showNoteFilterPickerBottomSheet({
  required BuildContext context,
  required ValueStream<List<LocalNoteTag>> Function() allTags,
  required FilterProps filterProps,
  required Map<String, Color> allColors,
  required FilterPropsCallback onChange,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints(maxWidth: 640.0, maxHeight: MediaQuery.of(context).size.height),
    builder: (context) => Entry(
      opacity: 0,
      duration: 400.milliseconds,
      curve: Curves.decelerate,
      child: NoteFilterPickerView(
        allTags: allTags,
        allColors: allColors,
        filterProps: filterProps,
        onChange: (newProps) => onChange(newProps),
      ),
    ),
  );
}

class NoteFilterPickerView extends StatefulWidget {
  const NoteFilterPickerView({
    super.key,
    required this.filterProps,
    required this.allTags,
    required this.allColors,
    required this.onChange,
  });

  final FilterProps filterProps;
  final ValueStream<List<LocalNoteTag>> Function() allTags;
  final Map<String, Color> allColors;
  final FilterPropsCallback onChange;

  @override
  State<NoteFilterPickerView> createState() => _NoteFilterPickerViewState();
}

class _NoteFilterPickerViewState extends State<NoteFilterPickerView> {
  late FilterProps filterProps;

  @override
  void initState() {
    filterProps = widget.filterProps;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        minChildSize: 0.35,
        initialChildSize: isDesktop ? 0.85 : 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Scaffold(
            backgroundColor: Color.alphaBlend(
              context.themeColors.surfaceTint.withAlpha(15),
              context.themeColors.background,
            ),
            appBar: AppBar(
              backgroundColor: Color.alphaBlend(
                context.themeColors.surfaceTint.withAlpha(15),
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
                        color: context.themeColors.onSurfaceVariant.withAlpha(100),
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
                      final tags = snapshot.data!;
                      final List<Widget> tagWidgetsRow1 = [], tagWidgetsRow2 = [];
                      var row1Width = 0.0;
                      var row2Width = 0.0;
                      final parentWidth = min(640.0, MediaQuery.of(context).size.width) - 88.0;
                      log(parentWidth.toString());
                      for (var i = 0; i < tags.length; i++) {
                        final tagWidget = TonalChip(
                          borderColor: (filterProps.filterTagIds.contains(tags[i].isarId))
                              ? Colors.transparent
                              : context.themeColors.secondary.withAlpha(70),
                          padding: const EdgeInsets.all(12.0),
                          borderRadius: BorderRadius.circular(18),
                          textStyle: TextStyle(
                            color: (filterProps.filterTagIds.contains(tags[i].isarId))
                                ? context.themeColors.onPrimary
                                : context.themeColors.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.0,
                          ),
                          onTap: () {
                            setState(() {
                              if (filterProps.filterTagIds.contains(tags[i].isarId)) {
                                filterProps.filterTagIds.remove(tags[i].isarId);
                              } else {
                                filterProps.filterTagIds;
                                filterProps.filterTagIds.add(tags[i].isarId);
                              }
                            });
                            widget.onChange(filterProps);
                          },
                          label: tags[i].name,
                          iconData: null,
                          backgroundColor: (filterProps.filterTagIds.contains(tags[i].isarId))
                              ? context.themeColors.primary
                              : context.themeColors.primaryContainer.withAlpha(200),
                          splashColor: context.themeColors.inversePrimary,
                        );
                        final widgetWidth = (TextPainter(
                          text: TextSpan(
                                  text: tags[i].name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                      fontFamily: 'Montserrat')),
                              maxLines: 1,
                              textScaler: MediaQuery.of(context).textScaler,
                              textDirection: TextDirection.ltr,
                            )..layout())
                                .size
                                .width +
                            26.0;
                        if (((row1Width + widgetWidth) <= parentWidth) || (row1Width < row2Width)) {
                          row1Width += widgetWidth;
                          if (tagWidgetsRow1.isNotEmpty) {
                            tagWidgetsRow1.add(const SizedBox(width: 8));
                            row1Width += 8.0;
                          }
                          tagWidgetsRow1.add(tagWidget);
                        } else {
                          row2Width += widgetWidth;
                          if (tagWidgetsRow2.isNotEmpty) {
                            tagWidgetsRow2.add(const SizedBox(width: 8));
                            row2Width += 8.0;
                          }
                          tagWidgetsRow2.add(tagWidget);
                        }
                        log('$row1Width, $row2Width');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag Filter
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              color: context.themeColors.primaryContainer.withAlpha(70),
                              border: Border.all(
                                color: context.themeColors.primary.withAlpha(15),
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FluentIcons.tag_multiple_24_filled,
                                        color: context.themeColors.onPrimaryContainer,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      Text(
                                        'Filter notes by tags',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: context.themeColors.onPrimaryContainer,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Spacer(flex: 1),
                                      IconButton.filledTonal(
                                        onPressed: () {
                                          setState(() {
                                            filterProps.filterTagIds = {};
                                          });
                                          widget.onChange(filterProps);
                                        },
                                        icon: const Icon(FluentIcons.arrow_reset_24_regular),
                                        style: IconButton.styleFrom(
                                          foregroundColor: context.themeColors.onPrimaryContainer,
                                          backgroundColor: context.themeColors.primaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                  child: CustomPaint(
                                    foregroundPainter: HorizontalFadingGradient(
                                      color: Color.alphaBlend(
                                        context.themeColors.primaryContainer.withAlpha(220),
                                        context.themeColors.background,
                                      ),
                                    ),
                                    child: Container(
                                      constraints: const BoxConstraints(minWidth: double.infinity),
                                      decoration: BoxDecoration(
                                        color: Color.alphaBlend(
                                          context.themeColors.primaryContainer.withAlpha(220),
                                          context.themeColors.background,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(28),
                                          topRight: Radius.circular(28),
                                          bottomLeft: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      child: Scrollbar(
                                        thickness: isDesktop ? 8 : 0,
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(14),
                                          scrollDirection: Axis.horizontal,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: tagWidgetsRow1,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: tagWidgetsRow2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2.5),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      filterProps.requireEntireTagFilter =
                                          !(filterProps.requireEntireTagFilter);
                                    });
                                    widget.onChange(filterProps);
                                  },
                                  splashColor: context.themeColors.secondary.withAlpha(40),
                                  highlightColor: context.themeColors.secondary.withAlpha(40),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    topLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(28),
                                  ),
                                  child: Ink(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      color: context.themeColors.secondaryContainer.withAlpha(220),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(28),
                                        bottomLeft: Radius.circular(28),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          side: BorderSide(
                                            color: context.themeColors.secondary,
                                            width: 2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4.0)),
                                          activeColor: context.themeColors.secondary,
                                          checkColor: context.themeColors.onSecondary,
                                          value: filterProps.requireEntireTagFilter,
                                          onChanged: (_) {
                                            setState(() {
                                              filterProps.requireEntireTagFilter =
                                                  !(filterProps.requireEntireTagFilter);
                                            });
                                            widget.onChange(filterProps);
                                          },
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Text(
                                            'Show only the notes with all of the selected tags.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: context.themeColors.onSecondaryContainer,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Color Filter
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              color: context.themeColors.primaryContainer.withAlpha(70),
                              border: Border.all(
                                color: context.themeColors.primary.withAlpha(15),
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FluentIcons.color_24_filled,
                                        color: context.themeColors.onPrimaryContainer,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      Text(
                                        'Filter notes by color',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: context.themeColors.onPrimaryContainer,
                                            fontSize: 15),
                                      ),
                                      const Spacer(flex: 1),
                                      IconButton.filledTonal(
                                        onPressed: () {
                                          setState(() {
                                            filterProps.filterColors = {};
                                          });
                                          widget.onChange(filterProps);
                                        },
                                        icon: const Icon(FluentIcons.arrow_reset_24_regular),
                                        style: IconButton.styleFrom(
                                          foregroundColor: context.themeColors.onPrimaryContainer,
                                          backgroundColor: context.themeColors.primaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(28),
                                    topRight: Radius.circular(28),
                                    bottomLeft: Radius.circular(28),
                                    bottomRight: Radius.circular(28),
                                  ),
                                  child: CustomPaint(
                                    foregroundPainter: HorizontalFadingGradient(
                                        color: Color.alphaBlend(
                                      context.themeColors.secondaryContainer.withAlpha(220),
                                      context.themeColors.background,
                                    )),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color:
                                            context.themeColors.secondaryContainer.withAlpha(220),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(28),
                                          topRight: Radius.circular(28),
                                          bottomLeft: Radius.circular(28),
                                          bottomRight: Radius.circular(28),
                                        ),
                                      ),
                                      child: Scrollbar(
                                        thickness: isDesktop ? 8 : 0,
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(maxHeight: 160),
                                            child: Material(
                                              type: MaterialType.transparency,
                                              child: Wrap(
                                                spacing: 4,
                                                runSpacing: 8,
                                                direction: Axis.vertical,
                                                children: widget.allColors.keys
                                                    .map<Widget>((key) => Tooltip(
                                                          message: key,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.only(bottom: 4),
                                                            child: InkWell(
                                                              splashColor: widget.allColors[key],
                                                              borderRadius:
                                                                  BorderRadius.circular(36),
                                                              onTap: () {
                                                                setState(() {
                                                                  if (filterProps.filterColors
                                                                      .contains(widget
                                                                          .allColors[key]!.value)) {
                                                                    filterProps.filterColors.remove(
                                                                        widget
                                                                            .allColors[key]!.value);
                                                                  } else {
                                                                    filterProps.filterColors.add(
                                                                        widget
                                                                            .allColors[key]!.value);
                                                                  }
                                                                });
                                                                widget.onChange(filterProps);
                                                              },
                                                              child: Ink(
                                                                height: 70,
                                                                width: 70,
                                                                decoration: BoxDecoration(
                                                                  color: widget.allColors[key]!
                                                                      .withAlpha(filterProps
                                                                              .filterColors
                                                                              .contains(widget
                                                                                  .allColors[key]!
                                                                                  .value)
                                                                          ? 150
                                                                          : 190),
                                                                  shape: BoxShape.circle,
                                                                  boxShadow: kElevationToShadow[
                                                                      filterProps.filterColors
                                                                              .contains(widget
                                                                                  .allColors[key]!
                                                                                  .value)
                                                                          ? 0
                                                                          : 1],
                                                                  border: filterProps.filterColors
                                                                          .contains(widget
                                                                              .allColors[key]!
                                                                              .value)
                                                                      ? Border.all(
                                                                          color: Color.alphaBlend(
                                                                            context.themeColors
                                                                                .inverseSurface
                                                                                .withAlpha(120),
                                                                            widget.allColors[key]!,
                                                                          ),
                                                                          width: 2)
                                                                      : null,
                                                                ),
                                                                child: filterProps.filterColors
                                                                        .contains(widget
                                                                            .allColors[key]!.value)
                                                                    ? Center(
                                                                        child: Icon(
                                                                          Icons.check_rounded,
                                                                          size: 40,
                                                                          color: Color.alphaBlend(
                                                                            context.themeColors
                                                                                .inverseSurface
                                                                                .withAlpha(120),
                                                                            widget.allColors[key]!,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : null,
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Date created filter
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              color: context.themeColors.primaryContainer.withAlpha(70),
                              border: Border.all(
                                color: context.themeColors.primary.withAlpha(15),
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FluentIcons.calendar_24_filled,
                                        color: context.themeColors.onPrimaryContainer,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Filter notes by date of creation',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: context.themeColors.onPrimaryContainer,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
                                          decoration: BoxDecoration(
                                            color: context.themeColors.surfaceVariant,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(4),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'From',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: context.themeColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                filterProps.createdRange.isNull
                                                    ? 'Not selected'
                                                    : '${switch (filterProps.createdRange!.start.day) {
                                                        1 => '1st',
                                                        2 => '2nd',
                                                        3 => '3rd',
                                                        int() =>
                                                          '${filterProps.createdRange!.start.day}th',
                                                      }} '
                                                        '${kMonthToString[filterProps.createdRange!.start.month]}, '
                                                        '${filterProps.createdRange!.start.year}',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: context.themeColors.onPrimaryContainer
                                                      .withAlpha(filterProps.createdRange.isNull
                                                          ? 200
                                                          : 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
                                          decoration: BoxDecoration(
                                            color: context.themeColors.surfaceVariant,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(24),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Till',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: context.themeColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                filterProps.createdRange.isNull
                                                    ? 'Not selected'
                                                    : '${switch (filterProps.createdRange!.end.day) {
                                                        1 => '1st',
                                                        2 => '2nd',
                                                        3 => '3rd',
                                                        int() =>
                                                          '${filterProps.createdRange!.end.day}th',
                                                      }} '
                                                        '${kMonthToString[filterProps.createdRange!.end.month]}, '
                                                        '${filterProps.createdRange!.end.year}',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: context.themeColors.onPrimaryContainer
                                                      .withAlpha(filterProps.createdRange.isNull
                                                          ? 200
                                                          : 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          final DateTimeRange? range = await showDateRangePicker(
                                            context: context,
                                            firstDate: DateTime(2022),
                                            lastDate: DateTime.now(),
                                          );
                                          if (range.isNotNull) {
                                            setState(() {
                                              filterProps.createdRange = range;
                                            });
                                            widget.onChange(filterProps);
                                          }
                                        },
                                        label: const Text('Select range'),
                                        icon: const Icon(FluentIcons.calendar_agenda_24_regular),
                                        style: TextButton.styleFrom(
                                          backgroundColor: context.themeColors.primaryContainer,
                                          foregroundColor: context.themeColors.onPrimaryContainer,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                topLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                                bottomLeft: Radius.circular(24)),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: filterProps.createdRange.isNotNull
                                            ? () async {
                                          setState(() {
                                            filterProps.createdRange = null;
                                          });
                                          widget.onChange(filterProps);
                                        }
                                            : null,
                                        label: const Text('Reset'),
                                        icon: const Icon(FluentIcons.arrow_reset_24_regular),
                                        style: TextButton.styleFrom(
                                          backgroundColor: context.themeColors.surfaceVariant.withAlpha(200),
                                          foregroundColor: context.themeColors.onSurface,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                topLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(24),
                                                bottomLeft: Radius.circular(4)),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Date modified filter
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              color: context.themeColors.primaryContainer.withAlpha(70),
                              border: Border.all(
                                color: context.themeColors.primary.withAlpha(15),
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FluentIcons.calendar_24_filled,
                                        color: context.themeColors.onPrimaryContainer,
                                      ),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      Flexible(
                                        child: Text(
                                          'Filter notes by date of modification',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: context.themeColors.onPrimaryContainer,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
                                          decoration: BoxDecoration(
                                            color: context.themeColors.surfaceVariant,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              topRight: Radius.circular(4),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'From',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: context.themeColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                filterProps.modifiedRange.isNull
                                                    ? 'Not selected'
                                                    : '${switch (filterProps.modifiedRange!.start.day) {
                                                        1 => '1st',
                                                        2 => '2nd',
                                                        3 => '3rd',
                                                        int() =>
                                                          '${filterProps.modifiedRange!.start.day}th',
                                                      }} '
                                                        '${kMonthToString[filterProps.modifiedRange!.start.month]}, '
                                                        '${filterProps.modifiedRange!.start.year}',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: context.themeColors.onPrimaryContainer
                                                      .withAlpha(filterProps.modifiedRange.isNull
                                                          ? 200
                                                          : 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Ink(
                                          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 18),
                                          decoration: BoxDecoration(
                                            color: context.themeColors.surfaceVariant,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(24),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Till',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: context.themeColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                filterProps.modifiedRange.isNull
                                                    ? 'Not selected'
                                                    : '${switch (filterProps.modifiedRange!.end.day) {
                                                        1 => '1st',
                                                        2 => '2nd',
                                                        3 => '3rd',
                                                        int() =>
                                                          '${filterProps.modifiedRange!.end.day}th',
                                                      }} '
                                                        '${kMonthToString[filterProps.modifiedRange!.end.month]}, '
                                                        '${filterProps.modifiedRange!.end.year}',
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                  color: context.themeColors.onPrimaryContainer
                                                      .withAlpha(filterProps.modifiedRange.isNull
                                                          ? 200
                                                          : 255),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          final DateTimeRange? range = await showDateRangePicker(
                                            context: context,
                                            firstDate: DateTime(2022),
                                            lastDate: DateTime.now(),
                                          );
                                          if (range.isNotNull) {
                                            setState(() {
                                              filterProps.modifiedRange = range;
                                            });
                                            widget.onChange(filterProps);
                                          }
                                        },
                                        label: const Text('Select range'),
                                        icon: const Icon(FluentIcons.calendar_agenda_24_regular),
                                        style: TextButton.styleFrom(
                                          backgroundColor: context.themeColors.primaryContainer,
                                          foregroundColor: context.themeColors.onPrimaryContainer,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                topLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                                bottomLeft: Radius.circular(24)),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: filterProps.modifiedRange.isNotNull
                                            ? () async {
                                                setState(() {
                                                  filterProps.modifiedRange = null;
                                                });
                                                widget.onChange(filterProps);
                                              }
                                            : null,
                                        label: const Text('Reset'),
                                        icon: const Icon(FluentIcons.arrow_reset_24_regular),
                                        style: TextButton.styleFrom(
                                          backgroundColor: context.themeColors.surfaceVariant.withAlpha(200),
                                          foregroundColor: context.themeColors.onSurface,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                topLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(24),
                                                bottomLeft: Radius.circular(4)),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),
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

class HorizontalFadingGradient extends CustomPainter {
  final Color color;

  const HorizontalFadingGradient({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Rect leftRect = Rect.fromPoints(const Offset(-1, 0), Offset(16, size.height));
    Rect rightRect =
        Rect.fromPoints(Offset(size.width + 1, 0), Offset(size.width - 16, size.height));

    LinearGradient lgRight = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [color.withAlpha(0), color],
    );
    LinearGradient lgLeft = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [color.withAlpha(0), color],
    );

    Paint paint = Paint();

    paint.shader = lgRight.createShader(leftRect);
    canvas.drawRect(leftRect, paint);

    paint.shader = lgLeft.createShader(rightRect);
    canvas.drawRect(rightRect, paint);
  }

  @override
  bool shouldRepaint(HorizontalFadingGradient oldDelegate) => false;
}

const kMonthToString = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};
