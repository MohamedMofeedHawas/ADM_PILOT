// lib/core/storage/assessment_record.g.dart
// ══════════════════════════════════════════════════════════════
// GENERATED — do NOT edit manually
// Regenerate with: flutter pub run build_runner build
// ══════════════════════════════════════════════════════════════

// ignore_for_file: type=lint

part of 'assessment_record.dart';

// ──────────────────────────────────────────────────
//  AssessmentRecord adapter
// ──────────────────────────────────────────────────
class AssessmentRecordAdapter extends TypeAdapter<AssessmentRecord> {
  @override final int typeId = kAssessmentRecordTypeId;

  @override
  AssessmentRecord read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return AssessmentRecord(
      id:             f[0]  as String,
      timestamp:      f[1]  as DateTime,
      pilotName:      f[2]  as String,
      flightId:       f[3]  as String,
      totalRiskScore: f[4]  as double,
      decision:       f[5]  as String,
      imsafe:         f[6]  as ImsafeScores,
      pave:           f[7]  as PaveScores,
      arousalLevel:   f[8]  as double,
      decideNotes:    f[9]  as String,
      flightPhase:    f[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AssessmentRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)  ..write(obj.id)
      ..writeByte(1)  ..write(obj.timestamp)
      ..writeByte(2)  ..write(obj.pilotName)
      ..writeByte(3)  ..write(obj.flightId)
      ..writeByte(4)  ..write(obj.totalRiskScore)
      ..writeByte(5)  ..write(obj.decision)
      ..writeByte(6)  ..write(obj.imsafe)
      ..writeByte(7)  ..write(obj.pave)
      ..writeByte(8)  ..write(obj.arousalLevel)
      ..writeByte(9)  ..write(obj.decideNotes)
      ..writeByte(10) ..write(obj.flightPhase);
  }

  @override bool operator ==(Object o) => o is AssessmentRecordAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────────────
//  ImsafeScores adapter
// ──────────────────────────────────────────────────
class ImsafeScoresAdapter extends TypeAdapter<ImsafeScores> {
  @override final int typeId = kImsafeScoresTypeId;

  @override
  ImsafeScores read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return ImsafeScores(
      illness:    f[0] as double,
      medication: f[1] as double,
      stress:     f[2] as double,
      alcohol:    f[3] as double,
      fatigue:    f[4] as double,
      emotion:    f[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ImsafeScores obj) {
    writer
      ..writeByte(6)
      ..writeByte(0) ..write(obj.illness)
      ..writeByte(1) ..write(obj.medication)
      ..writeByte(2) ..write(obj.stress)
      ..writeByte(3) ..write(obj.alcohol)
      ..writeByte(4) ..write(obj.fatigue)
      ..writeByte(5) ..write(obj.emotion);
  }

  @override bool operator ==(Object o) => o is ImsafeScoresAdapter;
  @override int get hashCode => typeId.hashCode;
}

// ──────────────────────────────────────────────────
//  PaveScores adapter
// ──────────────────────────────────────────────────
class PaveScoresAdapter extends TypeAdapter<PaveScores> {
  @override final int typeId = kPaveScoresTypeId;

  @override
  PaveScores read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (var i = 0; i < n; i++) reader.readByte(): reader.read()};
    return PaveScores(
      pilot:       f[0] as double,
      aircraft:    f[1] as double,
      environment: f[2] as double,
      external:    f[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PaveScores obj) {
    writer
      ..writeByte(4)
      ..writeByte(0) ..write(obj.pilot)
      ..writeByte(1) ..write(obj.aircraft)
      ..writeByte(2) ..write(obj.environment)
      ..writeByte(3) ..write(obj.external);
  }

  @override bool operator ==(Object o) => o is PaveScoresAdapter;
  @override int get hashCode => typeId.hashCode;
}
