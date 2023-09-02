import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/extensions/dateTime/custom_format.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_bloc.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_event.dart';
import 'package:thoughtbook/src/features/note/note_crud/bloc/note_editor_bloc/note_editor_state.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/local_note.dart';
import 'package:thoughtbook/src/features/note/note_crud/domain/presentable_note_data.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/color_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/bottom_sheets/note_tag_picker_bottom_sheet.dart';
import 'package:thoughtbook/src/features/note/note_crud/presentation/utilities/common_widgets/tonal_chip.dart';
import 'package:thoughtbook/src/utilities/dialogs/generic_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

typedef NoteCallback = void Function(LocalNote note);

class NoteEditorView extends StatefulWidget {
  /// This note is used to initialize the state of the [NoteEditorBloc]
  /// and it should not be used anywhere else.
  final LocalNote? note;
  final bool shouldAutoFocusContent;

  /// This callback, provided by [NotesView], will facilitate showing a [SnackBar]
  /// to undo the deletion, by adding a [NoteDeleteEvent] to the [NoteBloc] which is
  /// not accessible from this view's [context]
  final NoteCallback onDeleteNote;

  const NoteEditorView({
    required this.note,
    required this.shouldAutoFocusContent,
    required this.onDeleteNote,
    Key? key,
  }) : super(key: key);

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late final TextEditingController _noteContentController;
  late final TextEditingController _noteTitleController;
  late NoteEditorBloc noteEditorBloc;
  bool _showFab = true;
  ColorScheme noteColors = ColorScheme.fromSeed(
    seedColor: Colors.grey,
    brightness:
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? Brightness.dark
            : Brightness.light,
  );

  bool get _isDarkMode =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  @override
  void initState() {
    super.initState();
    _noteContentController =
        TextEditingController(text: widget.note?.content ?? '');
    _noteTitleController =
        TextEditingController(text: widget.note?.title ?? '');
    _setupTextControllerListener();
  }

  void _noteControllerListener() {
    context.read<NoteEditorBloc>().add(
          NoteEditorUpdateEvent(
            newTitle: _noteTitleController.text,
            newContent: _noteContentController.text,
          ),
        );
  }

  void _setupTextControllerListener() {
    _noteContentController.removeListener(() => _noteControllerListener());
    _noteContentController.addListener(() => _noteControllerListener());
    _noteTitleController.removeListener(() => _noteControllerListener());
    _noteTitleController.addListener(() => _noteControllerListener());
  }

