import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/casino_model.dart';
import 'casino_symbol_icon.dart';

class CasinoBoardView extends StatelessWidget {
  const CasinoBoardView({
    super.key,
    required this.game,
    required this.board,
    this.highlightPositions = const [],
    this.removedPositions = const [],
    this.bonus,
    this.spinning = false,
  });

  final CasinoGame game;
  final List<List<String>> board;
  final List<List<int>> highlightPositions;
  final List<List<int>> removedPositions;
  final CasinoBonusState? bonus;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final rows = board.isEmpty ? game.boardRows : board.length;
    final cols = board.isEmpty
        ? game.boardCols
        : (board.first.isEmpty ? game.boardCols : board.first.length);

    final highlight = {
      for (final pos in highlightPositions) '${pos[0]}:${pos[1]}',
    };
    final removed = {
      for (final pos in removedPositions) '${pos[0]}:${pos[1]}',
    };

    final idle = !_hasRealSymbols(board);

    return AspectRatio(
      aspectRatio: cols / rows,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.borderSubtle),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: List.generate(rows, (r) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (c) {
                  final raw = (r < board.length && c < board[r].length)
                      ? board[r][c]
                      : '';
                  final key = '$r:$c';
                  final isHit = highlight.contains(key);
                  final isRemoved = removed.contains(key);
                  final locked = bonus?.lockedCoins.any(
                        (coin) => coin.row == r && coin.col == c,
                      ) ??
                      false;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: idle
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _tileBg(raw, p).withValues(alpha: 0.28),
                                  p.card,
                                ],
                              ),
                        color: isRemoved
                            ? p.danger.withValues(alpha: 0.15)
                            : isHit
                                ? p.primary.withValues(alpha: 0.28)
                                : locked
                                    ? p.success.withValues(alpha: 0.2)
                                    : (idle ? p.card : null),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHit
                              ? p.primary
                              : locked
                                  ? p.success
                                  : p.borderSubtle,
                          width: isHit || locked ? 1.6 : 1,
                        ),
                        boxShadow: spinning && idle
                            ? [
                                BoxShadow(
                                  color: p.primary.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(cols >= 6 ? 6 : 8),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: isRemoved ? 0.2 : 1,
                          child: CasinoSymbolIcon(
                            symbol: raw,
                            palette: p,
                            idle: idle,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  bool _hasRealSymbols(List<List<String>> board) {
    for (final row in board) {
      for (final cell in row) {
        final s = cell.trim().toUpperCase();
        if (s.isNotEmpty && s != '·' && s != '.' && s != 'EMPTY') {
          return true;
        }
      }
    }
    return false;
  }

  Color _tileBg(String symbol, AppPalette p) {
    final s = symbol.trim().toUpperCase();
    return switch (s) {
      'SEVEN' || 'BABLO' || 'WILD' => p.primary,
      'DIAMOND' || 'RSV_COIN' || 'COIN' => p.success,
      'CHERRY' => p.danger,
      'BAR' => p.textMuted,
      _ => p.primary,
    };
  }
}

class CasinoBonusOverlay extends StatelessWidget {
  const CasinoBonusOverlay({super.key, required this.bonus});

  final CasinoBonusState bonus;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    if (!bonus.active) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: p.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bonus · respins ${bonus.remainingRespins} · '
              'coins ${bonus.lockedCoins.length} · '
              'acc ${bonus.accumulated}',
              style: TextStyle(
                color: p.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CasinoBetSelector extends StatelessWidget {
  const CasinoBetSelector({
    super.key,
    required this.steps,
    required this.bet,
    required this.enabled,
    required this.onChanged,
  });

  final List<num> steps;
  final double bet;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: steps.map((step) {
        final selected = step.toDouble() == bet;
        return ChoiceChip(
          label: Text(step.toString()),
          selected: selected,
          onSelected: !enabled ? null : (_) => onChanged(step.toDouble()),
          selectedColor: p.primary.withValues(alpha: 0.25),
        );
      }).toList(),
    );
  }
}
