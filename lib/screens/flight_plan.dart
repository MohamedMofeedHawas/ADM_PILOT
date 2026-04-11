import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const FlightPlanApp());

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
const _cNavy = Color(0xFF0D3260);
const _cPaper = Color(0xFFFDF8EF);
const _cSuppl = Color(0xFFF0E8CC);
const _cBg = Color(0xFF7A6B4F);
const _cBorder = Color(0xFF1A1A1A);
const _cWhite = Color(0xFFFFFFFF);
const _cFilled = Color(0xFFECF2FF);
const _cText = Color(0xFF0D0D0D);
const _cGrey = Color(0xFFAAAAAA);
const _cHdr = Color(0xFFD8CBAA);
const _cFocus = Color(0xFF1F5EBD);

const _sideH = BorderSide(color: _cBorder, width: 1.6);

const _tLbl = TextStyle(
    fontSize: 7.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
    color: Color(0xFF1A1A1A),
    fontFamily: 'Courier');
const _tSub = TextStyle(
    fontSize: 7.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
    fontFamily: 'Courier');
const _tBig = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    fontFamily: 'Courier',
    color: _cNavy,
    letterSpacing: 1.5,
    height: 1.1);
const _tIn = TextStyle(
    fontSize: 12, fontFamily: 'Courier', color: _cText, letterSpacing: 0.3);
const _tArr = TextStyle(
    fontSize: 14,
    fontFamily: 'Courier',
    color: Color(0xFF333333),
    fontWeight: FontWeight.bold);
