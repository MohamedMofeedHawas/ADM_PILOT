import 'package:flutter/material.dart';
import 'models.dart';
import 'scoring.dart';

// ─── AI RECOMMENDATION ENGINE ─────────────────────────────────────────────────
// Medical-grade recommendations based on IMSAFE + PAVE + DECIDE data
// Similar to how an Aviation Medical Examiner (AME) would evaluate a pilot

enum RecPriority { critical, high, medium, low, positive }
enum RecCategory { medical, psychological, operational, environmental, procedural }

class AiRecommendation {
  final String title;
  final String titleArabic;
  final String detail;
  final String detailArabic;
  final String actionRequired;
  final String actionArabic;
  final RecPriority priority;
  final RecCategory category;
  final String icon;
  final int daysUntilRecheck; // 0 = immediate, -1 = no recheck needed

  const AiRecommendation({
    required this.title,
    required this.titleArabic,
    required this.detail,
    required this.detailArabic,
    required this.actionRequired,
    required this.actionArabic,
    required this.priority,
    required this.category,
    required this.icon,
    this.daysUntilRecheck = 0,
  });
}

class AiRecommendationEngine {
  static List<AiRecommendation> generate(PilotScore score) {
    final recs = <AiRecommendation>[];

    // ─── CRITICAL — IMMEDIATE NO-GO ───────────────────────────────────────────
    if (score.hasAlcohol) {
      recs.add(const AiRecommendation(
        icon: '🍺',
        priority: RecPriority.critical,
        category: RecCategory.medical,
        title: 'ALCOHOL IMPAIRMENT — GROUND IMMEDIATELY',
        titleArabic: 'تأثير الكحول — توقف فوراً عن الطيران',
        detail: 'FAA regulation 91.17 mandates minimum 8 hours "bottle to throttle". '
            'Alcohol impairs spatial orientation, reaction time, and judgment even in sub-threshold '
            'blood alcohol concentrations. Residual effects (hangover) further impair cognition.',
        detailArabic: 'تنظيم FAA 91.17 يشترط 8 ساعات على الأقل. الكحول يضعف التوجه المكاني '
            'وزمن الاستجابة والحكم حتى في تركيزات الدم دون العتبة. التأثيرات المتبقية تضعف الإدراك.',
        actionRequired: '1. Cancel all flights immediately\n'
            '2. Wait minimum 12-24 hours (not just 8)\n'
            '3. Retest BAC before any flight consideration\n'
            '4. Report to HIMS AME if regular alcohol use',
        actionArabic: '١. إلغاء جميع الرحلات فوراً\n'
            '٢. انتظر على الأقل ١٢-٢٤ ساعة (وليس ٨ فقط)\n'
            '٣. أعد اختبار تركيز الكحول قبل أي اعتبار للطيران\n'
            '٤. راجع طبيب HIMS إذا كان الاستخدام منتظماً',
        daysUntilRecheck: 1,
      ));
    }

    if (score.hasCriticalIllness) {
      recs.add(const AiRecommendation(
        icon: '🤒',
        priority: RecPriority.critical,
        category: RecCategory.medical,
        title: 'MEDICAL CONDITION — FLIGHT PROHIBITED',
        titleArabic: 'حالة طبية — الطيران محظور',
        detail: 'Active illness causes physiological stress that impairs all cognitive '
            'functions critical to safe flight. Fever, congestion, and dizziness are '
            'significantly amplified at altitude due to hypoxia and pressure changes. '
            'Any medication taken for illness may also cause additional impairment.',
        detailArabic: 'المرض النشط يسبب إجهاداً فسيولوجياً يضعف جميع الوظائف الإدراكية. '
            'الحمى والاحتقان والدوخة تتضخم بشكل كبير على الارتفاع. '
            'أي دواء يُؤخذ للمرض قد يسبب ضعفاً إضافياً.',
        actionRequired: '1. Seek medical evaluation\n'
            '2. Rest and recover fully\n'
            '3. Wait 24-48 hours symptom-free before flying\n'
            '4. Consult Aviation Medical Examiner (AME) if symptoms persist >72h',
        actionArabic: '١. طلب التقييم الطبي\n'
            '٢. الراحة والتعافي الكامل\n'
            '٣. انتظر ٢٤-٤٨ ساعة خالية من الأعراض قبل الطيران\n'
            '٤. استشر فاحص الطب الجوي إذا استمرت الأعراض أكثر من ٧٢ ساعة',
        daysUntilRecheck: 2,
      ));
    }

    if (score.hasFatigue) {
      recs.add(const AiRecommendation(
        icon: '😴',
        priority: RecPriority.critical,
        category: RecCategory.medical,
        title: 'SEVERE FATIGUE — REST MANDATORY',
        titleArabic: 'إرهاق شديد — الراحة إلزامية',
        detail: 'Fatigue is the most underestimated risk in aviation. Research shows that '
            '17-19 hours without sleep produces impairment equivalent to a BAC of 0.05%. '
            'Fatigue impairs decision-making, spatial awareness, and reaction time — '
            'all critical for safe flight operations. There is NO safe level of severe fatigue in flight.',
        detailArabic: 'الإرهاق هو أكثر المخاطر التي يُقلل من شأنها في الطيران. تُظهر الأبحاث أن '
            '١٧-١٩ ساعة بدون نوم تنتج ضعفاً مكافئاً لنسبة كحول ٠.٠٥٪. '
            'الإرهاق يضعف صنع القرار والوعي المكاني وزمن الاستجابة.',
        actionRequired: '1. Minimum 8 hours restorative sleep required\n'
            '2. Delay all flights by at least 24 hours\n'
            '3. Address root cause (duty time, sleep disorder)\n'
            '4. Consider crew duty time regulations\n'
            '5. If chronic fatigue: consult sleep specialist',
        actionArabic: '١. مطلوب ٨ ساعات نوم مُجدٍ كحد أدنى\n'
            '٢. تأجيل جميع الرحلات لمدة ٢٤ ساعة على الأقل\n'
            '٣. معالجة السبب الجذري (وقت الخدمة، اضطراب النوم)\n'
            '٤. النظر في لوائح وقت خدمة الطاقم\n'
            '٥. إذا كان الإرهاق مزمناً: استشر أخصائي النوم',
        daysUntilRecheck: 1,
      ));
    }

    // ─── HIGH PRIORITY ─────────────────────────────────────────────────────────
    if (score.hasStress) {
      recs.add(const AiRecommendation(
        icon: '🧠',
        priority: RecPriority.high,
        category: RecCategory.psychological,
        title: 'HIGH STRESS — COGNITIVE IMPAIRMENT RISK',
        titleArabic: 'إجهاد عالٍ — خطر الضعف الإدراكي',
        detail: 'High stress activates the sympathetic nervous system causing tunnel vision, '
            'reduced working memory capacity, and impaired decision-making. '
            'The Yerkes-Dodson law shows performance degrades significantly beyond optimal arousal. '
            'High stress combined with other factors creates multiplicative risk.',
        detailArabic: 'الإجهاد العالي يُنشط الجهاز العصبي الودي مسبباً رؤية النفق، '
            'تقليل سعة الذاكرة العاملة، وضعف صنع القرار. '
            'قانون يركس-دودسون يُظهر أن الأداء يتدهور بشكل كبير. '
            'الإجهاد العالي مع عوامل أخرى يخلق مخاطر مضاعفة.',
        actionRequired: '1. Identify and address primary stressor\n'
            '2. Practice box breathing (4-4-4-4 pattern)\n'
            '3. Briefing with crew about mental state\n'
            '4. Consider flight delay if mission is non-critical\n'
            '5. Consult HIMS AME if stress is chronic (>2 weeks)',
        actionArabic: '١. تحديد ومعالجة مصدر الإجهاد الرئيسي\n'
            '٢. تمارين التنفس المربع (نمط ٤-٤-٤-٤)\n'
            '٣. الإحاطة مع الطاقم عن الحالة الذهنية\n'
            '٤. النظر في تأجيل الرحلة إذا كانت غير حرجة\n'
            '٥. استشر HIMS AME إذا كان الإجهاد مزمناً (أكثر من أسبوعين)',
        daysUntilRecheck: 3,
      ));
    }

    if (score.hasMedication) {
      recs.add(const AiRecommendation(
        icon: '💊',
        priority: RecPriority.high,
        category: RecCategory.medical,
        title: 'MEDICATION — AEROMEDICAL EVALUATION REQUIRED',
        titleArabic: 'أدوية — مطلوب تقييم طب جوي',
        detail: 'Many medications are prohibited for aviation use. Side effects including '
            'drowsiness, blurred vision, delayed reaction time, and impaired judgment '
            'are significantly worse at altitude. The FAA Drug Aeronautical Information Manual '
            'lists all prohibited substances and required waiting periods.',
        detailArabic: 'العديد من الأدوية محظورة للاستخدام الجوي. الآثار الجانبية بما فيها '
            'النعاس وضبابية الرؤية وتأخر وقت الاستجابة وضعف الحكم '
            'أسوأ بكثير على الارتفاع. دليل FAA للأدوية الملاحية يُدرج جميع المواد المحظورة.',
        actionRequired: '1. Check FAA Drug Aeronautical Information Manual\n'
            '2. Consult Aviation Medical Examiner (AME)\n'
            '3. Verify medication + dosage is FAA-approved\n'
            '4. Document all medications in medical records\n'
            '5. If in doubt — DO NOT FLY',
        actionArabic: '١. راجع دليل FAA للأدوية الملاحية\n'
            '٢. استشر فاحص الطب الجوي AME\n'
            '٣. تحقق من أن الدواء والجرعة معتمدان من FAA\n'
            '٤. وثّق جميع الأدوية في السجلات الطبية\n'
            '٥. إذا كنت في شك — لا تطِر',
        daysUntilRecheck: 7,
      ));
    }

    if (score.hasEmotions) {
      recs.add(const AiRecommendation(
        icon: '💭',
        priority: RecPriority.high,
        category: RecCategory.psychological,
        title: 'EMOTIONAL VOLATILITY — JUDGMENT COMPROMISED',
        titleArabic: 'تقلب عاطفي — الحكم معرّض للخطر',
        detail: 'Acute emotional disturbance (anger, grief, euphoria) significantly impairs '
            'rational decision-making by activating the amygdala and suppressing prefrontal cortex '
            'function. Aviation requires cold, analytical thinking that emotional states directly oppose. '
            'Research shows pilots under emotional distress make 3x more errors.',
        detailArabic: 'الاضطراب العاطفي الحاد يضعف بشكل كبير صنع القرار العقلاني '
            'عن طريق تنشيط اللوزة الدماغية وقمع وظيفة قشرة الفص الجبهي. '
            'تُظهر الأبحاث أن الطيارين تحت الضيق العاطفي يرتكبون ٣ أضعاف الأخطاء.',
        actionRequired: '1. Do NOT fly while emotionally distressed\n'
            '2. Brief crew on emotional state (CRM protocol)\n'
            '3. Practice cognitive reframing techniques\n'
            '4. Delay flight until emotional state normalizes\n'
            '5. Seek counseling if distress is recurrent',
        actionArabic: '١. لا تطِر أثناء الضيق العاطفي\n'
            '٢. أحطّ الطاقم بالحالة العاطفية (بروتوكول CRM)\n'
            '٣. مارس تقنيات إعادة الصياغة المعرفية\n'
            '٤. أجّل الرحلة حتى تتطبع الحالة العاطفية\n'
            '٥. اطلب الإرشاد إذا كان الضيق متكرراً',
        daysUntilRecheck: 1,
      ));
    }

    // ─── MEDIUM PRIORITY — PAVE GAPS ──────────────────────────────────────────
    if (score.paveMissedChecks > 0 && score.paveMissedChecks < 4) {
      recs.add(AiRecommendation(
        icon: '✈️',
        priority: RecPriority.medium,
        category: RecCategory.operational,
        title: 'PAVE GAPS: ${score.paveMissedChecks} CHECKS INCOMPLETE',
        titleArabic: 'فجوات PAVE: ${score.paveMissedChecks} نقاط غير مكتملة',
        detail: 'Incomplete PAVE assessment means unknown risks exist in your flight environment. '
            'Each unchecked item represents a potential hazard that has not been evaluated. '
            'The PAVE framework is designed to ensure comprehensive risk identification before flight.',
        detailArabic: 'تقييم PAVE غير المكتمل يعني وجود مخاطر غير معروفة في بيئة الطيران. '
            'كل عنصر غير محدد يمثل خطراً محتملاً لم يتم تقييمه.',
        actionRequired: '1. Complete all PAVE checkpoints before flight\n'
            '2. Pay special attention to aircraft airworthiness\n'
            '3. Obtain complete weather briefing\n'
            '4. Identify all external pressure factors',
        actionArabic: '١. أكمل جميع نقاط تحقق PAVE قبل الرحلة\n'
            '٢. انتبه بشكل خاص لصلاحية الطائرة للطيران\n'
            '٣. احصل على إحاطة طقس كاملة\n'
            '٤. حدد جميع عوامل الضغط الخارجية',
        daysUntilRecheck: 0,
      ));
    }

    if (score.paveMissedChecks >= 4) {
      recs.add(AiRecommendation(
        icon: '🛡️',
        priority: RecPriority.high,
        category: RecCategory.operational,
        title: 'CRITICAL PAVE GAPS: ${score.paveMissedChecks} ITEMS UNCHECKED',
        titleArabic: 'فجوات PAVE حرجة: ${score.paveMissedChecks} عناصر غير مفحوصة',
        detail: 'Major gaps in preflight preparation significantly increase accident risk. '
            'NTSB data shows incomplete preflight checks are a contributing factor in 23% of general aviation accidents. '
            'Flying with unchecked PAVE items is equivalent to operating with unknown system failures.',
        detailArabic: 'الثغرات الكبيرة في التحضير قبل الطيران تزيد بشكل كبير من خطر الحوادث. '
            'بيانات NTSB تُظهر أن الفحوصات القبل-طيرانية غير المكتملة عامل مساهم في ٢٣٪ من حوادث الطيران العام.',
        actionRequired: '1. DO NOT DEPART until PAVE is complete\n'
            '2. Complete all missing aircraft checks\n'
            '3. Get full weather briefing via 1800wxbrief.com\n'
            '4. Check all NOTAMs for route and destination\n'
            '5. Brief passengers on emergency procedures',
        actionArabic: '١. لا تُقلع حتى يكتمل PAVE\n'
            '٢. أكمل جميع فحوصات الطائرة المفقودة\n'
            '٣. احصل على إحاطة طقس كاملة\n'
            '٤. تحقق من جميع NOTAMs للمسار والوجهة\n'
            '٥. أحطّ الركاب بإجراءات الطوارئ',
        daysUntilRecheck: 0,
      ));
    }

    // ─── DECIDE PROCESS ────────────────────────────────────────────────────────
    if (score.decideCompletedSteps < 3) {
      recs.add(AiRecommendation(
        icon: '🎯',
        priority: RecPriority.medium,
        category: RecCategory.procedural,
        title: 'DECIDE MODEL INCOMPLETE (${score.decideCompletedSteps}/6)',
        titleArabic: 'نموذج DECIDE غير مكتمل (${score.decideCompletedSteps}/٦)',
        detail: 'The DECIDE model is a structured aeronautical decision-making (ADM) tool. '
            'Pilots who consistently apply ADM frameworks have 40% fewer incidents according to FAA research. '
            'An incomplete DECIDE process means you may be flying without a clear emergency action plan.',
        detailArabic: 'نموذج DECIDE هو أداة هيكلية لاتخاذ القرارات الملاحية. '
            'تُظهر أبحاث FAA أن الطيارين الذين يطبقون أُطر ADM باستمرار لديهم ٤٠٪ حوادث أقل. '
            'عملية DECIDE غير المكتملة تعني أنك قد تطير بدون خطة عمل طوارئ واضحة.',
        actionRequired: '1. Complete all 6 DECIDE steps before departure\n'
            '2. Brief crew on the decision made\n'
            '3. Establish clear abort criteria\n'
            '4. Identify alternate airports along route',
        actionArabic: '١. أكمل جميع خطوات DECIDE الست قبل المغادرة\n'
            '٢. أحطّ الطاقم بالقرار المتخذ\n'
            '٣. حدد معايير الإلغاء الواضحة\n'
            '٤. حدد المطارات البديلة على طول المسار',
        daysUntilRecheck: 0,
      ));
    }

    // ─── POSITIVE RECOMMENDATIONS ──────────────────────────────────────────────
    if (score.performanceScore >= 85) {
      recs.add(const AiRecommendation(
        icon: '🏆',
        priority: RecPriority.positive,
        category: RecCategory.operational,
        title: 'EXCELLENT FITNESS — CLEARED FOR ALL OPERATIONS',
        titleArabic: 'لياقة ممتازة — مرخص لجميع العمليات',
        detail: 'Your comprehensive assessment shows optimal pilot fitness. All IMSAFE factors '
            'are within acceptable limits, PAVE has been thoroughly completed, and the DECIDE '
            'framework has been properly applied. You are in the top tier of pilot readiness.',
        detailArabic: 'يُظهر تقييمك الشامل لياقة مثالية للطيار. جميع عوامل IMSAFE '
            'ضمن الحدود المقبولة، PAVE مكتمل بشكل شامل، وتم تطبيق إطار DECIDE بشكل صحيح.',
        actionRequired: '1. Maintain current health and rest standards\n'
            '2. Continue regular IMSAFE self-assessment\n'
            '3. Stay current with training requirements\n'
            '4. Share best practices with fellow pilots',
        actionArabic: '١. حافظ على معايير الصحة والراحة الحالية\n'
            '٢. استمر في تقييم IMSAFE الذاتي المنتظم\n'
            '٣. ابقَ حديثاً مع متطلبات التدريب\n'
            '٤. شارك أفضل الممارسات مع الطيارين الزملاء',
        daysUntilRecheck: 7,
      ));
    }

    if (score.performanceScore >= 65 && score.performanceScore < 85) {
      recs.add(const AiRecommendation(
        icon: '✅',
        priority: RecPriority.low,
        category: RecCategory.operational,
        title: 'GOOD FITNESS — STANDARD PRECAUTIONS APPLY',
        titleArabic: 'لياقة جيدة — تطبق الاحتياطات القياسية',
        detail: 'Your assessment indicates good overall fitness for flight. Some areas show '
            'room for improvement. Maintain heightened situational awareness and apply '
            'standard crew resource management (CRM) procedures.',
        detailArabic: 'يُشير تقييمك إلى لياقة جيدة بشكل عام للطيران. بعض المجالات تُظهر مجالاً للتحسين. '
            'حافظ على الوعي الظرفي المرتفع وطبّق إجراءات إدارة موارد الطاقم القياسية.',
        actionRequired: '1. Standard preflight briefing\n'
            '2. Brief crew on any elevated risk factors\n'
            '3. Establish clear go/no-go criteria\n'
            '4. Monitor fatigue throughout flight',
        actionArabic: '١. الإحاطة القياسية قبل الرحلة\n'
            '٢. أحطّ الطاقم بأي عوامل خطر مرتفعة\n'
            '٣. حدد معايير الطيران/عدم الطيران الواضحة\n'
            '٤. راقب الإرهاق طوال الرحلة',
        daysUntilRecheck: 3,
      ));
    }

    // Sort by priority
    recs.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return recs;
  }

