# Zenit — Reimagined Productivity

<div align="center">

**A productivity app that feels illegal to use.**

Dark glassmorphism • Micro-animations • Focus Timer • Smart Tasks • Mood Tracking

[Download](#installation) • [Features](#features) • [Architecture](#architecture)

</div>

---

## ✨ Design Philosophy

Zenit breaks away from the boring, cluttered productivity apps you're tired of. Inspired by the minimalist aesthetic of viral "cool iPhone apps" on Instagram and TikTok, Zenit combines:

- **Dark Glassmorphism UI** — Frosted glass cards that float on a pitch-black canvas
- **Buttery 120Hz Micro-animations** — Spring physics on every interaction  
- **SF Pro Display Typography** — Precise font weights (Semibold 600, Medium 500) for visual hierarchy
- **Intentional White Space** — Breathing room between every element
- **Custom Gradients** — Subtle CMYK blue accent (#6CAFF7) that pops without screaming

---

## 🎯 Features

### 🏠 **Home Dashboard**
Your productivity command center:
- Live greeting based on time of day
- Today's focus session counter with animated circular progress
- Upcoming tasks with swipe gestures (complete/delete)
- Recent mood entries with emoji visualization
- Quick access to all modules

### ⏱️ **Focus Timer**
Pomodoro technique, elevated:
- 25/5 minute work/break intervals
- Animated circular timer with stroke animation
- Background blur intensifies during focus mode  
- Haptic feedback on start/pause/complete
- Session history with streak tracking

### ✅ **Smart Tasks**
Task management that doesn't suck:
- Priority levels (High/Medium/Low) with color coding
- Due date picker with calendar view
- Subtasks with nested checkboxes
- Drag-to-reorder with spring animations
- Archive completed tasks, restore when needed

### 😊 **Mood Tracker**
Because productivity isn't just checking boxes:
- Daily mood logging with emoji picker
- Notes field for context (max 280 chars)
- Weekly mood graph with smooth bezier curves
- Insights: "You're most productive on Wednesdays"
- Export mood data as CSV

### 🔥 **Habit Tracker**  
Build systems, not goals:
- Unlimited custom habits
- Streak counter with fire emoji animation
- Calendar heatmap (GitHub-style contribution graph)
- Reminder notifications at your chosen time
- Monthly completion rate percentage

---

## 🏗️ Architecture

```
Zenit/
├── App/
│   ├── ZenitApp.swift          # App entry point, @main
│   ├── ContentView.swift        # Root navigation container
│   └── Components/
│       └── ZenitTabBar.swift    # Custom animated tab bar
├── Views/
│   ├── Home/
│   │   └── HomeView.swift       # Dashboard with stats
│   ├── Focus/
│   │   └── FocusView.swift      # Pomodoro timer
│   ├── Tasks/  
│   │   └── TasksView.swift      # Task list with CRUD
│   ├── Mood/
│   │   └── MoodView.swift       # Mood logging + graph
│   └── Habits/
│       └── HabitsView.swift     # Habit tracking
├── Design/
│   ├── ZenitTheme.swift         # Color palette, typography
│   └── DesignSystem.swift       # Reusable UI components  
├── Models/
│   └── ZenitModels.swift        # Data models (Task, Mood, Habit)
└── ViewModels/
    └── ZenitViewModels.swift    # Business logic, @Published state
```

**Tech Stack:**
- SwiftUI for declarative UI
- Combine for reactive data flow
- @AppStorage for local persistence
- SF Symbols 5 for iconography

---

## 📱 Screenshots

### Home Dashboard
> Clean, minimal, purposeful. Your productivity at a glance.

```swift
// SCREENSHOT: Dark background, glassmorphic card showing:
// "Good Evening, Gedeon"  
// Focus Sessions Today: 3/8 (circular progress: 37%)
// 2 upcoming tasks listed
// Recent mood: 😊 "Feeling productive"
```

### Focus Timer  
> The Pomodoro technique has never looked this good.

```swift
// SCREENSHOT: Large circular timer (200pt diameter)
// "24:37" in SF Pro Display Semibold 48pt
// Animated stroke: 98% complete (cyan gradient)
// "Pause" button below with blur effect
```

### Task Management
> Swipe to complete. Long-press to reorder. It just works.

```swift 
// SCREENSHOT: List of tasks with priority dots (red/yellow/green)
// "Finish Zenit README" — High Priority — Due Today
// "Review PRs" — Medium — Due Tomorrow  
// Floating "+" button (bottom-right, glassmorphic)
```

---

## 🚀 Installation

### Requirements
- Xcode 15.0+
- iOS 17.0+  
- Swift 5.9+

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/gedeonkoh/Zenit-iOS.git
   cd Zenit-iOS
   ```

2. **Open in Xcode:**
   ```bash
   open Zenit.xcodeproj
   ```

3. **Select your target device:**
   - iPhone 15 Pro (recommended for ProMotion 120Hz)
   - Or any iOS 17+ simulator/device

4. **Build and run:**
   - Press `⌘ + R` or click the Play button
   - App launches directly (no CocoaPods/SPM dependencies)

### First Launch
Zenit generates sample data on first run:
- 3 pre-populated tasks
- 7 days of mood history
- 2 active habits ("Morning Workout", "Read 30 min")

You can clear this in Settings → Reset App Data.

---

## 🎨 Design Details

### Color Palette
```swift
Background:     #000000 (Pure black, OLED-friendly)
Card:           #1C1C1E (with 40% opacity glassmorphism)  
Primary:        #FFFFFF (SF Pro Text, 17pt)
Secondary:      #8E8E93 (60% opacity for subtitles)
Accent:         #6CAFF7 (CMYK Blue, used sparingly)
Error:          #FF453A (High priority, delete actions)
Success:        #32D74B (Completed tasks, positive moods)
```

### Typography Scale  
```swift
Title:          SF Pro Display Semibold, 32pt  
Headline:       SF Pro Display Semibold, 24pt
Body:           SF Pro Text Regular, 17pt
Caption:        SF Pro Text Medium, 13pt (60% opacity)
```

### Animation Springs
```swift
Default:        .spring(response: 0.3, dampingFraction: 0.7)
Bouncy:         .spring(response: 0.4, dampingFraction: 0.6)  
Snappy:         .spring(response: 0.2, dampingFraction: 0.8)
```

---

## 🧠 Key Implementation Details

### Glassmorphism Effect
```swift
.background(
    RoundedRectangle(cornerRadius: 20)
        .fill(Color(white: 0.11).opacity(0.4))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
)
```

### Circular Progress Animation  
```swift
Circle()
    .trim(from: 0, to: progress) // 0.0 to 1.0
    .stroke(
        LinearGradient(...),  
        style: StrokeStyle(lineWidth: 12, lineCap: .round)
    )
    .rotationEffect(.degrees(-90))
    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
```

### Swipe Gesture on Tasks
```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        withAnimation(.spring()) {
            viewModel.deleteTask(task)
        }
    } label: { Label("Delete", systemImage: "trash") }
}
```

---

## 📝 License

MIT License — feel free to fork, remix, and build your own productivity empire.

---

## 🙏 Acknowledgments

Inspired by the best productivity apps that make you *want* to open them:
- **Things 3** — Gestural interactions
- **Streaks** — Habit tracking UI  
- **Rise** — Minimal sleep tracking aesthetic
- **Every Instagram "cool iOS apps" reel** — You know the ones

Built with obsessive attention to detail. Every pixel, every animation, every font weight matters.

---

<div align="center">

**Made with ☕ and SwiftUI**

*"The details are not the details. They make the design."* — Charles Eames

[⬆ Back to Top](#zenit--reimagined-productivity)

</div>