const _tPfx = TextStyle(
    fontSize: 15,
    fontFamily: 'Courier',
    fontWeight: FontWeight.bold,
    color: _cText,
    letterSpacing: 0.5);

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class _FPData {
  final DateTime filedAt;
  final String acId, acType, flightRules, typeOfFlight, numAircraft, wakeTurb;
  final String depAero, depTime, speed, level, route;
  final String destAero, eetHr, eetMin, altn1, altn2, otherInfo, equipment;
  final String endHr, endMin, pob;
  final bool uhf, vhf, elt, polar, desert, maritime, jungle;
  final bool lightJ, floresJ, uhfJ, vhfJ, dingCover;
  final String dingNum, dingCap, dingColor, acColor, remarks;
  final String pic, filedBy, acceptedBy, addInfo;

  const _FPData({
    required this.filedAt,
    required this.acId,
    required this.acType,
    required this.flightRules,
    required this.typeOfFlight,
    required this.numAircraft,
    required this.wakeTurb,
    required this.depAero,
    required this.depTime,
    required this.speed,
    required this.level,
    required this.route,
    required this.destAero,
    required this.eetHr,
    required this.eetMin,
    required this.altn1,
    required this.altn2,
    required this.otherInfo,
    required this.equipment,
    required this.endHr,
    required this.endMin,
    required this.pob,
    required this.uhf,
    required this.vhf,
    required this.elt,
    required this.polar,
    required this.desert,
    required this.maritime,
    required this.jungle,
    required this.lightJ,
    required this.floresJ,
    required this.uhfJ,
    required this.vhfJ,
    required this.dingCover,
    required this.dingNum,
    required this.dingCap,
    required this.dingColor,
    required this.acColor,
    required this.remarks,
    required this.pic,
    required this.filedBy,
    required this.acceptedBy,
    required this.addInfo,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// APP
// ═══════════════════════════════════════════════════════════════════════════════
class FlightPlanApp extends StatelessWidget {
  const FlightPlanApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'International Flight Plan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          scaffoldBackgroundColor: _cBg,
          colorScheme: const ColorScheme.light(primary: _cNavy),
        ),
        home: const FlightPlanScreen(),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class FlightPlanScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const FlightPlanScreen({super.key, this.onComplete});
  @override
  State<FlightPlanScreen> createState() => _FPS();
}

class _FPS extends State<FlightPlanScreen> {
  final _fk = GlobalKey<FormState>();
  final List<_FPData> _records = [];

  // Controllers
  final _cAddr1 = TextEditingController();
  final _cAddr2 = TextEditingController();
  final _cOrig = TextEditingController();
  final _cSpec = TextEditingController();
  final _cEqp = TextEditingController();
  final _cRoute = TextEditingController();
  final _cOther = TextEditingController();
  final _cDingC = TextEditingController();
  final _cAcCol = TextEditingController();
  final _cRem = TextEditingController();
  final _cPic = TextEditingController();
  final _cFiled = TextEditingController();
  final _cAccep = TextEditingController();
  final _cAdd = TextEditingController();

  // Segmented values
  String _depAero = '',
      _speed = '',
      _level = '',
      _destAero = '',
      _altn1 = '',
      _altn2 = '';
  String _eetHr = '', _eetMin = '', _endHr = '', _endMin = '', _pob = '';
  String _dingN = '', _dingCap = '', _acId = '', _acType = '';

  // Dropdowns
  String? _fr, _tof, _num, _wt;

  // DateTime
  DateTime? _fDT, _dDT;

  // Checkboxes
  bool _uhf = false, _vhf = false, _elt = false;
  bool _pol = false, _des = false, _mar = false, _jun = false;
  bool _ljt = false, _ljf = false, _lju = false, _ljv = false;
  bool _dc = false;

  @override
  void dispose() {
    for (final c in [
      _cAddr1,
      _cAddr2,
      _cOrig,
      _cSpec,
      _cEqp,
      _cRoute,
      _cOther,
      _cDingC,
      _cAcCol,
      _cRem,
      _cPic,
      _cFiled,
      _cAccep,
      _cAdd
    ]) c.dispose();
    super.dispose();
  }

  String _ddhhm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';
  String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDT(bool filing) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, c) => Theme(
          data:
              ThemeData(colorScheme: const ColorScheme.light(primary: _cNavy)),
          child: c!),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, c) => Theme(
          data:
              ThemeData(colorScheme: const ColorScheme.light(primary: _cNavy)),
          child: c!),
    );
    if (t == null) return;
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() {
      if (filing)
        _fDT = dt;
      else
        _dDT = dt;
    });
  }

  void _file() {
    final r = _FPData(
      filedAt: DateTime.now(),
      acId: _acId,
      acType: _acType,
      flightRules: _fr ?? '—',
      typeOfFlight: _tof ?? '—',
      numAircraft: _num ?? '1',
      wakeTurb: _wt ?? '—',
      depAero: _depAero,
      depTime: _dDT != null ? _hhmm(_dDT!) : '—',
      speed: _speed,
      level: _level,
      route: _cRoute.text,
      destAero: _destAero,
      eetHr: _eetHr,
      eetMin: _eetMin,
      altn1: _altn1,
      altn2: _altn2,
      otherInfo: _cOther.text,
      equipment: _cEqp.text,
      endHr: _endHr,
      endMin: _endMin,
      pob: _pob,
      uhf: _uhf,
      vhf: _vhf,
      elt: _elt,
      polar: _pol,
      desert: _des,
      maritime: _mar,
      jungle: _jun,
      lightJ: _ljt,
      floresJ: _ljf,
      uhfJ: _lju,
      vhfJ: _ljv,
      dingCover: _dc,
      dingNum: _dingN,
      dingCap: _dingCap,
      dingColor: _cDingC.text,
      acColor: _cAcCol.text,
      remarks: _cRem.text,
      pic: _cPic.text,
      filedBy: _cFiled.text,
      acceptedBy: _cAccep.text,
      addInfo: _cAdd.text,
    );
    setState(() => _records.insert(0, r));
    _showReport(r);
  }

  // ── Report dialog ────────────────────────────────────────────────────────
  void _showReport(_FPData d) {
    final radio =
        [if (d.uhf) 'UHF', if (d.vhf) 'VHF', if (d.elt) 'ELT'].join(' ');
    final surv = [
      if (d.polar) 'POLAR',
      if (d.desert) 'DESERT',
      if (d.maritime) 'MARITIME',
      if (d.jungle) 'JUNGLE'
    ].join(' ');
    final jkt = [
      if (d.lightJ) 'LIGHT',
      if (d.floresJ) 'FLUORES',
      if (d.uhfJ) 'UHF',
      if (d.vhfJ) 'VHF'
    ].join(' ');
    final ts = '${d.filedAt.day.toString().padLeft(2, '0')}/'
        '${d.filedAt.month.toString().padLeft(2, '0')}/'
        '${d.filedAt.year}  '
        '${d.filedAt.hour.toString().padLeft(2, '0')}:'
        '${d.filedAt.minute.toString().padLeft(2, '0')} UTC';

    showDialog(
        context: context,
        builder: (_) => Dialog(
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Container(
                width: 620,
                color: _cPaper,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Header
                  Container(
                    color: _cNavy,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    child: Row(children: [
                      const Icon(Icons.flight_takeoff,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                          child: Text('FLIGHT PLAN — OFFICIAL RECORD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2))),
                      Text(ts,
                          style: const TextStyle(
                              color: Color(0xFFAAC8FF),
                              fontSize: 10,
                              fontFamily: 'Courier')),
                    ]),
                  ),
                  // Body
                  Flexible(
                      child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _rs('FLIGHT IDENTIFICATION'),
                          _rr('Aircraft ID', d.acId.isEmpty ? '—' : d.acId),
                          _rr('Aircraft Type',
                              d.acType.isEmpty ? '—' : d.acType),
                          _rr('Flight Rules / Type',
                              '${d.flightRules} / ${d.typeOfFlight}'),
                          _rr('Number', d.numAircraft),
                          _rr('Wake Turbulence', d.wakeTurb),
                          _rr('Equipment',
                              d.equipment.isEmpty ? '—' : d.equipment),
                          const SizedBox(height: 10),
                          _rs('ROUTE'),
                          _rr('Departure',
                              '${d.depAero.isEmpty ? "—" : d.depAero}   ${d.depTime} UTC'),
                          _rr('Speed', d.speed.isEmpty ? '—' : d.speed),
                          _rr('Level', d.level.isEmpty ? '—' : d.level),
                          _rr('Route', d.route.isEmpty ? '—' : d.route),
                          _rr('Destination',
                              d.destAero.isEmpty ? '—' : d.destAero),
                          _rr('Total EET',
                              '${d.eetHr.isEmpty ? "00" : d.eetHr}h ${d.eetMin.isEmpty ? "00" : d.eetMin}m'),
                          _rr('Alternate 1', d.altn1.isEmpty ? '—' : d.altn1),
                          _rr('Alternate 2', d.altn2.isEmpty ? '—' : d.altn2),
                          _rr('Other Info',
                              d.otherInfo.isEmpty ? '—' : d.otherInfo),
                          const SizedBox(height: 10),
                          _rs('SUPPLEMENTARY'),
                          _rr('Endurance',
                              '${d.endHr.isEmpty ? "00" : d.endHr}h ${d.endMin.isEmpty ? "00" : d.endMin}m'),
                          _rr('POB', d.pob.isEmpty ? '—' : d.pob),
                          _rr('Radio', radio.isEmpty ? '—' : radio),
                          _rr('Survival', surv.isEmpty ? '—' : surv),
                          _rr('Jackets', jkt.isEmpty ? '—' : jkt),
                          _rr('Dinghies',
                              '${d.dingNum.isEmpty ? "—" : d.dingNum} / Cap: ${d.dingCap.isEmpty ? "—" : d.dingCap} / Cover: ${d.dingCover ? "YES" : "NO"} / Color: ${d.dingColor.isEmpty ? "—" : d.dingColor}'),
                          _rr('A/C Color', d.acColor.isEmpty ? '—' : d.acColor),
                          _rr('Remarks', d.remarks.isEmpty ? '—' : d.remarks),
                          const SizedBox(height: 10),
                          _rs('FILING DETAILS'),
                          _rr('PIC', d.pic.isEmpty ? '—' : d.pic),
                          _rr('Filed By', d.filedBy.isEmpty ? '—' : d.filedBy),
                          _rr('Accepted By',
                              d.acceptedBy.isEmpty ? '—' : d.acceptedBy),
                          _rr('Additional',
                              d.addInfo.isEmpty ? '—' : d.addInfo),
                        ]),
                  )),
                  // Footer
                  Container(
                    color: _cHdr,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    child: Row(children: [
                      Text('FAA Form 7233-4  ·  Filed: $ts',
                          style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'Courier',
                              color: Color(0xFF555555))),
                      const Spacer(),
                      if (_records.length > 1)
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: _cNavy),
                          onPressed: () {
                            Navigator.pop(context);
                            _showHistory();
                          },
                          child: const Text('ALL RECORDS',
                              style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: _cNavy),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE',
                            style: TextStyle(
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ]),
                  ),
                ]),
              ),
            ));
  }

  Widget _rs(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
          width: double.infinity,
          color: _cNavy,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 9,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0))));

  Widget _rr(String l, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 170,
            child: Text(l,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Courier',
                    color: Color(0xFF555555),
                    fontWeight: FontWeight.w600))),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Courier',
                    color: _cText,
                    fontWeight: FontWeight.bold))),
      ]));

  void _showHistory() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Container(
                width: 500,
                height: 500,
                color: _cPaper,
                child: Column(children: [
                  Container(
                      color: _cNavy,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: const Row(children: [
                        Icon(Icons.history, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('FILED FLIGHT PLANS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2)),
                      ])),
                  Expanded(
                      child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (_, i) {
                      final r = _records[i];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showReport(r);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: _cBorder.withOpacity(0.15))),
                            color: i.isEven ? _cPaper : const Color(0xFFF5EFD8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(
                                      r.acId.isEmpty
                                          ? '(no aircraft ID)'
                                          : r.acId,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Courier',
                                          fontWeight: FontWeight.bold,
                                          color: _cNavy)),
                                  Text(
                                      '${r.depAero.isEmpty ? "?" : r.depAero} → ${r.destAero.isEmpty ? "?" : r.destAero}   ${r.depTime} UTC',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'Courier',
                                          color: _cText)),
                                ])),
                            Text(
                                '${r.filedAt.day.toString().padLeft(2, '0')}/'
                                '${r.filedAt.month.toString().padLeft(2, '0')}/'
                                '${r.filedAt.year}\n'
                                '${r.filedAt.hour.toString().padLeft(2, '0')}:'
                                '${r.filedAt.minute.toString().padLeft(2, '0')}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 9,
                                    fontFamily: 'Courier',
                                    color: _cGrey)),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right,
                                size: 18, color: _cNavy),
                          ]),
                        ),
                      );
                    },
                  )),
                  Container(
                      color: _cHdr,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(children: [
                        Text('${_records.length} record(s)',
                            style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'Courier',
                                color: Color(0xFF555555))),
                        const Spacer(),
                        TextButton(
                            style:
                                TextButton.styleFrom(foregroundColor: _cNavy),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CLOSE',
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ])),
                ]),
              ),
            ));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _cBg,
        appBar: AppBar(
          backgroundColor: _cNavy,
          foregroundColor: _cWhite,
          elevation: 0,
          title: const Text('FAA Form 7233-4  ·  International Flight Plan',
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _cWhite)),
          actions: [
            if (_records.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  onPressed: _showHistory,
                  icon: const Icon(Icons.history, size: 16),
                  label: Text('${_records.length} FILED',
                      style:
                          const TextStyle(fontFamily: 'Courier', fontSize: 11)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: _cWhite,
                    foregroundColor: _cNavy,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                onPressed: () {
                  if (widget.onComplete != null)
                    widget.onComplete!();
                  else
                    _file();
                },
                icon: const Icon(Icons.flight_takeoff, size: 15),
                label: const Text('FILE FLIGHT PLAN',
                    style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1,
                        color: _cNavy)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Center(
            child: Container(
              width: 860,
              decoration: BoxDecoration(
                color: _cPaper,
                border: Border.all(color: _cBorder, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x60000000),
                      blurRadius: 18,
                      offset: Offset(8, 8))
                ],
              ),
              child: Form(
                key: _fk,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(),
                      _priority(),
                      _filingRow(),
                      _specId(),
                      _fplRow(),
                      _aircraftRow(),
                      _depRow(),
                      _routeSec(),
                      _destRow(),
                      _otherInfo(),
                      _supplHdr(),
                      _supplEnd(),
                      _supplSurv(),
                      _supplDing(),
                      _supplAcCol(),
                      _supplRem(),
                      _supplPic(),
                      _footerRow(),
                      _formFoot(),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Primitives ─────────────────────────────────────────────────────────────
  Widget _sec(
      {required Widget child,
      Border? border,
      EdgeInsets p = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      double? w,
      Color? bg}) {
    return Container(
        width: w,
        padding: p,
        decoration: BoxDecoration(color: bg ?? _cPaper, border: border),
        child: child);
  }

  Widget _lbl(String t, Widget c) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [Text(t, style: _tLbl), const SizedBox(height: 4), c]);

  Widget _txt(TextEditingController c,
      {String? hint,
      double? w,
      int? max,
      bool box = false,
      int lines = 1,
      TextCapitalization cap = TextCapitalization.characters,
      TextInputType? kb,
      String? Function(String?)? val}) {
    const b = OutlineInputBorder(
        borderSide: BorderSide(color: _cBorder, width: 1.2),
        borderRadius: BorderRadius.zero);
    const f = OutlineInputBorder(
        borderSide: BorderSide(color: _cFocus, width: 1.6),
        borderRadius: BorderRadius.zero);
    final fld = TextFormField(
        controller: c,
        style: _tIn,
        maxLength: max,
        maxLines: lines,
        textCapitalization: cap,
        keyboardType: kb,
        validator: val,
        decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: _cWhite,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            hintText: hint,

            // hintTextDirection: TextDire,
            hintStyle: const TextStyle(
                fontSize: 10, color: _cGrey, fontFamily: 'Courier'),
            border: b,
            enabledBorder: b,
            focusedBorder: f));
    return w != null ? SizedBox(width: w, child: fld) : fld;
  }

  Widget _drop(
      {required String label,
      required String? value,
      required List<_DI> items,
      required void Function(String?) ch,
      double? w}) {
    const b = UnderlineInputBorder(
        borderSide: BorderSide(color: _cBorder, width: 1.2));
    const f = UnderlineInputBorder(
        borderSide: BorderSide(color: _cFocus, width: 1.6));
    Widget dd = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: _tLbl),
          const SizedBox(height: 3),
          DropdownButtonFormField<String>(
              value: value,
              style: _tIn,
              isExpanded: true,
              dropdownColor: _cWhite,
              decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: _cWhite,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                  border: b,
                  enabledBorder: b,
                  focusedBorder: f),
              hint: Text('—', style: _tIn.copyWith(color: _cGrey)),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e.v,
                      child: Text(e.d, style: _tIn.copyWith(fontSize: 11))))
                  .toList(),
              selectedItemBuilder: (_) => items
                  .map((e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(e.v,
                          style: _tIn.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _cNavy))))
                  .toList(),
              onChanged: ch),
        ]);
    return w != null ? SizedBox(width: w, child: dd) : dd;
  }

  Widget _timeTap(
      {required String label,
      required DateTime? dt,
      required VoidCallback tap,
      required bool ddhhmm}) {
    final fmt = ddhhmm ? 'DDHHMM' : 'HHMM';
    final val = dt != null ? (ddhhmm ? _ddhhm(dt) : _hhmm(dt)) : '';
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: _tLbl),
          const SizedBox(height: 4),
          InkWell(
              onTap: tap,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _SegDisp(value: val, slots: fmt.length, hint: fmt),
                const SizedBox(width: 6),
                Icon(Icons.access_time_outlined, size: 13, color: _cGrey),
              ])),
        ]);
  }

  Widget _cbx(String label, bool val, void Function(bool) ch) =>
      GestureDetector(
          onTap: () => ch(!val),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: _tSub.copyWith(fontSize: 6.5)),
            const SizedBox(height: 3),
            Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    border: Border.all(color: _cBorder, width: 1.5),
                    color: val ? _cNavy : _cWhite),
                child: Center(
                    child: Text(label.isNotEmpty ? label[0] : '',
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            color: val ? _cWhite : const Color(0xFF222222))))),
          ]));

  Widget _a(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 2), child: Text(s, style: _tArr));

  // ── Section builders ───────────────────────────────────────────────────────
  Widget _header() => _sec(
      border: const Border(bottom: _sideH),
      p: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Stack(alignment: Alignment.center, children: [
        Align(
            alignment: Alignment.centerLeft,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _cBorder, width: 1.5)),
                  child: const Center(
                      child: Text('DOT',
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                              color: _cText)))),
              const SizedBox(height: 3),
              const Text('U S Department of Transportation',
                  style: TextStyle(
                      fontSize: 7.5, fontFamily: 'Courier', color: _cText)),
              const Text('Federal Aviation Administration',
                  style: TextStyle(
                      fontSize: 7.5,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                      color: _cText)),
            ])),
        const Text('International Flight Plan',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                letterSpacing: 1.5,
                color: _cNavy)),
        Align(
            alignment: Alignment.topRight,
            child: Text('Approved OMB No.\n2120-0026 Exp. 9/30/2023',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 7.5, color: _cGrey, fontFamily: 'Courier'))),
      ]));

  Widget _priority() => _sec(
      border: const Border(bottom: _sideH),
      p: EdgeInsets.zero,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sec(
            border: const Border(right: _sideH),
            w: 105,
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('PRIORITY', style: _tLbl),
                  SizedBox(height: 6),
                  Text('<=FF', style: _tBig)
                ])),
        Expanded(
            child: _sec(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const Text('ADDRESSEE(S)', style: _tLbl),
              const SizedBox(height: 5),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(child: _txt(_cAddr1)),
                const SizedBox(width: 6),
                _a('<=')
              ]),
              const SizedBox(height: 5),
              _txt(_cAddr2)
            ]))),
      ])));

  Widget _filingRow() => _sec(
      border: const Border(bottom: _sideH),
      p: EdgeInsets.zero,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sec(
            border: const Border(right: _sideH),
            w: 175,
            child: _timeTap(
                label: 'FILING TIME',
                dt: _fDT,
                tap: () => _pickDT(true),
                ddhhmm: true)),
        Expanded(
            child: _sec(
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: _lbl('ORIGINATOR', _txt(_cOrig))),
          const SizedBox(width: 6),
          _a('<=')
        ])))
      ])));

  Widget _specId() => _sec(
      border: const Border(bottom: _sideH),
      child: _lbl('SPECIFIC IDENTIFICATION OF ADDRESSEE(S) AND / OR ORIGINATOR',
          _txt(_cSpec)));

  Widget _fplRow() => _sec(
      border: const Border(bottom: _sideH),
      p: EdgeInsets.zero,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
              // mainAxisAlignment: MainAxisAlignment.spaceAround
              mainAxisSize: MainAxisSize.min
              , children: [
        _sec(
            border: const Border(right: _sideH),
            w: 135,
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('3 MESSAGE TYPE', style: _tLbl),
                  SizedBox(height: 6),
                  Text('<=(FPL', style: _tBig)
                ])),
        // ── Aircraft ID — mainAxisSize.min removes bottom gap ──
        Expanded(
            flex: 2,
            child: _sec(
                border: const Border(right: _sideH),
                p: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisSize: MainAxisSize.min, // ← NO extra space below
                    children: [
                      const Text('7 AIRCRAFT IDENTIFICATION', style: _tLbl),
                      const SizedBox(height: 6),
                      SegBox(
                          slots: 7,
                          hint: 'ABCDE12',
                          onChanged: (v) => setState(() => _acId = v))
                    ]))),
        _sec(
            border: const Border(right: _sideH),
            w: 125,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 6), child: _a('—')),
              const SizedBox(width: 4),
              Expanded(
                  child: _drop(
                      label: '8 FLIGHT RULES',
                      value: _fr,
                      items: const [
                        _DI('I', 'I  — IFR'),
                        _DI('V', 'V  — VFR'),
                        _DI('Y', 'Y  — IFR→VFR'),
                        _DI('Z', 'Z  — VFR→IFR')
                      ],
                      ch: (v) => setState(() => _fr = v)))
            ])),
        _sec(
            w: 135,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: _drop(
                      label: 'TYPE OF FLIGHT',
                      value: _tof,
                      items: const [
                        _DI('S', 'S  — Scheduled'),
                        _DI('N', 'N  — Non-sched.'),
                        _DI('G', 'G  — Gen. Aviation'),
                        _DI('M', 'M  — Military'),
                        _DI('X', 'X  — Other')
                      ],
                      ch: (v) => setState(() => _tof = v))),
              const SizedBox(width: 4),
              _a('<=')
            ])),
      ])));

  Widget _aircraftRow() => _sec(
      border: const Border(bottom: _sideH),
      p: EdgeInsets.zero,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _sec(
            border: const Border(right: _sideH),
            w: 90,
            child: _drop(
                label: '9 NUMBER',
                value: _num,
                items: List.generate(9, (i) => _DI('${i + 1}', '${i + 1}')),
                ch: (v) => setState(() => _num = v))),
        // ── Aircraft Type — mainAxisSize.min removes bottom gap ──
        Expanded(
            flex: 2,
            child: _sec(
                border: const Border(right: _sideH),
                p: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ← NO extra space below
                    children: [
                      const Text('TYPE OF AIRCRAFT', style: _tLbl),
                      const SizedBox(height: 6),
                      SegBox(
                          slots: 4,
                          hint: 'B738',
                          onChanged: (v) => setState(() => _acType = v))
                    ]))),
        _sec(
            border: const Border(right: _sideH),
            w: 160,
            child: _drop(
                label: 'WAKE TURBULENCE CAT.',
                value: _wt,
                items: const [
                  _DI('L', 'L  — Light  (<7t)'),
                  _DI('M', 'M  — Medium'),
                  _DI('H', 'H  — Heavy  (>136t)'),
                  _DI('J', 'J  — Super  (A380)')
                ],
                ch: (v) => setState(() => _wt = v))),
        _sec(
            border: const Border(right: _sideH),
            w: 26,
            p: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
            child: const Align(
                alignment: Alignment.bottomCenter,
                child: Text('—', style: _tArr))),
        Expanded(
            flex: 2,
            child: _sec(
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: _lbl('10 EQUIPMENT', _txt(_cEqp, hint: 'SDFG'))),
              const SizedBox(width: 4),
              _a('/'),
              const SizedBox(width: 4),
              _a('<=')
            ]))),
      ])));

  Widget _depRow() => _sec(
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _a('—'),
        const SizedBox(width: 8),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('13 DEPARTURE AERODROME', style: _tLbl),
              const SizedBox(height: 4),
              SegBox(
                  slots: 4,
                  hint: 'ICAO',
                  onChanged: (v) => setState(() => _depAero = v))
            ]),
        const SizedBox(width: 32),
        _timeTap(
            label: 'TIME', dt: _dDT, tap: () => _pickDT(false), ddhhmm: false),
        const SizedBox(width: 8),
        _a('<=')
      ]));

  Widget _routeSec() => _sec(
      border: const Border(bottom: _sideH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('15 CRUISING SPEED', style: _tLbl),
                const SizedBox(height: 4),
                SegBox(
                    slots: 5,
                    hint: 'N0450',
                    onChanged: (v) => setState(() => _speed = v))
              ]),
          const SizedBox(width: 20),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('LEVEL', style: _tLbl),
                const SizedBox(height: 4),
                SegBox(
                    slots: 5,
                    hint: 'F350',
                    onChanged: (v) => setState(() => _level = v))
              ]),
          const SizedBox(width: 20),
          const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text('ROUTE', style: _tLbl))
        ]),
        const SizedBox(height: 8),
        _txt(_cRoute,
            hint: 'Full route details  (e.g. DCT ALPHA B52 BETA DCT)',
            lines: 3,
            box: true),
        const SizedBox(height: 4),
        const Align(
            alignment: Alignment.centerRight, child: Text('<=', style: _tArr))
      ]));

  Widget _destRow() => _sec(
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('16 DESTINATION AERODROME', style: _tLbl),
              const SizedBox(height: 4),
              SegBox(
                  slots: 4,
                  hint: 'ICAO',
                  onChanged: (v) => setState(() => _destAero = v))
            ]),
        const SizedBox(width: 20),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('TOTAL  EET', style: _tLbl),
              const SizedBox(height: 4),
              Row(children: [
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('HR', style: _tSub),
                  const SizedBox(height: 2),
                  SegBox(
                      slots: 2,
                      hint: '00',
                      numOnly: true,
                      onChanged: (v) => setState(() => _eetHr = v))
                ]),
                const SizedBox(width: 10),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('MIN', style: _tSub),
                  const SizedBox(height: 2),
                  SegBox(
                      slots: 2,
                      hint: '00',
                      numOnly: true,
                      onChanged: (v) => setState(() => _eetMin = v))
                ])
              ])
            ]),
        const SizedBox(width: 20),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ALTN AERODROME', style: _tLbl),
              const SizedBox(height: 4),
              SegBox(
                  slots: 4,
                  hint: 'ICAO',
                  onChanged: (v) => setState(() => _altn1 = v))
            ]),
        const SizedBox(width: 20),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('2ND ALTN AERODROME', style: _tLbl),
              const SizedBox(height: 4),
              SegBox(
                  slots: 4,
                  hint: 'ICAO',
                  onChanged: (v) => setState(() => _altn2 = v))
            ]),
        const SizedBox(width: 6),
        _a('<=')
      ]));

  Widget _otherInfo() => _sec(
      border: const Border(bottom: _sideH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('18 OTHER INFORMATION', style: _tLbl),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.only(top: 10, right: 8),
              child: _a('—')),
          Expanded(child: _txt(_cOther, lines: 2, box: true))
        ]),
        const SizedBox(height: 4),
        const Align(
            alignment: Alignment.centerRight, child: Text('<=', style: _tArr))
      ]));

  Widget _supplHdr() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration:
          const BoxDecoration(color: _cHdr, border: Border(bottom: _sideH)),
      child: const Row(children: [
        Text('19',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
                color: _cNavy,
                letterSpacing: 1)),
        SizedBox(width: 12),
        Expanded(
            child: Text(
                'SUPPLEMENTARY INFORMATION  (NOT TO BE TRANSMITTED IN FPL MESSAGES)',
                style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    fontFamily: 'Courier',
                    color: _cText)))
      ]));

  Widget _supplEnd() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ENDURANCE', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('—E/', style: _tPfx),
                const SizedBox(width: 6),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('HR', style: _tSub),
                  const SizedBox(height: 2),
                  SegBox(
                      slots: 2,
                      hint: '00',
                      numOnly: true,
                      onChanged: (v) => setState(() => _endHr = v))
                ]),
                const SizedBox(width: 8),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('MIN', style: _tSub),
                  const SizedBox(height: 2),
                  SegBox(
                      slots: 2,
                      hint: '00',
                      numOnly: true,
                      onChanged: (v) => setState(() => _endMin = v))
                ])
              ])
            ]),
        const SizedBox(width: 30),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('PERSONS ON BOARD', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('P/', style: _tPfx),
                const SizedBox(width: 6),
                SegBox(
                    slots: 3,
                    hint: '000',
                    numOnly: true,
                    onChanged: (v) => setState(() => _pob = v))
              ])
            ]),
        const SizedBox(width: 30),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('EMERGENCY RADIO', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('R/', style: _tPfx),
                const SizedBox(width: 10),
                _cbx('UHF', _uhf, (v) => setState(() => _uhf = v)),
                const SizedBox(width: 10),
                _cbx('VHF', _vhf, (v) => setState(() => _vhf = v)),
                const SizedBox(width: 10),
                _cbx('ELT', _elt, (v) => setState(() => _elt = v))
              ])
            ])
      ]));

  Widget _supplSurv() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('SURVIVAL EQUIPMENT', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('/', style: _tPfx),
                const SizedBox(width: 8),
                _cbx('POLAR', _pol, (v) => setState(() => _pol = v)),
                const SizedBox(width: 8),
                _cbx('DESERT', _des, (v) => setState(() => _des = v)),
                const SizedBox(width: 8),
                _cbx('MARITIME', _mar, (v) => setState(() => _mar = v)),
                const SizedBox(width: 8),
                _cbx('JUNGLE', _jun, (v) => setState(() => _jun = v))
              ])
            ]),
        const SizedBox(width: 50),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('JACKETS', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('/', style: _tPfx),
                const SizedBox(width: 8),
                _cbx('LIGHT', _ljt, (v) => setState(() => _ljt = v)),
                const SizedBox(width: 8),
                _cbx('FLUORES', _ljf, (v) => setState(() => _ljf = v)),
                const SizedBox(width: 8),
                _cbx('UHF', _lju, (v) => setState(() => _lju = v)),
                const SizedBox(width: 8),
                _cbx('VHF', _ljv, (v) => setState(() => _ljv = v))
              ])
            ])
      ]));

  Widget _supplDing() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('DINGHIES', style: _tLbl),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('D/', style: _tPfx),
                const SizedBox(width: 6),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('NUMBER', style: _tSub),
                  const SizedBox(height: 2),
                  SegBox(
                      slots: 2,
                      hint: '00',
                      numOnly: true,
                      onChanged: (v) => setState(() => _dingN = v))
                ])
              ])
            ]),
        const SizedBox(width: 16),
        Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('CAPACITY', style: _tSub),
          const SizedBox(height: 2),
          SegBox(
              slots: 3,
              hint: '000',
              numOnly: true,
              onChanged: (v) => setState(() => _dingCap = v))
        ]),
        const SizedBox(width: 16),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('COVER', style: _tSub),
              const SizedBox(height: 2),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const Text('C', style: _tPfx),
                const SizedBox(width: 4),
                GestureDetector(
                    onTap: () => setState(() => _dc = !_dc),
                    child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            border: Border.all(color: _cBorder, width: 1.5),
                            color: _dc ? _cNavy : _cWhite),
                        child: _dc
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null))
              ])
            ]),
        const SizedBox(width: 16),
        Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: _lbl('COLOR', _txt(_cDingC))),
          const SizedBox(width: 6),
          _a('<=')
        ]))
      ]));

  Widget _supplAcCol() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('A/', style: _tPfx),
        const SizedBox(width: 8),
        Expanded(child: _lbl('AIRCRAFT COLOR AND MARKINGS', _txt(_cAcCol)))
      ]));

  Widget _supplRem() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('N/', style: _tPfx),
        const SizedBox(width: 8),
        Expanded(child: _lbl('REMARKS', _txt(_cRem))),
        const SizedBox(width: 6),
        _a('<=')
      ]));

  Widget _supplPic() => _sec(
      bg: _cSuppl,
      border: const Border(bottom: _sideH),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('C/', style: _tPfx),
        const SizedBox(width: 8),
        Expanded(
            child: _lbl('PILOT-IN-COMMAND',
                _txt(_cPic, cap: TextCapitalization.words))),
        const SizedBox(width: 6),
        _a(')<=')
      ]));

  Widget _footerRow() => _sec(
      border: const Border(bottom: _sideH),
      p: EdgeInsets.zero,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: _sec(
                border: const Border(right: _sideH),
                child: _lbl(
                    'FILED BY', _txt(_cFiled, cap: TextCapitalization.words)))),
        Expanded(
            child: _sec(
                border: const Border(right: _sideH),
                child: _lbl('ACCEPTED BY',
                    _txt(_cAccep, cap: TextCapitalization.words)))),
        Expanded(
            child: _sec(
                child: _lbl('ADDITIONAL INFORMATION',
                    _txt(_cAdd, cap: TextCapitalization.sentences))))
      ])));

  Widget _formFoot() => _sec(
      p: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: const Text('FAA Form 7233-4 (7/15)',
          style: TextStyle(fontSize: 8, color: _cGrey, fontFamily: 'Courier')));
}

