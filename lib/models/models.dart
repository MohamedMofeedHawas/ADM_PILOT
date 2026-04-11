import 'package:flutter/material.dart';

// ─── IMSAFE MODEL ─────────────────────────────────────────────────────────────
class ImsafeItem {
  final String key;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String arabicSubtitle;
  final String description;
  final String arabicDescription;
  final String iconEmoji;
  String rating; // 'LOW' | 'MEDIUM' | 'HIGH'
  String notes;
  Map<String, dynamic> subItems = {};

  ImsafeItem({
    required this.key,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.arabicSubtitle,
    required this.description,
    required this.arabicDescription,
    required this.iconEmoji,
    this.rating = 'LOW',
    this.notes = '',
  });

  bool get isRisky => rating == 'HIGH' || rating == 'MEDIUM';
  // int get riskScore => rating == 'HIGH' ? 2 : rating == 'MEDIUM' ? 1 : 0;
  int get riskScore {
    // المنطق الأساسي القديم
    int baseScore = {'LOW': 0, 'MEDIUM': 2, 'HIGH': 4}[rating] ?? 0;

    // منطق مخصص لـ "Illness"
    if (key == 'I') {
      bool isIll = subItems['isIll'] ?? false;
      Map<String, bool> symptoms = Map<String, bool>.from(subItems['symptoms'] ?? {});

      if (symptoms['fever'] == true) {
        return 10; // درجة خطرة عالية جداً تتجاوز NO-GO
      }
      if (isIll) {
        return 6; // درجة خطرة عالية
      }
      int symptomCount = symptoms.values.where((v) => v == true).length;
      return baseScore + (symptomCount * 2); // كل عرض يضيف 2 نقاط
    }

    // منطق مخصص لـ "Fatigue"
    if (key == 'F') {
      Map<String, bool> symptoms = Map<String, bool>.from(subItems['symptoms'] ?? {});
      int symptomCount = symptoms.values.where((v) => v == true).length;
      if (symptomCount >= 3) return 6; // 3 أعراض أو أكثر = خطورة عالية
      if (symptomCount >= 1) return baseScore + (symptomCount * 2);
    }

    return baseScore;}
}

List<ImsafeItem> buildImsafeItems() => [
  ImsafeItem(
    key: 'I', title: 'Illness', arabicTitle: 'المرض',
    subtitle: 'Current health issues',
    arabicSubtitle: 'المشاكل الصحية الحالية',
    iconEmoji: '🤒',
    description: 'Any symptoms like fever, congestion, or dizziness that could worsen under flight stress must be rated as high-risk.',
    arabicDescription: 'أي أعراض مثل الحمى أو الاحتقان أو الدوخة قد تسوء تحت ضغط الطيران يجب تصنيفها كخطر عالٍ.',
  ),
  ImsafeItem(
    key: 'M', title: 'Medication', arabicTitle: 'الأدوية',
    subtitle: 'Drug side effects',
    arabicSubtitle: 'الآثار الجانبية للأدوية',
    iconEmoji: '💊',
    description: 'List every medication. Check FAA aeromedical guidance. Side effects like drowsiness or blurred vision affect your GRM severity rating.',
    arabicDescription: 'اذكر كل الأدوية التي تتناولها. تحقق من إرشادات FAA. الآثار الجانبية كالنعاس أو ضبابية الرؤية تؤثر على تقييم المخاطر.',
  ),
  ImsafeItem(
    key: 'S', title: 'Stress', arabicTitle: 'الإجهاد',
    subtitle: 'Cognitive bandwidth drain',
    arabicSubtitle: 'استنزاف القدرة الذهنية',
    iconEmoji: '🧠',
    description: 'High stress drains cognitive bandwidth, making you prone to errors. Rate stress level and use it as a multiplier on other risks.',
    arabicDescription: 'الإجهاد العالي يستنزف قدرتك الذهنية ويجعلك أكثر عرضة للأخطاء. يعمل كمضاعف للمخاطر الأخرى.',
  ),
  ImsafeItem(
    key: 'A', title: 'Alcohol', arabicTitle: 'الكحول',
    subtitle: '8-hour bottle-to-throttle rule',
    arabicSubtitle: 'قاعدة 8 ساعات من القارورة إلى المحرك',
    iconEmoji: '🍺',
    description: 'FAA mandates at least 8 hours. Residual effects may linger longer. Even small amounts reduce situational awareness significantly.',
    arabicDescription: 'تشترط FAA انتظار 8 ساعات على الأقل. يمكن أن تستمر التأثيرات المتبقية لفترة أطول. حتى الكميات الصغيرة تقلل الوعي الظرفي.',
  ),
  ImsafeItem(
    key: 'F', title: 'Fatigue', arabicTitle: 'الإرهاق',
    subtitle: 'Sleep & rest quality',
    arabicSubtitle: 'جودة النوم والراحة',
    iconEmoji: '😴',
    description: 'Fatigue undermines every phase of flight. Note hours slept in past 24hrs, quality of rest. If below personal rest standard, delay the flight.',
    arabicDescription: 'الإرهاق يضعف كل مرحلة من مراحل الرحلة. إذا كنت دون معيار الراحة الشخصي، أجّل الرحلة.',
  ),
  ImsafeItem(
    key: 'E', title: 'Emotions', arabicTitle: 'العواطف',
    subtitle: 'Emotional state assessment',
    arabicSubtitle: 'تقييم الحالة العاطفية',
    iconEmoji: '💭',
    description: 'Emotional volatility (anger, grief, excitement) hijacks rational decision-making. Call out emotional state aloud and re-enter the DECIDE loop.',
    arabicDescription: 'التقلب العاطفي (الغضب، الحزن، الإثارة) يختطف القرار العقلاني. أعلن حالتك العاطفية بصوت عالٍ وأعد دخول حلقة DECIDE.',
  ),
];

