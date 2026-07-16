class Candle {
  const Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  factory Candle.fromBinance(List<dynamic> row) {
    return Candle(
      openTime: DateTime.fromMillisecondsSinceEpoch(row[0] as int, isUtc: true),
      open: double.parse(row[1].toString()),
      high: double.parse(row[2].toString()),
      low: double.parse(row[3].toString()),
      close: double.parse(row[4].toString()),
      volume: double.parse(row[5].toString()),
    );
  }

  bool get isBull => close >= open;
}

class MacdPoint {
  const MacdPoint({
    required this.time,
    this.macd,
    this.signal,
    this.histogram,
  });

  final DateTime time;
  final double? macd;
  final double? signal;
  final double? histogram;
}

enum ChartMarkerKind { buyEntry, sellExit, buySignal, sellSignal }

class ChartMarker {
  const ChartMarker({
    required this.time,
    required this.price,
    required this.kind,
    this.label,
  });

  final DateTime time;
  final double price;
  final ChartMarkerKind kind;
  final String? label;

  bool get isBuy =>
      kind == ChartMarkerKind.buyEntry || kind == ChartMarkerKind.buySignal;
}
