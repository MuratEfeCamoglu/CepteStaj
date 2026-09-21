import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/backup_service.dart';
import '../../core/pdf_export.dart';
import '../../data/app_state.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/responsive_content.dart';
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
              child: Text('Ayarlar', style: AppTextStyles.disp(fontSize: 26)),
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
                _SettingsSection(title: 'Staj', children: [
                  _SettingsTile(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Staj Wrapped\'ı gör',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WrappedScreen())),
                  ),
                  _SettingsTile(
                    icon: Icons.event_outlined,
                    label: 'Staj tarihleri',
                    trailing: i != null ? '${i.totalWorkdays} gün' : null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen(startAtStep: 1)),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.flag_outlined,
                    label: 'Günlük kelime hedefi',
                    trailing: i != null ? '${i.dailyWordGoal} kelime' : null,
                    onTap: () => _editWordGoal(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: 'Görünüm', children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Tema',
                    trailing: state.isDarkTheme ? 'Koyu' : 'Açık',
                    onTap: () => state.setDarkTheme(!state.isDarkTheme),
                  ),
                  _SettingsTile(
                    icon: Icons.text_fields_outlined,
                    label: 'Yazı boyutu',
                    trailing: _scaleLabel(state.textScale),
                    onTap: () => _cycleTextScale(state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: 'Bildirimler', children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: 'Günlük hatırlatıcı',
                    trailing: i?.reminderEnabled == true
                        ? '${i!.reminderHour.toString().padLeft(2, '0')}:${i.reminderMinute.toString().padLeft(2, '0')}'
                        : 'Kapalı',
                    onTap: () => _editReminder(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: 'Gizlilik', children: [
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    label: 'Günlüğüm PIN kilidi',
                    trailing: state.hasPinLock ? 'Açık' : 'Kapalı',
                    onTap: () => _togglePin(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: 'Veri', children: [
                  _SettingsTile(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Resmi Defter PDF',
                    onTap: () => _exportPdf(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.ios_share_outlined,
                    label: 'Yedekle (dışa aktar)',
                    onTap: () => _backup(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.settings_backup_restore_outlined,
                    label: 'Yedekten geri yükle',
                    onTap: () => _restore(context, state),
                  ),
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    label: 'Tüm verileri sıfırla',
                    color: AppColors.warning,
                    onTap: () => _confirmReset(context, state),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),
                _SettingsSection(title: 'Hakkında', children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    label: 'CepteStaj hakkında',
                    trailing: 'v1.0.0',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'Cepte Staj',
                      applicationVersion: 'v1.0.0',
                      applicationLegalese: 'Verilerin yalnızca telefonunda tutulur. Günlüğüm asla Resmi Defter PDF\'ine girmez.',
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
    if (v <= 0.95) return 'Küçük';
    if (v >= 1.1) return 'Büyük';
    return 'Normal';
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
        title: const Text('Günlük kelime hedefi'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v > 0) {
                state.updateInternship((i) => i.dailyWordGoal = v);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Kaydet'),
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
          title: const Text('Günlük hatırlatıcı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                onChanged: (v) => setDialogState(() => enabled = v),
                title: const Text('Açık'),
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
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Kaydet')),
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
      final pin = await showPinDialog(context, title: 'Kilidi kaldırmak için PIN gir');
      if (pin == null) return;
      if (state.unlockPersonal(pin)) {
        state.removePin();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yanlış PIN')));
      }
    } else {
      final pin = await showPinDialog(context, title: 'Yeni PIN belirle');
      if (pin == null || pin.isEmpty) return;
      if (!context.mounted) return;
      final confirm = await showPinDialog(context, title: 'PIN\'i tekrar gir');
      if (confirm != pin) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN\'ler eşleşmedi')));
        }
        return;
      }
      state.setPin(pin);
    }
  }

  void _exportPdf(BuildContext context, AppState state) async {
    final i = state.internship;
    if (i == null) return;
    try {
      await PdfExportService.shareOfficialNotebookPdf(internship: i, entries: state.allEntries, photos: state.photos);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF oluşturulamadı')));
      }
    }
  }

  void _backup(BuildContext context, AppState state) async {
    try {
      await BackupService.exportAndShare(state.toBackupJson());
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedekleme başarısız oldu')));
      }
    }
  }

  void _restore(BuildContext context, AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yedekten geri yükle'),
        content: const Text('Bu işlem mevcut tüm verilerin yerine seçtiğin yedeği yükler. Devam edilsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Vazgeç')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Devam et')),
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
          SnackBar(content: Text(ok ? 'Yedek geri yüklendi' : 'Yedek dosyası okunamadı')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yedek dosyası okunamadı')));
      }
    }
  }

  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tüm verileri sıfırla'),
        content: const Text('Tüm staj verilerin (defter, günlük, fotoğraflar, ayarlar) kalıcı olarak silinir. Emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Vazgeç')),
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
            child: Text('Sil', style: TextStyle(color: AppColors.warning)),
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
          child: Text(title.toUpperCase(),
              style: AppTextStyles.body(fontSize: 11, weight: FontWeight.w600, color: AppColors.textFaint)
                  .copyWith(letterSpacing: 0.6)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg, color: AppColors.border),
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.body(fontSize: 14, color: AppColors.textPrimary))),
            if (trailing != null)
              Text(trailing!, style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted)),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 18, color: AppColors.textFaint),
            ],
          ],
        ),
      ),
    );
  }
}