  Color getNoteColor(BuildContext context, LocalNote? note) {
    if (note != null) {
      if (note.color != null) {
        return Color(note.color!);
      } else {
        return Theme.of(context).colorScheme.primary;
      }
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _updateNoteColor(LocalNote note) async {
    final currentColor = (note.color != null) ? Color(note.color!) : null;
    final editorBloc = context.read<NoteEditorBloc>();
    final newColor = await showColorPickerModalBottomSheet(
      context: context,
      currentColor: currentColor,
      colorScheme: noteColors,
    );
    editorBloc.add(NoteEditorUpdateColorEvent(newColor: newColor));
  }

  @override
  void didChangeDependencies() {
    noteEditorBloc = context.read<NoteEditorBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();

    noteEditorBloc.add(const NoteEditorCloseEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteEditorBloc, NoteEditorState>(
      listener: (BuildContext context, NoteEditorState state) {
        if (state.snackBarText.isNotEmpty) {
          final snackBar = SnackBar(
            backgroundColor: noteColors.tertiary,
            content: Text(
              state.snackBarText,
              style: TextStyle(
                color: noteColors.onTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            dismissDirection: DismissDirection.startToEnd,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (state is NoteEditorDeletedState) {
          Navigator.of(context).pop();
          widget.onDeleteNote(state.deletedNote);
        }
      },
      buildWhen: (previousState, currentState) {
        if ((currentState is NoteEditorInitializedState) ||
            (currentState is NoteEditorUninitializedState)) {
          return true;
        } else {
          return false;
        }
      },
      builder: (BuildContext context, state) {
        if (state is NoteEditorUninitializedState) {
          context
              .read<NoteEditorBloc>()
              .add(NoteEditorInitializeEvent(note: widget.note));

          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is NoteEditorInitializedState) {
          return StreamBuilder<PresentableNoteData>(
            stream: state.noteData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    final PresentableNoteData noteData = snapshot.data!;
                    final note = noteData.note;
                    final tags = noteData.noteTags;
                    final bool isEditable = state.isEditable;
                    noteColors = ColorScheme.fromSeed(
                      seedColor: getNoteColor(context, note),
                      brightness:
                          _isDarkMode ? Brightness.dark : Brightness.light,
                    );
                    return Scaffold(
                      floatingActionButton: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _showFab ? 1 : 0,
                        child: AnimatedScale(
                          scale: _showFab ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: FloatingActionButton.extended(
                            onPressed: () => context.read<NoteEditorBloc>().add(
                                  NoteEditorChangeViewTypeEvent(
                                    wasEditable: isEditable,
                                  ),
                                ),
                            backgroundColor: noteColors.tertiaryContainer,
                            tooltip: isEditable ? 'Preview Note' : 'Edit note',
                            label: isEditable
                                ? const Text('Read')
                                : const Text('Edit'),
                            foregroundColor: noteColors.onTertiaryContainer,
                            icon: Icon(
                              isEditable
                                  ? FluentIcons.reading_mode_mobile_24_filled
                                  : FluentIcons.note_edit_24_filled,
                              color: noteColors.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ),
                      body: NestedScrollView(
                        floatHeaderSlivers: true,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverPinnedHeader(
                              child: AnimatedContainer(
                                color: innerBoxIsScrolled
                                    ? Color.alphaBlend(
                                  context
                                      .theme.colorScheme.onSurfaceVariant
                                      .withAlpha(20),
                                  Color.alphaBlend(
                                    noteColors.primaryContainer
                                        .withAlpha(50),
                                    noteColors.secondaryContainer,
                                  ),
                                )
                                    : Color.alphaBlend(
                                  noteColors.primaryContainer.withAlpha(50),
                                  noteColors.secondaryContainer,
                                ),
                                duration: const Duration(milliseconds: 150),
                                child: AppBar(
                                  // pinned: true,
                                  surfaceTintColor: Colors.transparent,
                                  iconTheme: IconThemeData(
                                    color: noteColors.onSecondaryContainer,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  leading: IconButton(
                                    tooltip: 'Go back',
                                    icon: const Icon(
                                        FluentIcons.chevron_left_28_filled),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: context.loc.change_color,
                                          onPressed: () async =>
                                              await _updateNoteColor(note),
                                          icon: const Icon(
                                              FluentIcons.color_24_regular),
                                        ),
                                        IconButton(
                                          onPressed: () => context
                                              .read<NoteEditorBloc>()
                                              .add(
                                                  const NoteEditorShareEvent()),
                                          icon: const Icon(
                                              FluentIcons.share_24_regular),
                                          tooltip: context.loc.share_note,
                                        ),
                                        IconButton(
                                          tooltip: context.loc.copy_text,
                                          onPressed: () => context
                                              .read<NoteEditorBloc>()
                                              .add(const NoteEditorCopyEvent()),
                                          icon: const Icon(
                                              FluentIcons.copy_24_regular),
                                        ),
                                        IconButton(
                                          tooltip: context.loc.delete,
                                          onPressed: () => context
                                              .read<NoteEditorBloc>()
                                              .add(
                                                  const NoteEditorDeleteEvent()),
                                          icon: const Icon(
                                              FluentIcons.delete_24_regular),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 8.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: AnimatedContainer(
                                color: innerBoxIsScrolled
                                    ? Color.alphaBlend(
                                        context
                                            .theme.colorScheme.onSurfaceVariant
                                            .withAlpha(20),
                                        Color.alphaBlend(
                                          noteColors.primaryContainer
                                              .withAlpha(50),
                                          noteColors.secondaryContainer,
                                        ),
                                      )
                                    : Color.alphaBlend(
                                  noteColors.primaryContainer.withAlpha(50),
                                  noteColors.secondaryContainer,
                                ),
                                duration: const Duration(milliseconds: 150),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 0.0, 16.0, 8.0),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      TonalChip(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        onTap: () => showGenericDialog(
                                          context: context,
                                          title: 'Info',
                                          icon: const Icon(
                                            FluentIcons.book_clock_24_filled,
                                            size: 40,
                                          ),
                                          content: 'content',
                                          optionsBuilder: () => {'OK': null},
                                        ),
                                        label: note.modified.customFormat(),
                                        iconData: FluentIcons.book_clock_24_filled,
                                        backgroundColor:
                                            noteColors.tertiaryContainer,
                                        foregroundColor:
                                            noteColors.onTertiaryContainer,
                                        splashColor: noteColors.tertiary,
                                      ),
                                      const SizedBox(width: 8.0),
                                      TonalChip(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        onTap: () async =>
                                            await showNoteTagPickerModalBottomSheet(
                                          context: context,
                                          noteStream: state.noteStream,
                                          allNoteTags: state.allNoteTags,
                                          onTapTag: (tag) => context
                                              .read<NoteEditorBloc>()
                                              .add(NoteEditorUpdateTagEvent(
                                                  selectedTag: tag)),
                                          colorScheme: noteColors,
                                        ),
                                        label: tags.isEmpty
                                            ? 'No labels'
                                            : tags
                                                .map((tag) => tag.name)
                                                .join(', '),
                                        textStyle: TextStyle(
                                          color: noteColors.onTertiaryContainer,
                                          fontStyle: tags.isEmpty
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        iconData: tags.isEmpty
                                            ? FluentIcons.tag_dismiss_24_filled
                                            : FluentIcons.tag_24_filled,
                                        backgroundColor:
                                            noteColors.tertiaryContainer,
                                        foregroundColor:
                                            noteColors.onTertiaryContainer,
                                        splashColor: noteColors.tertiary,
                                      ),
                                      const SizedBox(width: 8.0),
                                      TonalChip(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        onTap: () => showGenericDialog(
                                          context: context,
                                          title: note.isSyncedWithCloud
                                              ? 'Backed Up'
                                              : 'Pending Sync',
                                          icon: note.isSyncedWithCloud
                                              ? const Icon(
                                                  Icons.cloud_done_rounded,
                                                  size: 40,
                                                )
                                              : const Icon(
                                                  Icons.cloud_upload_rounded,
                                                  size: 40,
                                                ),
                                          content: noteData
                                                  .note.isSyncedWithCloud
                                              ? 'This note is saved to the the '
                                                  'cloud & can be accessed'
                                                  ' by using your account.'
                                              : 'Changes made to this note are '
                                                  'pending to be saved to the cloud, '
                                                  'but are safe on your device.'
                                                  ' We will save the changes when your '
                                                  'device is online.',
                                          optionsBuilder: () => {'OK': null},
                                        ),
                                        label: note.isSyncedWithCloud
                                            ? 'Changes saved'
                                            : 'Changes unsaved',
                                        iconData: note.isSyncedWithCloud
                                            ? FluentIcons
                                                .cloud_checkmark_24_filled
                                            : FluentIcons
                                                .cloud_arrow_up_24_filled,
                                        backgroundColor:
                                            noteColors.tertiaryContainer,
                                        foregroundColor:
                                            noteColors.onTertiaryContainer,
                                        splashColor: noteColors.tertiary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ];
                        },
                        body: AnimatedContainer(
                          color: Color.alphaBlend(
                            noteColors.primaryContainer.withAlpha(50),
                            noteColors.secondaryContainer,
                          ),
                          constraints: const BoxConstraints.expand(),
                          duration: const Duration(milliseconds: 150),
                          child: NotificationListener<UserScrollNotification>(
                            onNotification: (notification) {
                              ScrollDirection direction =
                                  notification.direction;
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
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 0.0, 16.0, 48.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedCrossFade(
                                      firstCurve: Curves.ease,
                                      secondCurve: Curves.ease,
                                      sizeCurve: Curves.ease,
                                      firstChild: NoteReadableView(
                                        key: const ValueKey<bool>(false),
                                        title: note.title,
                                        content: note.content,
                                        noteColors: noteColors,
                                      ),
                                      secondChild: NoteEditableView(
                                        key: const ValueKey<bool>(true),
                                        textColor:
                                            noteColors.onSecondaryContainer,
                                        titleController: _noteTitleController,
                                        contentController:
                                            _noteContentController,
                                        shouldAutofocusContent:
                                            widget.shouldAutoFocusContent,
                                      ),
                                      crossFadeState: !isEditable
                                          ? CrossFadeState.showFirst
                                          : CrossFadeState.showSecond,
                                      duration:
                                          const Duration(milliseconds: 300),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 1,
                          ),
                          SpinKitDoubleBounce(
                            color: context.theme.colorScheme.primary,
                            size: 80,
                          ),
                          const Spacer(
                            flex: 1,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(
                            height: 48.0,
                          ),
                        ],
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

class NoteEditableView extends StatelessWidget {
  final Color textColor;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool shouldAutofocusContent;

  const NoteEditableView({
    super.key,
    required this.textColor,
    required this.titleController,
    required this.contentController,
    required this.shouldAutofocusContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          autofocus: false,
          maxLines: null,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 25.0,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Title',
            hintStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 25.0,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        TextField(
          autofocus: shouldAutofocusContent,
          controller: contentController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
            height: 1.5,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: context.loc.start_typing_your_note,
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}

class NoteReadableView extends StatelessWidget {
  final String title;
  final String content;
  final ColorScheme noteColors;

  const NoteReadableView({
    super.key,
    required this.title,
    required this.content,
    required this.noteColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
            child: Text(
              title,
              style: TextStyle(
                color: noteColors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 25.0,
              ),
            ),
          ),
        if (title.isNotEmpty)
          const SizedBox(
            height: 8.0,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
          child: MarkdownBody(
            data: content,
            selectable: true,
            softLineBreak: true,
            onTapLink: (text, href, title) async {
              if (href != null) {
                await launchUrl(
                  Uri.parse(href),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            imageBuilder: (uri, title, alt) {
              // final asset = FadeInImage.assetNetwork(placeholder: placeholder, image: image)
              return OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 250),
                closedColor: Colors.transparent,
                closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                closedElevation: 4,
                openColor: noteColors.background,
                closedBuilder: (context, action) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      uri.toString(),
                      filterQuality: FilterQuality.low,
                    ),
                  );
                },
                openBuilder: (context, action) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        panEnabled: true,
                        scaleEnabled: true,
                        maxScale: 12,
                        minScale: 0.8,
                        child: Image.network(
                          uri.toString(),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        top: 48,
                        left: 12,
                        child: IconButton.filled(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            checkboxBuilder: (value) {
              return Checkbox(
                value: value,
                onChanged: (value) {
                  value = !value!;
                },
                checkColor: noteColors.onSecondary,
                activeColor: noteColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: noteColors.secondary,
                    strokeAlign: BorderSide.strokeAlignOutside,
                    width: 10,
                  ),
                ),
              );
            },
            bulletBuilder: (index, style) {
              switch (style) {
                case BulletStyle.orderedList:
                  return Text(
                    '${index.toString()}.',
                    style: TextStyle(
                      color: noteColors.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  );
                case BulletStyle.unorderedList:
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: noteColors.onSecondaryContainer,
                      ),
                    ),
                  );
              }
            },
            styleSheet: MarkdownStyleSheet(
                a: TextStyle(
                  color: noteColors.primary,
                  height: 1.5,
                ),
                code: const TextStyle(
                  backgroundColor: Colors.transparent,
                  fontSize: 14.0,
                  height: 1.3,
                ),
                codeblockDecoration: BoxDecoration(
                  color: noteColors.background.withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                ),
                codeblockPadding: const EdgeInsets.all(12.0),
                blockquoteDecoration: BoxDecoration(
                  color: noteColors.primaryContainer.withAlpha(120),
                  border: Border.all(
                    color: noteColors.onPrimaryContainer.withAlpha(70),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                blockquotePadding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                p: TextStyle(
                  color: noteColors.onSecondaryContainer,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
                  height: 1.5,
                ),
                h1: TextStyle(
                  color: noteColors.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.0,
                  height: 1.5,
                ),
                h2: TextStyle(
                  color: noteColors.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                  height: 1.5,
                ),
                h3: TextStyle(
                  color: noteColors.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 18.0,
                  height: 1.5,
                ),
                blockquote: TextStyle(
                  color: noteColors.onPrimaryContainer,
                  height: 1.5,
                )),
          ),
        ),
      ],
    );
  }
}
