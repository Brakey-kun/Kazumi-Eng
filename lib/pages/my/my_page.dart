import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/pages/menu/menu.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late NavigationBarState navigationBarState;

  void onBackPressed(BuildContext context) {
    navigationBarState.updateSelectedIndex(0);
    Modular.to.navigate('/tab/popular/');
  }

  @override
  void initState() {
    super.initState();
    navigationBarState =
        Provider.of<NavigationBarState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('My'), needTopOffset: false),
        body: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width > 1000) ? 1000 : null,
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Playback History and Video Sources'),
                  tiles: [
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/history/');
                      },
                      leading: const Icon(Icons.history_rounded),
                      title: const Text('History'),
                      description: const Text('View playback history'),
                    ),
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/plugin/');
                      },
                      leading: const Icon(Icons.extension),
                      title: const Text('Rule Management'),
                      description: const Text('Manage anime resource rules'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Player Settings'),
                  tiles: [
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/player');
                      },
                      leading: const Icon(Icons.display_settings_rounded),
                      title: const Text('Playback Settings'),
                      description: const Text('Configure player-related parameters'),
                    ),
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/danmaku/');
                      },
                      leading: const Icon(Icons.subtitles_rounded),
                      title: const Text('Danmaku Settings'),
                      description: const Text('Configure danmaku-related parameters'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Application and Appearance'),
                  tiles: [
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/theme');
                      },
                      leading: const Icon(Icons.palette_rounded),
                      title: const Text('Appearance Settings'),
                      description: const Text('Set app theme and refresh rate'),
                    ),
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/webdav/');
                      },
                      leading: const Icon(Icons.cloud),
                      title: const Text('Sync Settings'),
                      description: const Text('Configure sync parameters'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Other'),
                  tiles: [
                    SettingsTile.navigation(
                      onPressed: (_) {
                        Modular.to.pushNamed('/settings/about/');
                      },
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('About'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
