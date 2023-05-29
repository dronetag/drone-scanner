import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_opendroneid/models/message_pack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AircraftExpirationState {
  final bool cleanOldPacks;
  final double cleanTimeSec;
  final Map<String, Timer> expiryTimers;

  AircraftExpirationState({
    required this.cleanOldPacks,
    required this.cleanTimeSec,
    required this.expiryTimers,
  });

  AircraftExpirationState copyWith({
    bool? cleanOldPacks,
    double? cleanTimeSec,
    Map<String, Timer>? expiryTimers,
  }) =>
      AircraftExpirationState(
        cleanOldPacks: cleanOldPacks ?? this.cleanOldPacks,
        cleanTimeSec: cleanTimeSec ?? this.cleanTimeSec,
        expiryTimers: expiryTimers ?? this.expiryTimers,
      );
}

class AircraftExpirationCubit extends Cubit<AircraftExpirationState> {
  Function(String mac)? deleteCallback;
  static const maxTime = 600.0;
  static const minTime = 10.0;
  static const timeStep = 5.0;

  AircraftExpirationCubit()
      : super(AircraftExpirationState(
            cleanOldPacks: false, cleanTimeSec: 60.0, expiryTimers: {}));
  // load persistently saved settings
  Future<void> fetchSavedSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final cleanPacks = preferences.getBool('cleanOldPacks') ?? false;
    final cleanPacksSec = preferences.getDouble('cleanTimeSec') ?? 60;
    emit(
      state.copyWith(
        cleanOldPacks: cleanPacks,
        cleanTimeSec: cleanPacksSec,
      ),
    );
  }

  void setDeleteCallback(Function(String mac) callback) {
    deleteCallback = callback;
  }

  Future<void> setCleanOldPacks(Map<String, List<MessagePack>> packHistory,
      {required bool clean}) async {
    // persistently save this settings
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('cleanOldPacks', clean);
    // cancel or restart expiry timers
    if (!clean) {
      final timers = state.expiryTimers;
      timers.forEach(
        (key, value) {
          value.cancel();
        },
      );
      emit(state.copyWith(
        cleanOldPacks: clean,
        expiryTimers: timers,
      ));
    } else {
      emit(state.copyWith(
        cleanOldPacks: clean,
      ));

      resetExpiryTimers(packHistory);
    }
  }

  Future<void> setcleanTimeSec(
      double s, Map<String, List<MessagePack>> packHistory) async {
    // persistently save this setting
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble('cleanTimeSec', s);
    emit(
      state.copyWith(
        cleanTimeSec: s,
      ),
    );
    if (!state.cleanOldPacks) return;
    resetExpiryTimers(packHistory);
  }

  void resetExpiryTimers(Map<String, List<MessagePack>> packHistory) {
    var timers = state.expiryTimers;
    final toDelete = <String>[];
    packHistory.forEach((key, value) {
      final lastTStamp =
          packHistory[key]!.last.locationMessage!.receivedTimestamp;
      final packAgeSec =
          (DateTime.now().millisecondsSinceEpoch - lastTStamp) / 1000;
      final duration = state.cleanTimeSec - packAgeSec.toInt();
      if (duration <= 0) {
        toDelete.add(key);
        return;
      }
      if (timers[key] != null) {
        timers[key]?.cancel();
      }
      timers[key] = Timer(
          Duration(seconds: state.cleanTimeSec.toInt() - packAgeSec.toInt()),
          () {
        // remove if packs expire
        deleteCallback!(key);
      });
    });
    for (final element in toDelete) {
      deleteCallback!(element);
    }

    emit(state.copyWith(expiryTimers: timers));
  }

  void addTimer(String mac) {
    if (state.cleanOldPacks) {
      final timers = state.expiryTimers;
      timers[mac] = Timer(
        Duration(seconds: state.cleanTimeSec.toInt()),
        () {
          // remove if packs expire
          deleteCallback!(mac);
        },
      );
      emit(
        state.copyWith(
          expiryTimers: timers,
        ),
      );
    }
  }

  void removeTimer(String mac) {
    final timers = state.expiryTimers;
    if (timers.containsKey(mac)) {
      timers[mac]!.cancel();
      timers.remove(mac);
    }

    emit(
      state.copyWith(expiryTimers: timers),
    );
  }
}
