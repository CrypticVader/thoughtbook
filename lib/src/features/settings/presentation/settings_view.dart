import 'package:flutter/material.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';
import 'package:thoughtbook/src/features/authentication/repository/auth_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Ink(
                    color:
                        context.theme.colorScheme.inversePrimary.withAlpha(50)),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: context.theme.colorScheme.onBackground,
                  ),
                ),
                centerTitle: false,
              ),
            ),
          ];
        },
        body: Ink(
          color: context.theme.colorScheme.inversePrimary.withAlpha(50),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(12.0),
                children: [
                  // Account Settings
                  const PreferenceSectionHeader(
                    text: 'Account',
                    icon: Icons.account_circle_rounded,
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
                              backgroundColor: context.theme.colorScheme.primary,
                              foregroundColor: context.theme.colorScheme.onPrimary,
                              child: const Icon(
                                Icons.person_rounded,
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
                                    color:
                                        context.theme.colorScheme.onBackground,
                                  ),
                                ),
                                Text(
                                    AuthService.firebase().currentUser?.email ??
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
                              Icons.manage_accounts_rounded,
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
                        onTap: () {},
                        body: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
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
                              Icons.delete_forever_rounded,
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
                    icon: Icons.design_services_rounded,
                  ),
                  PreferenceSection(
                    items: [
                      PreferenceItem(
                        body: Row(
                          children: [
                            Icon(
                              Icons.invert_colors_rounded,
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
                              Icons.color_lens_rounded,
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
                              Icons.dashboard_rounded,
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
            splashColor: context.theme.colorScheme.primary.withAlpha(50),
            highlightColor: Colors.transparent,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background.withAlpha(200),
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
            splashColor: context.theme.colorScheme.primary.withAlpha(50),
            highlightColor: Colors.transparent,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background.withAlpha(200),
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
            splashColor: context.theme.colorScheme.primary.withAlpha(50),
            highlightColor: Colors.transparent,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            child: Ink(
              padding: item.padding,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.background.withAlpha(200),
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
