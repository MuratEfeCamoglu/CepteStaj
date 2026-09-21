import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

/// Shown in place of the Günlüğüm tab's content when a PIN is set and the
/// tab hasn't been unlocked yet this session. The official side of the app
/// stays fully open — only this private tab is gated.
class PersonalLockView extends StatefulWidget {
  const PersonalLockView({super.key});

  @override
  State<PersonalLockView> createState() => _PersonalLockViewState();
}

class _PersonalLockViewState extends State<PersonalLockView> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<AppState>();
    if (state.unlockPersonal(_ctrl.text)) {
      setState(() => _error = null);
    } else {
      setState(() => _error = 'Yanlış PIN');
      _ctrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 40, color: AppColors.terra),
            const SizedBox(height: AppSpacing.lg),
            Text('Günlüğüm kilitli', style: AppTextStyles.head(fontSize: 18)),
            const SizedBox(height: AppSpacing.sm),
            Text('Devam etmek için PIN gir', style: AppTextStyles.body(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _ctrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 8,
              style: AppTextStyles.head(fontSize: 20),
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                counterText: '',
                errorText: _error,
                filled: true,
                fillColor: AppColors.sunkenBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.card), borderSide: const BorderSide(color: AppColors.terra, width: 1.5)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(label: 'Kilidi aç', color: AppColors.terra, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

/// A small create/verify PIN dialog used from Ayarlar.
Future<String?> showPinDialog(BuildContext context, {required String title}) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 8,
        autofocus: true,
        decoration: const InputDecoration(counterText: ''),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Vazgeç')),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}
