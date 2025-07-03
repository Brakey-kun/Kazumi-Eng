# Kazumi
An anime collection and online viewing program based on custom rules, developed using Flutter. Build your own rules using up to five lines of selectors based on `Xpath` syntax. Supports rule import and rule sharing. Supports real-time super-resolution based on `Anime4K`. Currently in active development (～￣▽￣)～

## Supported Platforms

- Android 10 and above
- Windows 10 and above
- MacOS 10.15 and above
- Linux (experimental)
- iOS (requires self-signing)
- HarmonyOS NEXT (located in [branch repository](https://github.com/ErBWs/Kazumi/releases/latest), requires sideloading)

## Screenshots

<table>
  <tr>
    <td><img alt="" src="static/screenshot/img_1.png"></td>
    <td><img alt="" src="static/screenshot/img_2.png"></td>
    <td><img alt="" src="static/screenshot/img_3.png"></td>
  <tr>
  <tr>
    <td><img alt="" src="static/screenshot/img_4.png"></td>
    <td><img alt="" src="static/screenshot/img_5.png"></td>
    <td><img alt="" src="static/screenshot/img_6.png"></td>
  <tr>
</table>

## Features / Development Plan

- [x] Rule editor
- [x] Anime catalog
- [x] Anime search
- [x] Anime schedule
- [x] Anime subtitles
- [x] Episode playback
- [x] Video player
- [x] Multiple video source support
- [x] Rule sharing
- [x] Hardware acceleration
- [x] High refresh rate adaptation
- [x] Watchlist
- [x] Anime comments/danmaku
- [x] Online updates
- [x] History
- [x] Playback speed control
- [x] Color schemes
- [x] Cross-device synchronization
- [x] Wireless casting (DLNA)
- [x] External player playback
- [x] Super-resolution
- [x] Watch together
- [ ] Anime downloads
- [ ] Anime update notifications
- [ ] And more (/・ω・＼)

## Download

Download through the [releases](https://github.com/Predidit/Kazumi/releases) tab on this page:

<a href="https://github.com/Predidit/Kazumi/releases">
  <img src="static/svg/get_it_on_github.svg" alt="Get it on Github" width="200"/>
</a>

### Android

<a href="https://f-droid.org/packages/com.predidit.kazumi">
  <img src="https://fdroid.gitlab.io/artwork/badge/get-it-on-en-us.svg"
  alt="Get it on F-Droid" width="200">
</a>

### GNU/Linux

&nbsp;&nbsp;
<a href="https://flathub.org/apps/io.github.Predidit.Kazumi">
  <img src="https://flathub.org/api/badge?svg&locale=en" alt="Get it on Flathub" width="175"/>
</a>

#### Arch Linux

Can be installed from [AUR](http://aur.archlinux.org) or [archlinuxcn](https://github.com/archlinuxcn/repo).

##### AUR

```bash
[yay/paru] -S kazumi # Build from source
[yay/paru] -S kazumi-bin # Binary package
```

##### archlinuxcn

```bash
sudo pacman -S kazumi
```

## Contributing

We welcome submissions of your custom rules to our [rule repository](https://github.com/Predidit/KazumiRules). You can freely choose whether to include your ID in the rules.

## Q&A

<details>
<summary>User Q&A</summary>

#### Q: Why are there ads in some anime?

A: This project does not insert any advertisements. Ads come from video sources. Please do not trust any content in the ads and try to choose ad-free video sources for viewing.

#### Q: Why does playback stutter after I enable the super-resolution feature?

A: The super-resolution feature requires high GPU performance. If you're not running Kazumi on a high-performance dedicated graphics card, try choosing efficiency mode rather than quality mode. Using super-resolution on low-resolution video sources rather than high-resolution ones can also reduce performance consumption.

#### Q: Why is memory usage high when playing videos?

A: This program caches as much video as possible to memory during video playback to provide a good viewing experience. If your memory is limited, you can enable low memory mode in the playback settings tab, which will limit caching.

#### Q: Why can't some anime be watched through external players?

A: Some video sources use anti-hotlinking measures, which can be resolved by Kazumi but cannot be resolved by external players.

#### Q: Why does the downloaded Linux version lack icons and tray functionality?

A: Use the .deb version for installation. The tar.gz version is only for convenience of secondary packaging, and this format inherently lacks support for icons and tray functionality.

</details>

<details>
<summary>Rule Writer Q&A</summary>

#### Q: Why can't my custom rules implement search?

A: Currently, our support for `Xpath` syntax is not complete. We currently only support selectors starting with `//`. We recommend building custom rules based on the example rules we provide.

#### Q: Why can my custom rules implement search but not viewing?

A: Try disabling the use built-in player option for custom rules, which will attempt to use `webview` for playback, improving compatibility. However, when the built-in player is available, it's recommended to enable it for a smoother viewing experience with danmaku.

</details>

<details>
<summary>Developer Q&A</summary>

#### Q: I'm trying to compile this project myself, but compilation was unsuccessful.

A: This project requires a good network environment for compilation. In addition to Flutter-related dependencies hosted by Google, this project also depends on resources hosted on MavenCentral/Github/SourceForge. If you're located in mainland China, you may need to set appropriate mirror addresses.

</details>

## Art Resources

The project icon comes from a work published by [Yuquanaaa](https://www.pixiv.net/users/66219277) on [Pixiv](https://www.pixiv.net/artworks/116666979).

This icon is copyrighted by its original author [Yuquanaaa](https://www.pixiv.net/users/66219277). We have obtained authorization and permission from the original author to use this icon in this project. This icon is not free to use. Without explicit authorization from the original author, no one may use, copy, modify, or distribute this icon without permission.

## Disclaimer

This project is licensed under the GNU General Public License version 3 (GPL-3.0). We make no express or implied warranties regarding its applicability, reliability, or accuracy. To the maximum extent permitted by law, the authors and contributors shall not be liable for any direct, indirect, incidental, special, or consequential damages arising from the use of this software.

Use of this project must comply with local laws and regulations, and no activities that infringe on third-party intellectual property rights may be conducted. Data and cache generated from using this project should be cleared within 24 hours. Use beyond 24 hours requires authorization from relevant rights holders.

## Privacy Policy

We do not collect any user data and do not use any telemetry components.

## Code Signing Policy
Submitters: [Contributors](https://github.com/Predidit/Kazumi/graphs/contributors)
Reviewers: [Owner](https://github.com/Predidit)

## Sponsors
| ![signpath](https://signpath.org/assets/favicon-50x50.png) | Free code signing on Windows provided by [SignPath.io](https://about.signpath.io/), certificate by [SignPath Foundation](https://signpath.org/) |
|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|

## Acknowledgments

Special thanks to [XpathSelector](https://github.com/simonkimi/xpath_selector) - this excellent project is the foundation of our project.

Special thanks to [DandanPlayer](https://www.dandanplay.com/) - this project uses the dandanplayer open API to provide danmaku interaction.

Special thanks to [Bangumi](https://bangumi.tv/) - this project uses the Bangumi open API to provide anime metadata.

Special thanks to [Anime4K](https://github.com/bloc97/Anime4K) - this project uses Anime4K for real-time super-resolution.

Special thanks to [SyncPlay](https://github.com/Syncplay/syncplay) - this project uses the SyncPlay protocol and implements watch together functionality through SyncPlay public servers.

Thanks to [media-kit](https://github.com/media-kit/media-kit) - this project's cross-platform media playback capabilities come from media-kit.

Thanks to [avbuild](https://github.com/wang-bin/avbuild) - this project uses out-of-tree patches from avbuild to implement non-standard video stream playback.

Thanks to [hive](https://github.com/isar/hive) - this project's persistent storage capabilities come from hive.