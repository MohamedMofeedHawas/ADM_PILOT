// pilot_eval_models.dart
// Pilot Evaluation – 3 sections, 17 criteria, 5-point rating scale
// Arabic ↔ English bilingual

import 'package:flutter/material.dart';

// ─────────────────────────────────────────
// Rating scale  (1 = lowest … 5 = highest)
// ─────────────────────────────────────────
enum EvalRating { belowAverage, average, aboveAverage, good, veryGood }

extension EvalRatingX on EvalRating {
  int get value => index + 1; // 1‥5

  String get labelEn {
    const labels = ['Below Average', 'Average', 'Above Average', 'Good', 'Very Good'];
    return labels[index];
  }

  String get labelAr {
    const labels = ['دون المتوسط', 'متوسط', 'متوسط جيد', 'جيد', 'جيد جداً'];
    return labels[index];
  }

  Color get color {
    const colors = [
      Color(0xFFEF4444), // red
      Color(0xFFF97316), // orange
      Color(0xFFEAB308), // yellow
      Color(0xFF22C55E), // green
      Color(0xFF06B6D4), // cyan
    ];
    return colors[index];
  }

  /// percentage this rating represents out of 100
  double get pct => value / 5.0;
}

// ─────────────────────────────────────────
// Per‑rating level description
// ─────────────────────────────────────────
class RatingLevel {
  final String en;
  final String ar;
  const RatingLevel({required this.en, required this.ar});
}

// ─────────────────────────────────────────
// Single evaluation criterion
// ─────────────────────────────────────────
class PilotEvalCriterion {
  final String id;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;

  /// Descriptions indexed by EvalRating (length must == 5)
  final List<RatingLevel> levels; // index 0 = belowAverage … 4 = veryGood

  EvalRating? rating;

  PilotEvalCriterion({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.levels,
    this.rating,
  }) : assert(levels.length == 5, 'Exactly 5 rating levels required');

  double get ratingPct => rating == null ? 0 : rating!.pct;
  bool get isRated => rating != null;
}

// ─────────────────────────────────────────
// Section container
// ─────────────────────────────────────────
class PilotEvalSection {
  final String id;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final Color color;
  final List<PilotEvalCriterion> criteria;

  const PilotEvalSection({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.color,
    required this.criteria,
  });

  int get ratedCount => criteria.where((c) => c.isRated).length;
  double get averagePct {
    final rated = criteria.where((c) => c.isRated).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0.0, (s, c) => s + c.ratingPct) / rated.length;
  }

  bool get isComplete => criteria.every((c) => c.isRated);
}

