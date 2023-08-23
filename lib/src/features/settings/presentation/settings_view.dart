import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            // Account Settings
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withAlpha(150),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Account',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  const CircleAvatar(
                    minRadius: 48,
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AuthService.firebase().currentUser?.email ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            // Display Settings
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withAlpha(150),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Display',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  const ListTile(
                    leading: Icon(Icons.invert_colors_rounded),
                    title: Text('App theme'),
                    trailing: DropdownMenu(
                      label: Text('System'),
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: 'System',
                          label: 'System',
                        ),
                      ],
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.dashboard_rounded),
                    title: Text('Notes Layout'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ActionChip(
                          avatar: Icon(Icons.grid_view_rounded),
                          label: Text('Grid'),
                        ),
                        ActionChip(
                          avatar: Icon(Icons.list_rounded),
                          label: Text('List'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
