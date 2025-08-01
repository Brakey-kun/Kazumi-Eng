import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:card_settings_ui/card_settings_ui.dart';

class PlayerSettingsPage extends StatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  Box setting = GStorage.setting;
  late double defaultPlaySpeed;
  late bool hAenable;
  late bool androidEnableOpenSLES;
  late bool lowMemoryMode;
  late bool playResume;
  late bool showPlayerError;
  late bool privateMode;
  late bool playerDebugMode;

  @override
  void initState() {
    super.initState();
    defaultPlaySpeed =
        setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0);
    hAenable = setting.get(SettingBoxKey.hAenable, defaultValue: true);
    androidEnableOpenSLES =
        setting.get(SettingBoxKey.androidEnableOpenSLES, defaultValue: true);
    lowMemoryMode =
        setting.get(SettingBoxKey.lowMemoryMode, defaultValue: false);
    playResume = setting.get(SettingBoxKey.playResume, defaultValue: true);
    privateMode = setting.get(SettingBoxKey.privateMode, defaultValue: false);
    showPlayerError =
        setting.get(SettingBoxKey.showPlayerError, defaultValue: true);
    playerDebugMode =
        setting.get(SettingBoxKey.playerDebugMode, defaultValue: false);
  }

  void onBackPressed(BuildContext context) {
    // Navigator.of(context).pop();
  }

  void updateDefaultPlaySpeed(double speed) {
    setting.put(SettingBoxKey.defaultPlaySpeed, speed);
    setState(() {
      defaultPlaySpeed = speed;
    });
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
        appBar: const SysAppBar(title: Text('Player Settings')),
        body: Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width > 1000) ? 1000 : null,
            child: SettingsList(
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        hAenable = value ?? !hAenable;
                        await setting.put(SettingBoxKey.hAenable, hAenable);
                        setState(() {});
                      },
                      title: const Text('Hardware Decoding'),
                      initialValue: hAenable,
                    ),
                    SettingsTile.navigation(
                      onPressed: (value) async {
                        await Modular.to.pushNamed('/settings/player/decoder');
                      },
                      title: const Text('Hardware Decoder'),
                      description: const Text('Only effective when hardware decoding is enabled'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        lowMemoryMode = value ?? !lowMemoryMode;
                        await setting.put(
                            SettingBoxKey.lowMemoryMode, lowMemoryMode);
                        setState(() {});
                      },
                      title: const Text('Low Memory Mode'),
                      description: const Text('Disable advanced caching to reduce memory usage'),
                      initialValue: lowMemoryMode,
                    ),
                    if (Platform.isAndroid) ...[
                      SettingsTile.switchTile(
                        onToggle: (value) async {
                          androidEnableOpenSLES = value ?? !androidEnableOpenSLES;
                          await setting.put(
                              SettingBoxKey.androidEnableOpenSLES, androidEnableOpenSLES);
                          setState(() {});
                        },
                        title: const Text('Low Latency Audio'),
                        description: const Text('Enable OpenSLES audio output to reduce latency'),
                        initialValue: androidEnableOpenSLES,
                      ),
                    ],
                    SettingsTile.navigation(
                      onPressed: (_) async {
                        Modular.to.pushNamed('/settings/player/super');
                      },
                      title: const Text('Super Resolution'),
                    ),
                  ],
                ),
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        playResume = value ?? !playResume;
                        await setting.put(SettingBoxKey.playResume, playResume);
                        setState(() {});
                      },
                      title: const Text('Auto Resume'),
                      description: const Text('Jump to last playback position'),
                      initialValue: playResume,
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        showPlayerError = value ?? !showPlayerError;
                        await setting.put(
                            SettingBoxKey.showPlayerError, showPlayerError);
                        setState(() {});
                      },
                      title: const Text('Error Notifications'),
                      description: const Text('Show internal player error messages'),
                      initialValue: showPlayerError,
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        playerDebugMode = value ?? !playerDebugMode;
                        await setting.put(
                            SettingBoxKey.playerDebugMode, playerDebugMode);
                        setState(() {});
                      },
                      title: const Text('Debug Mode'),
                      description: const Text('Log internal player messages'),
                      initialValue: playerDebugMode,
                    ),
                    SettingsTile.switchTile(
                      onToggle: (value) async {
                        privateMode = value ?? !privateMode;
                        await setting.put(
                            SettingBoxKey.privateMode, privateMode);
                        setState(() {});
                      },
                      title: const Text('Private Mode'),
                      description: const Text('Do not keep viewing history'),
                      initialValue: privateMode,
                    ),
                  ],
                ),
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      onPressed: (_) async {
                        KazumiDialog.show(builder: (context) {
                          return AlertDialog(
                            title: const Text('Default Playback Speed'),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              final List<double> playSpeedList;
                              playSpeedList = defaultPlaySpeedList;
                              return Wrap(
                                spacing: 8,
                                runSpacing: Utils.isDesktop() ? 8 : 0,
                                children: [
                                  for (final double i
                                      in playSpeedList) ...<Widget>[
                                    if (i == defaultPlaySpeed) ...<Widget>[
                                      FilledButton(
                                        onPressed: () async {
                                          updateDefaultPlaySpeed(i);
                                          KazumiDialog.dismiss();
                                        },
                                        child: Text(i.toString()),
                                      ),
                                    ] else ...[
                                      FilledButton.tonal(
                                        onPressed: () async {
                                          updateDefaultPlaySpeed(i);
                                          KazumiDialog.dismiss();
                                        },
                                        child: Text(i.toString()),
                                      ),
                                    ]
                                  ]
                                ],
                              );
                            }),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => KazumiDialog.dismiss(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  updateDefaultPlaySpeed(1.0);
                                  KazumiDialog.dismiss();
                                },
                                child: const Text('Default Settings'),
                              ),
                            ],
                          );
                        });
                      },
                      title: const Text('Default Playback Speed'),
                      value: Text('$defaultPlaySpeed'),
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
