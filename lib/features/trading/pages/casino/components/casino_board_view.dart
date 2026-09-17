import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/casino_symbol_assets.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme_controller.dart';
import '../../../models/casino_model.dart';
import 'casino_fx.dart';
import 'casino_symbol_icon.dart';

class CasinoBoardView extends StatefulWidget {
  const CasinoBoardView({
    super.key,
    required this.game,
    required this.board,
    this.highlightPositions = const [],
    this.removedPositions = const [],
    this.bonus,
    this.spinning = false,
    this.turbo = false,
    this.miss = false,
  });

  final CasinoGame game;
  final List<List<String>> board;
  final List<List<int>> highlightPositions;
  final List<List<int>> removedPositions;
  final CasinoBonusState? bonus;
  final bool spinning;
  final bool turbo;
  final bool miss;

  @override
  State<CasinoBoardView> createState() => _CasinoBoardViewState();
}

class _CasinoBoardViewState extends State<CasinoBoardView>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _land;
  late final AnimationController _glow;
  late final AnimationController _win;
  late final AnimationController _shake;
  int _dropGen = 0;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.turbo ? 160 : 280),
    );
    _land = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.turbo ? 520 : 1180),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _win = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.spinning) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant CasinoBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final spinMs = widget.turbo ? 160 : 280;
    final landMs = widget.turbo ? 520 : 1180;
    if (_spin.duration?.inMilliseconds != spinMs) {
      _spin.duration = Duration(milliseconds: spinMs);
    }
    if (_land.duration?.inMilliseconds != landMs) {
      _land.duration = Duration(milliseconds: landMs);
    }

    if (widget.spinning && !oldWidget.spinning) {
      _land.stop();
      _land.reset();
      _win.stop();
      _win.reset();
      _spin.repeat();
    } else if (!widget.spinning && oldWidget.spinning) {
      _spin.stop();
      _land.forward(from: 0);
    }

    if (widget.highlightPositions.isNotEmpty &&
        oldWidget.highlightPositions.isEmpty) {
      _win.repeat(reverse: true);
    } else if (widget.highlightPositions.isEmpty &&
        oldWidget.highlightPositions.isNotEmpty) {
      _win.stop();
      _win.reset();
    }

    if (widget.miss && !oldWidget.miss) {
      _shake.forward(from: 0);
    }

    if (!widget.spinning &&
        !oldWidget.spinning &&
        !_sameBoard(oldWidget.board, widget.board)) {
      _dropGen++;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _land.dispose();
    _glow.dispose();
    _win.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    final rows =
        widget.board.isEmpty ? widget.game.boardRows : widget.board.length;
    final cols =
        widget.board.isEmpty
            ? widget.game.boardCols
            : (widget.board.first.isEmpty
                ? widget.game.boardCols
                : widget.board.first.length);

    final highlight = {
      for (final pos in widget.highlightPositions) '${pos[0]}:${pos[1]}',
    };
    final removed = {
      for (final pos in widget.removedPositions) '${pos[0]}:${pos[1]}',
    };

    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _land, _glow, _win, _shake]),
      builder: (context, _) {
        final shakeX =
            math.sin(_shake.value * math.pi * 8) * (1 - _shake.value) * 10;
        return Transform.translate(
          offset: Offset(shakeX, 0),
          child: AspectRatio(
            aspectRatio: cols / rows,
            child: CasinoMachineFrame(
              palette: p,
              pulse: _glow.value,
              spinning: widget.spinning,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final origins = <Offset>[];
                  for (final pos in widget.highlightPositions) {
                    if (pos.length < 2) continue;
                    origins.add(
                      Offset(
                        (pos[1] + 0.5) * constraints.maxWidth / cols,
                        (pos[0] + 0.5) * constraints.maxHeight / rows,
                      ),
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: List.generate(cols, (c) {
                            return Expanded(
                              child: RepaintBoundary(
                                child: _ReelColumn(
                                  column: c,
                                  columns: cols,
                                  rows: rows,
                                  board: widget.board,
                                  palette: p,
                                  spinning: widget.spinning,
                                  spinT: _spin.value,
                                  landT: _land.value,
                                  winT: _win.value,
                                  dropGen: _dropGen,
                                  highlight: highlight,
                                  removed: removed,
                                  bonus: widget.bonus,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const Positioned.fill(child: _ReelWindowShade()),
                      if (widget.highlightPositions.length >= 2)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: CasinoPaylinePainter(
                                positions: widget.highlightPositions,
                                rows: rows,
                                cols: cols,
                                color: const Color(0xFFFFE082),
                                pulse: _win.value,
                              ),
                            ),
                          ),
                        ),
                      if (widget.highlightPositions.isNotEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: CasinoSparklePainter(
                                t: _win.value,
                                color: const Color(0xFFFFE082),
                                origins: origins,
                              ),
                            ),
                          ),
                        ),
                      if (widget.spinning)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(19),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.04),
                                  ],
                                  stops: const [0, 0.5, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool _sameBoard(List<List<String>> a, List<List<String>> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var r = 0; r < a.length; r++) {
      if (a[r].length != b[r].length) return false;
      for (var c = 0; c < a[r].length; c++) {
        if (a[r][c] != b[r][c]) return false;
      }
    }
    return true;
  }
}

class _ReelWindowShade extends StatelessWidget {
  const _ReelWindowShade();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.42),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.5),
            ],
            stops: const [0, 0.18, 0.82, 1],
          ),
        ),
      ),
    );
  }
}

