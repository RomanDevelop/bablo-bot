import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Placeholder AI Assistant — no LLM backend yet; keeps floating entry point ready.
class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('AI Assistant')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      'Bablo AI Hub',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Помощник по стратегии Alligator, рискам и статусу бота. '
                  'Чат с бэкендом подключим отдельно — UI-точка уже глобальная.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Suggestion(
            title: 'Почему сейчас HOLD?',
            onTap: () => _soon(context),
          ),
          _Suggestion(
            title: 'Объясни открытую позицию',
            onTap: () => _soon(context),
          ),
          _Suggestion(
            title: 'Риск на сегодня',
            onTap: () => _soon(context),
          ),
        ],
      ),
    );
  }

  static void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI чат — скоро подключим API')),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.elevatedCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
