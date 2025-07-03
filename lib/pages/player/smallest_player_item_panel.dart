import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kazumi/utils/utils.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/pages/player/player_controller.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/utils/remote.dart';
import 'package:kazumi/pages/settings/danmaku/danmaku_settings_sheet.dart';
import 'package:kazumi/bean/widget/collect_button.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:hive/hive.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/bean/appbar/drag_to_move_bar.dart' as dtb;
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:kazumi/bean/widget/embedded_native_control_area.dart';

class SmallestPlayerItemPanel extends StatefulWidget {
  const SmallestPlayerItemPanel({
    super.key,
    required this.onBackPressed,
    required this.setPlaybackSpeed,
    required this.showDanmakuSwitch,
    required this.handleFullscreen,
    required this.handleProgressBarDragStart,
    required this.handleProgressBarDragEnd,
    required this.animationController,
    required this.keyboardFocus,
    required this.handleHove,
    required this.startHideTimer,
    required this.cancelHideTimer,
    required this.handleDanmaku,
    required this.showVideoInfo,
    required this.showSyncPlayRoomCreateDialog,
    required this.showSyncPlayEndPointSwitchDialog,
  });

  final void Function(BuildContext) onBackPressed;
  final Future<void> Function(double) setPlaybackSpeed;
  final void Function() showDanmakuSwitch;
  final void Function() handleDanmaku;
  final void Function() handleFullscreen;
  final void Function(ThumbDragDetails details) handleProgressBarDragStart;
  final void Function() handleProgressBarDragEnd;
  final void Function() handleHove;
  final AnimationController animationController;
  final FocusNode keyboardFocus;
  final void Function() startHideTimer;
  final void Function() cancelHideTimer;
  final void Function() showVideoInfo;
  final void Function() showSyncPlayRoomCreateDialog;
  final void Function() showSyncPlayEndPointSwitchDialog;

  @override
  State<SmallestPlayerItemPanel> createState() =>
      _SmallestPlayerItemPanelState();
}

class _SmallestPlayerItemPanelState extends State<SmallestPlayerItemPanel> {
  Box setting = GStorage.setting;
  late bool haEnable;
  late Animation<Offset> topOffsetAnimation;
  late Animation<Offset> bottomOffsetAnimation;
  late Animation<Offset> leftOffsetAnimation;
  final VideoPageController videoPageController =
      Modular.get<VideoPageController>();
  final PlayerController playerController = Modular.get<PlayerController>();
  final TextEditingController textController = TextEditingController();

