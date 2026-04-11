// // lib/screens/pilot_info_screen.dart — bottom buttons updated
// // NEW FLIGHT ▶  +  COPY FLIGHT PLAN ✈  (→ FlightPlanScreen)
//
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart' hide TextDirection;
// import '../theme/theme.dart';
// import 'flight_plan.dart';
//
// class PilotInfo {
//   final String pilotName, flightNumber, aircraftType, airline;
//   final DateTime departureTime;
//   final String origin, destination, license, registeration;
//   final Uint8List? photoBytes;
//   final String aviationHours ;
//   final double age;
//
//
//   const PilotInfo({
//     required this.pilotName, required this.flightNumber,
//     required this.aircraftType, required this.airline,
//     required this.departureTime,
//     required this.origin, required this.destination,
//     required this.license, required this.registeration,
//     this.photoBytes, required this.aviationHours,
//     required this.age ,
//   });
//
//   String get formattedDeparture =>
//       DateFormat('dd MMM yyyy  —  HH:mm').format(departureTime);
// }
//
// class PilotInfoScreen extends StatefulWidget {
//   final bool showArabic;
//   final PilotInfo? existing;
//   final Function(PilotInfo info) onSave;
//
//   const PilotInfoScreen({
//     super.key, required this.showArabic,
//     required this.onSave, this.existing,
//   });
//   @override State<PilotInfoScreen> createState() => _PilotInfoScreenState();
// }
//
// class _PilotInfoScreenState extends State<PilotInfoScreen> {
//   final _formKey       = GlobalKey<FormState>();
//   final _name          = TextEditingController();
//   final _license       = TextEditingController();
//   final _flight        = TextEditingController();
//   final _aircraft      = TextEditingController();
//   final _airline       = TextEditingController();
//   final _origin        = TextEditingController();
//   final _dest          = TextEditingController();
//   final _registeration = TextEditingController();
//   final _aviHours      = TextEditingController();
//   final _age           = TextEditingController();
//
//   DateTime _depTime = DateTime.now().add(const Duration(hours: 2));
//   DateTime _arrTime = DateTime.now().add(const Duration(hours: 4));
//   Uint8List? _photoBytes;
//
//   Set<String> _selectedCertifications = {};
//   Set<String> _selectedRatings        = {};
//
//   static const _commonCertifications = ['PPL', 'CPL', 'ATPL'];
//   static const _commonRatings        = ['IR', 'ME', 'SEP', 'MEP', 'CFI', 'CFII'];
//
//   @override
//   void initState() {
//     super.initState();
//     final e = widget.existing;
//     if (e != null) {
//       _name.text          = e.pilotName;
//       _flight.text        = e.flightNumber;
//       _aircraft.text      = e.aircraftType;
//       _airline.text       = e.airline;
//       _origin.text        = e.origin;
//       _dest.text          = e.destination;
//       _depTime            = e.departureTime;
//       _photoBytes         = e.photoBytes;
//       _license.text       = e.license;
//       _registeration.text = e.registeration;
//       _aviHours.text = e.aviationHours;
//       _age.text = e.age.toInt().toString();
//     }
//   }
//
//   @override
//   void dispose() {
//     _name.dispose(); _flight.dispose(); _aircraft.dispose();
//     _airline.dispose(); _origin.dispose(); _dest.dispose();
//     _license.dispose(); _registeration.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickPhoto() async {
//     try {
//       final p = await ImagePicker().pickImage(
//           source: ImageSource.gallery,
//           maxWidth: 400, maxHeight: 400, imageQuality: 85);
//       if (p == null || !mounted) return;
//       setState(() async => _photoBytes = await p.readAsBytes());
//     } catch (_) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(widget.showArabic
//               ? 'تعذّر فتح الصور' : 'Could not open gallery'),
//           backgroundColor: AppColors.amber));
//     }
//   }
//
//   Future<void> _pickTime() async {
//     final d = await showDatePicker(context: context,
//         initialDate: _depTime,
//         firstDate: DateTime.now().subtract(const Duration(days: 1)),
//         lastDate: DateTime.now().add(const Duration(days: 365)),
//         builder: (c, ch) => _theme(c, ch!));
//     if (d == null || !mounted) return;
//     final t = await showTimePicker(context: context,
//         initialTime: TimeOfDay.fromDateTime(_depTime),
//         builder: (c, ch) => _theme(c, ch!));
//     if (t == null || !mounted) return;
//     setState(() => _depTime =
//         DateTime(d.year, d.month, d.day, t.hour, t.minute));
//   }
//
//   Future<void> _pickArrTime(bool ar) async {
//     final d = await showDatePicker(context: context,
//         initialDate: _arrTime,
//         firstDate: DateTime.now().subtract(const Duration(days: 1)),
//         lastDate: DateTime.now().add(const Duration(days: 365)),
//         builder: (c, ch) => _theme(c, ch!));
//     if (d == null || !mounted) return;
//     final t = await showTimePicker(context: context,
//         initialTime: TimeOfDay.fromDateTime(_arrTime),
//         builder: (c, ch) => _theme(c, ch!));
//     if (t == null || !mounted) return;
//     final arr = DateTime(d.year, d.month, d.day, t.hour, t.minute);
//     if (arr.isBefore(_depTime)) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(ar
//               ? 'وقت الوصول يجب أن يكون بعد وقت الإقلاع'
//               : 'Arrival must be after departure'),
//           backgroundColor: AppColors.amber));
//       return;
//     }
//     setState(() => _arrTime = arr);
//   }
//
//   Widget _theme(BuildContext c, Widget ch) => Theme(
//       data: ThemeData.dark().copyWith(
//           colorScheme: const ColorScheme.dark(
//               primary: AppColors.cyan, onPrimary: AppColors.bg,
//               surface: AppColors.surface, onSurface: AppColors.textPrimary),
//           dialogBackgroundColor: AppColors.surface), child: ch);
//
//   void _save() {
//     if (!_formKey.currentState!.validate()) return;
//     widget.onSave(PilotInfo(
//       pilotName:    _name.text.trim().toUpperCase(),
//       flightNumber: _flight.text.trim().toUpperCase(),
//       aircraftType: _aircraft.text.trim().toUpperCase(),
//       airline:      _airline.text.trim().toUpperCase(),
//       registeration: _registeration.text.toUpperCase(),
//       departureTime: _depTime,
//       origin:       _origin.text.trim().toUpperCase(),
//       destination:  _dest.text.trim().toUpperCase(),
//       license:      _license.text.trim().toUpperCase(),
//       photoBytes:   _photoBytes,
//       aviationHours: _aviHours.text.trim().toUpperCase(),
//       age: double.tryParse(_age.text.trim()) ?? 0,
//
//
//     ));
//   }
//
//   String _duration() {
//     final d = _arrTime.difference(_depTime);
//     final abs = d.abs();
//     final r = abs.inHours > 0
//         ? '${abs.inHours}h ${abs.inMinutes % 60}m'
//         : '${abs.inMinutes % 60}m';
//     return d.isNegative ? '$r-' : r;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final ar = widget.showArabic;
//     return Directionality(
//       textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
//       child: Scaffold(
//         backgroundColor: AppColors.bg,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(ar ? 'بيانات الطيار والرحلة' : 'PILOT & FLIGHT INFO',
//               style: GoogleFonts.shareTechMono(fontSize: 14, letterSpacing: 1)),
//         ),
//         body: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//
//               // Banner
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                     color: AppColors.cyan.withOpacity(0.06),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: AppColors.cyan.withOpacity(0.2))),
//                 child: Row(children: [
//                   const Text('✈️', style: TextStyle(fontSize: 22)),
//                   const SizedBox(width: 10),
//                   Expanded(child: Text(
//                       ar ? 'أدخل بيانات الطيار والرحلة — ستظهر في التقرير النهائي والـ PDF'
//                           : 'Enter pilot & flight details — shown in final report & PDF.',
//                       textAlign: ar ? TextAlign.right : TextAlign.left,
//                       style: const TextStyle(
//                           fontSize: 11, color: AppColors.textSecondary, height: 1.4))),
//                 ]),
//               ).animate().fadeIn(),
//               const SizedBox(height: 20),
//
//               // Photo
//               Center(child: GestureDetector(
//                 onTap: _pickPhoto,
//                 child: Stack(alignment: Alignment.bottomRight, children: [
//                   Container(
//                       width: 100, height: 100,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle, color: AppColors.elevated,
//                           border: Border.all(color: AppColors.cyan.withOpacity(0.5), width: 2),
//                           image: _photoBytes != null
//                               ? DecorationImage(
//                               image: MemoryImage(_photoBytes!),
//                               fit: BoxFit.cover) : null),
//                       child: _photoBytes == null
//                           ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                         const Icon(Icons.person_outline,
//                             size: 34, color: AppColors.textTertiary),
//                         Text(ar ? 'صورة' : 'PHOTO',
//                             style: const TextStyle(
//                                 fontSize: 8, color: AppColors.textTertiary,
//                                 letterSpacing: 1)),
//                       ]) : null),
//                   Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(
//                           shape: BoxShape.circle, color: AppColors.cyan),
//                       child: const Icon(Icons.camera_alt, size: 14, color: AppColors.bg)),
//                 ]),
//               )).animate().fadeIn(),
//               const SizedBox(height: 6),
//               Center(child: Text(
//                   ar ? 'اضغط لاختيار صورة (اختياري)'
//                       : 'Tap to add photo (optional)',
//                   style: const TextStyle(fontSize: 10, color: AppColors.textTertiary))),
//               const SizedBox(height: 24),
//
//               // ── PILOT SECTION ────────────────────────
//               _sh(ar ? 'بيانات الطيار' : 'PILOT INFORMATION', Icons.person_outline),
//               const SizedBox(height: 10),
//               _f(_name, ar ? 'اسم الطيار الكامل' : 'Full Pilot Name',
//                   ar ? 'CAPT. محمد' : 'CAPT. JOHN SMITH', Icons.badge_outlined, ar),
//               const SizedBox(height: 12),
//               _f(_age, ar ? 'العمر' : 'Age',
//                   ar ? '50' : '50', Icons.calendar_today, ar),
//               const SizedBox(height: 12),
//               _f(_aviHours, ar ? 'عدد ساعات الطيران' : 'Aviation Hours',
//                   ar ? '5000' : '5000', Icons.hourglass_top_outlined, ar),
//               const SizedBox(height: 12),
//               _f(_license, ar ? 'رقم الرخصة' : 'License Number',
//                   'LIC-123456', Icons.card_membership_rounded, ar),
//               const SizedBox(height: 12),
//               _f(_airline, ar ? 'شركة الطيران' : 'Home Base Airport',
//                   ar ? 'مصر للطيران' : 'HECA', Icons.location_on_rounded, ar),
//               const SizedBox(height: 14),
//
//               Text(ar ? 'رخص الطيران' : 'Licenses',
//                   style: const TextStyle(fontSize: 12,
//                       color: AppColors.textSecondary, letterSpacing: 1)),
//               const SizedBox(height: 8),
//               _chips(_commonCertifications, _selectedCertifications),
//               const SizedBox(height: 14),
//
//               Text(ar ? 'الشهادات والتقييمات' : 'Rating & Certification',
//                   style: const TextStyle(fontSize: 12,
//                       color: AppColors.textSecondary, letterSpacing: 1)),
//               const SizedBox(height: 8),
//               _chips(_commonRatings, _selectedRatings),
//               const SizedBox(height: 24),
//
//               // // ── FLIGHT SECTION ───────────────────────
//               // _sh(ar ? 'بيانات الرحلة' : 'FLIGHT INFORMATION', Icons.flight_outlined),
//               // const SizedBox(height: 10),
//               // Row(children: [
//               //   Expanded(child: _f(_flight, ar ? 'رقم الرحلة' : 'Flight No.',
//               //       'MS 777', Icons.confirmation_number_outlined, ar)),
//               //   const SizedBox(width: 12),
//               //   Expanded(child: _f(_aircraft, ar ? 'طراز الطائرة' : 'Aircraft Type',
//               //       'B737-800', Icons.airplanemode_active, ar)),
//               // ]),
//               // const SizedBox(height: 12),
//               // _f(_registeration, ar ? 'كود الطائرة' : 'Registration Number',
//               //     'SU-GEN', Icons.app_registration, ar),
//               // const SizedBox(height: 12),
//               // Row(children: [
//               //   Expanded(child: _f(_origin, ar ? 'مطار المغادرة' : 'Origin',
//               //       'HECA / CAI', Icons.flight_takeoff, ar)),
//               //   const SizedBox(width: 12),
//               //   Expanded(child: _f(_dest, ar ? 'مطار الوصول' : 'Destination',
//               //       'EGLL / LHR', Icons.flight_land, ar)),
//               // ]),
//               // const SizedBox(height: 12),
//
//               // _timeRow(
//               //     icon: Icons.schedule_outlined,
//               //     label: ar ? 'وقت الإقلاع المحدد' : 'Scheduled Departure',
//               //     value: DateFormat('dd MMM yyyy  —  HH:mm').format(_depTime),
//               //     onTap: _pickTime),
//               // const SizedBox(height: 10),
//               // _timeRow(
//               //     icon: Icons.schedule_outlined,
//               //     label: ar ? 'وقت الوصول المحدد' : 'Scheduled Arrival',
//               //     value: DateFormat('dd MMM yyyy  —  HH:mm').format(_arrTime),
//               //     onTap: () => _pickArrTime(ar)),
//               // const SizedBox(height: 10),
//               // _timeRow(
//               //     icon: Icons.timer_outlined,
//               //     label: ar ? 'مدة الرحلة المقدرة' : 'Estimated Flight Duration',
//               //     value: _duration(), onTap: null,
//               //     trailing: Icons.hourglass_bottom_outlined),
//               // const SizedBox(height: 32),
//               //
//               // // ══════════════════════════════════════════
//               // // BUTTONS — replaces old _buildPreview + START
//               // // ══════════════════════════════════════════
//
//               // ① NEW FLIGHT
//               SizedBox(
//                 height: 54,
//                 child: ElevatedButton.icon(
//                   onPressed: _save,
//                   icon: const Icon(Icons.play_arrow_rounded, size: 22),
//                   label: Text(ar ? 'رحلة جديدة  ▶' : 'NEW FLIGHT  ▶',
//                       style: GoogleFonts.shareTechMono(
//                           fontSize: 14, letterSpacing: 2)),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.cyan,
//                       foregroundColor: AppColors.bg,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       elevation: 0),
//                 ),
//               ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
//
//               const SizedBox(height: 12),
//
//               // ② COPY FLIGHT PLAN → FlightPlanScreen
//               SizedBox(
//                 height: 54,
//                 child: OutlinedButton.icon(
//                   onPressed: () => Navigator.push(context,
//                       MaterialPageRoute(
//                           builder: (_) => FlightPlanScreen(
//                             onComplete: () {
//                               Navigator.pop(context); // يرجع لـ PilotInfo
//                               _save(); // يكمل الـ flow = يودي لـ Medical ثم IMSAFE
//                             },
//                           ))),
//                   icon: const Icon(Icons.content_copy_outlined, size: 18),
//                   label: Text(
//                       ar ? 'املأ خطة الطيران  ✈' : 'COPY FLIGHT PLAN  ✈',
//                       style: GoogleFonts.shareTechMono(
//                           fontSize: 13, letterSpacing: 1.5)),
//                   style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.amber,
//                       side: const BorderSide(
//                           color: AppColors.amber, width: 1.5),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10))),
//                 ),
//               ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.15),
//
//               const SizedBox(height: 8),
//               Center(child: Text(
//                 ar ? 'خطة الطيران الدولية — FAA Form 7233-4'
//                     : 'International Flight Plan — FAA Form 7233-4',
//                 style: const TextStyle(
//                     fontSize: 10, color: AppColors.textTertiary),
//               )).animate().fadeIn(delay: 400.ms),
//
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Helpers ───────────────────────────────────────────────
//   Widget _sh(String t, IconData icon) => Row(children: [
//     Icon(icon, size: 14, color: AppColors.cyan),
//     const SizedBox(width: 6),
//     Text(t, style: GoogleFonts.shareTechMono(
//         fontSize: 10, color: AppColors.cyan, letterSpacing: 2)),
//     const SizedBox(width: 8),
//     Expanded(child: Container(height: 0.5, color: AppColors.border)),
//   ]);
//
//   Widget _f(TextEditingController c, String label, String hint,
//       IconData icon, bool ar) => TextFormField(
//     controller: c,
//     textCapitalization: TextCapitalization.characters,
//     style: GoogleFonts.shareTechMono(
//         fontSize: 13, color: AppColors.textPrimary),
//     validator: (v) => (v == null || v.trim().isEmpty)
//         ? (ar ? 'مطلوب' : 'Required') : null,
//     decoration: InputDecoration(
//       labelText: label, hintText: hint,
//       prefixIcon: Icon(icon, size: 18, color: AppColors.cyan),
//       labelStyle: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
//       hintStyle: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
//       filled: true, fillColor: AppColors.elevated,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.border)),
//       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.border)),
//       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.cyan, width: 1.5)),
//       errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.red)),
//     ),
//   );
//
//   Widget _timeRow({
//     required IconData icon, required String label,
//     required String value, required VoidCallback? onTap,
//     IconData trailing = Icons.edit_calendar_outlined,
//   }) => GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       decoration: BoxDecoration(
//           color: AppColors.elevated,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: AppColors.border)),
//       child: Row(children: [
//         Icon(icon, size: 18, color: AppColors.cyan),
//         const SizedBox(width: 10),
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label, style: const TextStyle(
//               fontSize: 10, color: AppColors.textTertiary)),
//           const SizedBox(height: 3),
//           Text(value, style: GoogleFonts.shareTechMono(
//               fontSize: 14, color: AppColors.cyan)),
//         ])),
//         if (onTap != null)
//           Icon(trailing, size: 16, color: AppColors.textTertiary),
//       ]),
//     ),
//   );
//
//   Widget _chips(List<String> opts, Set<String> sel) => Wrap(
//     spacing: 8, runSpacing: 8,
//     children: opts.map((r) {
//       final s = sel.contains(r);
//       return GestureDetector(
//         onTap: () {
//           HapticFeedback.selectionClick();
//           setState(() { if (s) sel.remove(r); else sel.add(r); });
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 180),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//               color: s ? AppColors.textPrimary.withOpacity(0.1) : Colors.transparent,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                   color: s ? AppColors.textPrimary
//                       : AppColors.textSecondary.withOpacity(0.5),
//                   width: s ? 1.5 : 1)),
//           child: Text(r, style: TextStyle(
//               fontSize: 13,
//               fontWeight: s ? FontWeight.w700 : FontWeight.w400,
//               color: s ? AppColors.textPrimary
//                   : AppColors.textSecondary.withOpacity(0.8))),
//         ),
//       );
//     }).toList(),
//   ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
// }
// lib/screens/pilot_info_screen.dart — Light + Dark mode support
// ══════════════════════════════════════════════════════════════

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../theme/app_theme_colors.dart';
import 'flight_plan.dart';