// ─── PAVE MODEL ───────────────────────────────────────────────────────────────
class PaveItem {
  final String key;
  final String title;
  final String arabicTitle;
  final String description;
  final String arabicDescription;
  final String iconEmoji;
  final List<PaveCheckpoint> checkpoints;

  const PaveItem({
    required this.key,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.arabicDescription,
    required this.iconEmoji,
    required this.checkpoints,
  });
}

class PaveCheckpoint {
  final String text;
  final String arabicText;
  bool checked;

  PaveCheckpoint({required this.text, required this.arabicText, this.checked = false});
}

List<PaveItem> buildPaveItems() => [
  PaveItem(
    key: 'P', title: 'Pilot', arabicTitle: 'الطيار',
    iconEmoji: '🧑‍✈️',
    description: 'Your personal readiness, proficiency, health, currency, and mindset.',
    arabicDescription: 'جاهزيتك الشخصية، كفاءتك، صحتك، تحديثاتك التدريبية، وحالتك الذهنية.',
    checkpoints: [
      PaveCheckpoint(text: 'Completed IMSAFE self-assessment', arabicText: 'إتمام تقييم IMSAFE الذاتي'),
      PaveCheckpoint(text: 'Reviewed recent flight experience & currency', arabicText: 'مراجعة تجربة الطيران الأخيرة والتحديث'),
      PaveCheckpoint(text: 'Familiar with aircraft type & avionics', arabicText: 'إلمام بنوع الطائرة والإلكترونيات'),
      PaveCheckpoint(text: 'Emergency procedures reviewed', arabicText: 'مراجعة إجراءات الطوارئ'),
      PaveCheckpoint(text: 'Personal minimums established', arabicText: 'تحديد الحدود الشخصية الدنيا'),
    ],
  ),
  PaveItem(
    key: 'A', title: 'Aircraft', arabicTitle: 'الطائرة',
    iconEmoji: '✈️',
    description: 'Condition, airworthiness, and performance capabilities of the aircraft.',
    arabicDescription: 'حالة الطائرة وصلاحيتها للطيران وقدراتها الأدائية.',
    checkpoints: [
      PaveCheckpoint(text: 'Airworthiness documents verified', arabicText: 'التحقق من وثائق الصلاحية للطيران'),
      PaveCheckpoint(text: 'Detailed preflight inspection done', arabicText: 'إتمام الفحص التمهيدي التفصيلي'),
      PaveCheckpoint(text: 'Weight & balance within limits', arabicText: 'الوزن والتوازن ضمن الحدود'),
      PaveCheckpoint(text: 'POH performance charts referenced', arabicText: 'الرجوع إلى جداول الأداء في دليل التشغيل'),
      PaveCheckpoint(text: 'Fuel state confirmed for route + alternate', arabicText: 'تأكيد حالة الوقود للمسار والبديل'),
    ],
  ),
  PaveItem(
    key: 'V', title: 'Environment', arabicTitle: 'البيئة',
    iconEmoji: '🌤️',
    description: 'Weather, terrain, airports, and airspace affecting your route.',
    arabicDescription: 'الطقس والتضاريس والمطارات والمجال الجوي المؤثرة على مسارك.',
    checkpoints: [
      PaveCheckpoint(text: 'Full weather briefing obtained (METARs, TAFs)', arabicText: 'الحصول على إحاطة طقس كاملة'),
      PaveCheckpoint(text: 'NOTAMs, TFRs, restricted airspace checked', arabicText: 'فحص NOTAMs والمناطق المحظورة'),
      PaveCheckpoint(text: 'Terrain and obstacle clearance evaluated', arabicText: 'تقييم خلوص التضاريس والعوائق'),
      PaveCheckpoint(text: 'Alternate and diversion routes planned', arabicText: 'تخطيط المسارات البديلة وخطط الانحراف'),
      PaveCheckpoint(text: 'AIRMETs/SIGMETs reviewed', arabicText: 'مراجعة AIRMETs/SIGMETs'),
    ],
  ),
  PaveItem(
    key: 'E', title: 'External Pressures', arabicTitle: 'الضغوط الخارجية',
    iconEmoji: '⚖️',
    description: 'Passenger expectations, schedules, business demands, and personal ambitions.',
    arabicDescription: 'توقعات الركاب، المواعيد، متطلبات العمل، والطموحات الشخصية.',
    checkpoints: [
      PaveCheckpoint(text: 'Passenger/organizational expectations assessed', arabicText: 'تقييم توقعات الركاب والمنظمة'),
      PaveCheckpoint(text: 'Personal goals pressure acknowledged', arabicText: 'الاعتراف بضغط الأهداف الشخصية'),
      PaveCheckpoint(text: 'Contingency plans built with margin', arabicText: 'بناء خطط طوارئ مع هامش أمان'),
      PaveCheckpoint(text: 'No-guilt go/no-go decision point set', arabicText: 'تحديد نقطة قرار الطيران/عدم الطيران بلا ضغط'),
      PaveCheckpoint(text: 'Time pressure honestly evaluated', arabicText: 'تقييم صادق لضغط الوقت'),
    ],
  ),
];