class _ReelColumn extends StatelessWidget {
  const _ReelColumn({
    required this.column,
    required this.columns,
    required this.rows,
    required this.board,
    required this.palette,
    required this.spinning,
    required this.spinT,
    required this.landT,
    required this.winT,
    required this.dropGen,
    required this.highlight,
    required this.removed,
    required this.bonus,
  });

  final int column;
  final int columns;
  final int rows;
  final List<List<String>> board;
  final AppPalette palette;
  final bool spinning;
  final double spinT;
  final double landT;
  final double winT;
  final int dropGen;
  final Set<String> highlight;
  final Set<String> removed;
  final CasinoBonusState? bonus;

  @override
  Widget build(BuildContext context) {
    final stagger = columns <= 1 ? 0.0 : column / (columns - 1) * 0.48;
    final local = spinning ? 0.0 : ((landT - stagger) / 0.52).clamp(0.0, 1.0);
    final land = Curves.elasticOut.transform(local);
    final stillSpinning = spinning || local <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              stillSpinning
                  ? _ColumnSpinStrip(
                    column: column,
                    rows: rows,
                    spinT: spinT,
                    palette: palette,
                  )
                  : Column(
                    children: List.generate(rows, (r) {
                      final raw =
                          (r < board.length && column < board[r].length)
                              ? board[r][column]
                              : '';
                      final key = '$r:$column';
                      return Expanded(
                        child: _ReelCell(
                          row: r,
                          column: column,
                          symbol: raw,
                          palette: palette,
                          land: land,
                          winT: winT,
                          dropGen: dropGen,
                          hit: highlight.contains(key),
                          isRemoved: removed.contains(key),
                          locked:
                              bonus?.lockedCoins.any(
                                (coin) => coin.row == r && coin.col == column,
                              ) ??
                              false,
                        ),
                      );
                    }),
                  ),
        ),
      ),
    );
  }
}

class _ColumnSpinStrip extends StatelessWidget {
  const _ColumnSpinStrip({
    required this.column,
    required this.rows,
    required this.spinT,
    required this.palette,
  });