// ═══════════════════════════════════════════════════════════════════════════════
// DROPDOWN ITEM
// ═══════════════════════════════════════════════════════════════════════════════
class _DI {
  final String v, d;
  const _DI(this.v, this.d);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEGMENTED BOX  — FIX: addPostFrameCallback stops !_debugDuringDeviceUpdate
// ═══════════════════════════════════════════════════════════════════════════════
class SegBox extends StatefulWidget {
  final int slots;
  final String? hint;
  final bool numOnly;
  final ValueChanged<String>? onChanged;
  final double boxW, boxH;

  const SegBox(
      {super.key,
      required this.slots,
      this.hint,
      this.numOnly = false,
      this.onChanged,
      this.boxW = 20,
      this.boxH = 23});

  @override
  State<SegBox> createState() => _SB();
}

class _SB extends State<SegBox> {
  late List<TextEditingController> _cs;
  late List<FocusNode> _ns;

  @override
  void initState() {
    super.initState();
    _cs = List.generate(widget.slots, (_) => TextEditingController());
    // ── KEY FIX: wrap setState in addPostFrameCallback
    //    Flutter Web fires the FocusNode listener during the mouse-tracking
    //    phase which causes !_debugDuringDeviceUpdate to fire.
    _ns = List.generate(widget.slots, (_) {
      final fn = FocusNode();
      fn.addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      });
      return fn;
    });
  }

  @override
  void dispose() {
    for (var c in _cs) c.dispose();
    for (var f in _ns) f.dispose();
    super.dispose();
  }

  String get _val => _cs.map((c) => c.text).join();
  RegExp get _allow =>
      widget.numOnly ? RegExp(r'[0-9]') : RegExp(r'[A-Za-z0-9]');

  void _paste(String raw, int start) {
    final chars =
        raw.toUpperCase().split('').where((ch) => _allow.hasMatch(ch)).toList();
    for (int i = start, j = 0; i < widget.slots && j < chars.length; i++, j++) {
      _cs[i].text = chars[j];
    }
    setState(() {});
    final nxt = (start + chars.length).clamp(0, widget.slots - 1);
    FocusScope.of(context).requestFocus(_ns[nxt]);
    widget.onChanged?.call(_val);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.slots, (i) {
        final filled = _cs[i].text.isNotEmpty;
        final focused = _ns[i].hasFocus;
        final hintCh = (widget.hint != null && i < widget.hint!.length)
            ? widget.hint![i]
            : '';
        return Container(
          width: widget.boxW,
          height: widget.boxH,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
              color: focused
                  ? const Color(0xFFEEF6FF)
                  : filled
                      ? _cFilled
                      : _cWhite,
              border: Border.all(
                  color: focused ? _cFocus : _cBorder,
                  width: focused ? 1.8 : 1.2)),
          child: TextField(
              controller: _cs[i],
              focusNode: _ns[i],
              textAlign: TextAlign.center,
              maxLength: 1,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: _cText,
                  height: 1.2),
              decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintText: hintCh,
                  hintStyle: const TextStyle(
                      fontSize: 11, color: _cGrey, fontFamily: 'Courier'),
                  contentPadding: EdgeInsets.zero,
                  isDense: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(_allow),
                _UC()
              ],
              onChanged: (v) {
                if (v.length > 1) {
                  _paste(v, i);
                  return;
                }
                setState(() {});
                if (v.isNotEmpty && i < widget.slots - 1) {
                  FocusScope.of(context).requestFocus(_ns[i + 1]);
                } else if (v.isEmpty && i > 0) {
                  FocusScope.of(context).requestFocus(_ns[i - 1]);
                }
                widget.onChanged?.call(_val);
              }),
        );
      }),
    );
  }
}

class _UC extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) =>
      n.copyWith(text: n.text.toUpperCase());
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEGMENTED DISPLAY (read-only, for date-picker output)
// ═══════════════════════════════════════════════════════════════════════════════
class _SegDisp extends StatelessWidget {
  final String value, hint;
  final int slots;
  const _SegDisp(
      {required this.value, required this.slots, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(slots, (i) {
          final ch = i < value.length ? value[i] : '';
          final hintCh = i < hint.length ? hint[i] : ' ';
          return Container(
              width: 20,
              height: 24,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                  border: Border.all(color: _cBorder, width: 1.0),
                  color: ch.isNotEmpty ? _cFilled : _cWhite),
              child: Center(
                  child: Text(ch.isNotEmpty ? ch : hintCh,
                      style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          color: ch.isNotEmpty ? _cNavy : _cGrey))));
        }));
  }
}
