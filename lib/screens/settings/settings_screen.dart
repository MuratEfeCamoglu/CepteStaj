import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n.dart';
import '../../core/tr_text.dart';
import '../../core/app_info.dart';
import '../../core/backup_service.dart';
import '../../data/app_state.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/export_sheet.dart';
import '../../widgets/motion.dart';
import '../../widgets/responsive_content.dart';
import '../../core/snippets.dart';
import '../day_detail/day_detail_screen.dart' show showFieldPicker;
import '../lock/pin_lock_screen.dart';
import '../wrapped/wrapped_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final i = state.internship;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveContent(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: SizedBox(
                width: double.infinity,
                child: Text(t('Ayarlar'), style: AppTextStyles.disp(fontSize: 30)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                ResponsiveContent(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(children: [
                _SettingsSection(title: t('Staj'), children: [
                  _SettingsTile(
                    icon: Icons.auto_awesome_outlined,
                    color: AppColors.violet,
                    label: t('Staj Wrapped\'ı gör'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WrappedScreen())),
                  ),
                  _SettingsTile(
                    icon: Icons.event_outlined,
                    label: t('Staj tarihleri'),
                    trailing: i != null ? t('{n} gün', {'n': i.totalWorkdays}) : null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen(startAtStep: 1)),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.work_outline_rounded,
                    label: t('Staj alanın'),
                    trailing: i != null ? t(fieldFor(i.field).label) : null,
                    onTap: () => showFieldPicker(context),
                  ),
                  _SettingsTile(
                    icon: Icons.flag_outlined,
                    label: t('Günlük kelime hedefi'),
                    trailing: i != null ? t('{n} kelime', {'n': i.dailyWordGoal}) : null,
                    onTap: () => _editWordGoal(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: t('Görünüm'), children: [
                  _SettingsTile(
                    icon: state.isDarkTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    color: AppColors.sky,
                    label: t('Tema'),
                    trailing: _themeLabel(state.themeMode),
                    onTap: () => _pickTheme(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    color: AppColors.sky,
                    label: t('Dil'),
                    trailing: state.language == 'en' ? 'English' : 'Türkçe',
                    onTap: () => _pickLanguage(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.text_fields_outlined,
                    color: AppColors.sky,
                    label: t('Yazı boyutu'),
                    trailing: _scaleLabel(state.textScale),
                    onTap: () => _cycleTextScale(state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: t('Bildirimler'), children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    color: AppColors.amber,
                    label: t('Günlük hatırlatıcı'),
                    trailing: i?.reminderEnabled == true
                        ? '${i!.reminderHour.toString().padLeft(2, '0')}:${i.reminderMinute.toString().padLeft(2, '0')}'
                        : t('Kapalı'),
                    onTap: () => _editReminder(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: t('Gizlilik'), children: [
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    color: AppColors.coral,
                    label: t('Günlüğüm PIN kilidi'),
                    trailing: state.hasPinLock ? t('Açık') : t('Kapalı'),
                    onTap: () => _togglePin(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: t('Veri'), children: [
                  _SettingsTile(
                    icon: Icons.picture_as_pdf_outlined,
                    label: t('Resmi Defter (PDF / Word)'),
                    onTap: () => showExportSheet(context),
                  ),
                  _SettingsTile(
                    icon: Icons.ios_share_outlined,
                    label: t('Yedekle (dışa aktar)'),
                    onTap: () => _backup(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.settings_backup_restore_outlined,
                    label: t('Yedekten geri yükle'),
                    onTap: () => _restore(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    label: t('Tüm verileri sıfırla'),
                    color: AppColors.danger,
                    onTap: () => _confirmReset(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: t('Hakkında'), children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    color: AppColors.textMuted,
                    label: t('Cepte Staj hakkında'),
                    trailing: 'v${AppInfo.version}',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: t('Cepte Staj'),
                      applicationVersion: 'v${AppInfo.version}',
                      applicationLegalese: t('Verilerin yalnızca telefonunda tutulur. Günlüğüm asla Resmi Defter PDF\'ine girmez. Spotify\'dan bir şarkı paylaştığında yalnızca o şarkının bağlantısı, adını öğrenmek için Spotify\'a gönderilir.'),
                    ),
                  ),
                ]),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _scaleLabel(double v) {
    if (v <= 0.95) return t('Küçük');
    if (v >= 1.1) return t('Büyük');
    return t('Normal');
  }

  String _themeLabel(String mode) => switch (mode) {
        'light' => t('Açık'),
        'dark' => t('Koyu'),
        _ => t('Sistem'),
      };

  void _pickTheme(BuildContext context, AppState state) {
    _showChoiceSheet(
      context,
      title: t('Tema'),
      selected: state.themeMode,
      options: [
        ('system', Icons.brightness_auto_outlined, t('Sistem'), t('Telefonun ayarını takip eder')),
        ('light', Icons.light_mode_outlined, t('Açık'), null),
        ('dark', Icons.dark_mode_outlined, t('Koyu'), null),
      ],
      onSelected: state.setThemeMode,
    );
  }

  void _pickLanguage(BuildContext context, AppState state) {
    _showChoiceSheet(
      context,
      title: t('Dil'),
      selected: state.language,
      options: const [
        ('tr', Icons.language_rounded, 'Türkçe', null),
        ('en', Icons.language_rounded, 'English', null),
      ],
      onSelected: state.setLanguage,
    );
  }

  void _showChoiceSheet(
    BuildContext context, {
    required String title,
    required String selected,
    required List<(String, IconData, String, String?)> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.head(fontSize: 18)),
              const SizedBox(height: AppSpacing.md),
              for (final (value, icon, label, hint) in options)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ChoiceTile(
                    icon: icon,
                    label: label,
                    hint: hint,
                    selected: value == selected,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      if (value != selected) onSelected(value);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _cycleTextScale(AppState state) {
    const steps = [0.9, 1.0, 1.15];
    final idx = steps.indexWhere((s) => (s - state.textScale).abs() < 0.01);
    final next = steps[(idx + 1) % steps.length];
    state.setTextScale(next);
  }

  void _editWordGoal(BuildContext context, AppState state) {
    final ctrl = TextEditingController(text: '${state.internship?.dailyWordGoal ?? 120}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Günlük kelime hedefi')),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v > 0) {
                state.updateInternship((i) => i.dailyWordGoal = v);
              }
              Navigator.of(ctx).pop();
            },
            child: Text(t('Kaydet')),
          ),
        ],
      ),
    );
  }

  void _editReminder(BuildContext context, AppState state) async {
    final i = state.internship;
    if (i == null) return;
    var enabled = i.reminderEnabled;
    var time = TimeOfDay(hour: i.reminderHour, minute: i.reminderMinute);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(t('Günlük hatırlatıcı')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                onChanged: (v) => setDialogState(() => enabled = v),
                title: Text(t('Açık')),
              ),
              if (enabled)
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: time);
                    if (picked != null) setDialogState(() => time = picked);
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(time.format(ctx)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(t('Vazgeç'))),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(t('Kaydet'))),
          ],
        ),
      ),
    );
    if (result != true) return;
    state.updateInternship((i) {
      i.reminderEnabled = enabled;
      i.reminderHour = time.hour;
      i.reminderMinute = time.minute;
    });
  }

  void _togglePin(BuildContext context, AppState state) async {
    if (state.hasPinLock) {
      final pin = await showPinDialog(context, title: t('Kilidi kaldırmak için PIN gir'));
      if (pin == null) return;
      if (state.unlockPersonal(pin)) {
        state.removePin();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Yanlış PIN'))));
      }
    } else {
      final pin = await showPinDialog(context, title: t('Yeni PIN belirle'));
      if (pin == null || pin.isEmpty) return;
      if (!context.mounted) return;
      final confirm = await showPinDialog(context, title: t('PIN\'i tekrar gir'));
      if (confirm != pin) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('PIN\'ler eşleşmedi'))));
        }
        return;
      }
      state.setPin(pin);
    }
  }

  void _backup(BuildContext context, AppState state) async {
    try {
      await BackupService.exportAndShare(state.toBackupJson());
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Yedekleme başarısız oldu'))));
      }
    }
  }

  void _restore(BuildContext context, AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Yedekten geri yükle')),
        content: Text(t('Bu işlem mevcut tüm verilerin yerine seçtiğin yedeği yükler. Devam edilsin mi?')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(t('Vazgeç'))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(t('Devam et'))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final json = await BackupService.pickAndReadBackup();
      if (json == null) return;
      final ok = await state.restoreFromBackupJson(json);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? t('Yedek geri yüklendi') : t('Yedek dosyası okunamadı'))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Yedek dosyası okunamadı'))));
      }
    }
  }

  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('Tüm verileri sıfırla')),
        content: Text(t('Tüm staj verilerin (defter, günlük, fotoğraflar, ayarlar) kalıcı olarak silinir. Emin misin?')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(t('Vazgeç'))),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final navigator = Navigator.of(context, rootNavigator: true);
              await state.resetAllData();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            child: Text(t('Sil'), style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperTr(), style: AppTextStyles.label()),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.cardLarge),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 64, endIndent: AppSpacing.lg, color: AppColors.border),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? color;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.ink;
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.sunkenBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        child: Row(
          children: [
            // Icon on a tinted rounded square — gives each row a quick
            // visual anchor, the way modern settings lists do.
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tint(accent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(
                  fontSize: 15,
                  weight: FontWeight.w500,
                  color: color == AppColors.danger ? color : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  trailing!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textFaint),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? hint;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.standard),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkLight : AppColors.sunkenBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: selected ? AppColors.ink : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.ink : AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body(fontSize: 15, weight: FontWeight.w600)),
                  if (hint != null)
                    Text(hint!, style: AppTextStyles.body(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}
