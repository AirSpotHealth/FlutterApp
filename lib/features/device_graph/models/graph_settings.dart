enum BreathPercentageDisplayMode {
  none,
  percentage,
  oneInX,
  both,
}

class GraphSettings {
  final bool showZoomSlider;
  final bool showAreaFill;
  final bool showMarkLines;
  final BreathPercentageDisplayMode breathPercentageDisplayMode;

  const GraphSettings({
    this.showZoomSlider = false,
    this.showAreaFill = false,
    this.showMarkLines = true,
    this.breathPercentageDisplayMode = BreathPercentageDisplayMode.none,
  });

  // Convenience getter for backward compatibility
  bool get showRebreathePercentage =>
      breathPercentageDisplayMode != BreathPercentageDisplayMode.none;

  factory GraphSettings.defaults() {
    return GraphSettings(
      showZoomSlider: false,
      showAreaFill: true,
      showMarkLines: false,
      breathPercentageDisplayMode: BreathPercentageDisplayMode.none,
    );
  }

  GraphSettings copyWith({
    bool? showZoomSlider,
    bool? showAreaFill,
    bool? showMarkLines,
    BreathPercentageDisplayMode? breathPercentageDisplayMode,
  }) {
    return GraphSettings(
      showZoomSlider: showZoomSlider ?? this.showZoomSlider,
      showAreaFill: showAreaFill ?? this.showAreaFill,
      showMarkLines: showMarkLines ?? this.showMarkLines,
      breathPercentageDisplayMode:
          breathPercentageDisplayMode ?? this.breathPercentageDisplayMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showZoomSlider': showZoomSlider,
      'showAreaFill': showAreaFill,
      'showMarkLines': showMarkLines,
      'breathPercentageDisplayMode': breathPercentageDisplayMode.name,
    };
  }

  factory GraphSettings.fromJson(Map<String, dynamic> json) {
    return GraphSettings(
      showZoomSlider: json['showZoomSlider'] ?? false,
      showAreaFill: json['showAreaFill'] ?? true,
      showMarkLines: json['showMarkLines'] ?? false,
      breathPercentageDisplayMode:
          BreathPercentageDisplayMode.values.firstWhere(
        (e) => e.name == json['breathPercentageDisplayMode'],
        orElse: () => BreathPercentageDisplayMode.none,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GraphSettings &&
        other.showZoomSlider == showZoomSlider &&
        other.showAreaFill == showAreaFill &&
        other.showMarkLines == showMarkLines &&
        other.breathPercentageDisplayMode == breathPercentageDisplayMode;
  }

  @override
  int get hashCode {
    return showZoomSlider.hashCode ^
        showAreaFill.hashCode ^
        showMarkLines.hashCode ^
        breathPercentageDisplayMode.hashCode;
  }

  @override
  String toString() =>
      'GraphSettings(showZoomSlider: $showZoomSlider, showAreaFill: $showAreaFill, showMarkLines: $showMarkLines, breathPercentageDisplayMode: $breathPercentageDisplayMode)';
}
