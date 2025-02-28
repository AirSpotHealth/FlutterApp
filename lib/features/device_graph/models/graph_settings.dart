class GraphSettings {
  final bool showZoomSlider;
  final bool showAreaFill;
  final bool showMarkLines;
  final bool showRebreathePercentage;

  GraphSettings({
    required this.showZoomSlider,
    required this.showAreaFill,
    required this.showMarkLines,
    required this.showRebreathePercentage,
  });

  factory GraphSettings.defaults() {
    return GraphSettings(
      showZoomSlider: false,
      showAreaFill: true,
      showMarkLines: false,
      showRebreathePercentage: false,
    );
  }

  GraphSettings copyWith({
    bool? showZoomSlider,
    bool? showAreaFill,
    bool? showMarkLines,
    bool? showRebreathePercentage,
  }) {
    return GraphSettings(
      showZoomSlider: showZoomSlider ?? this.showZoomSlider,
      showAreaFill: showAreaFill ?? this.showAreaFill,
      showMarkLines: showMarkLines ?? this.showMarkLines,
      showRebreathePercentage:
          showRebreathePercentage ?? this.showRebreathePercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GraphSettings &&
        other.showZoomSlider == showZoomSlider &&
        other.showAreaFill == showAreaFill &&
        other.showMarkLines == showMarkLines &&
        other.showRebreathePercentage == showRebreathePercentage;
  }

  @override
  int get hashCode {
    return showZoomSlider.hashCode ^
        showAreaFill.hashCode ^
        showMarkLines.hashCode ^
        showRebreathePercentage.hashCode;
  }

  @override
  String toString() =>
      'GraphSettings(showZoomSlider: $showZoomSlider, showAreaFill: $showAreaFill, showMarkLines: $showMarkLines, showRebreathePercentage: $showRebreathePercentage)';
}
