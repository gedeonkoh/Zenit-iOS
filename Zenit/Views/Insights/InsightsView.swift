import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTimeframe: Timeframe = .week
    @State private var showDetailSheet = false
    
    var body: some View {
        ZStack {
            // Background
            ZenitColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Timeframe Picker
                    timeframePicker
                        .padding(.horizontal, 20)
                    
                    // Productivity Score
                    productivityScoreCard
                        .padding(.horizontal, 20)
                    
                    // Activity Chart
                    activityChart
                        .padding(.horizontal, 20)
                    
                    // Stats Grid
                    statsGrid
                        .padding(.horizontal, 20)
                    
                    // Habit Completion
                    habitCompletionCard
                        .padding(.horizontal, 20)
                    
                    // Mood Trends
                    moodTrendsCard
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
        }
    }
    
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Insights")
                    .font(ZenitFonts.largeTitle)
                    .foregroundColor(.white)
                
                Text("Your productivity journey")
                    .font(ZenitFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    var timeframePicker: some View {
        HStack(spacing: 12) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTimeframe = timeframe
                    }
                } label: {
                    Text(timeframe.rawValue)
                        .font(ZenitFonts.caption.weight(.medium))
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            selectedTimeframe == timeframe ?
                            ZenitColors.gradient : Color.white.opacity(0.1)
                        )
                        .cornerRadius(20)
                }
            }
        }
    }
    
    var productivityScoreCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(spacing: 16) {
                HStack {
                    Text("Productivity Score")
                        .font(ZenitFonts.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .foregroundColor(ZenitColors.accent)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 20)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: CGFloat(store.productivityScore) / 100.0)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [ZenitColors.primary, ZenitColors.accent]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(Int(store.productivityScore))")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("out of 100")
                            .font(ZenitFonts.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(width: 200, height: 200)
                
                Text("You're performing \(Int(store.productivityScore - 65))% better than last week")
                    .font(ZenitFonts.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }
    
    var activityChart: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Focus Time")
                    .font(ZenitFonts.headline)
                    .foregroundColor(.white)
                
                if #available(iOS 16.0, *) {
                    Chart(store.weeklyFocusData) { item in
                        BarMark(
                            x: .value("Day", item.day),
                            y: .value("Minutes", item.minutes)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [ZenitColors.primary, ZenitColors.accent]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(8)
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel()
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(Color.white.opacity(0.6))
                        }
                    }
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: 8) {
                        ForEach(store.weeklyFocusData) { item in
                            HStack {
                                Text(item.day)
                                    .font(ZenitFonts.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(width: 40, alignment: .leading)
                                
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ZenitColors.gradient)
                                        .frame(width: geometry.size.width * CGFloat(item.minutes) / 120.0)
                                }
                                .frame(height: 20)
                                
                                Text("\(item.minutes)m")
                                    .font(ZenitFonts.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Tasks Done",
                value: "\(store.completedTasksCount)",
                icon: "checkmark.circle.fill",
                color: ZenitColors.accent
            )
            
            StatCard(
                title: "Focus Hours",
                value: String(format: "%.1f", store.totalFocusHours),
                icon: "timer",
                color: ZenitColors.primary
            )
            
            StatCard(
                title: "Streak",
                value: "\(store.journalStreak)",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Habits",
                value: "\(store.completedHabitsCount)/\(store.totalHabitsCount)",
                icon: "star.fill",
                color: .yellow
            )
        }
    }
    
    var habitCompletionCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Habit Completion")
                    .font(ZenitFonts.headline)
                    .foregroundColor(.white)
                
                ForEach(store.topHabits.prefix(5)) { habit in
                    HStack {
                        Text(habit.icon)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(ZenitFonts.body)
                                .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ZenitColors.gradient)
                                        .frame(width: geometry.size.width * CGFloat(habit.completionRate), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        
                        Text("\(Int(habit.completionRate * 100))%")
                            .font(ZenitFonts.caption.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(24)
        }
    }
    
    var moodTrendsCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mood Trends")
                    .font(ZenitFonts.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        VStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                            
                            Text("\(store.moodCount(for: mood))")
                                .font(ZenitFonts.caption.weight(.semibold))
                                .foregroundColor(.white)
                            
                            Text(mood.rawValue.prefix(3).capitalized)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(24)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 20))
                    
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(ZenitFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(20)
        }
    }
}

enum Timeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct FocusDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

struct HabitStat: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let completionRate: Double
}

#Preview {
    InsightsView()
        .environmentObject(AppStore())
}
