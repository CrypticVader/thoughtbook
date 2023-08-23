import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

Future<void> showNoteGroupModePickerBottomSheet(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => const NoteGroupModePickerView(),
  );
}

class NoteGroupModePickerView extends StatefulWidget {
  const NoteGroupModePickerView({super.key});

  @override
  State<NoteGroupModePickerView> createState() => _NoteGroupModePickerViewState();
}

class _NoteGroupModePickerViewState extends State<NoteGroupModePickerView> {
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
              toolbarHeight: 80,
              centerTitle: true,
              title: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 16.0),
                    child: Ink(
                      height: 6.0,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color:
                        context.themeColors.onSurfaceVariant.withAlpha(100),
                      ),
                    ),
                  ),
                  Text(
                    'Group notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: context.themeColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
