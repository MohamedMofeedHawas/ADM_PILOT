// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'imsafe_screen.dart';
//
// void main() => runApp(const FlightPlanApp());
//
// // ─── COLORS ──────────────────────────────────────────────────────────────────
// const _kAccent  = Color(0xFF0D3260);
// const _kAccentL = Color(0xFF1A4A8A);
// const _kForm    = Color(0xFFFDF8EF);
// const _kSuppl   = Color(0xFFF0E9D0);
// const _kBg      = Color(0xFF8C7E60);
// const _kSide    = BorderSide(color: Colors.black, width: 1.5);
// const _kThin    = BorderSide(color: Colors.black, width: 1.0);
//
// // ─── TEXT STYLES ─────────────────────────────────────────────────────────────
// const _kLbl = TextStyle(
//   fontSize: 7.5, fontWeight: FontWeight.w800,
//   letterSpacing: 0.8, color: Color(0xFF1A1A1A), fontFamily: 'Courier',
// );
// const _kSub = TextStyle(
//   fontSize: 7.0, fontWeight: FontWeight.bold,
//   color: Color(0xFF333333), fontFamily: 'Courier',
// );
// const _kBig = TextStyle(
//   fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Courier',
//   color: Colors.black, letterSpacing: 1.5, height: 1.1,
// );
// const _kIn = TextStyle(
//   fontSize: 12, fontFamily: 'Courier', color: Colors.black, letterSpacing: 0.3,
// );
// const _kArrow = TextStyle(
//   fontSize: 13, fontFamily: 'Courier', color: Color(0xFF444444),
// );
//
// // ─── FIELD DECORATION ────────────────────────────────────────────────────────
// InputDecoration _fieldDec({String? hint, bool box = false}) {
//   final base = box
//       ? const OutlineInputBorder(
//     borderSide: BorderSide(color: Colors.black, width: 1.2),
//     borderRadius: BorderRadius.zero,
//   )
//       : const UnderlineInputBorder(
//     borderSide: BorderSide(color: Colors.black, width: 1.2),
//   );
//   final focused = box
//       ? const OutlineInputBorder(
//     borderSide: BorderSide(color: _kAccent, width: 1.6),
//     borderRadius: BorderRadius.zero,
//   )
//       : const UnderlineInputBorder(
//     borderSide: BorderSide(color: _kAccent, width: 1.6),
//   );
//   return InputDecoration(
//     isDense: true,
//     counterText: '',
//     contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//     hintText: hint,
//     hintStyle: TextStyle(fontSize: 10, color: Colors.grey[400], fontFamily: 'Courier'),
//     border: base,
//     enabledBorder: base,
//     focusedBorder: focused,
//   );
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // APP
// // ─────────────────────────────────────────────────────────────────────────────
// class FlightPlanApp extends StatelessWidget {
//   const FlightPlanApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'International Flight Plan',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: false,
//         scaffoldBackgroundColor: _kBg,
//         colorScheme: ColorScheme.fromSeed(seedColor: _kAccent),
//       ),
//       home: const FlightPlanScreen(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // IMSAFE SCREEN (destination after complete)
// // ─────────────────────────────────────────────────────────────────────────────
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SEGMENTED INPUT — interactive individual character boxes
// // ─────────────────────────────────────────────────────────────────────────────
// class _SegmentedInput extends StatefulWidget {
//   final int length;
//   final String label;
//   final bool isRequired;
//   final void Function(String)? onChanged;
//   final String? hint;
//
//   const _SegmentedInput({
//     required this.length,
//     required this.label,
//     this.isRequired = false,
//     this.onChanged,
//     this.hint, required GlobalKey<_SegmentedInputState> key,
//   });
//
//   @override
//   State<_SegmentedInput> createState() => _SegmentedInputState();
// }
//
// class _SegmentedInputState extends State<_SegmentedInput> {
//   late final List<TextEditingController> _controllers;
//   late final List<FocusNode> _focuses;
//   int _activeIndex = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(widget.length, (_) => TextEditingController());
//     _focuses = List.generate(widget.length, (_) => FocusNode());
//     for (int i = 0; i < widget.length; i++) {
//       _focuses[i].addListener(() {
//         setState(() => _activeIndex = _focuses[i].hasFocus ? i : _activeIndex);
//         if (!_focuses[i].hasFocus && _activeIndex == i) {
//           setState(() => _activeIndex = -1);
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     for (final c in _controllers) c.dispose();
//     for (final f in _focuses) f.dispose();
//     super.dispose();
//   }
//
//   String get value => _controllers.map((c) => c.text).join();
//
//   void _handlePaste(String pasted, int startIndex) {
//     final chars = pasted.toUpperCase().replaceAll(' ', '').split('');
//     for (int i = startIndex; i < widget.length && (i - startIndex) < chars.length; i++) {
//       _controllers[i].text = chars[i - startIndex];
//     }
//     final nextIndex = (startIndex + chars.length).clamp(0, widget.length - 1);
//     FocusScope.of(context).requestFocus(_focuses[nextIndex]);
//     widget.onChanged?.call(value);
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             Text(widget.label, style: _kLbl),
//             if (widget.isRequired)
//               const Text(' *', style: TextStyle(fontSize: 7.5, color: Colors.red, fontFamily: 'Courier')),
//           ],
//         ),
//         const SizedBox(height: 5),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(widget.length, (i) {
//             final isActive = _activeIndex == i;
//             final isFilled = _controllers[i].text.isNotEmpty;
//             return GestureDetector(
//               onTap: () => FocusScope.of(context).requestFocus(_focuses[i]),
//               child: Container(
//                 width: 22,
//                 height: 28,
//                 margin: const EdgeInsets.only(right: 3),
//                 decoration: BoxDecoration(
//                   color: isActive
//                       ? const Color(0xFFE8F0FF)
//                       : isFilled
//                       ? const Color(0xFFF0F4FF)
//                       : Colors.white,
//                   border: Border.all(
//                     color: isActive ? _kAccent : Colors.black,
//                     width: isActive ? 2.0 : 1.2,
//                   ),
//                   boxShadow: isActive
//                       ? [BoxShadow(color: _kAccent.withOpacity(0.2), blurRadius: 4)]
//                       : null,
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: TextField(
//                         controller: _controllers[i],
//                         focusNode: _focuses[i],
//                         textAlign: TextAlign.center,
//                         maxLength: 1,
//                         textCapitalization: TextCapitalization.characters,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontFamily: 'Courier',
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                           height: 1,
//                         ),
//                         decoration: const InputDecoration(
//                           counterText: '',
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(vertical: 5),
//                         ),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
//                           _UpperCaseFormatter(),
//                         ],
//                         onChanged: (val) {
//                           if (val.length > 1) {
//                             _handlePaste(val, i);
//                             return;
//                           }
//                           widget.onChanged?.call(value);
//                           setState(() {});
//                           if (val.isNotEmpty && i < widget.length - 1) {
//                             FocusScope.of(context).requestFocus(_focuses[i + 1]);
//                           }
//                         },
//                         onEditingComplete: () {
//                           if (i < widget.length - 1) {
//                             FocusScope.of(context).requestFocus(_focuses[i + 1]);
//                           }
//                         },
//                       ),
//                     ),
//                     if (!isFilled && widget.hint != null && i < widget.hint!.length)
//                       Positioned.fill(
//                         child: IgnorePointer(
//                           child: Center(
//                             child: Text(
//                               widget.hint![i],
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontFamily: 'Courier',
//                                 color: Colors.grey[400],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MAIN SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
// class FlightPlanScreen extends StatefulWidget {
//   const FlightPlanScreen({super.key});
//   @override
//   State<FlightPlanScreen> createState() => _FPState();
// }
//
// class _FPState extends State<FlightPlanScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isComplete = false;
//
//   // Segmented keys
//   final _keyAcId   = GlobalKey<_SegmentedInputState>();
//   final _keyAcType = GlobalKey<_SegmentedInputState>();
//   final _keyDep    = GlobalKey<_SegmentedInputState>();
//   final _keyDest   = GlobalKey<_SegmentedInputState>();
//   final _keyAltn1  = GlobalKey<_SegmentedInputState>();
//   final _keyAltn2  = GlobalKey<_SegmentedInputState>();
//
//   // Text controllers
//   final _cAddr1      = TextEditingController();
//   final _cAddr2      = TextEditingController();
//   final _cOriginator = TextEditingController();
//   final _cSpecId     = TextEditingController();
//   final _cEquipment  = TextEditingController();
//   final _cSpeed      = TextEditingController();
//   final _cLevel      = TextEditingController();
//   final _cRoute      = TextEditingController();
//   final _cEetHr      = TextEditingController();
//   final _cEetMin     = TextEditingController();
//   final _cOtherInfo  = TextEditingController();
//   final _cEndHr      = TextEditingController();
//   final _cEndMin     = TextEditingController();
//   final _cPob        = TextEditingController();
//   final _cDingNum    = TextEditingController();
//   final _cDingCap    = TextEditingController();
//   final _cDingColor  = TextEditingController();
//   final _cAcColor    = TextEditingController();
//   final _cRemarks    = TextEditingController();
//   final _cPic        = TextEditingController();
//   final _cFiledBy    = TextEditingController();
//   final _cAcceptedBy = TextEditingController();
//   final _cAddInfo    = TextEditingController();
//
//   // Dropdowns
//   String? _flightRules, _typeOfFlight, _numAircraft, _wakeTurb;
//
//   // DateTime
//   DateTime? _filingDT, _depDT;
//
//   // Checkboxes
//   bool _uhf = false, _vhf = false, _elt = false;
//   bool _polar = false, _desert = false, _maritime = false, _jungle = false;
//   bool _lightJ = false, _floresJ = false, _uhfJ = false, _vhfJ = false;
//   bool _dingCover = false;
//
//   @override
//   void dispose() {
//     for (final c in [
//       _cAddr1, _cAddr2, _cOriginator, _cSpecId, _cEquipment,
//       _cSpeed, _cLevel, _cRoute, _cEetHr, _cEetMin, _cOtherInfo,
//       _cEndHr, _cEndMin, _cPob, _cDingNum, _cDingCap, _cDingColor,
//       _cAcColor, _cRemarks, _cPic, _cFiledBy, _cAcceptedBy, _cAddInfo,
//     ]) c.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickFiling() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (ctx, child) => Theme(
//         data: ThemeData(colorScheme: const ColorScheme.light(primary: _kAccent)),
//         child: child!,
//       ),
//     );
//     if (d == null || !mounted) return;
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (ctx, child) => Theme(
//         data: ThemeData(colorScheme: const ColorScheme.light(primary: _kAccent)),
//         child: child!,
//       ),
//     );
//     if (t == null) return;
//     setState(() => _filingDT = DateTime(d.year, d.month, d.day, t.hour, t.minute));
//   }
//
//   Future<void> _pickDep() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (ctx, child) => Theme(
//         data: ThemeData(colorScheme: const ColorScheme.light(primary: _kAccent)),
//         child: child!,
//       ),
//     );
//     if (d == null || !mounted) return;
//     final t = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (ctx, child) => Theme(
//         data: ThemeData(colorScheme: const ColorScheme.light(primary: _kAccent)),
//         child: child!,
//       ),
//     );
//     if (t == null) return;
//     setState(() => _depDT = DateTime(d.year, d.month, d.day, t.hour, t.minute));
//   }
//
//   String _fmtDDHHMM(DateTime dt) =>
//       '${dt.day.toString().padLeft(2, '0')}${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}';
//
//   String _fmtHHMM(DateTime dt) =>
//       '${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}';
//
//   bool _validateAll() {
//     final acId   = _keyAcId.currentState?.value ?? '';
//     final dep    = _keyDep.currentState?.value ?? '';
//     final dest   = _keyDest.currentState?.value ?? '';
//     final pic    = _cPic.text.trim();
//     final speed  = _cSpeed.text.trim();
//     final level  = _cLevel.text.trim();
//
//     if (acId.isEmpty || dep.isEmpty || dest.isEmpty ||
//         pic.isEmpty || speed.isEmpty || level.isEmpty ||
//         _flightRules == null || _depDT == null) {
//       return false;
//     }
//     return true;
//   }
//
//   void _onCompleteAndAssign() {
//     if (!_validateAll()) {
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           titlePadding: EdgeInsets.zero,
//           title: Container(
//             color: Colors.red[800],
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: const Row(
//               children: [
//                 Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
//                 SizedBox(width: 8),
//                 Text(
//                   'INCOMPLETE FLIGHT PLAN',
//                   style: TextStyle(
//                     color: Colors.white, fontSize: 12,
//                     fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 1.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           content: const Text(
//             'Please fill all required fields:\n\n'
//                 '• Aircraft ID\n• Flight Rules\n• Departure Aerodrome\n'
//                 '• Departure Time\n• Cruising Speed\n• Level\n'
//                 '• Destination\n• Pilot-in-Command',
//             style: TextStyle(fontSize: 12, fontFamily: 'Courier', height: 1.7),
//           ),
//           actions: [
//             TextButton(
//               style: TextButton.styleFrom(foregroundColor: _kAccent),
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK', style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isComplete = true);
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//         titlePadding: EdgeInsets.zero,
//         title: Container(
//           color: const Color(0xFF1B5E20),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: const Row(
//             children: [
//               Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
//               SizedBox(width: 8),
//               Text(
//                 'FLIGHT PLAN COMPLETE',
//                 style: TextStyle(
//                   color: Colors.white, fontSize: 12,
//                   fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         content: Text(
//           'Aircraft   : ${_keyAcId.currentState?.value ?? ""}\n'
//               'Rules      : ${_flightRules ?? "—"} / ${_typeOfFlight ?? "—"}\n'
//               'Departure  : ${_keyDep.currentState?.value ?? ""}  ${_depDT != null ? _fmtHHMM(_depDT!) + "Z" : ""}\n'
//               'Destination: ${_keyDest.currentState?.value ?? ""}\n'
//               'Speed/Level: ${_cSpeed.text} / ${_cLevel.text}\n'
//               'PIC        : ${_cPic.text}',
//           style: const TextStyle(fontSize: 11, fontFamily: 'Courier', height: 1.8),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.grey),
//             onPressed: () {
//               setState(() => _isComplete = false);
//               Navigator.pop(context);
//             },
//             child: const Text('REVIEW', style: TextStyle(fontFamily: 'Courier')),
//           ),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _kAccent,
//               foregroundColor: Colors.white,
//               shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ImsafeScreen()),
//               );
//             },
//             icon: const Icon(Icons.flight_takeoff, size: 15),
//             label: const Text(
//               'PROCEED',
//               style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── BUILD ────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: _kAccent,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           title: const Row(
//             children: [
//               Icon(Icons.flight, size: 16),
//               SizedBox(width: 8),
//               Text(
//                 'FAA 7233-4  ·  International Flight Plan',
//                 style: TextStyle(
//                   fontSize: 12, fontFamily: 'Courier',
//                   fontWeight: FontWeight.w700, letterSpacing: 1.0,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
//               child: Center(
//                 child: Container(
//                   width: 860,
//                   decoration: BoxDecoration(
//                     color: _kForm,
//                     border: Border.all(color: Colors.black, width: 2),
//                     boxShadow: const [
//                       BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(8, 8)),
//                     ],
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         _buildHeader(),
//                         _buildPriorityRow(),
//                         _buildFilingRow(),
//                         _buildSpecIdRow(),
//                         _buildFplRow(),
//                         _buildAircraftRow(),
//                         _buildDepartureRow(),
//                         _buildRouteSection(),
//                         _buildDestinationRow(),
//                         _buildOtherInfoSection(),
//                         _buildSupplHeader(),
//                         _buildSupplEndurance(),
//                         _buildSupplSurvival(),
//                         _buildSupplDinghies(),
//                         _buildSupplAcColor(),
//                         _buildSupplRemarks(),
//                         _buildSupplPic(),
//                         _buildFooterRow(),
//                         _buildCompleteButton(),
//                         _buildFormFooter(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── SECTION HELPERS ─────────────────────────────────────────────────────
//   Widget _sec({
//     required Widget child,
//     Border? border,
//     EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//     double? width,
//     Color? bg,
//   }) {
//     return Container(
//       width: width,
//       padding: padding,
//       decoration: BoxDecoration(color: bg, border: border),
//       child: child,
//     );
//   }
//
//   Widget _lbl(String text, Widget child, {bool required = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(children: [
//           Text(text, style: _kLbl),
//           if (required)
//             const Text(' *', style: TextStyle(fontSize: 7.5, color: Colors.red, fontFamily: 'Courier')),
//         ]),
//         const SizedBox(height: 4),
//         child,
//       ],
//     );
//   }
//
//   Widget _txt(
//       TextEditingController c, {
//         String? hint, double? width, int? max,
//         bool box = false, int lines = 1,
//         TextCapitalization cap = TextCapitalization.characters,
//         TextInputType? keyboard,
//         String? Function(String?)? validator,
//         List<TextInputFormatter>? formatters,
//       }) {
//     final field = TextFormField(
//       controller: c,
//       style: _kIn,
//       maxLength: max,
//       maxLines: lines,
//       textCapitalization: cap,
//       keyboardType: keyboard,
//       inputFormatters: formatters,
//       validator: validator,
//       decoration: _fieldDec(hint: hint, box: box),
//     );
//     return width != null ? SizedBox(width: width, child: field) : field;
//   }
//
//   Widget _drop({
//     required String label,
//     required String? value,
//     required List<_DropItem> items,
//     required void Function(String?) onChange,
//     double? width,
//     bool required = false,
//   }) {
//     Widget dd = Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(children: [
//           Text(label, style: _kLbl),
//           if (required)
//             const Text(' *', style: TextStyle(fontSize: 7.5, color: Colors.red, fontFamily: 'Courier')),
//         ]),
//         const SizedBox(height: 4),
//         DropdownButtonFormField<String>(
//           value: value,
//           style: _kIn,
//           isExpanded: true,
//           decoration: const InputDecoration(
//             isDense: true,
//             contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//             border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.2)),
//             enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.2)),
//             focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kAccent, width: 1.6)),
//           ),
//           hint: Text('—', style: _kIn.copyWith(color: Colors.grey)),
//           items: items.map((e) => DropdownMenuItem<String>(
//             value: e.value,
//             child: Text(e.display, style: _kIn.copyWith(fontSize: 11)),
//           )).toList(),
//           selectedItemBuilder: (_) => items.map((e) => Align(
//             alignment: Alignment.centerLeft,
//             child: Text(e.value, style: _kIn.copyWith(
//               fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3,
//             )),
//           )).toList(),
//           onChanged: onChange,
//         ),
//       ],
//     );
//     return width != null ? SizedBox(width: width, child: dd) : dd;
//   }
//
//   Widget _dateTap({
//     required String label, required DateTime? dt,
//     required VoidCallback onTap, required String fmt, String? hint,
//     bool required = false,
//   }) {
//     final display = dt != null
//         ? (fmt == 'DDHHMM' ? _fmtDDHHMM(dt) : _fmtHHMM(dt))
//         : '';
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(children: [
//           Text(label, style: _kLbl),
//           if (required)
//             const Text(' *', style: TextStyle(fontSize: 7.5, color: Colors.red, fontFamily: 'Courier')),
//         ]),
//         const SizedBox(height: 5),
//         GestureDetector(
//           onTap: onTap,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ...List.generate(fmt.length, (i) {
//                 final char = i < display.length ? display[i] : '';
//                 final hintChar = i < fmt.length ? fmt[i] : ' ';
//                 return Container(
//                   width: 22, height: 28,
//                   margin: const EdgeInsets.only(right: 3),
//                   decoration: BoxDecoration(
//                     color: char.isNotEmpty ? const Color(0xFFEEF4FF) : Colors.white,
//                     border: Border.all(
//                       color: dt != null ? _kAccent : Colors.black,
//                       width: dt != null ? 1.6 : 1.2,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       char.isNotEmpty ? char : hintChar,
//                       style: TextStyle(
//                         fontSize: 11, fontFamily: 'Courier', fontWeight: FontWeight.bold,
//                         color: char.isNotEmpty ? Colors.black : Colors.grey[400],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//               const SizedBox(width: 6),
//               Icon(Icons.access_time_outlined, size: 14,
//                   color: dt != null ? _kAccent : Colors.grey[500]),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _cbx(String label, bool val, void Function(bool) onChange) {
//     return GestureDetector(
//       onTap: () => onChange(!val),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label, style: _kSub.copyWith(fontSize: 6.5)),
//           const SizedBox(height: 3),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 150),
//             width: 22, height: 22,
//             decoration: BoxDecoration(
//               border: Border.all(color: val ? _kAccent : Colors.black, width: 1.5),
//               color: val ? _kAccent : Colors.white,
//               boxShadow: val ? [BoxShadow(color: _kAccent.withOpacity(0.3), blurRadius: 4)] : null,
//             ),
//             child: Center(
//               child: val
//                   ? const Icon(Icons.check, size: 14, color: Colors.white)
//                   : Text(
//                 label.isNotEmpty ? label[0] : '',
//                 style: const TextStyle(
//                   fontSize: 11, fontFamily: 'Courier',
//                   fontWeight: FontWeight.bold, color: Color(0xFF888888),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sym(String s) =>
//       Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(s, style: _kArrow));
//
//   // ─── SECTION BUILDERS ────────────────────────────────────────────────────
//
//   Widget _buildHeader() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 32, height: 32,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: _kAccent, width: 2),
//                     color: _kAccent.withOpacity(0.08),
//                   ),
//                   child: const Center(
//                     child: Text('DOT', style: TextStyle(
//                       fontSize: 7, fontWeight: FontWeight.bold,
//                       fontFamily: 'Courier', color: _kAccent,
//                     )),
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 const Text('U.S. Department of Transportation',
//                     style: TextStyle(fontSize: 7.5, fontFamily: 'Courier')),
//                 const Text('Federal Aviation Administration',
//                     style: TextStyle(fontSize: 7.5, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//           const Text(
//             'International Flight Plan',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
//                 fontFamily: 'Courier', letterSpacing: 1.5),
//           ),
//           Align(
//             alignment: Alignment.topRight,
//             child: Text(
//               'Approved OMB No.\n2120-0026 Exp. 9/30/2023',
//               textAlign: TextAlign.right,
//               style: TextStyle(fontSize: 7.5, color: Colors.grey[600], fontFamily: 'Courier'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPriorityRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: EdgeInsets.zero,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _sec(
//               border: const Border(right: _kSide),
//               width: 110,
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('PRIORITY', style: _kLbl),
//                   SizedBox(height: 6),
//                   Text('<=FF', style: _kBig),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: _sec(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('ADDRESSEE(S)', style: _kLbl),
//                     const SizedBox(height: 5),
//                     Row(children: [
//                       Expanded(child: _txt(_cAddr1)),
//                       const SizedBox(width: 6),
//                       _sym('<='),
//                     ]),
//                     const SizedBox(height: 4),
//                     _txt(_cAddr2),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilingRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: EdgeInsets.zero,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _sec(
//               border: const Border(right: _kSide),
//               width: 180,
//               child: _dateTap(
//                 label: 'FILING TIME', dt: _filingDT,
//                 onTap: _pickFiling, fmt: 'DDHHMM',
//               ),
//             ),
//             Expanded(
//               child: _sec(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Expanded(child: _lbl('ORIGINATOR', _txt(_cOriginator))),
//                     const SizedBox(width: 8),
//                     _sym('<='),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSpecIdRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       child: _lbl(
//         'SPECIFIC IDENTIFICATION OF ADDRESSEE(S) AND / OR ORIGINATOR',
//         _txt(_cSpecId),
//       ),
//     );
//   }
//
//   Widget _buildFplRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: EdgeInsets.zero,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _sec(
//               border: const Border(right: _kSide),
//               width: 130,
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('3 MESSAGE TYPE', style: _kLbl),
//                   SizedBox(height: 6),
//                   Text('<=(FPL', style: _kBig),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 2,
//               child: _sec(
//                 border: const Border(right: _kSide),
//                 child: _SegmentedInput(
//                   key: _keyAcId,
//                   length: 7,
//                   label: '7 AIRCRAFT IDENTIFICATION',
//                   isRequired: true,
//                   hint: 'ABCD123',
//                 ),
//               ),
//             ),
//             _sec(
//               border: const Border(right: _kSide),
//               width: 140,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _sym('—'),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: _drop(
//                       label: '8 FLIGHT RULES',
//                       required: true,
//                       value: _flightRules,
//                       items: [
//                         const _DropItem('I', 'I — IFR'),
//                         const _DropItem('V', 'V — VFR'),
//                         const _DropItem('Y', 'Y — IFR→VFR'),
//                         const _DropItem('Z', 'Z — VFR→IFR'),
//                       ],
//                       onChange: (v) => setState(() => _flightRules = v),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _sec(
//               width: 140,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: _drop(
//                       label: 'TYPE OF FLIGHT',
//                       value: _typeOfFlight,
//                       items: [
//                         const _DropItem('S', 'S — Scheduled'),
//                         const _DropItem('N', 'N — Non-sched.'),
//                         const _DropItem('G', 'G — Gen. Aviation'),
//                         const _DropItem('M', 'M — Military'),
//                         const _DropItem('X', 'X — Other'),
//                       ],
//                       onChange: (v) => setState(() => _typeOfFlight = v),
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   _sym('<='),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAircraftRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: EdgeInsets.zero,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _sec(
//               border: const Border(right: _kSide),
//               width: 100,
//               child: _drop(
//                 label: '9 NUMBER',
//                 value: _numAircraft,
//                 items: List.generate(9, (i) => _DropItem('${i + 1}', '${i + 1}')),
//                 onChange: (v) => setState(() => _numAircraft = v),
//               ),
//             ),
//             _sec(
//               border: const Border(right: _kSide),
//               child: _SegmentedInput(
//                 key: _keyAcType,
//                 length: 4,
//                 label: 'TYPE OF AIRCRAFT',
//                 hint: 'B738',
//               ),
//             ),
//             _sec(
//               border: const Border(right: _kSide),
//               width: 160,
//               child: _drop(
//                 label: 'WAKE TURBULENCE CAT.',
//                 value: _wakeTurb,
//                 items: [
//                   const _DropItem('L', 'L — Light (<7t)'),
//                   const _DropItem('M', 'M — Medium'),
//                   const _DropItem('H', 'H — Heavy (>136t)'),
//                   const _DropItem('J', 'J — Super (A380)'),
//                 ],
//                 onChange: (v) => setState(() => _wakeTurb = v),
//               ),
//             ),
//             _sec(
//               border: const Border(right: _kSide),
//               width: 24,
//               padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
//               child: const Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Text('—', style: _kArrow),
//               ),
//             ),
//             Expanded(
//               child: _sec(
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Expanded(child: _lbl('10 EQUIPMENT', _txt(_cEquipment, hint: 'SDFG'))),
//                     const SizedBox(width: 4),
//                     _sym('/'),
//                     const SizedBox(width: 4),
//                     _sym('<='),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDepartureRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _sym('—'),
//           const SizedBox(width: 8),
//           _SegmentedInput(
//             key: _keyDep,
//             length: 4,
//             label: '13 DEPARTURE AERODROME',
//             isRequired: true,
//             hint: 'ICAO',
//           ),
//           const SizedBox(width: 40),
//           _dateTap(
//             label: 'TIME (UTC)',
//             dt: _depDT,
//             onTap: _pickDep,
//             fmt: 'HHMM',
//             required: true,
//           ),
//           const SizedBox(width: 8),
//           _sym('<='),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRouteSection() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               SizedBox(
//                 width: 120,
//                 child: _lbl('15 CRUISING SPEED', _txt(_cSpeed, hint: 'N0450', max: 5), required: true),
//               ),
//               const SizedBox(width: 20),
//               SizedBox(
//                 width: 100,
//                 child: _lbl('LEVEL', _txt(_cLevel, hint: 'F350', max: 5), required: true),
//               ),
//               const SizedBox(width: 20),
//               const Padding(
//                 padding: EdgeInsets.only(bottom: 5),
//                 child: Text('ROUTE', style: _kLbl),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           _txt(
//             _cRoute,
//             hint: 'Full route details (e.g. DCT ALPHA B52 BETA DCT)',
//             lines: 3,
//             box: true,
//           ),
//           const SizedBox(height: 3),
//           const Align(alignment: Alignment.centerRight, child: Text('<=', style: _kArrow)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDestinationRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _SegmentedInput(
//             key: _keyDest,
//             length: 4,
//             label: '16 DESTINATION AERODROME',
//             isRequired: true,
//             hint: 'ICAO',
//           ),
//           const SizedBox(width: 24),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('TOTAL EET', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 Column(children: [
//                   const Text('HR', style: _kSub),
//                   SizedBox(width: 38, child: _txt(_cEetHr, keyboard: TextInputType.number, max: 2)),
//                 ]),
//                 const SizedBox(width: 8),
//                 Column(children: [
//                   const Text('MIN', style: _kSub),
//                   SizedBox(width: 38, child: _txt(_cEetMin, keyboard: TextInputType.number, max: 2)),
//                 ]),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 24),
//           _SegmentedInput(key: _keyAltn1, length: 4, label: 'ALTN AERODROME', hint: 'ICAO'),
//           const SizedBox(width: 24),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               _SegmentedInput(key: _keyAltn2, length: 4, label: '2ND ALTN AERODROME', hint: 'ICAO'),
//               const SizedBox(width: 6),
//               _sym('<='),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOtherInfoSection() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('18 OTHER INFORMATION', style: _kLbl),
//           const SizedBox(height: 6),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Padding(padding: EdgeInsets.only(top: 8, right: 6), child: Text('—', style: _kArrow)),
//               Expanded(child: _txt(_cOtherInfo, lines: 2, box: true)),
//             ],
//           ),
//           const SizedBox(height: 3),
//           const Align(alignment: Alignment.centerRight, child: Text('<=', style: _kArrow)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: const BoxDecoration(
//         color: Color(0xFFDDD3B0),
//         border: Border(bottom: _kSide),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34, height: 34,
//             decoration: BoxDecoration(
//               color: _kAccent,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: const Center(
//               child: Text('19', style: TextStyle(
//                 fontSize: 18, fontWeight: FontWeight.w900,
//                 fontFamily: 'Courier', color: Colors.white,
//               )),
//             ),
//           ),
//           const SizedBox(width: 10),
//           const Expanded(
//             child: Text(
//               'SUPPLEMENTARY INFORMATION  (NOT TO BE TRANSMITTED IN FPL MESSAGES)',
//               style: TextStyle(
//                 fontSize: 7.5, fontWeight: FontWeight.w800,
//                 letterSpacing: 0.6, fontFamily: 'Courier',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplEndurance() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('ENDURANCE', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('—E/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 Column(children: [
//                   const Text('HR', style: _kSub),
//                   SizedBox(width: 38, child: _txt(_cEndHr, keyboard: TextInputType.number, max: 2)),
//                 ]),
//                 const SizedBox(width: 6),
//                 Column(children: [
//                   const Text('MIN', style: _kSub),
//                   SizedBox(width: 38, child: _txt(_cEndMin, keyboard: TextInputType.number, max: 2)),
//                 ]),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 28),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('PERSONS ON BOARD', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('P/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 SizedBox(width: 70, child: _txt(_cPob, keyboard: TextInputType.number, max: 3)),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 28),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('EMERGENCY RADIO', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('R/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 8),
//                 _cbx('UHF', _uhf, (v) => setState(() => _uhf = v)),
//                 const SizedBox(width: 8),
//                 _cbx('VHF', _vhf, (v) => setState(() => _vhf = v)),
//                 const SizedBox(width: 8),
//                 _cbx('ELT', _elt, (v) => setState(() => _elt = v)),
//               ]),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplSurvival() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('SURVIVAL EQUIPMENT', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('/', style: TextStyle(fontSize: 14, fontFamily: 'Courier')),
//                 const SizedBox(width: 8),
//                 _cbx('POLAR',    _polar,    (v) => setState(() => _polar    = v)),
//                 const SizedBox(width: 8),
//                 _cbx('DESERT',   _desert,   (v) => setState(() => _desert   = v)),
//                 const SizedBox(width: 8),
//                 _cbx('MARITIME', _maritime, (v) => setState(() => _maritime = v)),
//                 const SizedBox(width: 8),
//                 _cbx('JUNGLE',   _jungle,   (v) => setState(() => _jungle   = v)),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 50),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('JACKETS', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('/', style: TextStyle(fontSize: 14, fontFamily: 'Courier')),
//                 const SizedBox(width: 8),
//                 _cbx('LIGHT',   _lightJ,  (v) => setState(() => _lightJ  = v)),
//                 const SizedBox(width: 8),
//                 _cbx('FLUORES', _floresJ, (v) => setState(() => _floresJ = v)),
//                 const SizedBox(width: 8),
//                 _cbx('UHF',     _uhfJ,    (v) => setState(() => _uhfJ    = v)),
//                 const SizedBox(width: 8),
//                 _cbx('VHF',     _vhfJ,    (v) => setState(() => _vhfJ    = v)),
//               ]),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplDinghies() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('DINGHIES', style: _kLbl),
//               const SizedBox(height: 4),
//               Row(children: [
//                 const Text('D/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 Column(children: [
//                   const Text('NUMBER', style: _kSub),
//                   SizedBox(width: 44, child: _txt(_cDingNum, keyboard: TextInputType.number, max: 2)),
//                 ]),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('CAPACITY', style: _kSub),
//               SizedBox(width: 55, child: _txt(_cDingCap, keyboard: TextInputType.number, max: 3)),
//             ],
//           ),
//           const SizedBox(width: 14),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('COVER', style: _kSub),
//               Row(children: [
//                 const Text('C', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => setState(() => _dingCover = !_dingCover),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 150),
//                     width: 22, height: 22,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: _dingCover ? _kAccent : Colors.black, width: 1.5),
//                       color: _dingCover ? _kAccent : Colors.white,
//                     ),
//                     child: _dingCover
//                         ? const Icon(Icons.check, size: 14, color: Colors.white)
//                         : null,
//                   ),
//                 ),
//               ]),
//             ],
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Expanded(child: _lbl('COLOR', _txt(_cDingColor))),
//                 const SizedBox(width: 6),
//                 _sym('<='),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplAcColor() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Text('A/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//           const SizedBox(width: 6),
//           Expanded(child: _lbl('AIRCRAFT COLOR AND MARKINGS', _txt(_cAcColor))),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplRemarks() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Text('N/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//           const SizedBox(width: 6),
//           Expanded(child: _lbl('REMARKS', _txt(_cRemarks))),
//           const SizedBox(width: 6),
//           _sym('<='),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSupplPic() {
//     return _sec(
//       bg: _kSuppl,
//       border: const Border(bottom: _kSide),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Text('C/', style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
//           const SizedBox(width: 6),
//           Expanded(
//             child: _lbl(
//               'PILOT-IN-COMMAND',
//               _txt(
//                 _cPic,
//                 cap: TextCapitalization.words,
//                 validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
//               ),
//               required: true,
//             ),
//           ),
//           const SizedBox(width: 6),
//           _sym(')<='),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFooterRow() {
//     return _sec(
//       border: const Border(bottom: _kSide),
//       padding: EdgeInsets.zero,
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: _sec(
//                 border: const Border(right: _kSide),
//                 child: _lbl('FILED BY', _txt(_cFiledBy, cap: TextCapitalization.words)),
//               ),
//             ),
//             Expanded(
//               child: _sec(
//                 border: const Border(right: _kSide),
//                 child: _lbl('ACCEPTED BY', _txt(_cAcceptedBy, cap: TextCapitalization.words)),
//               ),
//             ),
//             Expanded(
//               child: _sec(
//                 child: _lbl('ADDITIONAL INFORMATION', _txt(_cAddInfo, cap: TextCapitalization.sentences)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCompleteButton() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: const BoxDecoration(
//         color: Color(0xFFF5F0E0),
//         border: Border(bottom: _kSide),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.info_outline, size: 14, color: Colors.grey),
//           const SizedBox(width: 6),
//           const Text(
//             'Fields marked * are required',
//             style: TextStyle(fontSize: 9, fontFamily: 'Courier', color: Colors.grey),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: _onCompleteAndAssign,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               decoration: BoxDecoration(
//                 color: _kAccent,
//                 boxShadow: [
//                   BoxShadow(color: _kAccent.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
//                 ],
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.flight_takeoff, color: Colors.white, size: 16),
//                   SizedBox(width: 10),
//                   Text(
//                     'COMPLETE & ASSIGN',
//                     style: TextStyle(
//                       color: Colors.white, fontSize: 12,
//                       fontFamily: 'Courier', fontWeight: FontWeight.bold, letterSpacing: 1.5,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Icon(Icons.arrow_forward, color: Colors.white60, size: 14),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFormFooter() {
//     return _sec(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'FAA Form 7233-4 (7/15)',
//             style: TextStyle(fontSize: 8, color: Colors.grey[600], fontFamily: 'Courier'),
//           ),
//           Text(
//             'NSN 0052-00-012-9744',
//             style: TextStyle(fontSize: 8, color: Colors.grey[500], fontFamily: 'Courier'),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HELPERS
// // ─────────────────────────────────────────────────────────────────────────────
// class _DropItem {
//   final String value;
//   final String display;
//   const _DropItem(this.value, this.display);
// }
//
// class _UpperCaseFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
//       n.copyWith(text: n.text.toUpperCase());
// }

/*
  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MedicalProvider>();
    final content = Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(children: [
        Positioned.fill(
            child: CustomPaint(
                painter: _MedGridPainter(borderColor: _border(context)))),
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ── Title (only shown in initial flow, no app bar) ──
            if (widget.isInitialFlow) ...[
              _InlineTitle(
                  isAr: _isAr, text1: _text1(context), text2: _text2(context)),
              const SizedBox(height: 16),
            ],

            _SectionHeader(
                    isAr: _isAr, text1: _text1(context), text2: _text2(context))
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.1),
            const SizedBox(height: 16),

            _ReferencePanel(
              vitals: _vitals,
              isAr: _isAr,
              expanded: _refExpanded,
              onToggle: () => setState(() => _refExpanded = !_refExpanded),
              surface: _surface(context),
              border: _border(context),
              text1: _text1(context),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            const SizedBox(height: 20),

            ..._vitals.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _VitalInputCard(
                    vital: e.value,
                    isAr: _isAr,
                    surface: _surface(context),
                    border: _border(context),
                    text1: _text1(context),
                    text2: _text2(context),
                    onChanged: (v, v2) {
                      if (v2 != null) {
                        context
                            .read<MedicalProvider>()
                            .setValue2(e.value.id, v2);
                      }
                      context.read<MedicalProvider>().setValue(e.value.id, v);
                      if (mp.allFilled) {
                        setState(() => _showDecision = true);
                      }
                    },
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 150 + e.key * 80),
                        duration: 400.ms,
                      )
                      .slideX(begin: 0.05),
                )),

            if (mp.allFilled || _showDecision) ...[
              const SizedBox(height: 8),
              _DecisionBanner(
                mp: mp,
                isAr: _isAr,
                pulseCtrl: _pulseCtrl,
                surface: _surface(context),
                border: _border(context),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.96, 0.96)),
              const SizedBox(height: 20),
            ],

            if (mp.currentResults.isNotEmpty) ...[
              _ScoreBreakdown(
                mp: mp,
                isAr: _isAr,
                vitals: _vitals,
                surface: _surface(context),
                border: _border(context),
                text1: _text1(context),
                text2: _text2(context),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),
            ],
          ]),
        ),
      ]),
    );

    if (!widget.wrapInScaffold) return content;
    return Scaffold(
        backgroundColor: _bg(context),
        appBar: widget.isInitialFlow ? null : _buildAppBar(context, mp),
        bottomNavigationBar: _FinishBar(
          isAr: _isAr,
          mp: mp,
          saving: _saving,
          onFinish: _onFinish,
          surface: _surface(context),
          border: _border(context),
          text2: _text2(context),
        ),
        body: content);
  }
 */