  // Face/stress analysis simulation (for camera integration)
  static Map<String, dynamic> analyzeFaceStressIndicators({
    required double eyeOpenness,    // 0.0 = closed, 1.0 = fully open
    required double browFurrow,     // 0.0 = relaxed, 1.0 = heavily furrowed
    required double microExpressions, // 0.0 = neutral, 1.0 = stressed
  }) {
    final stressIndex = (browFurrow * 0.4 + microExpressions * 0.4 + (1 - eyeOpenness) * 0.2);
    final fatigueIndex = (1 - eyeOpenness) * 0.7 + microExpressions * 0.3;

    String stressLevel = 'LOW';
    String fatigueLevel = 'LOW';

    if (stressIndex > 0.6) stressLevel = 'HIGH';
    else if (stressIndex > 0.35) stressLevel = 'MEDIUM';

    if (fatigueIndex > 0.6) fatigueLevel = 'HIGH';
    else if (fatigueIndex > 0.35) fatigueLevel = 'MEDIUM';

    return {
      'stressLevel': stressLevel,
      'fatigueLevel': fatigueLevel,
      'stressIndex': (stressIndex * 100).toInt(),
      'fatigueIndex': (fatigueIndex * 100).toInt(),
      'eyeOpennessScore': (eyeOpenness * 100).toInt(),
      'confidence': 78, // simulated confidence %
    };
  }
}

extension RecPriorityExt on RecPriority {
  Color get color {
    switch (this) {
      case RecPriority.critical: return const Color(0xFFFF3D57);
      case RecPriority.high:     return const Color(0xFFFF6B35);
      case RecPriority.medium:   return const Color(0xFFFFB020);
      case RecPriority.low:      return const Color(0xFF00C8F0);
      case RecPriority.positive: return const Color(0xFF00E676);
    }
  }

  String get label {
    switch (this) {
      case RecPriority.critical: return 'CRITICAL';
      case RecPriority.high:     return 'HIGH';
      case RecPriority.medium:   return 'MEDIUM';
      case RecPriority.low:      return 'ADVISORY';
      case RecPriority.positive: return 'POSITIVE';
    }
  }
}