// ─── DECIDE MODEL ─────────────────────────────────────────────────────────────
class DecideStep {
  final String key;
  final String title;
  final String arabicTitle;
  final String description;
  final String arabicDescription;
  final String cockpitApp;
  final String arabicCockpitApp;
  final String iconEmoji;
  final Color color;
  String userInput;
  bool completed;

  DecideStep({
    required this.key,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.arabicDescription,
    required this.cockpitApp,
    required this.arabicCockpitApp,
    required this.iconEmoji,
    required this.color,
    this.userInput = '',
    this.completed = false,
  });
  bool skipped = false;
}


List<DecideStep> buildDecideSteps() => [
  DecideStep(
    key: 'D', title: 'DETECT', arabicTitle: 'اكتشف',
    iconEmoji: '🔍', color: const Color(0xFF00C8F0),
    description: 'Maintain continuous vigilance for anything affecting your flight. Systematic scan of external, internal, and personal domains.',
    arabicDescription: 'حافظ على يقظة مستمرة لأي شيء يؤثر على رحلتك. فحص منهجي للمجالات الخارجية والداخلية والشخصية.',
    cockpitApp: 'Cross-check instruments every 20-30 seconds. Use PAVE scan at level-off and cruise. Log emerging hazards on kneeboard.',
    arabicCockpitApp: 'تحقق من الأجهزة كل 20-30 ثانية. استخدم مسح PAVE عند الاستواء والإبحار. سجّل المخاطر الناشئة على لوحة الركبة.',
  ),
  DecideStep(
    key: 'E', title: 'EVALUATE', arabicTitle: 'قيّم',
    iconEmoji: '⚖️', color: const Color(0xFF8B5CF6),
    description: 'Assess hazard severity and probability. Two-dimensional risk: Severity (how bad) × Likelihood (how probable) = Risk score.',
    arabicDescription: 'قيّم شدة الخطر واحتماليته. المخاطرة ثنائية الأبعاد: الخطورة × الاحتمالية = درجة المخاطرة.',
    cockpitApp: 'Rate turbulence ahead: medium if under 100ft excursions, high if straining harness. Evaluate fuel vs. diversion distance.',
    arabicCockpitApp: 'صنّف الاضطراب القادم: متوسط إذا كان أقل من 100 قدم، عالٍ إذا كان يشد حزام الأمان. قيّم الوقود مقابل مسافة الانحراف.',
  ),
  DecideStep(
    key: 'C', title: 'CONSIDER', arabicTitle: 'فكّر',
    iconEmoji: '💡', color: const Color(0xFFFFB020),
    description: 'Brainstorm all viable courses of action. Generate at least 3 workable alternatives. Engage crew for additional input.',
    arabicDescription: 'افكّر في جميع مسارات العمل الممكنة. أنشئ على الأقل 3 بدائل قابلة للتطبيق. استشر طاقم الرحلة لإضافة مدخلات.',
    cockpitApp: 'Thunderstorms: list 3 options (altitude change, lateral deviation, alternate route). Write options on scratchpad to keep in view.',
    arabicCockpitApp: 'العواصف الرعدية: ضع 3 خيارات (تغيير الارتفاع، الانحراف الجانبي، مسار بديل). اكتب الخيارات على لوحة الكتابة لتبقى مرئية.',
  ),
  DecideStep(
    key: 'I', title: 'INTEGRATE', arabicTitle: 'ادمج',
    iconEmoji: '🔗', color: const Color(0xFF00E676),
    description: 'Merge chosen mitigations into a coherent flight plan. Balance against performance, regulations, and passenger needs.',
    arabicDescription: 'ادمج التخفيفات المختارة في خطة طيران متماسكة. وازن بين الأداء واللوائح واحتياجات الركاب.',
    cockpitApp: 'Compute new heading, distance, fuel burn, ETA for diversion. Integrate ATC clearance, amend GPS, update approach brief.',
    arabicCockpitApp: 'احسب الاتجاه الجديد والمسافة واستهلاك الوقود ووقت الوصول للانحراف. ادمج تصريح ATC، عدّل GPS، حدّث إحاطة الاقتراب.',
  ),
  DecideStep(
    key: 'D2', title: 'DECIDE', arabicTitle: 'قرّر',
    iconEmoji: '✅', color: const Color(0xFFFF6B35),
    description: 'Select the single best plan and commit. Strong verbal call-out. A decision is only good if shared and executed without hesitation.',
    arabicDescription: 'اختر أفضل خطة واحدة والتزم بها. إعلان لفظي قوي. القرار لا يكون جيداً إلا إذا شُورك وتُنفّذ دون تردد.',
    cockpitApp: '"I\'m diverting to MXY. Heading 180, squawk 1200, time enroute 12 min." Brief passengers. Tell ATC immediately.',
    arabicCockpitApp: '"أنا أنحرف إلى MXY. اتجاه 180، كود 1200، وقت الرحلة 12 دقيقة." أحطّ الركاب. أخبر مراقبة الحركة الجوية فوراً.',
  ),
  DecideStep(
    key: 'E2', title: 'EXECUTE & REASSESS', arabicTitle: 'نفّذ وأعد التقييم',
    iconEmoji: '🔄', color: const Color(0xFFFF3D57),
    description: 'Put decision into action with flawless execution. Monitor outcomes. If conditions change, loop back through Detect-Evaluate.',
    arabicDescription: 'نفّذ القرار بدقة تامة. راقب النتائج. إذا تغيرت الظروف، عد إلى حلقة Detect-Evaluate مجدداً.',
    cockpitApp: 'After descent, check VS vs FMC profile. In turbulence, reconfirm seatbelts. 5 min after diversion, run PAVE scan again.',
    arabicCockpitApp: 'بعد الهبوط، تحقق من معدل الهبوط مقابل ملف FMC. في الاضطراب، أعد تأكيد الأحزمة. بعد 5 دقائق من الانحراف، شغّل مسح PAVE مجدداً.',
  ),
];
