// lib/features/profile/profile_screen.dart
// ══════════════════════════════════════════════════════════════
// Pilot profile — name, flight ID, phase
// Accessible from dashboard FAB or settings icon
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'profile_provider.dart';

const _kGo      = Color(0xFF00C853);
const _kCaution = Color(0xFFFFAA00);
const _kCyan    = Color(0xFF00BCD4);
const _kBg      = Color(0xFF0A0E14);
const _kSurface = Color(0xFF0D1520);
const _kBorder  = Color(0xFF1A3A2A);
const _kText1   = Color(0xFFE0E0E0);
const _kText2   = Color(0xFF558866);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _flightCtrl;

  @override
  void initState() {
    super.initState();
    final p     = context.read<ProfileProvider>();
    _nameCtrl   = TextEditingController(text: p.pilotName);
    _flightCtrl = TextEditingController(text: p.flightId);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _flightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        title: Text('PILOT PROFILE',
            style: GoogleFonts.shareTechMono(
                fontSize: 15, color: _kCyan, letterSpacing: 2)),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('SAVE',
                style: GoogleFonts.shareTechMono(
                    fontSize: 12, color: _kGo, letterSpacing: 1)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

          // ── Avatar ─────────────────────────────────────────
          Center(child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kCyan.withOpacity(0.1),
              border: Border.all(color: _kCyan.withOpacity(0.4), width: 2),
            ),
            child: Center(child: Text(
              p.pilotName.isNotEmpty
                  ? p.pilotName.substring(0, 1).toUpperCase()
                  : '?',
              style: GoogleFonts.shareTechMono(
                  fontSize: 28, color: _kCyan, fontWeight: FontWeight.w700),
            )),
          )),
          const SizedBox(height: 24),

          // ── Pilot name ─────────────────────────────────────
          _Label('PILOT NAME / CALLSIGN', _kText2),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: _kText1, fontSize: 14),
            decoration: _input('e.g. Capt. Smith / AEROSAFE01'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // ── Flight ID ──────────────────────────────────────
          _Label('FLIGHT ID / ROUTE', _kText2),
          const SizedBox(height: 8),
          TextField(
            controller: _flightCtrl,
            style: const TextStyle(color: _kText1, fontSize: 14),
            decoration: _input('e.g. AA101 or CAI→DXB'),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 20),

          // ── Flight phase ───────────────────────────────────
          _Label('CURRENT FLIGHT PHASE', _kText2),
          const SizedBox(height: 8),
          _PhasePicker(
            current: p.flightPhase,
            onChanged: (v) => p.setFlightPhase(v),
          ),
          const SizedBox(height: 32),

          // ── Save button ────────────────────────────────────
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kCyan.withOpacity(0.15),
                foregroundColor: _kCyan,
                side: const BorderSide(color: _kCyan),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text('SAVE PROFILE',
                  style: GoogleFonts.shareTechMono(
                      fontSize: 13, letterSpacing: 1.5)),
            ),
          ),
        ]),
      ),
    );
  }

  void _save() {
    final p = context.read<ProfileProvider>();
    p.setPilotName(_nameCtrl.text.trim());
    p.setFlightId(_flightCtrl.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile saved',
          style: GoogleFonts.shareTechMono(fontSize: 12)),
      backgroundColor: _kGo,
      duration: const Duration(seconds: 2),
    ));
    Navigator.of(context).maybePop();
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.shareTechMono(
        fontSize: 12, color: _kText2.withOpacity(0.6)),
  );
}

// ── Phase picker ──────────────────────────────────────────────
class _PhasePicker extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _PhasePicker({required this.current, required this.onChanged});

  static const _phases = [
    ('pre_flight',  'PRE-FLIGHT',  Icons.flight_takeoff_outlined),
    ('in_flight',   'IN-FLIGHT',   Icons.flight_outlined),
    ('post_flight', 'POST-FLIGHT', Icons.flight_land_outlined),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: _phases.map((p) {
      final sel = current == p.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => onChanged(p.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? _kCyan.withOpacity(0.08) : _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: sel ? _kCyan : _kBorder,
                  width: sel ? 1.5 : 1),
            ),
            child: Row(children: [
              Icon(p.$3,
                  color: sel ? _kCyan : _kText2, size: 20),
              const SizedBox(width: 12),
              Text(p.$2,
                  style: GoogleFonts.shareTechMono(
                      fontSize: 12,
                      color: sel ? _kCyan : _kText2,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
              const Spacer(),
              if (sel)
                Icon(Icons.check_circle, color: _kCyan, size: 16),
            ]),
          ),
        ),
      );
    }).toList(),
  );
}

class _Label extends StatelessWidget {
  final String text; final Color color;
  const _Label(this.text, this.color);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.shareTechMono(
          fontSize: 10, color: color, letterSpacing: 1.5));
}
