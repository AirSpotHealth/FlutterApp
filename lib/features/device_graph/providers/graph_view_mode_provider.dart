import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GraphViewMode {
  graph,
  pieChart,
}

/// Provider to manage the current graph view mode (graph vs pie chart)
class GraphViewModeNotifier extends StateNotifier<GraphViewMode> {
  GraphViewModeNotifier() : super(GraphViewMode.graph);

  /// Toggle between graph and pie chart view
  void toggleViewMode() {
    state = state == GraphViewMode.graph
        ? GraphViewMode.pieChart
        : GraphViewMode.graph;
  }

  /// Set the view mode explicitly
  void setViewMode(GraphViewMode mode) {
    state = mode;
  }

  /// Check if currently showing graph
  bool get isGraphMode => state == GraphViewMode.graph;

  /// Check if currently showing pie chart
  bool get isPieChartMode => state == GraphViewMode.pieChart;
}

final graphViewModeProvider =
    StateNotifierProvider<GraphViewModeNotifier, GraphViewMode>(
  (ref) => GraphViewModeNotifier(),
);
