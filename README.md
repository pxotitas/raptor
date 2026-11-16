<div align="center">

<img src="Raptor/Resources/RaptorIcon.svg" alt="Raptor" width="132" />

# Raptor

**A native YouTube client for legacy iOS devices.**

Built for the iPad 3. Written in Objective-C and UIKit.

[![Platform](https://img.shields.io/badge/platform-iOS%209%2B-lightgrey)](#compatibility)
[![Architecture](https://img.shields.io/badge/architecture-ARMv7-blue)](#compatibility)
[![Status](https://img.shields.io/badge/status-early%20development-orange)](#status)

[Website](https://pxotitas.github.io/raptor/) · [Source](https://github.com/pxotitas/raptor)

</div>

---

## Overview

Raptor is an attempt to make YouTube usable on older iPads without relying on a modern browser or a recent version of iOS.

The initial target is the iPad 3 (A5X, 32-bit ARM) running iOS 9.3.5. The interface is native UIKit; the embedded player uses the legacy WebKit engine available on that system.

## Features

- Native iPad interface.
- YouTube search result parsing.
- Video titles, channel names and thumbnails.
- Embedded playback view.
- Layouts for portrait and landscape.
- No account required for the current prototype.

## Compatibility

| Device | System | Architecture | Status |
|:--|:--|:--|:--|
| iPad 3 (A1416) | iOS 9.3.5 | ARMv7 | Primary target |
| Other iOS devices | iOS 9.0+ | ARMv7 | Not tested |

Search and playback depend on YouTube's current website and player behavior. Compatibility with the live service is not guaranteed. H.264/AVC and AAC are the preferred playback formats for the target hardware; actual stream selection still needs on-device verification.

## Project layout

```text
Raptor/
├── Resources/
│   ├── RaptorIcon.svg
│   ├── Icon-*.png
│   └── raptor-player.css
├── Sources/
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── RootViewController.h
│   ├── RootViewController.m
│   └── main.m
└── Info.plist

website/
├── index.html
├── assets/
└── docs/
```

## Building

The project uses Theos and an iOS SDK. The target is ARMv7 with an iOS 9.0 deployment minimum.

See [the build guide](https://pxotitas.github.io/raptor/building.html) for the Linux setup and build commands.

## Status

Raptor is experimental. The source is being developed against the iOS 9 SDK, but a complete ARMv7 package and playback on physical hardware have not yet been verified.

## Acknowledgements

- [Theos](https://theos.dev/) for the build system.
- [YouTube](https://www.youtube.com/) for the video service.