// ─────────────────────────────────────────
// Factory – build all sections + criteria
// ─────────────────────────────────────────
List<PilotEvalSection> buildPilotEvalSections() => [
  // ══════════════════════════════════
  // SECTION A – Aviation Capabilities
  // ══════════════════════════════════
  PilotEvalSection(
    id: 'A',
    titleEn: 'Aviation Capabilities',
    titleAr: 'تقسيم مستويات إمكانيات الطيران',
    subtitleEn: 'Mental, perceptual and flight performance capabilities',
    subtitleAr: 'القدرات الذهنية والإدراكية وأداء الطيران',
    color: const Color(0xFF06B6D4), // cyan
    criteria: [
      // 1 ─ Focus / التركيز
      PilotEvalCriterion(
        id: 'A1',
        titleEn: 'Concentration',
        titleAr: 'التركيز',
        descEn: 'Ability to direct mental resources, manage distractions, and maintain focus on flight tasks.',
        descAr: 'القدرة على توجيه القدرات العقلية والذهنية، إدارة المشتتات، والإبقاء على التركيز في مهام الطيران.',
        levels: [
          const RatingLevel(
            en: 'Cannot concentrate during basic lessons; unable to retrieve essential information.',
            ar: 'لا يستطيع الطالب التركيز أثناء الدروس البسيطة وعدم القدرة على استرجاع المعلومات الأساسية.',
          ),
          const RatingLevel(
            en: 'Can handle one variable in simple lessons but needs assistance for more.',
            ar: 'يستطيع التعامل مع متغير واحد في الدروس البسيطة ولكن بمساعدة.',
          ),
          const RatingLevel(
            en: 'Can handle multiple variables in most simple lessons and fairly complex ones without assistance.',
            ar: 'يستطيع التعامل مع أكثر من متغير في أكثر الدروس البسيطة والصعبة نسبياً بدون مساعدة.',
          ),
          const RatingLevel(
            en: 'Handles multiple variables in complex lessons with adequate accuracy.',
            ar: 'يستطيع التعامل مع أكثر من متغير أثناء الدروس الصعبة بدقة كافية.',
          ),
          const RatingLevel(
            en: 'Handles multiple variables in complex lessons with high accuracy and manages critical situations.',
            ar: 'يستطيع التعامل مع أكثر من متغير أثناء الدروس الصعبة بدقة عالية وبوجه الحالات الحرجة.',
          ),
        ],
      ),

      // 2 ─ Reaction / رد الفعل
      PilotEvalCriterion(
        id: 'A2',
        titleEn: 'Reaction',
        titleAr: 'رد الفعل',
        descEn: 'Speed and accuracy of response from the decision moment to the start of execution.',
        descAr: 'القدرة على الاستجابة الحركية لمثير معين في أقصر وقت ممكن من لحظة اتخاذ القرار وحتى البدء في التنفيذ.',
        levels: [
          const RatingLevel(
            en: 'Performs all procedures with inappropriate timing affecting flight safety.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في زمن غير مناسب يؤثر على الأمان.',
          ),
          const RatingLevel(
            en: 'Performs procedures within natural time but longer than normal; needs guidance.',
            ar: 'يقوم بعمل جميع الإجراءات في الزمن الطبيعي ولكن أطول من الطبيعي ويحتاج توجيه.',
          ),
          const RatingLevel(
            en: 'Performs all procedures within natural time, fairly, without guidance.',
            ar: 'يقوم بعمل جميع الإجراءات في الزمن الطبيعي نسبياً بدون توجيه.',
          ),
          const RatingLevel(
            en: 'Performs procedures slightly faster than natural time without guidance.',
            ar: 'يقوم بعمل جميع الإجراءات في زمن أقل قليلاً من الطبيعي بدون توجيه.',
          ),
          const RatingLevel(
            en: 'Always performs all procedures in the appropriate time, without delay, at high accuracy.',
            ar: 'دائماً ما ينفذ الطالب قرارًا في الزمن المناسب وبدون تأخير ودقة عالية.',
          ),
        ],
      ),

      // 3 ─ Comprehension / الاستيعاب والتفكير
      PilotEvalCriterion(
        id: 'A3',
        titleEn: 'Comprehension & Thinking',
        titleAr: 'قدرة الاستيعاب والتفكير',
        descEn: 'Ability to absorb lessons on the ground and in the air and understand them.',
        descAr: 'قدرة الطالب على استيعاب الدروس البسيطة والمهام الزائدة على الأرض وفي الجو ومدى تفهمه للدروس.',
        levels: [
          const RatingLevel(
            en: 'Cannot absorb basic lessons; requires constant repetition.',
            ar: 'لا يستطيع الطالب استيعاب الدروس البسيطة بسهولة ويحتاج تكرار الشرح باستمرار.',
          ),
          const RatingLevel(
            en: 'Can absorb simple lessons and tasks but needs repetition.',
            ar: 'يستطيع الطالب أن يستوعب و يستقبل المهام البسيطة والمهام الزائدة و لكن بعد تكرار للشرح.',
          ),
          const RatingLevel(
            en: 'Absorbs simple and complex tasks without need for repetition; can be prompted alone.',
            ar: 'يستطيع الطالب أن يستوعب ويستقبل المهام البسيطة والمهام الزائدة بدون احتياج لتكرار للشرح ويكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Understands how to handle average and critical situations with good accuracy.',
            ar: 'يستطيع الطالب أن يفهم كيفية التعامل مع المواقف العادية والحرجة وتحقيقها بدقة.',
          ),
          const RatingLevel(
            en: 'Fully understands how to handle all situations with very high accuracy independently.',
            ar: 'يستطيع الطالب أن يتفهم كيفية التعامل مع المواقف العادية والحرجة وتحقيقها بدقة عالية.',
          ),
        ],
      ),

      // 4 ─ Awareness / الإدراك
      PilotEvalCriterion(
        id: 'A4',
        titleEn: 'Situational Awareness',
        titleAr: 'الإدراك (الوعي)',
        descEn: 'Awareness of different flight lessons and their interrelations.',
        descAr: 'مدى إلمام الطالب بالمعلومات الكافية عن الدروس المختلفة في الطيران وعلاقتها ببعض ومدى تأثير كل منها على الآخر.',
        levels: [
          const RatingLevel(
            en: 'Completely unaware of factors affecting flight; needs strong instructor support.',
            ar: 'الطالب غير مدرك لأغلبية العوامل المؤثرة على الطيران ويحتاج مساعدة قوية من المدرس.',
          ),
          const RatingLevel(
            en: 'Has minor gaps in awareness; sometimes needs instructor assistance.',
            ar: 'يكون للطالب هفوات صغيرة من عدم الإدراك ويحتاج أحياناً المساعدة من المدرس.',
          ),
          const RatingLevel(
            en: 'Has minor gaps in awareness but can handle situations at average level independently.',
            ar: 'يكون للطالب هفوات صغيرة من عدم الإدراك في المواقف الحرجة ولكن ليس في المواقف ويكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Has some gaps for certain non-influential factors; generally aware of most elements.',
            ar: 'يتعرض الطالب لبعض الهفوات على فترات متباعدة من الأخطاء البسيطة المؤثرة على الطيران.',
          ),
          const RatingLevel(
            en: 'Fully aware of all factors; high situational awareness independently.',
            ar: 'يصعب خطأ الطالب ويكون على دراية بكل العوامل.',
          ),
        ],
      ),

      // 5 ─ Control Handling / مناولة أدوات القيادة
      PilotEvalCriterion(
        id: 'A5',
        titleEn: 'Control Handling',
        titleAr: 'أسلوب مناولة أدوات القيادة',
        descEn: 'Understanding and smoothly placing hands on controls and using them correctly.',
        descAr: 'تدل على تفهم الطالب لوضع الأيدي والأقدام على أدوات القيادة بصورة صحيحة وكيفية إستخدام أدوات التحكم بنعومة.',
        levels: [
          const RatingLevel(
            en: 'Very rough on controls in normal conditions; affects safety.',
            ar: 'الطالب عنيف جداً ومشدود على أدوات التحكم في الظروف العادية مما يؤثر على الأمان والسلامة.',
          ),
          const RatingLevel(
            en: 'Rough on controls in normal conditions; instructor must occasionally intervene.',
            ar: 'الطالب مشدود على أدوات التحكم في الظروف العادية ويتلاشى بدون تدخل المدرس أحياناً ويعود مرة أخرى.',
          ),
          const RatingLevel(
            en: 'Somewhat rough in critical situations; improves without instructor.',
            ar: 'الطالب مشدود نسبياً على أدوات التحكم في الحرجة فقط ويتلاشى بدون تدخل المدرس ويكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Uses controls smoothly and correctly; occasionally needs instructor direction.',
            ar: 'يستخدم الطالب أدوات التحكم بصورة صحيحة ولكن يوجه أحياناً للأداء.',
          ),
          const RatingLevel(
            en: 'Uses controls smoothly and accurately at all times including in large maneuvers.',
            ar: 'يستخدم الطالب أدوات التحكم بصورة صحيحة وبنعومة وبدقة عالية حتى أثناء المناورات الكبيرة.',
          ),
        ],
      ),

      // 6 ─ Flight Lesson Performance / أداء دروس الطيران
      PilotEvalCriterion(
        id: 'A6',
        titleEn: 'Flight Lesson Performance',
        titleAr: 'أداء دروس الطيران',
        descEn: 'Overall quality of lesson execution in the air.',
        descAr: 'مستوى أداء الطالب الفعلي للدروس أثناء الطيران.',
        levels: [
          const RatingLevel(
            en: 'Performs lesson with major errors; cannot complete it without constant help.',
            ar: 'يؤدي الطالب الدرس بأخطاء حرجة وغير حرجة ولا يصلح لأداء الدرس المستمر.',
          ),
          const RatingLevel(
            en: 'Performs lesson with errors; detects some independently but needs help for others.',
            ar: 'يؤدي الطالب الدرس باخطاء غير حرجة ويكتشف و يصلح الأخطاء بقليل من مساعدة المدرس.',
          ),
          const RatingLevel(
            en: 'Performs lesson with minor errors; detects and corrects them independently.',
            ar: 'يؤدي الطالب الدرس بدون وجود اخطاء حرجة ويكتشف و يصلح الأخطاء بدون مساعدة المدرس.',
          ),
          const RatingLevel(
            en: 'Performs lesson close to standards with good self-correction.',
            ar: 'يؤدي الطالب الدرس أقرب للدقة للدفة تسبيا مع وجود أخطاء بسيطة ويصلحها.',
          ),
          const RatingLevel(
            en: 'Performs lesson accurately and precisely with very minor or no errors.',
            ar: 'يؤدي الطالب الدرس بدقة مع وجود أخطاء بسيطة جداً أو بدون أخطاء.',
          ),
        ],
      ),

      // 7 ─ External Vision / الرؤية الخارجية
      PilotEvalCriterion(
        id: 'A7',
        titleEn: 'External Vision (Lookout)',
        titleAr: 'الرؤية الخارجية',
        descEn: 'Quality and effectiveness of external scan, arrangement, and situational lookout.',
        descAr: 'جودة وفعالية المسح الخارجي والترتيب والرؤية الظرفية.',
        levels: [
          const RatingLevel(
            en: 'Does not look outside; no useful external visual scanning observed.',
            ar: 'الطالب لا ينظر للخارج (لا توجد رؤية خارجية) أو رؤية لا فائدة منها.',
          ),
          const RatingLevel(
            en: 'Performs external scan with little instructor guidance; occasionally benefits.',
            ar: 'يؤدي الطالب الرؤية الخارجية بقليل من التوجيه من المدرس أحياناً.',
          ),
          const RatingLevel(
            en: 'Performs external scan without guidance but does not benefit from it.',
            ar: 'يؤدي الطالب الرؤية الخارجية بدون توجيه ولكن لا يستفيد منها.',
          ),
          const RatingLevel(
            en: 'Performs external scan and benefits with some arrangement or lookout errors.',
            ar: 'يؤدي الطالب الرؤية الخارجية ويستفيد منها مع وجود أخطاء بسيطة في الترتيب أو الحيوية أو مجال الرؤية.',
          ),
          const RatingLevel(
            en: 'Performs exemplary external scan and fully benefits from it without errors.',
            ar: 'يؤدي الطالب الرؤية الخارجية ويستفيد منها بشكل مثالي بدون أخطاء.',
          ),
        ],
      ),

      // 8 ─ Emergency Situations / الحالات الاضطرارية
      PilotEvalCriterion(
        id: 'A8',
        titleEn: 'Emergency Procedures',
        titleAr: 'الحالات الاضطرارية',
        descEn: 'Ability to detect emergency cues and execute all emergency procedures correctly.',
        descAr: 'قدرة الطالب على اكتشاف شواهد الموقف والتصرف مع الحالة الطارئة وأخذ جميع الإجراءات المقررة.',
        levels: [
          const RatingLevel(
            en: 'Cannot detect emergency cues; completely unable to manage the aircraft in emergencies.',
            ar: 'يكون الطالب غير قادر على اكتشاف شواهد الموقف أو التصرف مع الحالة الطارئة مع الطائرة.',
          ),
          const RatingLevel(
            en: 'Detects some cues and handles situation with instructor assistance.',
            ar: 'يكون الطالب قادر على اكتشاف شواهد الموقف ولكن يحتاج مساعدة المدرس أحياناً.',
          ),
          const RatingLevel(
            en: 'Detects cues and handles situation without instructor intervention.',
            ar: 'يكون الطالب قادر على اكتشاف شواهد الموقف والتصرف مع الحالة الطارئة بدون مساعدة المدرس.',
          ),
          const RatingLevel(
            en: 'Detects all cues and executes some procedures correctly without errors.',
            ar: 'يكون الطالب قادر على اكتشاف شواهد الموقف والتصرف مع الحالة الطارئة بدون أخطاء وبسرعة الأداء.',
          ),
          const RatingLevel(
            en: 'Executes all emergency procedures professionally with high speed and accuracy.',
            ar: 'يؤدي الطالب جميع الإجراءات المقررة كمحترف بطريقة صحيحة وبسرعة و بدقة عالية.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════
  // SECTION B – Personal Qualities
  // ══════════════════════════════════
  PilotEvalSection(
    id: 'B',
    titleEn: 'Personal Qualities',
    titleAr: 'تقسيم مستويات الصفات الشخصية',
    subtitleEn: 'Psychological and attitudinal traits of the student pilot',
    subtitleAr: 'الصفات النفسية والسلوكية للطالب الطيار',
    color: const Color(0xFF22C55E), // green
    criteria: [
      // 1 ─ Personal Effort / الجهود الشخصية
      PilotEvalCriterion(
        id: 'B1',
        titleEn: 'Personal Effort',
        titleAr: 'الجهود الشخصية',
        descEn: 'Volume of self-preparation effort on the ground and mental rehearsal during flight.',
        descAr: 'حجم المجهود المبذول في التحضير الأرضي والتخيل المبذول أثناء الطيران مع الإصرار على تنفيذ ما تم تحضيره على الأرض.',
        levels: [
          const RatingLevel(
            en: 'Exerts no effort; needs firm follow-up and sometimes incorrect attitude.',
            ar: 'الطالب لا يبذل أي مجهود وقد يحتاج معاملة بحزم ويحتاج المتابعة المستمرة وأحياناً إتجاهه خاطئ.',
          ),
          const RatingLevel(
            en: 'Exerts insufficient effort; direction unclear but sometimes correct.',
            ar: 'الطالب يبذل مجهود غير كافي نسبياً لـلوصول للمستوى المطلوب بدون توجيه لكن في اتجاه خاطئ أحياناً.',
          ),
          const RatingLevel(
            en: 'Exerts sufficient effort toward the required level.',
            ar: 'الطالب يبذل المجهود الكافي للوصول للمستوى المطلوب منه في الاتجاه الصحيح.',
          ),
          const RatingLevel(
            en: 'Exerts more than required effort toward the correct direction.',
            ar: 'الطالب يبذل مجهود واضح زائد للوصول للمستوى المطلوب منه في الاتجاه الصحيح.',
          ),
          const RatingLevel(
            en: 'Exerts significant extra effort clearly and consistently in more than one direction.',
            ar: 'الطالب يبذل مجهود زائد وبوضوح في أكثر من اتجاه.',
          ),
        ],
      ),

      // 2 ─ Self-Confidence & Decision Making / الثقة في النفس واتخاذ القرار
      PilotEvalCriterion(
        id: 'B2',
        titleEn: 'Self-Confidence & Decision Making',
        titleAr: 'الثقة في النفس واتخاذ القرار',
        descEn: 'Pilot\'s sense of his own ability and capacity to make the right decision.',
        descAr: 'إحساس الطيار بقدراته وإمكانياته ومدى القدرة على تنفيذ المطلوب منه أو اتخاذ القرار الصحيح في ظل الظروف المختلفة.',
        levels: [
          const RatingLevel(
            en: 'Very low self-confidence; never makes decisions; complete collapse under pressure.',
            ar: 'يكون الطالب غير واثق في نفسه وذو شخصية انهزامية ولا مستسلمة ولا يقوم باتخاذ قرار في جميع المواقف.',
          ),
          const RatingLevel(
            en: 'Relatively confident; takes decisions in normal situations but needs help in critical ones.',
            ar: 'يكون الطالب واثق نسبياً ويقوم باتخاذ قرار في المواقف الطبيعية لكن بمساعدة المدرس.',
          ),
          const RatingLevel(
            en: 'Confident; takes decisions in normal situations sometimes correctly alone.',
            ar: 'يكون الطالب واثق بنفسه ويقوم باتخاذ قرار في المواقف الطبيعية بدون مساعدة ولكن يوجه للقرار الصائب.',
          ),
          const RatingLevel(
            en: 'Confident; makes correct decisions in normal and some critical situations.',
            ar: 'يكون الطالب واثق بنفسه ويقوم باتخاذ القرار الصائب في المواقف الحرجة ولكن بعض الأحيان يحتاج للمساعدة.',
          ),
          const RatingLevel(
            en: 'Highly confident; always makes correct decisions even in the most critical situations.',
            ar: 'يكون الطالب ذو ثقة عالية بنفسه ودائماً ما يقوم باتخاذ قرار صائب في المواقف المعقدة.',
          ),
        ],
      ),

      // 3 ─ Balance & Fear / الاتزان والخوف
      PilotEvalCriterion(
        id: 'B3',
        titleEn: 'Balance & Fear Control',
        titleAr: 'الاتزان والخوف',
        descEn: 'Balance and calmness when participating in any situation; control of fear.',
        descAr: 'يدل على مدى شعور الطالب بالاتزان والرهبة والقلق عند المشاركة في موقف جديد أو حرج ومدى قدرته على التعامل تحت الشعور بالخوف.',
        levels: [
          const RatingLevel(
            en: 'Strong fear tendency in simple situations; needs instructor to reach goals.',
            ar: 'يكون للطالب ميل للخوف والرغبة بشدة للبعد عن المواقف البسيطة ويحتاج مساعدة المدرس للوصول للهدف.',
          ),
          const RatingLevel(
            en: 'Shows some fear signs in simple situations; needs instructor to approach goals.',
            ar: 'يظهر على الطالب بعض علامات الرهبة أثناء الدروس البسيطة ويحتاج مساعدة المدرس للوصول للهدو.',
          ),
          const RatingLevel(
            en: 'Despite some stress signs, can handle the situation and approach goals alone.',
            ar: 'بالرغم من ظهور بعض الشد العصبي يكون الطالب قادر على التعامل مع المواقف ولائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'No visible stress signs; fully manages situations and complex emergencies independently.',
            ar: 'لا يظهر على الطالب أعراض الشد العصبي لكن يكون قادر على التعامل مع المواقف الحرجة.',
          ),
          const RatingLevel(
            en: 'Completely calm; manages all situations including the most complex independently.',
            ar: 'يستطيع الطالب التعامل مع أي موقف مهما كانت درجة تعقيده بطريقة هادئة.',
          ),
        ],
      ),

      // 4 ─ Persistence / الإصرار
      PilotEvalCriterion(
        id: 'B4',
        titleEn: 'Persistence',
        titleAr: 'الإصرار',
        descEn: 'Student\'s commitment to perform correctly, observe errors, and reach accuracy.',
        descAr: 'هي قدرة الطالب على الإلتزام نفسه على الأداء الصحيح مع ملاشاة أخطاءه والوصول للدقة.',
        levels: [
          const RatingLevel(
            en: 'Lacks persistence; does not observe any of his errors.',
            ar: 'يفتقد الطالب الإصرار على ملاشاة جميع أخطاءه.',
          ),
          const RatingLevel(
            en: 'Shows persistence on observing main errors only; needs minor instructor guidance.',
            ar: 'يقوم الطالب بالإصرار على ملاشاة أخطاءه الرئيسية بتوجيه بسيط من المدرس.',
          ),
          const RatingLevel(
            en: 'Shows persistence on secondary and most primary errors; can perform alone.',
            ar: 'الطالب لديه إصرار على ملاشاة أخطاءه الثانوية و معظم الأخطاء الرئيسية يكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Shows persistence on all errors including secondary ones with high accuracy.',
            ar: 'الطالب لديه إصرار على ملاشاة أخطاءه الثانوية والرئيسية ويحققها بدقة.',
          ),
          const RatingLevel(
            en: 'Outstanding persistence on observing all errors with high accuracy.',
            ar: 'يمتاز الطالب بالإصرار العالي على ملاشاة جميع أخطاءه.',
          ),
        ],
      ),

      // 5 ─ Following Orders & Regulations / اتباع الأوامر والقوانين
      PilotEvalCriterion(
        id: 'B5',
        titleEn: 'Following Orders & Regulations',
        titleAr: 'اتباع الأوامر والقوانين',
        descEn: 'Student\'s commitment to executing all procedures and following flight orders and safety regulations.',
        descAr: 'إلتزام الطالب بتنفيذ كافة الإجراءات واتباع أوامر الطيران في نطاق الأمان والسلامة.',
        levels: [
          const RatingLevel(
            en: 'Does not execute correct procedures and commits errors in safety compliance.',
            ar: 'لا يقوم الطالب بتنفيذ الإجراءات الصحيحة ويحتاج مساعدة المدرس لتجنب المواقف الخطيرة.',
          ),
          const RatingLevel(
            en: 'Executes procedures with errors; needs some instructor assistance.',
            ar: 'يقوم الطالب بتنفيذ الإجراءات بأخطاء ولكن بقليل من مساعدة المدرس.',
          ),
          const RatingLevel(
            en: 'Executes all procedures without assistance; some minor errors remain.',
            ar: 'يؤدي الطالب جميع الإجراءات بدون مساعدة مع الدرس مع وجود بعض الأخطاء البسيطة ويكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Executes all standard procedures correctly; follows the correct methods accurately.',
            ar: 'يؤدي الطالب جميع الإجراءات التالية الصحيحة الطرق الصحيحة بدقة.',
          ),
          const RatingLevel(
            en: 'Executes all procedures without errors; follows all regulations and safety rules.',
            ar: 'لا يرتكب الطالب أي أخطاء في تنفيذه للإجراءات أو اتباعه للقوانين.',
          ),
        ],
      ),
    ],
  ),

  // ══════════════════════════════════
  // SECTION C – Performance Levels
  // ══════════════════════════════════
  PilotEvalSection(
    id: 'C',
    titleEn: 'Performance Levels',
    titleAr: 'تقسيم مستويات الأداء',
    subtitleEn: 'Physical and psychomotor performance accuracy',
    subtitleAr: 'دقة الأداء الحركي والجسدي',
    color: const Color(0xFFF59E0B), // amber
    criteria: [
      // 1 ─ Aircraft Tolerances / مراقبة مسموحات الطائرة
      PilotEvalCriterion(
        id: 'C1',
        titleEn: 'Aircraft Tolerances Monitoring',
        titleAr: 'مراقبة مسموحات الطائرة',
        descEn: 'Awareness of primary and secondary aircraft tolerances and continuous monitoring.',
        descAr: 'مدى دراية الطالب بالمسموحات الرئيسية والثانوية وملاحظتها جيداً باستمرار.',
        levels: [
          const RatingLevel(
            en: 'No awareness of tolerances; needs major assistance to avoid exceedance.',
            ar: 'الطالب لا يكون على دراية بحدود الطائرة ويحتاج مساعدة كبيرة لتجنب زيادة المسموحات الخطأ.',
          ),
          const RatingLevel(
            en: 'Aware of primary tolerances only; needs instructor to stay within limits.',
            ar: 'يكون الطالب على دراية بالمسموحات الرئيسية فقط ويحتاج و يظل في نطاق المسموحات الثانوية.',
          ),
          const RatingLevel(
            en: 'Aware of primary and secondary tolerances; needs assistance to stay within all limits.',
            ar: 'يكون الطالب على دراية بالمسموحات الرئيسية والثانوية لكن يحتاج المساعدة ليظل في نطاق المسموحات الثانوية ويكون لائق لأداء منفرداً.',
          ),
          const RatingLevel(
            en: 'Aware of all tolerances and follows them consistently without deviation.',
            ar: 'يكون الطالب على دراية تامة بالمسموحات الرئيسية والثانوية ويتابعها بإستمرار.',
          ),
          const RatingLevel(
            en: 'Complete awareness and excellent observation of all tolerances continuously.',
            ar: 'يكون الطالب على دراية تامة وملاحظة جيدة لكل مسموحات الطائرة.',
          ),
        ],
      ),

      // 2 ─ Sensitivity / الحساسية
      PilotEvalCriterion(
        id: 'C2',
        titleEn: 'Sensitivity',
        titleAr: 'الحساسية',
        descEn: 'Human\'s sense of stability or change in what is seen or touched.',
        descAr: 'هي إحساس الإنسان بالثبات أو بالتغير على مايراه أو يلمسه.',
        levels: [
          const RatingLevel(
            en: 'Cannot sense changes in position at all; needs instructor to reach critical states.',
            ar: 'لا يستطيع الطالب الإحساس بالتغيير بالوضع في توقيت متأخر ويحتاج أحياناً المساعدة للوصول للأوضاع الحرجة.',
          ),
          const RatingLevel(
            en: 'Senses small changes late; sometimes needs help reaching correct positions.',
            ar: 'يستطيع الطالب الإحساس بالتغيير الصغير في الوضع في توقيت متأخر أحياناً ويصلح بمساعدة.',
          ),
          const RatingLevel(
            en: 'Senses small changes in appropriate time but may not reach critical state alone.',
            ar: 'يستطيع الطالب الإحساس بالتغيير الصغير في الوضع وفي التوقيت المناسب وإن كان أحياناً ليس المناسب ويصلح أمن للمنفرد.',
          ),
          const RatingLevel(
            en: 'Senses small changes in appropriate time accurately.',
            ar: 'يستطيع الطالب الإحساس بالتغيير الصغير في الوضع وفي التوقيت المناسب.',
          ),
          const RatingLevel(
            en: 'Senses all environmental changes quickly, accurately, and at exactly the right time.',
            ar: 'يستطيع الطالب الإحساس بكل التغيرات المحيطة به بدقة عالية.',
          ),
        ],
      ),

      // 3 ─ Coordination / التوافق
      PilotEvalCriterion(
        id: 'C3',
        titleEn: 'Coordination',
        titleAr: 'التوافق',
        descEn: 'Ease of transmitting neural commands to produce combined movements at synchronized timing.',
        descAr: 'هو سهولة إنتقال الأوامر من الجهاز العصبي إلى الجهاز الحركي ليؤدي مجموعة من الحركات في إيقاع سليم والوصول إلى إدماج حركات من أنواع مختلفة في توقيت متزامن.',
        levels: [
          const RatingLevel(
            en: 'Cannot coordinate simple movements or actions with each other.',
            ar: 'لا يستطيع الطالب التفكير وأداء أي حركات بسيطة مدمجة مع بعضها.',
          ),
          const RatingLevel(
            en: 'Performs simple movements but coordination breaks during complex actions.',
            ar: 'يستطيع الطالب التفكير وأداء الحركات الصغيرة مدمجة ولكن متقطع الأداء ويحتاج القليل من التوجيه.',
          ),
          const RatingLevel(
            en: 'Performs combined simple movements at appropriate timing but needs guidance for complex ones.',
            ar: 'يستطيع الطالب التفكير وأداء الحركات البسيطة مدمجة في توقيت مناسب نسبياً ويكون أمن للمنفرد.',
          ),
          const RatingLevel(
            en: 'Coordinates simple and complex movements at appropriate timing with high accuracy.',
            ar: 'يستطيع الطالب التفكير وأداء الحركات البسيطة والصعبة مدمجة في توقيت مناسب ويحتاج لبعض التوجيه للدقة في الحركات الصعبة.',
          ),
          const RatingLevel(
            en: 'Fully coordinates all movements with high timing efficiency in complex situations.',
            ar: 'يستطيع الطالب التفكير وأداء الحركات البسيطة والصعبة مدمجة بدقة فعالية في توقيت مناسب.',
          ),
        ],
      ),

      // 4 ─ Vitality / الحيوية
      PilotEvalCriterion(
        id: 'C4',
        titleEn: 'Vitality (Reaction Time)',
        titleAr: 'الحيوية',
        descEn: 'Ability to execute an action in a defined time after beginning; inversely proportional to execution time.',
        descAr: 'هي القدرة على تنفيذ فعل على تنفيذ فعل معين في زمن محدد وهى المدة التي يتخذها الفرد في تنفيذ الفعل بعد البدء في التنفيذ، وتتناسب الحيوية عكسياً مع زمن تنفيذ الفعل.',
        levels: [
          const RatingLevel(
            en: 'Performs all procedures in a time that negatively affects flight safety.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في زمن أكثر من الطبيعي يؤثر على الأمان.',
          ),
          const RatingLevel(
            en: 'Performs all procedures within natural time but longer than standard; needs guidance.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في الزمن الطبيعي ولكن أطول من الطبيعي ويحتاج لبعض من التوجيه.',
          ),
          const RatingLevel(
            en: 'Performs all procedures within natural time fairly; can perform alone.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في الزمن الطبيعي نسبياً بدون توجيه يكون لائق للمنفرد.',
          ),
          const RatingLevel(
            en: 'Performs all procedures in slightly less than natural time without guidance.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في الزمن الطبيعي و في زمن أقل من الطبيعي بدون توجيه.',
          ),
          const RatingLevel(
            en: 'Performs all procedures in well below natural time with very high accuracy.',
            ar: 'يقوم الطالب بعمل جميع الإجراءات في زمن أقل كثيراً من الطبيعي.',
          ),
        ],
      ),
    ],
  ),
];