  void showForwardChange() {
    KazumiDialog.show(builder: (context) {
      String input = "";
      return AlertDialog(
        title: const Text('Skip Seconds'),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ],
            decoration: InputDecoration(
              floatingLabelBehavior:
                  FloatingLabelBehavior.never, // Control label display
              labelText: playerController.forwardTime.toString(),
            ),
            onChanged: (value) {
              input = value;
            },
          );
        }),
        actions: <Widget>[
          TextButton(
            onPressed: () => KazumiDialog.dismiss(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (input != "") {
                playerController.setForwardTime(int.parse(input));
                KazumiDialog.dismiss();
              } else {
                KazumiDialog.dismiss();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    topOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));
    bottomOffsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));
    leftOffsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeInOut,
    ));
    haEnable = setting.get(SettingBoxKey.hAenable, defaultValue: true);
  }

  Widget forwardIcon() {
    return Tooltip(
      message: 'Long press to modify time',
      child: GestureDetector(
        onLongPress: () => showForwardChange(),
        child: IconButton(
          icon: Image.asset(
            'assets/images/forward_80.png',
            color: Colors.white,
            height: 24,
          ),
          onPressed: () {
            playerController.seek(playerController.currentPosition +
                Duration(seconds: playerController.forwardTime));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svgString = danmakuOnSvg.replaceFirst(
        '00AEEC',
        Theme.of(context)
            .colorScheme
            .primary
            .toARGB32()
            .toRadixString(16)
            .substring(2));
    return Observer(builder: (context) {
      return Stack(
        alignment: Alignment.center,
        children: [
          //Top gradient area
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: !playerController.lockPanel,
              child: SlideTransition(
                position: topOffsetAnimation,
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black45,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //Bottom gradient area
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            bottom: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: !playerController.lockPanel,
              child: SlideTransition(
                position: bottomOffsetAnimation,
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black45,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Top progress bar
          Positioned(
              top: 25,
              child: playerController.showSeekTime
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          child: Text(
                            playerController.currentPosition.compareTo(
                                        playerController.playerPosition) >
                                    0
                                ? 'Fast Forward ${playerController.currentPosition.inSeconds - playerController.playerPosition.inSeconds} seconds'
                                : 'Rewind ${playerController.playerPosition.inSeconds - playerController.currentPosition.inSeconds} seconds',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container()),
          // Top playback speed bar
          Positioned(
              top: 25,
              child: playerController.showPlaySpeed
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                          child: const Row(
                            children: <Widget>[
                              Icon(Icons.fast_forward, color: Colors.white),
                              Text(
                                ' Speed Playback',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container()),
          // Brightness bar
          Positioned(
              top: 25,
              child: playerController.showBrightness
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.brightness_7,
                                    color: Colors.white),
                                Text(
                                  ' ${(playerController.brightness * 100).toInt()} %',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )
                  : Container()),
          // Volume bar
          Positioned(
              top: 25,
              child: playerController.showVolume
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(Icons.volume_down,
                                    color: Colors.white),
                                Text(
                                  ' ${playerController.volume.toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )
                  : Container()),
          // Custom top component
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: !playerController.lockPanel,
              child: SlideTransition(
                position: topOffsetAnimation,
                child: EmbeddedNativeControlArea(
                  child: Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          widget.onBackPressed(context);
                        },
                      ),
                      // Drag bar
                      const Expanded(
                        child: dtb.DragToMoveArea(child: SizedBox(height: 40)),
                      ),
                      // Skip
                      forwardIcon(),
                      if (Utils.isDesktop())
                        IconButton(
                            onPressed: () {
                              if (videoPageController.isPip) {
                                Utils.exitDesktopPIPWindow();
                              } else {
                                Utils.enterDesktopPIPWindow();
                              }
                              videoPageController.isPip =
                                  !videoPageController.isPip;
                            },
                            icon: const Icon(Icons.picture_in_picture,
                                color: Colors.white)),
                      // Danmaku switch
                      IconButton(
                        color: Colors.white,
                        icon: playerController.danmakuOn
                            ? SvgPicture.string(
                                svgString,
                                height: 24,
                              )
                            : SvgPicture.asset(
                                'assets/images/danmaku_off.svg',
                                height: 24,
                              ),
                        onPressed: () {
                          widget.handleDanmaku();
                        },
                        tooltip: playerController.danmakuOn ? 'Turn off danmaku' : 'Turn on danmaku',
                      ),
                      // Follow anime
                      CollectButton(
                        bangumiItem: videoPageController.bangumiItem,
                        onOpen: () {
                          widget.cancelHideTimer();
                          playerController.canHidePlayerPanel = false;
                        },
                        onClose: () {
                          widget.cancelHideTimer();
                          widget.startHideTimer();
                          playerController.canHidePlayerPanel = true;
                        },
                      ),
                      MenuAnchor(
                        consumeOutsideTap: true,
                        onOpen: () {
                          widget.cancelHideTimer();
                          playerController.canHidePlayerPanel = false;
                        },
                        onClose: () {
                          widget.cancelHideTimer();
                          widget.startHideTimer();
                          playerController.canHidePlayerPanel = true;
                        },
                        builder: (BuildContext context,
                            MenuController controller, Widget? child) {
                          return IconButton(
                            onPressed: () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                          );
                        },
                        menuChildren: [
                          SubmenuButton(
                            menuChildren: List<MenuItemButton>.generate(
                              3,
                              (int index) => MenuItemButton(
                                onPressed: () => playerController
                                    .aspectRatioType = index + 1,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Text(
                                    index + 1 == 1
                                        ? 'Auto'
                                        : index + 1 == 2
                                            ? 'Crop Fill'
                                            : 'Stretch Fill',
                                    style: TextStyle(
                                        color: index + 1 ==
                                                playerController.aspectRatioType
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null),
                                  ),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Video Ratio"),
                            ),
                          ),
                          SubmenuButton(
                            menuChildren: [
                              for (final double i
                                  in defaultPlaySpeedList) ...<MenuItemButton>[
                                MenuItemButton(
                                  onPressed: () async {
                                    await widget.setPlaybackSpeed(i);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 10, 10, 10),
                                    child: Text(
                                      '${i}x',
                                      style: TextStyle(
                                          color:
                                              i == playerController.playerSpeed
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Speed"),
                            ),
                          ),
                          SubmenuButton(
                            menuChildren: List<MenuItemButton>.generate(
                              3,
                              (int index) => MenuItemButton(
                                onPressed: () =>
                                    playerController.setShader(index + 1),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Text(
                                    index + 1 == 1
                                        ? 'Off'
                                        : index + 1 == 2
                                            ? 'Performance'
                                            : 'Quality',
                                    style: TextStyle(
                                      color: playerController
                                                  .superResolutionType ==
                                              index + 1
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Super Resolution"),
                            ),
                          ),
                          SubmenuButton(
                              menuChildren: [
                                MenuItemButton(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                    child: Text(
                                        "Current Room: ${playerController.syncplayRoom == '' ? 'Not joined' : playerController.syncplayRoom}"),
                                  ),
                                ),
                                MenuItemButton(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                    child: Text(
                                        "Network Latency: ${playerController.syncplayClientRtt}ms"),
                                  ),
                                ),
                                MenuItemButton(
                                  onPressed: () {
                                    widget.showSyncPlayRoomCreateDialog();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                    child: Text("Join Room"),
                                  ),
                                ),
                                MenuItemButton(
                                  onPressed: () {
                                    widget.showSyncPlayEndPointSwitchDialog();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                    child: Text("Switch Server"),
                                  ),
                                ),
                                MenuItemButton(
                                  onPressed: () async {
                                    await playerController.exitSyncPlayRoom();
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                    child: Text("Disconnect"),
                                  ),
                                ),
                              ],
                              child: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                                  child: Text("Watch Together"))),
                          MenuItemButton(
                            onPressed: () {
                              widget.showDanmakuSwitch();
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Danmaku Switch"),
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                constraints: BoxConstraints(
                                    maxHeight: 280,
                                    maxWidth: (Utils.isDesktop() ||
                                            Utils.isTablet())
                                        ? MediaQuery.of(context).size.width *
                                            9 /
                                            16
                                        : MediaQuery.of(context).size.width),
                                clipBehavior: Clip.antiAlias,
                                context: context,
                                builder: (context) {
                                  return DanmakuSettingsSheet(
                                      danmakuController:
                                          playerController.danmakuController);
                                },
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Danmaku Settings"),
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              widget.showVideoInfo();
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Video Details"),
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              bool needRestart = playerController.playing;
                              playerController.pause();
                              RemotePlay()
                                  .castVideo(playerController.videoUrl,
                                      videoPageController.currentPlugin.referer)
                                  .whenComplete(() {
                                if (needRestart) {
                                  playerController.play();
                                }
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("Remote Cast"),
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              playerController.lanunchExternalPlayer();
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              child: Text("External Player"),
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
          // Custom player bottom component
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Visibility(
              visible: !playerController.lockPanel,
              child: SlideTransition(
                position: bottomOffsetAnimation,
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: Icon(playerController.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      onPressed: () {
                        playerController.playOrPause();
                      },
                    ),
                    Expanded(
                      child: ProgressBar(
                        thumbRadius: 8,
                        thumbGlowRadius: 18,
                        timeLabelLocation: TimeLabelLocation.none,
                        progress: playerController.currentPosition,
                        buffered: playerController.buffer,
                        total: playerController.duration,
                        onSeek: (duration) {
                          playerController.seek(duration);
                        },
                        onDragStart: (details) {
                          widget.handleProgressBarDragStart(details);
                        },
                        onDragUpdate: (details) => {
                          playerController.currentPosition = details.timeStamp
                        },
                        onDragEnd: () {
                          widget.handleProgressBarDragEnd();
                        },
                      ),
                    ),
                    Text(
                      "    ${Utils.durationToString(playerController.currentPosition)} / ${Utils.durationToString(playerController.duration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    (!videoPageController.isPip)
                        ? IconButton(
                            color: Colors.white,
                            icon: Icon(videoPageController.isFullscreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded),
                            onPressed: () {
                              widget.handleFullscreen();
                            },
                          )
                        : const Text('    '),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}