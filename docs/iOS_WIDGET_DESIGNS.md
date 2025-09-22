# iOS Widget Designs - Text-Based Layouts

## 📱 Small Widget (2x2) - Vertical Layout

```
┌─────────────────────────┐
│  📶 🔋85% 🔔 ⏱️ 📳     │  ← Status icons (top right)
│                         │
│                         │
│         450             │  ← Large CO2 value (center)
│       CO₂ ppm           │  ← CO2 label
│                         │
│    AirSpot Device       │  ← Device name
│      at 12:15 PM       │  ← Last updated time
│                         │
└─────────────────────────┘
```

**Key Features:**

- **Status Icons**: Bluetooth, Battery%, Alarm, Timer, Vibration (top right)
- **CO2 Value**: Large, bold, color-coded (green/yellow/red)
- **Device Info**: Name and timestamp at bottom
- **Vertical Centering**: CO2 value is the main focus
- **No Graph**: Too small for graph

---

## 📱 Medium Widget (4x2) - Two-Row Layout

```
┌─────────────────────────────────────────────────────────┐
│ AirSpot Device   450 CO₂ ppm    🔋85% 🔔               │  ← Row 1: Device info + CO2 + Icons
│ at 12:15 PM              ⏱️3Min 📳                     │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │  ← Row 2: CO2 Graph
│ │                CO₂ History Graph                    │ │
│ │     📈 Line chart with color zones                 │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

**Key Features:**

- **Row 1**: Device name/time, CO2 value, 2x2 icon grid (Battery+Alarm, Timer+Vibration)
- **Row 2**: CO2 history graph (70px height)
- **Reusable Content**: Uses `WidgetContentView` component
- **Icon Grid**: 2x2 layout for status indicators

---

## 📱 Large Widget (4x4) - Three-Section Layout

```
┌─────────────────────────────────────────────────────────┐
│ AirSpot Device   450 CO₂ ppm    🔋85% 🔔               │  ← Section 1: Device info + CO2 + Icons
│ at 12:15 PM              ⏱️3Min 📳                     │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │  ← Section 2: CO2 Graph
│ │                CO₂ History Graph                    │ │
│ │     📈 Line chart with color zones (76px height)   │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│     🥧 Pie Chart    │    75% green zone air            │  ← Section 3: Zone Analysis
│                     │    environment today             │
└─────────────────────────────────────────────────────────┘
```

**Key Features:**

- **Section 1**: Same as medium widget (device info + CO2 + icons)
- **Section 2**: CO2 history graph (76px height)
- **Section 3**: Zone analysis with pie chart (left) and summary text (right)
- **Pie Chart**: 100px size, shows green/yellow/red zone percentages
- **Summary Text**: "X% [color] zone air environment today"

---

## 🎨 Design Specifications

### **Colors:**

- **Background**: Black with 0.8 opacity
- **CO2 Values**: Green (≤800), Yellow (801-1000), Red (>1000)
- **Battery**: Green (charging), White (>25%), Yellow (10-25%), Red (<10%)
- **Icons**: Blue (enabled), Gray (disabled)

### **Typography:**

- **CO2 Value**: Bold, large (32px small, 24px medium, 28px large)
- **Labels**: Medium weight, smaller sizes
- **Device Name**: Gray color
- **Time**: Gray, smaller

### **Layout Principles:**

- **Small**: Vertical, CO2-focused
- **Medium**: Two rows, graph included
- **Large**: Three sections, full analysis
- **Consistent**: Same top section across medium/large
- **Responsive**: Different font sizes per widget size

### **Icon Grid Layout (Medium/Large):**

```
Row 1: [Battery + %] [Alarm Icon]
Row 2: [Timer + Mode] [Vibration Icon]
```

### **Zone Analysis (Large Only):**

```
Left Half:  🥧 Pie Chart (100px)
Right Half: "75% green zone air environment today"
```

---

## 📋 Implementation Notes

### **iOS Widget Structure:**

- **SmallWidgetView**: Vertical layout, status icons top-right
- **MediumWidgetView**: Two-row layout with graph
- **LargeWidgetView**: Three-section layout with zone analysis
- **WidgetContentView**: Reusable component for top section

### **Android Widget Requirements:**

- Match exact layouts and styling
- Use same color scheme and typography
- Implement proper icon grid alignment
- Create CO2 graph drawing functionality
- Add pie chart for zone analysis (large widget)

### **Data Flow:**

- Widgets receive data via `LiveActivityModel`
- Zone percentages calculated in Flutter
- Real-time updates every 5 minutes
- Fallback to "No Device Connected" state