  final int column;
  final int rows;
  final double spinT;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final cycle = CasinoSymbolAssets.spinCycle;
    final phase = (spinT + column * 0.13) % 1.0;
    final shifted = phase * cycle.length;
    final base = shifted.floor();
    final frac = shifted - base;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellH = constraints.maxHeight / rows;
        return ClipRect(
          child: Transform.translate(
            offset: Offset(0, -frac * cellH),
            child: OverflowBox(
              maxHeight: cellH * (rows + 1),
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: cellH * (rows + 1),
                child: Column(
                  children: List.generate(rows + 1, (i) {
                    final symbol = cycle[(base + i) % cycle.length];
                    return SizedBox(
                      height: cellH,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _tileBg(
                                  symbol,
                                  palette,
                                ).withValues(alpha: 0.28),
                                const Color(0xFF120C08),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: CasinoSymbolIcon(
                            symbol: symbol,
                            palette: palette,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReelCell extends StatelessWidget {
  const _ReelCell({
    required this.row,
    required this.column,
    required this.symbol,
    required this.palette,
    required this.land,
    required this.winT,
    required this.dropGen,
    required this.hit,
    required this.isRemoved,
    required this.locked,
  });

  final int row;
  final int column;
  final String symbol;
  final AppPalette palette;
  final double land;
  final double winT;
  final int dropGen;
  final bool hit;
  final bool isRemoved;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final cellIdle = !_isRealSymbol(symbol);
    final accent =
        hit
            ? const Color(0xFFFFE082)
            : locked
            ? palette.success
            : _tileBg(symbol, palette);
    final glow = hit ? 0.55 + 0.45 * winT : (locked ? 0.35 : 0.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient:
            cellIdle
                ? null
                : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: hit ? 0.55 : 0.28),
                    const Color(0xFF120C08),
                  ],
                ),
        color:
            isRemoved
                ? palette.danger.withValues(alpha: 0.16)
                : (cellIdle ? palette.card : null),
        border: Border.all(
          color:
              hit
                  ? const Color(0xFFFFE082)
                  : locked
                  ? palette.success
                  : Colors.white.withValues(alpha: 0.06),
          width: hit || locked ? 1.8 : 1,
        ),
        boxShadow:
            glow > 0
                ? [
                  BoxShadow(
                    color: accent.withValues(alpha: glow),
                    blurRadius: 14,
                  ),
                ]
                : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: AnimatedScale(
          scale: isRemoved ? 0.12 : (hit ? 1 + 0.07 * winT : 1),
          duration: const Duration(milliseconds: 280),
          curve: isRemoved ? Curves.easeInBack : Curves.easeOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isRemoved ? 0 : 1,
            child: Transform.translate(
              offset: Offset(0, (1 - land) * 22),
              child: Transform.scale(
                scale: 0.86 + 0.14 * land,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('$dropGen-$row-$column-$symbol'),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(
                      milliseconds: 380 + row * 55 + column * 30,
                    ),
                    curve: Curves.easeOutBack,
                    builder: (context, t, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - t) * -28),
                        child: child,
                      );
                    },
                    child: CasinoSymbolIcon(
                      symbol: symbol,
                      palette: palette,
                      idle: cellIdle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isRealSymbol(String cell) {
  final s = cell.trim().toUpperCase();
  return s.isNotEmpty && s != '·' && s != '.' && s != 'EMPTY';
}

Color _tileBg(String symbol, AppPalette p) {
  final s = symbol.trim().toUpperCase();
  return switch (s) {
    'WILD' => const Color(0xFFC84DFF),
    'BAR' || 'BABLO' => const Color(0xFFE0A020),
    'SEVEN' || 'CHERRY' => const Color(0xFFC4182C),
    'DIAMOND' => const Color(0xFF3AA0FF),
    'COIN' => const Color(0xFFD4A017),
    'RSV_COIN' => const Color(0xFF1E8A3A),
    _ => p.primary,
  };
}

class CasinoBonusOverlay extends StatelessWidget {
  const CasinoBonusOverlay({super.key, required this.bonus});

  final CasinoBonusState bonus;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ThemeController>().palette;
    if (!bonus.active) return const SizedBox.shrink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE0A020).withValues(alpha: 0.22),
              p.primary.withValues(alpha: 0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE0A020).withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0A020).withValues(alpha: 0.28),
              blurRadius: 16,
            ),
          ],
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
      children:
          steps.map((step) {
            final selected = step.toDouble() == bet;
            return AnimatedScale(
              scale: selected ? 1.06 : 1,
              duration: const Duration(milliseconds: 180),
              child: ChoiceChip(
                label: Text(step.toString()),
                selected: selected,
                onSelected: !enabled ? null : (_) => onChanged(step.toDouble()),
                selectedColor: p.primary.withValues(alpha: 0.25),
              ),
            );
          }).toList(),
    );
  }
}
