import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_keys.dart';

/// Plays the short confirmation sound after money is recorded, the way
/// a payment app does.
class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  static const String _enabledKey = 'transaction_sound_enabled';

  /// One player reused for every sound.
  ///
  /// Creating a new one per tap leaks native handles on Android, and
  /// quick successive entries would cut each other off.
  final AudioPlayer _player = AudioPlayer();

  bool _ready = false;

  /// Off switch, so a user in a meeting can silence it.
  bool get isEnabled {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return true;
    return Hive.box(AppKeys.settingsBox).get(_enabledKey, defaultValue: true)
        as bool;
  }

  Future<void> setEnabled(bool value) async {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return;
    await Hive.box(AppKeys.settingsBox).put(_enabledKey, value);
  }

  Future<void> _prepare() async {
    if (_ready) return;

    // Low latency keeps the sound tight to the tap. It also means the
    // clip is held in memory, which is fine for something this short.
    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setReleaseMode(ReleaseMode.stop);

    _ready = true;
  }

  /// Confirmation for a saved transaction.
  ///
  /// The haptic fires first and always: it is instant, and it still
  /// confirms the save on a phone that is on silent.
  Future<void> playSuccess() async {
    HapticFeedback.mediumImpact();

    if (!isEnabled) return;

    try {
      await _prepare();
      await _player.stop();
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // A missing codec or a device with audio disabled must never stop
      // a transaction from being saved.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    _ready = false;
  }
}
