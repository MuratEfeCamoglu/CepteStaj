import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n.dart';
import '../../core/notification_service.dart';
import '../../core/workday_calculator.dart';
import '../../data/app_state.dart';
import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/lined_paper_background.dart';
import '../../widgets/motion.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_content.dart';
import '../../screens/day_detail/day_detail_screen.dart' show FieldChips;
import '../../screens/shell/app_shell.dart';

/// 5-step first-run setup: welcome/privacy, internship info, work days +
/// holiday exclusion (→ estimated end date), daily word goal + reminder
/// time, time capsule. Also reachable later from Ayarlar → "Staj tarihleri"
/// with `startAtStep` pointing straight at step 2.
class OnboardingScreen extends StatefulWidget {
  final int startAtStep;
  const OnboardingScreen({super.key, this.startAtStep = 0});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  late int _step;

  final nameCtrl = TextEditingController(text: t('Stajım'));
  final companyCtrl = TextEditingController();
  DateTime startDate = WorkdayCalculator.dateOnly(DateTime.now());
  int totalWorkdays = 20;
  List<bool> workDaysMask = [true, true, true, true, true, false, false];
  bool excludeHolidays = true;
  String field = 'general';
  int dailyWordGoal = 120;
  bool reminderEnabled = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0);
  final expectationCtrl = TextEditingController();
  final fearCtrl = TextEditingController();

  /// Editing an existing internship (from Ayarlar) skips the welcome step and
  /// the Zaman Kapsülü step — the capsule is only written once, at first setup.
  bool get _editing => widget.startAtStep > 0;
  int get _lastStep => _editing ? 3 : 4;
  int get _stepCount => _lastStep + 1;

  @override
  void initState() {
    super.initState();
    _step = widget.startAtStep;
    _controller = PageController(initialPage: _step);
    final existing = context.read<AppState>().internship;
    if (existing != null) {
      nameCtrl.text = existing.name;
      companyCtrl.text = existing.company;
      startDate = existing.startDate;
      totalWorkdays = existing.totalWorkdays;
      workDaysMask = [...existing.workDaysMask];
      excludeHolidays = existing.excludeHolidays;
      field = existing.field;
      dailyWordGoal = existing.dailyWordGoal;
      reminderEnabled = existing.reminderEnabled;
      reminderTime = TimeOfDay(hour: existing.reminderHour, minute: existing.reminderMinute);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    nameCtrl.dispose();
    companyCtrl.dispose();
    expectationCtrl.dispose();
    fearCtrl.dispose();
    super.dispose();
  }

  DateTime get estimatedEnd => WorkdayCalculator.computeEndDate(
        start: startDate,
        totalWorkdays: totalWorkdays,
        workDaysMask: workDaysMask,
        excludeHolidays: excludeHolidays,
      );

  void _next() {
    if (_step == 2 && !workDaysMask.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('En az bir çalışma günü seçmelisin'))),
      );
      return;
    }
    if (_step < _lastStep) {
      setState(() => _step++);
      _controller.nextPage(duration: AppMotion.of(context, AppMotion.standard), curve: AppMotion.emphasized);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step <= widget.startAtStep) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
    _controller.previousPage(duration: AppMotion.of(context, AppMotion.standard), curve: AppMotion.emphasized);
  }

  Future<void> _finish() async {
    final state = context.read<AppState>();
    final wasSet = state.hasInternship;
    if (wasSet) {
      state.updateInternship((i) {
        i.name = nameCtrl.text.trim().isEmpty ? t('Stajım') : nameCtrl.text.trim();
        i.company = companyCtrl.text.trim();
        i.startDate = startDate;
        i.totalWorkdays = totalWorkdays;
        i.workDaysMask = workDaysMask;
        i.excludeHolidays = excludeHolidays;
        i.field = field;
        i.dailyWordGoal = dailyWordGoal;
        i.reminderEnabled = reminderEnabled;
        i.reminderHour = reminderTime.hour;
        i.reminderMinute = reminderTime.minute;
      });
    } else {
      state.setupInternship(Internship(
        name: nameCtrl.text.trim().isEmpty ? t('Stajım') : nameCtrl.text.trim(),
        company: companyCtrl.text.trim(),
        startDate: startDate,
        totalWorkdays: totalWorkdays,
        workDaysMask: workDaysMask,
        excludeHolidays: excludeHolidays,
        field: field,
        dailyWordGoal: dailyWordGoal,
        reminderEnabled: reminderEnabled,
        reminderHour: reminderTime.hour,
        reminderMinute: reminderTime.minute,
        capsuleExpectation: expectationCtrl.text.trim(),
        capsuleFear: fearCtrl.text.trim(),
      ));
    }
    if (reminderEnabled) {
      await NotificationService.requestPermission();
    }
    if (!mounted) return;
    if (!wasSet) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    for (var i = 0; i < _stepCount; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            height: 5,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.sunkenBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: AnimatedFractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: i <= _step ? 1 : 0,
                              duration: AppMotion.of(context, AppMotion.slow),
                              curve: AppMotion.emphasized,
                              child: ColoredBox(color: AppColors.ink),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomeStep(
                    onLanguageChanged: (lang) {
                      final wasDefaultName = nameCtrl.text == t('Stajım');
                      context.read<AppState>().setLanguage(lang);
                      if (wasDefaultName) nameCtrl.text = t('Stajım');
                    },
                  ),
                  _InternshipInfoStep(nameCtrl: nameCtrl, companyCtrl: companyCtrl, startDate: startDate,
                      earliestDate: startDate.isBefore(DateTime.now().subtract(const Duration(days: 365)))
                          ? startDate
                          : DateTime.now().subtract(const Duration(days: 365)),
                      totalWorkdays: totalWorkdays,
                      field: field,
                      onField: (f) => setState(() => field = f),
                      onStartDate: (d) => setState(() => startDate = d),
                      onTotalWorkdays: (v) => setState(() => totalWorkdays = v)),
                  _WorkDaysStep(
                    workDaysMask: workDaysMask,
                    excludeHolidays: excludeHolidays,
                    estimatedEnd: estimatedEnd,
                    onToggleDay: (i) => setState(() => workDaysMask[i] = !workDaysMask[i]),
                    onExcludeHolidays: (v) => setState(() => excludeHolidays = v),
                  ),
                  _GoalsStep(
                    dailyWordGoal: dailyWordGoal,
                    reminderEnabled: reminderEnabled,
                    reminderTime: reminderTime,
                    onWordGoal: (v) => setState(() => dailyWordGoal = v),
                    onReminderEnabled: (v) => setState(() => reminderEnabled = v),
                    onReminderTime: (t) => setState(() => reminderTime = t),
                  ),
                  if (!_editing) _CapsuleStep(expectationCtrl: expectationCtrl, fearCtrl: fearCtrl),
                ],
              ),
            ),
            ResponsiveContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _back,
                      child: Text(t('Geri'), style: AppTextStyles.body(fontSize: 14, color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(
                        label: _step == _lastStep ? (_editing ? t('Kaydet') : t('Başla')) : t('Devam et'),
                        onTap: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  const _StepScaffold({required this.title, this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ResponsiveContent(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Entrance(child: Text(title, style: AppTextStyles.disp(fontSize: 32))),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Entrance(
                    index: 1,
                    child: Text(subtitle!, style: AppTextStyles.body(fontSize: 15, color: AppColors.textMuted, height: 1.4)),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Entrance(
                  index: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  final ValueChanged<String> onLanguageChanged;
  const _WelcomeStep({required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LinedPaperBackground(lineHeight: 40, opacity: 0.05),
        _StepScaffold(
          title: t('Cepte Staj\'a hoş geldin'),
          subtitle: t('Gün içinde hızlıca not al, defterini dakikalar içinde tamamla. Staj bir ödev değil, hatırlanır bir deneyim.'),
          children: [
            _LanguageToggle(onChanged: onLanguageChanged),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(
              icon: Icons.lock_outline,
              color: AppColors.ink,
              title: t('Verilerin sadece telefonunda'),
              body: t('Yazdıkların hiçbir sunucuya gönderilmez. Gizli şirket bilgisi yazmamaya özen göster.'),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.layers_outlined,
              color: AppColors.coral,
              title: t('İki katman, tek uygulama'),
              body: t('Resmi Defter dışa aktarılır. Günlüğüm (kişisel) hiçbir zaman dışa aktarma akışına girmez.'),
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.emoji_events_outlined,
              color: AppColors.violet,
              title: t('Rozetler, bingo, Wrapped'),
              body: t('Stajın sonunda paylaşılabilir bir özetin olacak.'),
            ),
          ],
        ),
      ],
    );
  }
}

/// TR / EN switch on the very first screen, so an English speaker isn't
/// stuck reading five Turkish steps before reaching Ayarlar.
class _LanguageToggle extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _LanguageToggle({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.translate_rounded, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.sm),
        for (final (code, label) in const [('tr', 'Türkçe'), ('en', 'English')])
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Pressable(
              onTap: () => onChanged(code),
              child: AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.standard),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: L10n.lang == code ? AppColors.ink : AppColors.sunkenBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: AppTextStyles.body(
                    fontSize: 13,
                    weight: FontWeight.w600,
                    color: L10n.lang == code ? AppColors.onInk : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.tint(color), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.head(fontSize: 16)),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InternshipInfoStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController companyCtrl;
  final DateTime startDate;
  final DateTime earliestDate;
  final int totalWorkdays;
  final String field;
  final ValueChanged<String> onField;
  final ValueChanged<DateTime> onStartDate;
  final ValueChanged<int> onTotalWorkdays;

  const _InternshipInfoStep({
    required this.nameCtrl,
    required this.companyCtrl,
    required this.startDate,
    required this.earliestDate,
    required this.totalWorkdays,
    required this.field,
    required this.onField,
    required this.onStartDate,
    required this.onTotalWorkdays,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t('Staj bilgileri'),
      subtitle: t('Süre ve başlangıç tarihi, bitiş tarihini otomatik hesaplar.'),
      children: [
        _FieldLabel(t('Staj alanın')),
        FieldChips(selected: field, onSelected: onField),
        const SizedBox(height: AppSpacing.lg),
        _FieldLabel(t('Staj / bölüm adı')),
        _TextInput(controller: nameCtrl, hint: t('örn. Hemşirelik Stajı')),
        const SizedBox(height: AppSpacing.lg),
        _FieldLabel(t('Şirket (opsiyonel)')),
        _TextInput(controller: companyCtrl, hint: t('örn. Acme A.Ş.')),
        const SizedBox(height: AppSpacing.lg),
        _FieldLabel(t('Başlangıç tarihi')),
        _DatePickerTile(
          date: startDate,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: startDate,
              firstDate: earliestDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onStartDate(picked);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _FieldLabel(t('Staj süresi (iş günü)')),
        Row(
          children: [
            _StepperButton(icon: Icons.remove, onTap: () => onTotalWorkdays((totalWorkdays - 1).clamp(1, 400))),
            Expanded(
              child: Center(
                child: Text(t('{n} gün', {'n': totalWorkdays}), style: AppTextStyles.head(fontSize: 18)),
              ),
            ),
            _StepperButton(icon: Icons.add, onTap: () => onTotalWorkdays((totalWorkdays + 1).clamp(1, 400))),
          ],
        ),
      ],
    );
  }
}

class _WorkDaysStep extends StatelessWidget {
  final List<bool> workDaysMask;
  final bool excludeHolidays;
  final DateTime estimatedEnd;
  final ValueChanged<int> onToggleDay;
  final ValueChanged<bool> onExcludeHolidays;

  const _WorkDaysStep({
    required this.workDaysMask,
    required this.excludeHolidays,
    required this.estimatedEnd,
    required this.onToggleDay,
    required this.onExcludeHolidays,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t('Çalışma günleri'),
      subtitle: t('Hangi günler stajdasın? Resmi tatiller otomatik hariç tutulabilir.'),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < 7; i++)
              _DayChip(
                label: weekdayShortNames[i],
                selected: workDaysMask[i],
                onTap: () => onToggleDay(i),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: excludeHolidays,
          onChanged: onExcludeHolidays,
          activeThumbColor: AppColors.ink,
          title: Text(t('Resmi tatilleri hariç tut'), style: AppTextStyles.body(fontSize: 14)),
          subtitle: Text(t('Yılbaşı, bayramlar vb. iş günü sayılmaz'), style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.inkLight,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 18, color: AppColors.ink),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t('Tahmini bitiş: {date}', {'date': fullDateFor(estimatedEnd)}),
                  style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalsStep extends StatelessWidget {
  final int dailyWordGoal;
  final bool reminderEnabled;
  final TimeOfDay reminderTime;
  final ValueChanged<int> onWordGoal;
  final ValueChanged<bool> onReminderEnabled;
  final ValueChanged<TimeOfDay> onReminderTime;

  const _GoalsStep({
    required this.dailyWordGoal,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.onWordGoal,
    required this.onReminderEnabled,
    required this.onReminderTime,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t('Hedef ve hatırlatma'),
      subtitle: t('Günlük kelime hedefi ilerleme çubuğunda gösterilir.'),
      children: [
        _FieldLabel(t('Günlük kelime hedefi')),
        Row(
          children: [
            _StepperButton(icon: Icons.remove, onTap: () => onWordGoal((dailyWordGoal - 10).clamp(20, 500))),
            Expanded(child: Center(child: Text(t('{n} kelime', {'n': dailyWordGoal}), style: AppTextStyles.head(fontSize: 18)))),
            _StepperButton(icon: Icons.add, onTap: () => onWordGoal((dailyWordGoal + 10).clamp(20, 500))),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: reminderEnabled,
          onChanged: onReminderEnabled,
          activeThumbColor: AppColors.ink,
          title: Text(t('Günlük hatırlatıcı'), style: AppTextStyles.body(fontSize: 14)),
          subtitle: Text(t('Bugünü doldurmayı unutma bildirimi'), style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
        ),
        if (reminderEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          _DatePickerTile(
            label: reminderTime.format(context),
            icon: Icons.notifications_outlined,
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: reminderTime);
              if (picked != null) onReminderTime(picked);
            },
          ),
        ],
      ],
    );
  }
}

class _CapsuleStep extends StatelessWidget {
  final TextEditingController expectationCtrl;
  final TextEditingController fearCtrl;
  const _CapsuleStep({required this.expectationCtrl, required this.fearCtrl});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: t('Zaman Kapsülü'),
      subtitle: t('Bu iki cevap staj bitene kadar kilitli kalır. Sonra ne olduğunu yanına yazarsın.'),
      children: [
        _FieldLabel(t('Bu stajdan ne bekliyorsun?')),
        _TextInput(controller: expectationCtrl, hint: t('Serbest yaz...'), maxLines: 3),
        const SizedBox(height: AppSpacing.lg),
        _FieldLabel(t('Neyden korkuyorsun?')),
        _TextInput(controller: fearCtrl, hint: t('Serbest yaz...'), maxLines: 3),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: AppColors.textMuted)),
      );
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _TextInput({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.body(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(fontSize: 14, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.sunkenBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide(color: AppColors.ink, width: 1.5)),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? date;
  final String? label;
  final IconData icon;
  final VoidCallback onTap;
  const _DatePickerTile({this.date, this.label, this.icon = Icons.event_outlined, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = label ?? fullDateFor(date!);
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.ink),
            const SizedBox(width: AppSpacing.sm),
            Text(text, style: AppTextStyles.body(fontSize: 14, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: AppColors.sunkenBg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DayChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.standard),
        curve: AppMotion.standardCurve,
        width: 48,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label, style: AppTextStyles.body(fontSize: 13, weight: FontWeight.w600, color: selected ? AppColors.onInk : AppColors.textMuted)),
      ),
    );
  }
}
