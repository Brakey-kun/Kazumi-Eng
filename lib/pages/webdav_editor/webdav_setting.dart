import 'package:flutter/material.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/webdav.dart';
import 'package:hive/hive.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:card_settings_ui/card_settings_ui.dart';

class WebDavSettingsPage extends StatefulWidget {
  const WebDavSettingsPage({super.key});

  @override
  State<WebDavSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<WebDavSettingsPage> {
  Box setting = GStorage.setting;
  late bool webDavEnable;
  late bool webDavEnableHistory;
  late bool enableGitProxy;

  @override
  void initState() {
    super.initState();
    webDavEnable = setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
    webDavEnableHistory =
        setting.get(SettingBoxKey.webDavEnableHistory, defaultValue: false);
    enableGitProxy =
        setting.get(SettingBoxKey.enableGitProxy, defaultValue: false);
  }

  void onBackPressed(BuildContext context) {}

  Future<void> checkWebDav() async {
    var webDavURL =
        await setting.get(SettingBoxKey.webDavURL, defaultValue: '');
    if (webDavURL == '') {
      await setting.put(SettingBoxKey.webDavEnable, false);
      KazumiDialog.showToast(message: 'No valid WebDAV configuration found');
      return;
    }
    try {
      KazumiDialog.showToast(message: 'Trying to sync from WebDav');
      var webDav = WebDav();
      await webDav.downloadAndPatchHistory();
      KazumiDialog.showToast(message: 'Sync successful');
    } catch (e) {
      if (e.toString().contains('Error: Not Found')) {
        KazumiDialog.showToast(message: 'Configuration successful, this is a new WebDav without existing sync files');
      } else {
        KazumiDialog.showToast(message: 'Sync failed ${e.toString()}');
      }
    }
  }

  Future<void> updateWebdav() async {
    var webDavEnable =
        await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
    if (webDavEnable) {
      KazumiDialog.showToast(message: 'Trying to upload to WebDav');
      var webDav = WebDav();
      await webDav.updateHistory();
      KazumiDialog.showToast(message: 'Sync successful');
    } else {
      KazumiDialog.showToast(message: 'WebDav sync is not enabled or configuration is invalid');
    }
  }

  Future<void> downloadWebdav() async {
    var webDavEnable =
        await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
    if (webDavEnable) {
      try {
        KazumiDialog.showToast(message: 'Trying to sync from WebDav');
        var webDav = WebDav();
        await webDav.downloadAndPatchHistory();
        KazumiDialog.showToast(message: 'Sync successful');
      } catch (e) {
        KazumiDialog.showToast(message: 'Sync failed ${e.toString()}');
      }
    } else {
      KazumiDialog.showToast(message: 'WebDav sync is not enabled or configuration is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        onBackPressed(context);
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('Sync Settings')),
        body: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width > 1000) ? 1000 : null,
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Github'),
                  tiles: [
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        enableGitProxy = value ?? !enableGitProxy;
                        await setting.put(
                            SettingBoxKey.enableGitProxy, enableGitProxy);
                        setState(() {});
                      },
                      title: const Text('Github Proxy'),
                      description: const Text('Use a proxy to access Github repositories'),
                      initialValue: enableGitProxy,
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('WEBDAV'),
                  tiles: [
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        webDavEnable = value ?? !webDavEnable;
                        if (!WebDav().initialized && webDavEnable) {
                          WebDav().init();
                        }
                        if (!webDavEnable) {
                          webDavEnableHistory = false;
                          await setting.put(SettingBoxKey.webDavEnableHistory, false);
                        }
                        await setting.put(
                            SettingBoxKey.webDavEnable, webDavEnable);
                        setState(() {});
                      },
                      title: const Text('WEBDAV Sync'),
                      initialValue: webDavEnable,
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        if (!webDavEnable) {
                          KazumiDialog.showToast(message: 'Please enable WEBDAV sync first');
                          return;
                        }
                        webDavEnableHistory = value ?? !webDavEnableHistory;
                        await setting.put(SettingBoxKey.webDavEnableHistory,
                            webDavEnableHistory);
                        setState(() {});
                      },
                      title: const Text('Watch History Sync'),
                      description: const Text('Allow automatic synchronization of watch history'),
                      initialValue: webDavEnableHistory,
                    ),
                    SettingsTile.navigation(
                      onPressed: (_) async {
                        Modular.to.pushNamed('/settings/webdav/editor');
                      },
                      title: Text(
                        'WEBDAV Configuration',
                        style: Theme.of(context).textTheme.titleMedium!,
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  bottomInfo: const Text('Upload watch history to WEBDAV now'),
                  tiles: [
                    SettingsTile(
                      trailing: const Icon(Icons.cloud_upload_rounded),
                      onPressed: (_) {
                        updateWebdav();
                      },
                      title: const Text('Manual Upload'),
                    ),
                  ],
                ),
                SettingsSection(
                  bottomInfo: const Text('Download watch history to local now'),
                  tiles: [
                    SettingsTile(
                      trailing: const Icon(Icons.cloud_download_rounded),
                      onPressed: (_) {
                        downloadWebdav();
                      },
                      title: const Text('Manual Download'),
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
