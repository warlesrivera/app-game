import 'package:flutter/material.dart';

enum PlatformFamily { playstation, xbox, nintendo, pc, mobile, other }

abstract final class PlatformIconMapper {
  static IconData iconFor(String platform) {
    return iconForFamily(familyFor(platform));
  }

  static IconData iconForFamily(PlatformFamily family) {
    return switch (family) {
      PlatformFamily.playstation => Icons.sports_esports_rounded,
      PlatformFamily.xbox => Icons.videogame_asset_rounded,
      PlatformFamily.nintendo => Icons.videogame_asset_outlined,
      PlatformFamily.pc => Icons.desktop_windows_rounded,
      PlatformFamily.mobile => Icons.phone_iphone_rounded,
      PlatformFamily.other => Icons.devices_other_rounded,
    };
  }

  static PlatformFamily familyFor(String platform) {
    final name = platform.toLowerCase();

    if (name.contains('playstation') ||
        name.contains('psp') ||
        name.contains('ps vita') ||
        RegExp(r'\bps\s?\d').hasMatch(name)) {
      return PlatformFamily.playstation;
    }
    if (name.contains('xbox')) {
      return PlatformFamily.xbox;
    }
    if (name.contains('nintendo') ||
        name.contains('switch') ||
        name.contains('wii') ||
        name.contains('gamecube') ||
        name.contains('game boy') ||
        name.contains('3ds') ||
        name.contains('nes') ||
        name.contains('snes')) {
      return PlatformFamily.nintendo;
    }
    if (name.contains('pc') ||
        name.contains('macos') ||
        name.contains('linux') ||
        name.contains('steam')) {
      return PlatformFamily.pc;
    }
    if (name.contains('ios') ||
        name.contains('android') ||
        name.contains('mobile')) {
      return PlatformFamily.mobile;
    }
    return PlatformFamily.other;
  }

  static String labelFor(PlatformFamily family) {
    return switch (family) {
      PlatformFamily.playstation => 'PlayStation',
      PlatformFamily.xbox => 'Xbox',
      PlatformFamily.nintendo => 'Nintendo',
      PlatformFamily.pc => 'PC',
      PlatformFamily.mobile => 'Mobile',
      PlatformFamily.other => 'Otras',
    };
  }

  static List<({PlatformFamily family, IconData icon, String label})>
  uniqueIcons(List<String> platforms) {
    final families = <PlatformFamily>{};
    for (final platform in platforms) {
      families.add(familyFor(platform));
    }
    return [
      for (final family in families)
        (
          family: family,
          icon: iconForFamily(family),
          label: labelFor(family),
        ),
    ];
  }
}
