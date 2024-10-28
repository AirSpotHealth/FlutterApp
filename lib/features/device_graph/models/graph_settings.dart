class GraphSettings {
  final bool showZoomSlider;
  final bool showAreaFill;
  final bool showMarkLines;

  GraphSettings({
    required this.showZoomSlider,
    required this.showAreaFill,
    required this.showMarkLines,
  });

  factory GraphSettings.defaults() {
    return GraphSettings(
      showZoomSlider: false,
      showAreaFill: false,
      showMarkLines: false,
    );
  }

  GraphSettings copyWith({
    bool? showZoomSlider,
    bool? showAreaFill,
    bool? showMarkLines,
  }) {
    return GraphSettings(
      showZoomSlider: showZoomSlider ?? this.showZoomSlider,
      showAreaFill: showAreaFill ?? this.showAreaFill,
      showMarkLines: showMarkLines ?? this.showMarkLines,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GraphSettings &&
        other.showZoomSlider == showZoomSlider &&
        other.showAreaFill == showAreaFill &&
        other.showMarkLines == showMarkLines;
  }

  @override
  int get hashCode {
    return showZoomSlider.hashCode ^
        showAreaFill.hashCode ^
        showMarkLines.hashCode;
  }

  @override
  String toString() =>
      'GraphSettings(showZoomSlider: $showZoomSlider, showAreaFill: $showAreaFill, showMarkLines: $showMarkLines)';
}
