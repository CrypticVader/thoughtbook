import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_bloc.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_event.dart';
import 'package:thoughtbook/src/features/authentication/bloc/auth_state.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';
import 'package:thoughtbook/src/utilities/dialogs/logout_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color.alphaBlend(
            context.theme.colorScheme.inversePrimary.withAlpha(50),
            context.theme.colorScheme.background,
          ),
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar.large(
                  pinned: true,
                  leading: IconButton(
                    tooltip: 'Go back',
                    icon: const Icon(FluentIcons.arrow_left_24_filled),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  backgroundColor: Color.alphaBlend(
                    context.theme.colorScheme.inversePrimary.withAlpha(50),
                    context.theme.colorScheme.background,
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.theme.colorScheme.onBackground,
                    ),
                  ),
                ),
              ];
            },
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Account Settings
                    const PreferenceSectionHeader(
                      text: 'Account',
                      icon: FluentIcons.person_accounts_24_filled,
                    ),
                    PreferenceSection(
                      items: [
                        PreferenceItem(
                          dividerAfterItem: true,
                          padding: const EdgeInsets.symmetric(
                            vertical: 28.0,
                            horizontal: 16.0,
                          ),
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor:
                                    context.theme.colorScheme.primary,
                                foregroundColor:
                                    context.theme.colorScheme.onPrimary,
                                child: const Icon(
                                  FluentIcons.person_24_filled,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lorem Ipsum',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: context
                                          .theme.colorScheme.onBackground,
                                    ),
                                  ),
                                  Text(AuthService.firebase()
                                          .currentUser
                                          ?.email ??
                                      ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          onTap: () {},
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.edit_settings_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Edit account details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          onTap: () async {
                            final authBloc = context.read<AuthBloc>();
                            final shouldLogout =
                                await showLogoutDialog(context);
                            if (shouldLogout) {
                              authBloc.add(const AuthEventLogOut());
                              Navigator.of(context).pop();
                            }
                          },
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.sign_out_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          onTap: () {},
                          body: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.person_delete_24_filled,
                                color: context.theme.colorScheme.error,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // Appearance Settings
                    const PreferenceSectionHeader(
                      text: 'Appearance',
                      icon: FluentIcons.design_ideas_24_filled,
                    ),
                    PreferenceSection(
                      items: [
                        PreferenceItem(
                          body: Row(
                            children: [
                              Icon(
                                FluentIcons.dark_theme_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                'App theme',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          body: Row(
                            children: [
                              Icon(
                                FluentIcons.color_fill_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                'Accent color',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          body: Row(
                            children: [
                              Icon(
                                FluentIcons.board_split_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                'Notes Layout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: context.theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PreferenceItem(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          body: Row(
                            children: [
                              Icon(
                                FluentIcons.pin_24_filled,
                                color: context.theme.colorScheme.onBackground,
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  'Pin toolbar in the note editor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: context.theme.colorScheme.onBackground,
                                  ),
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Switch(
                                value: true,
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PreferenceSectionHeader extends StatelessWidget {
  final String text;

  final IconData icon;

  const PreferenceSectionHeader({
    super.key,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(
            width: 6.0,
          ),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class PreferenceItem {
  final bool dividerAfterItem;
  final Widget body;
  final EdgeInsets padding;
  final void Function()? onTap;

  const PreferenceItem({
    this.dividerAfterItem = true,
    this.padding = const EdgeInsets.all(16.0),
    required this.body,
    this.onTap,
  });
}

class PreferenceSection extends StatelessWidget {
  final List<PreferenceItem> items;

  const PreferenceSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = items[index];
        if (index == 0) {
          return InkWell(
            onTap: item.onTap,
            splashColor:
                context.theme.colorScheme.inversePrimary.withAlpha(120),
            highlightColor:
                context.theme.colorScheme.inversePrimary.withAlpha(100),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: item.body,
            ),
          );
        } else if (index == (items.length - 1)) {
          return InkWell(
            onTap: item.onTap,
            splashColor:
                context.theme.colorScheme.inversePrimary.withAlpha(120),
            highlightColor:
                context.theme.colorScheme.inversePrimary.withAlpha(100),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: item.body,
            ),
          );
        } else {
          return InkWell(
            onTap: item.onTap,
            splashColor:
                context.theme.colorScheme.inversePrimary.withAlpha(120),
            highlightColor:
                context.theme.colorScheme.inversePrimary.withAlpha(100),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: item.body,
            ),
          );
        }
      },
      separatorBuilder: (context, index) => items[index].dividerAfterItem
          ? const SizedBox(height: 2.0)
          : const SizedBox(height: 0),
      itemCount: items.length,
    );
  }
}
