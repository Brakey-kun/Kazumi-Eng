import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/utils/webdav.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kazumi/utils/logger.dart';
import 'package:provider/provider.dart';
import 'package:kazumi/bean/settings/theme_provider.dart';
import 'package:kazumi/shaders/shaders_controller.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  final PluginsController pluginsController = Modular.get<PluginsController>();
  final CollectController collectController = Modular.get<CollectController>();
  final ShadersController shadersController = Modular.get<ShadersController>();
  final MyController myController = Modular.get<MyController>();
  Box setting = GStorage.setting;
  late final ThemeProvider themeProvider;

  @override
  void initState() {
    _pluginInit();
    _webDavInit();
    _migrateStorage();
    _loadShaders();
    _loadDanmakuShield();
    _update();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    super.initState();
  }

  // migrate collect from old version (favorites)
  Future<void> _migrateStorage() async {
    await collectController.migrateCollect();
  }

  Future<void> _loadShaders() async {
    await shadersController.copyShadersToExternalDirectory();
  }

  Future<void> _loadDanmakuShield() async {
    myController.loadShieldList();
  }

  Future<void> _webDavInit() async {
    bool webDavEnable =
        await setting.get(SettingBoxKey.webDavEnable, defaultValue: false);
    if (webDavEnable) {
      var webDav = WebDav();
      KazumiLogger().log(Level.info, 'Start syncing records from WEBDAV');
      try {
        await webDav.init();
        try {
          await webDav.downloadAndPatchHistory();
          KazumiLogger().log(Level.info, 'Sync watch history completed');
        } catch (e) {
          KazumiLogger().log(Level.error, 'Sync watch history failed ${e.toString()}');
        }
      } catch (e) {
        KazumiLogger().log(Level.error, 'WebDav initialization failed ${e.toString()}');
      }
    }
  }

  Future<void> _pluginInit() async {
    String statementsText = '';
    try {
      await pluginsController.init();
      statementsText =
          await rootBundle.loadString("assets/statements/statements.txt");
      _pluginUpdate();
    } catch (_) {}
    if (pluginsController.pluginList.isEmpty) {
      await KazumiDialog.show(
        clickMaskDismiss: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Disclaimer'),
              scrollable: true,
              content: Text(statementsText),
              actions: [
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(
                    'Exit',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await pluginsController.copyPluginsToExternalDirectory();
                    } catch (_) {}
                    KazumiDialog.dismiss();
                    if (!Platform.isAndroid) {
                      Modular.to.navigate('/tab/popular/');
                      return;
                    }
                    _switchUpdateMirror();
                  },
                  child: const Text('Read and agreed'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      themeProvider.setDynamic(
          setting.get(SettingBoxKey.useDynamicColor, defaultValue: false));
      Modular.to.navigate('/tab/popular/');
    }
  }

  Future<void> _switchUpdateMirror() async {
    await KazumiDialog.show(
      clickMaskDismiss: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Update Mirror'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Where would you like to get app updates from?',
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'The GitHub mirror is the best choice in most cases. If you use the F-Droid app store, please select the F-Droid mirror.',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setting.put(SettingBoxKey.autoUpdate, true);
                  KazumiDialog.dismiss();
                  Modular.to.navigate('/tab/popular/');
                },
                child: const Text(
                  'Github',
                ),
              ),
              TextButton(
                onPressed: () {
                  setting.put(SettingBoxKey.autoUpdate, false);
                  KazumiDialog.dismiss();
                  Modular.to.navigate('/tab/popular/');
                },
                child: Text(
                  'F-Droid',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update() async {
    await Future.delayed(const Duration(seconds: 1));
    if (pluginsController.pluginList.isNotEmpty) {
      bool autoUpdate =
          setting.get(SettingBoxKey.autoUpdate, defaultValue: true);
      if (autoUpdate) {
        Modular.get<MyController>().checkUpdata(type: 'auto');
      }
    }
  }

  Future<void> _pluginUpdate() async {
    await pluginsController.queryPluginHTTPList();
    int count = 0;
    for (var plugin in pluginsController.pluginList) {
      if (pluginsController.pluginUpdateStatus(plugin) == 'updatable') {
        count++;
      }
    }
    if (count != 0) {
      KazumiDialog.showToast(message: 'Detected $count rules that can be updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Adapt to tablet devices
    Box setting = GStorage.setting;
    bool isWideScreen = MediaQuery.of(context).size.shortestSide >= 600 &&
        (MediaQuery.of(context).size.shortestSide /
                MediaQuery.of(context).size.longestSide >=
            9 / 16);
    if (isWideScreen) {
      KazumiLogger().log(Level.info, 'Current device is widescreen');
    } else {
      KazumiLogger().log(Level.info, 'Current device is not widescreen');
    }
    setting.put(SettingBoxKey.isWideScreen, isWideScreen);
    return const LoadingWidget();
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
