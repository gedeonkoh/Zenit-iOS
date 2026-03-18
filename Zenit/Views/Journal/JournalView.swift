import SwiftUI

struct JournalView: View {
    @EnvironmentObject var store: AppStore
    @State private var showNewEntry = false
    @State private var searchText = ""
    @State private var selectedMood: Mood? = nil
    
    var filteredEntries: [JournalEntry] {
        var entries = store.journalEntries
        
        if !searchText.isEmpty {
            entries = entries.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let mood = selectedMood {
            entries = entries.filter { $0.mood == mood }
        }
        
        return entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            // Background
            ZenitColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Search and Filter
                searchFilterSection
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // Entries List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEntries) { entry in
                            JournalEntryCard(entry: entry)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(20)
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showNewEntry = true
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(ZenitColors.gradient)
                                .frame(width: 64, height: 64)
                                .shadow(color: ZenitColors.primary.opacity(0.4), radius: 12, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showNewEntry) {
            NewJournalEntryView()
                .environmentObject(store)
        }
    }
    
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Journal")
                    .font(ZenitFonts.largeTitle)
                    .foregroundColor(.white)
                
                Text("\(filteredEntries.count) entries")
                    .font(ZenitFonts.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Streak indicator
            GlassCard(cornerRadius: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(ZenitColors.accent)
                    
                    Text("\(store.journalStreak)")
                        .font(ZenitFonts.headline)
                        .foregroundColor(.white)
                    
                    Text("day streak")
                        .font(ZenitFonts.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    var searchFilterSection: some View {
        VStack(spacing: 12) {
            // Search bar
            GlassCard(cornerRadius: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("Search entries...", text: $searchText)
                        .foregroundColor(.white)
                        .font(ZenitFonts.body)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            
            // Mood filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    MoodFilterChip(mood: nil, selectedMood: $selectedMood, label: "All")
                    
                    ForEach(Mood.allCases, id: \.self) { mood in
                        MoodFilterChip(mood: mood, selectedMood: $selectedMood)
                    }
                }
            }
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    @State private var isExpanded = false
    
    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(entry.mood.emoji)
                        .font(.system(size: 32))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.date, style: .date)
                            .font(ZenitFonts.headline)
                            .foregroundColor(.white)
                        
                        Text(entry.date, style: .time)
                            .font(ZenitFonts.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                
                // Content
                Text(entry.content)
                    .font(ZenitFonts.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(isExpanded ? nil : 3)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(20)
        }
    }
}

struct MoodFilterChip: View {
    let mood: Mood?
    @Binding var selectedMood: Mood?
    var label: String?
    
    var isSelected: Bool {
        mood == selectedMood
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedMood = mood
            }
        } label: {
            HStack(spacing: 6) {
                if let mood = mood {
                    Text(mood.emoji)
                        .font(.system(size: 16))
                    Text(mood.rawValue.capitalized)
                        .font(ZenitFonts.caption.weight(.medium))
                } else {
                    Text(label ?? "All")
                        .font(ZenitFonts.caption.weight(.medium))
                }
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        ZenitColors.gradient
                    } else {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .cornerRadius(20)
        }
    }
}

struct NewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: AppStore
    @State private var content = ""
    @State private var selectedMood: Mood = .neutral
    
    var body: some View {
        NavigationView {
            ZStack {
                ZenitColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Mood selector
                    VStack(spacing: 12) {
                        Text("How are you feeling?")
                            .font(ZenitFonts.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Mood.allCases, id: \.self) { mood in
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedMood = mood
                                        }
                                    } label: {
                                        VStack(spacing: 8) {
                                            Text(mood.emoji)
                                                .font(.system(size: 40))
                                            Text(mood.rawValue.capitalized)
                                                .font(ZenitFonts.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding(16)
                                        .background(
                                            selectedMood == mood ?
                                            ZenitColors.gradient : Color.white.opacity(0.1)
                                        )
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Text editor
                    GlassCard(cornerRadius: 20) {
                        TextEditor(text: $content)
                            .font(ZenitFonts.body)
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 200)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let entry = JournalEntry(content: content, mood: selectedMood, date: Date())
                        store.addJournalEntry(entry)
                        dismiss()
                    }
                    .foregroundColor(ZenitColors.accent)
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

enum Mood: String, CaseIterable {
    case amazing, happy, neutral, sad, stressed
    
    var emoji: String {
        switch self {
        case .amazing: return "🤩"
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .stressed: return "😰"
        }
    }
}

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let content: String
    let mood: Mood
    let date: Date
    
    init(id: UUID = UUID(), content: String, mood: Mood, date: Date) {
        self.id = id
        self.content = content
        self.mood = mood
        self.date = date
    }
}

#Preview {
    JournalView()
        .environmentObject(AppStore())
}
