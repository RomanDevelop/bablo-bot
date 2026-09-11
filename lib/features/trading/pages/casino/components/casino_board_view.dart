import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/theme_controller.dart';
import '../../../models/casino_model.dart';

class CasinoBoardView extends StatelessWidget {
  const CasinoBoardView({
    super.key,
    required this.game,
    required this.board,
    this.highlightPositions = const [],
    this.removedPositions = const [],
    this.bonus,
  });

  final CasinoGame game;
  final List<List<String>> board;
  final List<List<int>> highlightPositions;
  final List<List<int>> removedPositions;
  final CasinoBonusState? bonus;

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

    return AspectRatio(
      aspectRatio: cols / rows,
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.borderSubtle),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: List.generate(rows, (r) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (c) {
                  final symbol = (r < board.length && c < board[r].length)
                      ? board[r][c]
                      : '·';
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
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isRemoved
                            ? p.danger.withValues(alpha: 0.15)
                            : isHit
                                ? p.primary.withValues(alpha: 0.22)
                                : locked
                                    ? p.success.withValues(alpha: 0.18)
                                    : p.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHit
                              ? p.primary
                              : locked
                                  ? p.success
                                  : p.borderSubtle,
                        ),
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: isRemoved ? 0.25 : 1,
                          child: Text(
                            _label(symbol),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: _fontSize(cols),
                              height: 1.05,
                            ),
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

  String _label(String symbol) {
    if (symbol == 'EMPTY' || symbol == '·') return '·';
    if (symbol == 'RSV_COIN') return 'RSV';
    if (symbol.length <= 4) return symbol;
    return symbol.substring(0, 4);
  }

  double _fontSize(int cols) {
    if (cols >= 6) return 10;
    if (cols >= 5) return 11;
    return 12;
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
          onSelected: !enabled
              ? null
              : (_) => onChanged(step.toDouble()),
          selectedColor: p.primary.withValues(alpha: 0.25),
        );
      }).toList(),
    );
  }
}