class PilotInfo {
  final String     pilotName, flightNumber, aircraftType, airline;
  final DateTime   departureTime;
  final String     origin, destination, license, registeration;
  final Uint8List? photoBytes;
  final String     aviationHours;
  final double     age;

  const PilotInfo({
    required this.pilotName,
    required this.flightNumber,
    required this.aircraftType,
    required this.airline,
    required this.departureTime,
    required this.origin,
    required this.destination,
    required this.license,
    required this.registeration,
    this.photoBytes,
    required this.aviationHours,
    required this.age,
  });

  String get formattedDeparture =>
      DateFormat('dd MMM yyyy  —  HH:mm').format(departureTime);
}

class PilotInfoScreen extends StatefulWidget {
  final bool showArabic;
  final PilotInfo? existing;
  final Function(PilotInfo info) onSave;

  const PilotInfoScreen({
    super.key,
    required this.showArabic,
    required this.onSave,
    this.existing,
  });

  @override
  State<PilotInfoScreen> createState() => _PilotInfoScreenState();
}

class _PilotInfoScreenState extends State<PilotInfoScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _name           = TextEditingController();
  final _license        = TextEditingController();
  final _flight         = TextEditingController();
  final _aircraft       = TextEditingController();
  final _airline        = TextEditingController();
  final _origin         = TextEditingController();
  final _dest           = TextEditingController();
  final _registeration  = TextEditingController();
  final _aviHours       = TextEditingController();
  final _age            = TextEditingController();

  DateTime _depTime = DateTime.now().add(const Duration(hours: 2));
  DateTime _arrTime = DateTime.now().add(const Duration(hours: 4));
  Uint8List? _photoBytes;

  Set<String> _selectedCertifications = {};
  Set<String> _selectedRatings        = {};

  static const _commonCertifications = ['PPL', 'CPL', 'ATPL'];
  static const _commonRatings = ['IR', 'ME', 'SEP', 'MEP', 'CFI', 'CFII'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text          = e.pilotName;
      _flight.text        = e.flightNumber;
      _aircraft.text      = e.aircraftType;
      _airline.text       = e.airline;
      _origin.text        = e.origin;
      _dest.text          = e.destination;
      _depTime            = e.departureTime;
      _photoBytes         = e.photoBytes;
      _license.text       = e.license;
      _registeration.text = e.registeration;
      _aviHours.text      = e.aviationHours;
      _age.text           = e.age.toInt().toString();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _flight.dispose();
    _aircraft.dispose();
    _airline.dispose();
    _origin.dispose();
    _dest.dispose();
    _license.dispose();
    _registeration.dispose();
    _aviHours.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final p = await ImagePicker().pickImage(
          source:       ImageSource.gallery,
          maxWidth:     400,
          maxHeight:    400,
          imageQuality: 85);
      if (p == null || !mounted) return;
      final bytes = await p.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.showArabic
              ? 'تعذّر فتح الصور'
              : 'Could not open gallery'),
          backgroundColor: AppThemeColors.amber));
    }
  }

  Future<void> _pickTime() async {
    final d = await showDatePicker(
        context:     context,
        initialDate: _depTime,
        firstDate:   DateTime.now().subtract(const Duration(days: 1)),
        lastDate:    DateTime.now().add(const Duration(days: 365)),
        builder:     (c, ch) => _theme(c, ch!));
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context:     context,
        initialTime: TimeOfDay.fromDateTime(_depTime),
        builder:     (c, ch) => _theme(c, ch!));
    if (t == null || !mounted) return;
    setState(() =>
    _depTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _pickArrTime(bool ar) async {
    final d = await showDatePicker(
        context:     context,
        initialDate: _arrTime,
        firstDate:   DateTime.now().subtract(const Duration(days: 1)),
        lastDate:    DateTime.now().add(const Duration(days: 365)),
        builder:     (c, ch) => _theme(c, ch!));
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context:     context,
        initialTime: TimeOfDay.fromDateTime(_arrTime),
        builder:     (c, ch) => _theme(c, ch!));
    if (t == null || !mounted) return;
    final arr = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    if (arr.isBefore(_depTime)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ar
              ? 'وقت الوصول يجب أن يكون بعد وقت الإقلاع'
              : 'Arrival must be after departure'),
          backgroundColor: AppThemeColors.amber));
      return;
    }
    setState(() => _arrTime = arr);
  }

  Widget _theme(BuildContext ctx, Widget ch) => Theme(
      data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary:   AppThemeColors.cyan,
              onPrimary: Color(0xFF07090F),
              surface:   Color(0xFF0E1219),
              onSurface: Colors.white),
          dialogBackgroundColor: const Color(0xFF0E1219)),
      child: ch);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(PilotInfo(
      pilotName:    _name.text.trim().toUpperCase(),
      flightNumber: _flight.text.trim().toUpperCase(),
      aircraftType: _aircraft.text.trim().toUpperCase(),
      airline:      _airline.text.trim().toUpperCase(),
      registeration: _registeration.text.toUpperCase(),
      departureTime: _depTime,
      origin:        _origin.text.trim().toUpperCase(),
      destination:   _dest.text.trim().toUpperCase(),
      license:       _license.text.trim().toUpperCase(),
      photoBytes:    _photoBytes,
      aviationHours: _aviHours.text.trim().toUpperCase(),
      age:           double.tryParse(_age.text.trim()) ?? 0,
    ));
  }

  String _duration() {
    final d   = _arrTime.difference(_depTime);
    final abs = d.abs();
    final r   = abs.inHours > 0
        ? '${abs.inHours}h ${abs.inMinutes % 60}m'
        : '${abs.inMinutes % 60}m';
    return d.isNegative ? '$r-' : r;
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.showArabic;
    final c  = context.appColors;

    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation:       0,
          automaticallyImplyLeading: false,
          title: Text(
            ar ? 'بيانات الطيار والرحلة' : 'PILOT & FLIGHT INFO',
            style: GoogleFonts.shareTechMono(
                fontSize: 14, letterSpacing: 1, color: AppThemeColors.cyan),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: c.border),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Banner ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:        AppThemeColors.cyan.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border:       Border.all(
                        color: AppThemeColors.cyan.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Text('✈️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ar
                            ? 'أدخل بيانات الطيار والرحلة — ستظهر في التقرير النهائي والـ PDF'
                            : 'Enter pilot & flight details — shown in final report & PDF.',
                        textAlign: ar ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                            fontSize: 11,
                            color:    c.textSecondary,
                            height:   1.4),
                      ),
                    ),
                  ]),
                ).animate().fadeIn(),
                const SizedBox(height: 20),

                // ── Photo ──────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape:  BoxShape.circle,
                            color:  c.elevated,
                            border: Border.all(
                                color: AppThemeColors.cyan.withOpacity(0.5),
                                width: 2),
                            image: _photoBytes != null
                                ? DecorationImage(
                                image: MemoryImage(_photoBytes!),
                                fit:   BoxFit.cover)
                                : null,
                          ),
                          child: _photoBytes == null
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline,
                                  size:  34,
                                  color: c.textTertiary),
                              Text(ar ? 'صورة' : 'PHOTO',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color:    c.textTertiary,
                                      letterSpacing: 1)),
                            ],
                          )
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppThemeColors.cyan),
                          child: const Icon(Icons.camera_alt,
                              size: 14, color: Color(0xFF07090F)),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    ar
                        ? 'اضغط لاختيار صورة (اختياري)'
                        : 'Tap to add photo (optional)',
                    style: TextStyle(fontSize: 10, color: c.textTertiary),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Pilot section ──────────────────────────
                _sectionHeader(
                    ar ? 'بيانات الطيار' : 'PILOT INFORMATION',
                    Icons.person_outline, c),
                const SizedBox(height: 10),

                _field(_name,
                    ar ? 'اسم الطيار الكامل' : 'Full Pilot Name',
                    ar ? 'CAPT. محمد' : 'CAPT. JOHN SMITH',
                    Icons.badge_outlined, ar, c),
                const SizedBox(height: 12),

                _field(_age, ar ? 'العمر' : 'Age',
                    '50', Icons.calendar_today, ar, c),
                const SizedBox(height: 12),

                _field(_aviHours,
                    ar ? 'عدد ساعات الطيران' : 'Aviation Hours',
                    '5000', Icons.hourglass_top_outlined, ar, c),
                const SizedBox(height: 12),

                _field(_license, ar ? 'رقم الرخصة' : 'License Number',
                    'LIC-123456', Icons.card_membership_rounded, ar, c),
                const SizedBox(height: 12),

                _field(_airline,
                    ar ? 'شركة الطيران' : 'Home Base Airport',
                    ar ? 'مصر للطيران' : 'HECA',
                    Icons.location_on_rounded, ar, c),
                const SizedBox(height: 14),

                Text(
                  ar ? 'رخص الطيران' : 'Licenses',
                  style: TextStyle(
                      fontSize: 12,
                      color:    c.textSecondary,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                _chips(_commonCertifications, _selectedCertifications, c),
                const SizedBox(height: 14),

                Text(
                  ar ? 'الشهادات والتقييمات' : 'Rating & Certification',
                  style: TextStyle(
                      fontSize: 12,
                      color:    c.textSecondary,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                _chips(_commonRatings, _selectedRatings, c),
                const SizedBox(height: 32),

                // ── NEW FLIGHT button ──────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon:  const Icon(Icons.play_arrow_rounded, size: 22),
                    label: Text(
                      ar ? 'رحلة جديدة  ▶' : 'NEW FLIGHT  ▶',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 14, letterSpacing: 2),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeColors.cyan,
                      foregroundColor: const Color(0xFF07090F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
                const SizedBox(height: 12),

                // ── COPY FLIGHT PLAN button ────────────────
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlightPlanScreen(
                          onComplete: () {
                            Navigator.pop(context);
                            _save();
                          },
                        ),
                      ),
                    ),
                    icon:  const Icon(Icons.content_copy_outlined, size: 18),
                    label: Text(
                      ar ? 'املأ خطة الطيران  ✈' : 'COPY FLIGHT PLAN  ✈',
                      style: GoogleFonts.shareTechMono(
                          fontSize: 13, letterSpacing: 1.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeColors.amber,
                      side: const BorderSide(
                          color: AppThemeColors.amber, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ).animate().fadeIn(delay: 320.ms).slideY(begin: 0.15),
                const SizedBox(height: 8),

                Center(
                  child: Text(
                    ar
                        ? 'خطة الطيران الدولية — FAA Form 7233-4'
                        : 'International Flight Plan — FAA Form 7233-4',
                    style:
                    TextStyle(fontSize: 10, color: c.textTertiary),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────
  Widget _sectionHeader(
      String title, IconData icon, AppThemeColors c) =>
      Row(children: [
        Icon(icon, size: 14, color: AppThemeColors.cyan),
        const SizedBox(width: 6),
        Text(title,
            style: GoogleFonts.shareTechMono(
                fontSize: 10,
                color:    AppThemeColors.cyan,
                letterSpacing: 2)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 0.5, color: c.border)),
      ]);

  // ── Text field ─────────────────────────────────────────────
  Widget _field(
      TextEditingController ctrl,
      String label,
      String hint,
      IconData icon,
      bool ar,
      AppThemeColors c,
      ) =>
      TextFormField(
        controller:            ctrl,
        textCapitalization:    TextCapitalization.characters,
        style: GoogleFonts.shareTechMono(
            fontSize: 13, color: c.textPrimary),
        validator: (v) =>
        (v == null || v.trim().isEmpty)
            ? (ar ? 'مطلوب' : 'Required')
            : null,
        decoration: InputDecoration(
          labelText:  label,
          hintText:   hint,
          prefixIcon: Icon(icon, size: 18, color: AppThemeColors.cyan),
          labelStyle: TextStyle(fontSize: 11, color: c.textPrimary),
          hintStyle:  TextStyle(fontSize: 11, color: c.textTertiary),
          filled:     true,
          fillColor:  c.elevated,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:   BorderSide(color: c.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:   BorderSide(color: c.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: AppThemeColors.cyan, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppThemeColors.red)),
        ),
      );

  // ── Chip selector ──────────────────────────────────────────
  Widget _chips(
      List<String> opts,
      Set<String> sel,
      AppThemeColors c,
      ) =>
      Wrap(
        spacing: 8, runSpacing: 8,
        children: opts.map((r) {
          final selected = sel.contains(r);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (selected) sel.remove(r);
                else          sel.add(r);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? c.textPrimary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? c.textPrimary : c.textSecondary.withOpacity(0.5),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(r,
                  style: TextStyle(
                    fontSize:   13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color:      selected
                        ? c.textPrimary
                        : c.textSecondary.withOpacity(0.8),
                  )),
            ),
          );
        }).toList(),
      ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
}