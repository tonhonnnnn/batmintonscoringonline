import SwiftUI
import Combine
import AudioToolbox

// MARK: - Localizable Strings Dictionary
struct LanguageStrings {
    let appTitle: String
    let defaultPlayers: [String]
    let rightServe: String
    let leftServe: String
    let setsTitle: String
    let btnNewMatch: String
    let btnUndo: String
    let btnProgress: String
    let statsTitle: String
    let totalPoints: String
    let consecutiveStreak: String
    let timelineTitle: String
    let noPointsYet: String
    let matchCompleted: String
    let winsMatch: String
    let setsTo: String
    let playAgain: String
    let confirmReset: String
    let switchSidesTitle: String
    let changeLangTitle: String
}

let TRANSLATIONS: [String: LanguageStrings] = [
    "th": LanguageStrings(
        appTitle: "BATMINTON SCORE",
        defaultPlayers: ["ผู้เล่น 1", "ผู้เล่น 2"],
        rightServe: "เสิร์ฟขวา",
        leftServe: "เสิร์ฟซ้าย",
        setsTitle: "SETS",
        btnNewMatch: "เริ่มแมตช์",
        btnUndo: "ย้อนกลับ",
        btnProgress: "สถิติ",
        statsTitle: "สถิติการแข่งขัน",
        totalPoints: "คะแนนรวมที่ได้",
        consecutiveStreak: "ทำคะแนนต่อเนื่องสูงสุด",
        timelineTitle: "ลำดับการได้คะแนน (เซตปัจจุบัน)",
        noPointsYet: "ยังไม่มีคะแนนในเซตนี้",
        matchCompleted: "จบการแข่งขัน",
        winsMatch: "ชนะการแข่งขัน!",
        setsTo: "เซต ต่อ",
        playAgain: "เล่นอีกครั้ง",
        confirmReset: "ต้องการเริ่มแมตช์ใหม่ใช่หรือไม่? คะแนนที่กำลังเล่นอยู่จะหายไป",
        switchSidesTitle: "สลับฝั่งผู้เล่น",
        changeLangTitle: "เปลี่ยนภาษา"
    ),
    "en": LanguageStrings(
        appTitle: "BADMINTON SCORE",
        defaultPlayers: ["Player 1", "Player 2"],
        rightServe: "RIGHT SERVE",
        leftServe: "LEFT SERVE",
        setsTitle: "SETS",
        btnNewMatch: "New Match",
        btnUndo: "Undo",
        btnProgress: "Progress",
        statsTitle: "Match Statistics",
        totalPoints: "Total Points Won",
        consecutiveStreak: "Consecutive Points Streak",
        timelineTitle: "Score Progress Sequence (Current Set)",
        noPointsYet: "No points in this set yet",
        matchCompleted: "MATCH COMPLETED",
        winsMatch: "Wins!",
        setsTo: "Sets to",
        playAgain: "Play Again",
        confirmReset: "Do you want to start a new match? Current scores will be lost.",
        switchSidesTitle: "Switch Sides",
        changeLangTitle: "Change Language"
    ),
    "zh": LanguageStrings(
        appTitle: "羽毛球比分",
        defaultPlayers: ["选手 1", "选手 2"],
        rightServe: "右区发球",
        leftServe: "左区发球",
        setsTitle: "局数",
        btnNewMatch: "新比赛",
        btnUndo: "撤销",
        btnProgress: "统计",
        statsTitle: "比赛统计",
        totalPoints: "总得分",
        consecutiveStreak: "最大连得分",
        timelineTitle: "得分走势 (当前局)",
        noPointsYet: "本局尚无得分",
        matchCompleted: "比赛结束",
        winsMatch: "获胜！",
        setsTo: "比",
        playAgain: "再来一局",
        confirmReset: "确定要重新开始比赛吗？当前比分将会丢失。",
        switchSidesTitle: "交换场地",
        changeLangTitle: "切换语言"
    ),
    "ja": LanguageStrings(
        appTitle: "バドミントン スコア",
        defaultPlayers: ["プレイヤー 1", "プレイヤー 2"],
        rightServe: "ライト サーブ",
        leftServe: "レフト サーブ",
        setsTitle: "セット",
        btnNewMatch: "新規マッチ",
        btnUndo: "戻す",
        btnProgress: "統計",
        statsTitle: "試合の統計",
        totalPoints: "合計得点",
        consecutiveStreak: "連続得点",
        timelineTitle: "得点経過シーケンス (現在のセット)",
        noPointsYet: "このセットの得点はまだありません",
        matchCompleted: "試合終了",
        winsMatch: "の勝ち！",
        setsTo: "セット 対",
        playAgain: "もう一度プレイ",
        confirmReset: "新しい試合を始めますか？現在のスコアは失われます。",
        switchSidesTitle: "コート交代",
        changeLangTitle: "言語変更"
    ),
    "ko": LanguageStrings(
        appTitle: "배드민턴 스코어",
        defaultPlayers: ["선수 1", "선수 2"],
        rightServe: "오른쪽 서브",
        leftServe: "왼쪽 서브",
        setsTitle: "세트",
        btnNewMatch: "새 매치",
        btnUndo: "취소",
        btnProgress: "통계",
        statsTitle: "경기 통계",
        totalPoints: "총 득점",
        consecutiveStreak: "연속 득점",
        timelineTitle: "점수 득점 순서 (현재 세트)",
        noPointsYet: "이 세트의 점수가 아직 없습니다",
        matchCompleted: "경기 종료",
        winsMatch: "승리!",
        setsTo: "세트 대",
        playAgain: "다시 하기",
        confirmReset: "새 매치를 시작하시겠습니까? 현재 점수가 초기화됩니다.",
        switchSidesTitle: "코트 변경",
        changeLangTitle: "언어 변경"
    )
];

// MARK: - State Management Snapshot for Undo
struct MatchStateSnapshot {
    let scores: [Int]
    let sets: [[Int?]]
    let setWinners: [Int?]
    let activeSet: Int
    let server: Int
    let isMatchOver: Bool
    let pointHistory: [Int]
    let setPointHistories: [[Int]]
    let customizedNames: [Bool]
    let playerNames: [String]
}

// MARK: - Game State ViewModel
class MatchViewModel: ObservableObject {
    @Published var playerNames: [String]
    @Published var customizedNames: [Bool] = [false, false]
    @Published var scores: [Int] = [0, 0]
    @Published var sets: [[Int?]] = [
        [nil, nil],
        [nil, nil],
        [nil, nil]
    ]
    @Published var setWinners: [Int?] = [nil, nil, nil]
    @Published var activeSet: Int = 0
    @Published var server: Int = 0
    @Published var swappedSides: Bool = false
    @Published var isMatchOver: Bool = false
    @Published var pointHistory: [Int] = [] // All points scored
    @Published var setPointHistories: [[Int]] = [[], [], []] // Point scorer indices per set
    @Published var lang: String
    
    @Published var showStats: Bool = false
    @Published var showWinnerOverlay: Bool = false
    @Published var showLangDropdown: Bool = false
    
    private var historyStack: [MatchStateSnapshot] = []
    
    init() {
        let savedLang = UserDefaults.standard.string(forKey: "badminton_lang") ?? "th"
        self.lang = savedLang
        self.playerNames = TRANSLATIONS[savedLang]!.defaultPlayers
    }
    
    var strings: LanguageStrings {
        TRANSLATIONS[lang] ?? TRANSLATIONS["th"]!
    }
    
    func changeLanguage(_ newLang: String) {
        guard TRANSLATIONS[newLang] != nil else { return }
        self.lang = newLang
        UserDefaults.standard.set(newLang, forKey: "badminton_lang")
        
        // Translate default names if they are not custom edited
        let trans = TRANSLATIONS[newLang]!
        if !customizedNames[0] {
            playerNames[0] = trans.defaultPlayers[0]
        }
        if !customizedNames[1] {
            playerNames[1] = trans.defaultPlayers[1]
        }
    }
    
    func updatePlayerName(index: Int, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trans = TRANSLATIONS[lang]!
        
        playerNames[index] = trimmed.isEmpty ? trans.defaultPlayers[index] : trimmed
        
        // Mark as customized if different from default
        let isDefault = trans.defaultPlayers.contains(trimmed) || trimmed.isEmpty
        customizedNames[index] = !isDefault
    }
    
    func pushHistory() {
        let snapshot = MatchStateSnapshot(
            scores: scores,
            sets: sets,
            setWinners: setWinners,
            activeSet: activeSet,
            server: server,
            isMatchOver: isMatchOver,
            pointHistory: pointHistory,
            setPointHistories: setPointHistories,
            customizedNames: customizedNames,
            playerNames: playerNames
        )
        historyStack.append(snapshot)
    }
    
    func scorePoint(playerIndex: Int) {
        guard !isMatchOver else { return }
        
        pushHistory()
        playFeedback()
        
        scores[playerIndex] += 1
        server = playerIndex
        
        pointHistory.append(playerIndex)
        setPointHistories[activeSet].append(playerIndex)
        
        checkSetStatus()
    }
    
    private func checkSetStatus() {
        let s0 = scores[0]
        let s1 = scores[1]
        var winner: Int? = nil
        
        // Standard badminton rules: first to 21, win by 2, cap at 30.
        if s0 >= 21 && (s0 - s1 >= 2) {
            winner = 0
        } else if s1 >= 21 && (s1 - s0 >= 2) {
            winner = 1
        } else if s0 == 30 {
            winner = 0
        } else if s1 == 30 {
            winner = 1
        }
        
        if let setWinner = winner {
            sets[activeSet] = [s0, s1]
            setWinners[activeSet] = setWinner
            
            // Count total sets won
            var wins = [0, 0]
            for w in setWinners {
                if let winnerIndex = w {
                    wins[winnerIndex] += 1
                }
            }
            
            // Best of 3 sets
            if wins[0] == 2 || wins[1] == 2 {
                isMatchOver = true
                showWinnerOverlay = true
            } else {
                activeSet += 1
                scores = [0, 0]
                server = setWinner
            }
        }
    }
    
    func undo() {
        guard !historyStack.isEmpty else { return }
        playUndoFeedback()
        
        let snapshot = historyStack.removeLast()
        
        scores = snapshot.scores
        sets = snapshot.sets
        setWinners = snapshot.setWinners
        activeSet = snapshot.activeSet
        server = snapshot.server
        isMatchOver = snapshot.isMatchOver
        pointHistory = snapshot.pointHistory
        setPointHistories = snapshot.setPointHistories
        customizedNames = snapshot.customizedNames
        playerNames = snapshot.playerNames
        
        if !isMatchOver {
            showWinnerOverlay = false
        }
    }
    
    func switchSides() {
        playFeedback()
        swappedSides.toggle()
    }
    
    func confirmNewMatch(performReset: @escaping () -> Void) {
        performReset()
    }
    
    func closeWinnerModalAndReset() {
        showWinnerOverlay = false
        resetMatch()
    }
    
    func resetMatch() {
        scores = [0, 0]
        sets = [
            [nil, nil],
            [nil, nil],
            [nil, nil]
        ]
        setWinners = [nil, nil, nil]
        activeSet = 0
        server = 0
        isMatchOver = false
        pointHistory = []
        setPointHistories = [[], [], []]
        historyStack.removeAll()
        
        let trans = TRANSLATIONS[lang]!
        if !customizedNames[0] {
            playerNames[0] = trans.defaultPlayers[0]
        }
        if !customizedNames[1] {
            playerNames[1] = trans.defaultPlayers[1]
        }
    }
    
    var canUndo: Bool {
        !historyStack.isEmpty
    }
    
    private func playFeedback() {
        // Native System Tap Sound
        AudioServicesPlaySystemSound(1104)
        
        // Native Apple Haptics
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    private func playUndoFeedback() {
        // Deeper system tick
        AudioServicesPlaySystemSound(1105)
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Main Application View
struct ContentView: View {
    @StateObject private var vm = MatchViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var showingResetAlert = false
    @State private var footerActiveIndex: Int = 1
    @State private var leftScale: CGFloat = 1.0
    @State private var rightScale: CGFloat = 1.0
    
    private var headerLogo: some View {
        Group {
            if let uiImage = UIImage(named: "logo1") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "logo1", ofType: "png") ?? "") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            } else {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 0, green: 113/255, blue: 227/255))
                    )
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background color (Apple `#f5f5f7`)
            Color(red: 245/255, green: 245/255, blue: 247/255)
                .edgesIgnoringSafeArea(.all)
            
            // Layout switcher (Portrait vs Landscape)
            if verticalSizeClass == .compact {
                landscapeLayout
            } else {
                portraitLayout
            }
            
            // Popups & Modal Sheets
            if vm.showLangDropdown {
                Color.black.opacity(0.15)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        vm.showLangDropdown = false
                    }
                
                languageDropdownPopover
            }
            
            if vm.showWinnerOverlay {
                WinnerOverlayView(vm: vm)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(10)
            }
        }
        .sheet(isPresented: $vm.showStats) {
            StatsSheetView(vm: vm)
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Batminton Score"),
                message: Text(vm.strings.confirmReset),
                primaryButton: .destructive(Text(vm.strings.btnNewMatch)) {
                    vm.resetMatch()
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: vm.scores) { oldValue, newValue in
            // Animate left score changes
            if vm.scores[0] > 0 {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.45, blendDuration: 0)) {
                    leftScale = 1.15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
                        leftScale = 1.0
                    }
                }
            }
            // Animate right score changes
            if vm.scores[1] > 0 {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.45, blendDuration: 0)) {
                    rightScale = 1.15
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0)) {
                        rightScale = 1.0
                    }
                }
            }
        }
    }
    
    // MARK: - Portrait UI Layout
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            // Navigation Header (Liquid Glass style)
            HStack {
                // Switch Sides (Left)
                Button(action: { vm.switchSides() }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                // Brand Logo Title
                headerLogo
                
                Spacer()
                
                // Language switcher (Right)
                Button(action: { vm.showLangDropdown.toggle() }) {
                    Image(systemName: "globe")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32) // Pushes cards down from notch/dynamic island
            .padding(.bottom, 32)
            
            // Score Cards Grid
            HStack(spacing: 20) {
                // Left Visual Card (corresponds to player index based on swappedSides)
                let leftIdx = vm.swappedSides ? 1 : 0
                scoreCardView(playerIndex: leftIdx, alignLeft: true)
                
                // Right Visual Card
                let rightIdx = vm.swappedSides ? 0 : 1
                scoreCardView(playerIndex: rightIdx, alignLeft: false)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16) // Creates space below header logo
            
            // Sets Score List History
            setsListView
                .padding(.vertical, 40) // Spreads sets history list down
            
            Spacer()
            
            // Floating Liquid Glass Menu Footer
            footerControlsContainer
        }
    }
    
    // MARK: - Landscape UI Layout
    private var landscapeLayout: some View {
        HStack(spacing: 20) {
            // Left Score Card
            let leftIdx = vm.swappedSides ? 1 : 0
            scoreCardView(playerIndex: leftIdx, alignLeft: true)
                .frame(maxWidth: .infinity)
            
            // Center column controls
            VStack(spacing: 12) {
                // Compact header title
                headerLogo
                    .scaleEffect(0.8)
                
                // Sets log list
                setsListView
                    .scaleEffect(0.85)
                    .frame(height: 90)
                
                Spacer()
                
                // Stacked buttons
                VStack(spacing: 6) {
                    // New Match
                    Button(action: { showingResetAlert = true }) {
                        Text(vm.strings.btnNewMatch)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color(red: 0, green: 113/255, blue: 227/255))
                            .cornerRadius(10)
                    }
                    
                    // Undo
                    Button(action: { vm.undo() }) {
                        Text(vm.strings.btnUndo)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 210/255, green: 210/255, blue: 215/255), lineWidth: 1))
                            .opacity(vm.canUndo ? 1.0 : 0.4)
                    }
                    .disabled(!vm.canUndo)
                    
                    // Progress Stats
                    Button(action: { vm.showStats = true }) {
                        Text(vm.strings.btnProgress)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 210/255, green: 210/255, blue: 215/255), lineWidth: 1))
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(width: 160)
            .overlay(
                // Floating top-left/right buttons overlay on landscape
                HStack {
                    Button(action: { vm.switchSides() }) {
                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                            .frame(width: 30, height: 30)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: { vm.showLangDropdown.toggle() }) {
                        Image(systemName: "globe")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                            .frame(width: 30, height: 30)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, -32)
                .padding(.top, -10)
                , alignment: .top
            )
            
            // Right Score Card
            let rightIdx = vm.swappedSides ? 0 : 1
            scoreCardView(playerIndex: rightIdx, alignLeft: false)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Subviews & UI Components
    
    // Custom Score Card view component
    private func scoreCardView(playerIndex: Int, alignLeft: Bool) -> some View {
        VStack(spacing: 12) {
            // Card Tap Target
            Button(action: { vm.scorePoint(playerIndex: playerIndex) }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.black.opacity(0.02), lineWidth: 1)
                        )
                    
                    VStack {
                        // Serving status Court text indicator
                        let isServing = vm.server == playerIndex && !vm.isMatchOver
                        let isEven = vm.scores[playerIndex] % 2 == 0
                        let serveText = isEven ? vm.strings.rightServe : vm.strings.leftServe
                        
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color(red: 0, green: 113/255, blue: 227/255))
                                .frame(width: 6, height: 6)
                            Text(serveText)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(red: 0, green: 113/255, blue: 227/255))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(red: 0, green: 113/255, blue: 227/255).opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 16)
                        .opacity(isServing ? 1.0 : 0.0)
                        
                        Spacer()
                        
                        Text(String(format: "%02d", vm.scores[playerIndex]))
                            .font(.system(size: verticalSizeClass == .compact ? 90 : 96, weight: .heavy, design: .default))
                            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                            .tracking(-2)
                            .scaleEffect(playerIndex == 0 ? leftScale : rightScale)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .id("score-\(playerIndex)-\(vm.scores[playerIndex])") // forces layout pop transition
                        
                        Spacer()
                    }
                }
            }
            .buttonStyle(CardButtonStyle())
            .aspectRatio(verticalSizeClass == .compact ? .infinity : 1/1.35, contentMode: .fit)
            
            // Editable Player Name text fields
            TextField("", text: Binding(
                get: { vm.playerNames[playerIndex] },
                set: { vm.updatePlayerName(index: playerIndex, name: $0) }
            ))
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.01))
            .cornerRadius(8)
        }
    }
    
    // Historical Sets scores tracker panel
    private var setsListView: some View {
        VStack(spacing: 8) {
            Text(vm.strings.setsTitle)
                .font(.system(size: 12, weight: .bold))
                .tracking(1)
                .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
            
            VStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { s in
                    let isCurrent = (s == vm.activeSet && !vm.isMatchOver)
                    let setScore = vm.sets[s]
                    let winner = vm.setWinners[s]
                    
                    HStack(spacing: 12) {
                        // Player 1 Set score
                        let p0ScoreText = isCurrent ? "\(vm.scores[0])" : (setScore[0] != nil ? "\(setScore[0]!)" : "-")
                        Text(p0ScoreText)
                            .font(.system(size: 16, weight: winner == 0 ? .bold : .regular))
                            .foregroundColor(winner == 0 ? Color(red: 29/255, green: 29/255, blue: 31/255) : (isCurrent ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 134/255, green: 134/255, blue: 139/255)))
                            .frame(width: 32, alignment: .trailing)
                        
                        // Set number round circle badge
                        Text("\(s + 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(isCurrent ? Color(red: 0, green: 113/255, blue: 227/255) : (setScore[0] != nil ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 180/255, green: 180/255, blue: 185/255)))
                            .clipShape(Circle())
                            .shadow(color: isCurrent ? Color(red: 0, green: 113/255, blue: 227/255).opacity(0.3) : Color.clear, radius: 4)
                        
                        // Player 2 Set score
                        let p1ScoreText = isCurrent ? "\(vm.scores[1])" : (setScore[1] != nil ? "\(setScore[1]!)" : "-")
                        Text(p1ScoreText)
                            .font(.system(size: 16, weight: winner == 1 ? .bold : .regular))
                            .foregroundColor(winner == 1 ? Color(red: 29/255, green: 29/255, blue: 31/255) : (isCurrent ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 134/255, green: 134/255, blue: 139/255)))
                            .frame(width: 32, alignment: .leading)
                    }
                    .opacity(isCurrent || setScore[0] != nil ? 1.0 : 0.4)
                }
            }
        }
    }
    
    // Floating "Liquid Glass" translucent menu bar
    private var footerControlsContainer: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let buttonWidth = (width - 16) / 3
            
            ZStack(alignment: .leading) {
                // Translucent Capsule Container Background (Liquid Glass look)
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .background(.ultraThinMaterial)
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
                
                // Sliding Liquid Glass Pill Background!
                Capsule()
                    .fill(Color.white.opacity(0.85))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                    .frame(width: buttonWidth - 4, height: 38)
                    .padding(.leading, 2)
                    .offset(x: CGFloat(footerActiveIndex) * buttonWidth)
                    .animation(.spring(response: 0.32, dampingFraction: 0.75, blendDuration: 0), value: footerActiveIndex)
                
                // HStack of buttons
                HStack(spacing: 0) {
                    // New Match Button
                    Button(action: {
                        footerActiveIndex = 0
                        showingResetAlert = true
                    }) {
                        Text(vm.strings.btnNewMatch)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(footerActiveIndex == 0 ? Color(red: 0, green: 113/255, blue: 227/255) : Color(red: 29/255, green: 29/255, blue: 31/255))
                            .frame(width: buttonWidth, height: 42)
                    }
                    
                    // Undo Button
                    Button(action: {
                        footerActiveIndex = 1
                        vm.undo()
                    }) {
                        Text(vm.strings.btnUndo)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(footerActiveIndex == 1 ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 134/255, green: 134/255, blue: 139/255))
                            .frame(width: buttonWidth, height: 42)
                    }
                    .disabled(!vm.canUndo)
                    .opacity(vm.canUndo ? 1.0 : 0.4)
                    
                    // Progress Button
                    Button(action: {
                        footerActiveIndex = 2
                        vm.showStats = true
                    }) {
                        Text(vm.strings.btnProgress)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(footerActiveIndex == 2 ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 134/255, green: 134/255, blue: 139/255))
                            .frame(width: buttonWidth, height: 42)
                    }
                }
            }
            .frame(height: 42)
            .padding(.horizontal, 4)
        }
        .frame(height: 42)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
    
    // Language Dropdown Popover (aligned relative to top-right button)
    private var languageDropdownPopover: some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    ForEach([("th", "ไทย"), ("en", "English"), ("zh", "中文"), ("ja", "日本語"), ("ko", "한국어")], id: \.0) { item in
                        Button(action: {
                            vm.changeLanguage(item.0)
                            vm.showLangDropdown = false
                        }) {
                            HStack {
                                Text(item.1)
                                    .font(.system(size: 14, weight: vm.lang == item.0 ? .bold : .medium))
                                    .foregroundColor(vm.lang == item.0 ? Color(red: 0, green: 113/255, blue: 227/255) : Color(red: 29/255, green: 29/255, blue: 31/255))
                                Spacer()
                                if vm.lang == item.0 {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(red: 0, green: 113/255, blue: 227/255))
                                }
                            }
                            .frame(width: 110)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(vm.lang == item.0 ? Color(red: 0, green: 113/255, blue: 227/255).opacity(0.08) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(6)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                .padding(.trailing, 24)
                .padding(.top, 66) // sits directly under top-right globe button
            }
            Spacer()
        }
    }
}

// MARK: - Tap Haptic Button Style helper
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Native iOS Bottom Sheet for Stats
struct StatsSheetView: View {
    @ObservedObject var vm: MatchViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let stats = getCalculatedStats()
        
        VStack(spacing: 0) {
            // Drag Indicator Handle at top
            Capsule()
                .fill(Color(red: 210/255, green: 210/255, blue: 215/255))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            // Header
            HStack {
                Text(vm.strings.statsTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 210/255, green: 210/255, blue: 215/255))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Stat Item: Total Points Won comparison bar
                    statItemView(
                        label: vm.strings.totalPoints,
                        leftVal: stats.totalPoints0,
                        rightVal: stats.totalPoints1,
                        pctLeft: stats.totalPointsPct0
                    )
                    
                    // Stat Item: Point Streaks comparison bar
                    statItemView(
                        label: vm.strings.consecutiveStreak,
                        leftVal: stats.streak0,
                        rightVal: stats.streak1,
                        pctLeft: stats.streakPct0
                    )
                    
                    // Timeline Point Scorer Sequence
                    VStack(alignment: .leading, spacing: 10) {
                        Text(vm.strings.timelineTitle)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                        
                        let currentSetPoints = vm.setPointHistories[vm.activeSet]
                        if currentSetPoints.isEmpty {
                            Text(vm.strings.noPointsYet)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(0..<currentSetPoints.count, id: \.self) { index in
                                        let scorer = currentSetPoints[index]
                                        Capsule()
                                            .fill(scorer == 0 ? Color(red: 29/255, green: 29/255, blue: 31/255) : Color(red: 0, green: 113/255, blue: 227/255))
                                            .frame(width: 8, height: 40)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .padding(12)
                            .background(Color(red: 245/255, green: 245/255, blue: 247/255))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color.white)
    }
    
    private func statItemView(label: String, leftVal: Int, rightVal: Int, pctLeft: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
            
            HStack(spacing: 12) {
                Text("\(leftVal)")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 32, alignment: .trailing)
                
                // Comparative bar track
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        // Left bar (Player 1 - Dark)
                        Color(red: 29/255, green: 29/255, blue: 31/255)
                            .frame(width: geo.size.width * CGFloat(pctLeft))
                        
                        // Right bar (Player 2 - Blue)
                        Color(red: 0, green: 113/255, blue: 227/255)
                            .frame(width: geo.size.width * CGFloat(1.0 - pctLeft))
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
                .background(Color(red: 245/255, green: 245/255, blue: 247/255))
                .cornerRadius(4)
                
                Text("\(rightVal)")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 32, alignment: .leading)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // Stats calculation helper
    struct CalculatedStats {
        let totalPoints0: Int
        let totalPoints1: Int
        let totalPointsPct0: Double
        let streak0: Int
        let streak1: Int
        let streakPct0: Double
    }
    
    private func getCalculatedStats() -> CalculatedStats {
        var t0 = 0
        var t1 = 0
        
        // Sum locked sets
        for s in vm.sets {
            if let s0 = s[0], let s1 = s[1] {
                t0 += s0
                t1 += s1
            }
        }
        // Add current set scores
        if !vm.isMatchOver {
            t0 += vm.scores[0]
            t1 += vm.scores[1]
        }
        
        let sumTotal = t0 + t1
        let pct0 = sumTotal > 0 ? Double(t0) / Double(sumTotal) : 0.5
        
        // Point streaks calculations
        var mStr0 = 0
        var mStr1 = 0
        var cur0 = 0
        var cur1 = 0
        
        for scorer in vm.pointHistory {
            if scorer == 0 {
                cur0 += 1
                cur1 = 0
                mStr0 = max(mStr0, cur0)
            } else {
                cur1 += 1
                cur0 = 0
                mStr1 = max(mStr1, cur1)
            }
        }
        
        let sumStreak = mStr0 + mStr1
        let pctStr0 = sumStreak > 0 ? Double(mStr0) / Double(sumStreak) : 0.5
        
        return CalculatedStats(
            totalPoints0: t0,
            totalPoints1: t1,
            totalPointsPct0: pct0,
            streak0: mStr0,
            streak1: mStr1,
            streakPct0: pctStr0
        )
    }
}

// MARK: - Native Fullscreen Winner Celebration Overlay
struct WinnerOverlayView: View {
    @ObservedObject var vm: MatchViewModel
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            // Blurred background (ultraThinMaterial)
            Rectangle()
                .fill(Color.white.opacity(0.85))
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            
            // Native Fireworks
            FireworkView()
                .edgesIgnoringSafeArea(.all)
            
            // Custom Falling Confetti particle layer
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let elapsed = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let age = elapsed - particle.spawnTime
                        var y = particle.startY + particle.speedY * age
                        var x = particle.startX + particle.speedX * age
                        
                        // Loop boundaries
                        if y > size.height + 50 {
                            let cycleHeight = size.height + 150
                            let timeToCycle = cycleHeight / particle.speedY
                            let cycles = floor(age / timeToCycle)
                            y = particle.startY + particle.speedY * age - cycles * cycleHeight
                            x = particle.startX + particle.speedX * age - cycles * (particle.speedX * timeToCycle)
                        }
                        
                        x = x.truncatingRemainder(dividingBy: size.width + 100) - 50
                        
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: particle.width, height: particle.height)),
                            with: .color(particle.color)
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Celebration Card
            VStack(spacing: 8) {
                Text("🏆")
                    .font(.system(size: 72))
                    .padding(.bottom, 12)
                
                Text(vm.strings.matchCompleted)
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2)
                    .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                
                // Winner Name announcement
                let wins = getSetWins()
                let winnerIndex = wins[0] == 2 ? 0 : 1
                let winnerName = vm.playerNames[winnerIndex]
                let winsText = vm.lang == "ja" ? "\(winnerName)\(vm.strings.winsMatch)" : "\(winnerName) \(vm.strings.winsMatch)"
                
                Text(winsText)
                    .font(.system(size: 26, weight: .heavy))
                    .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Set Wins Summary (e.g. 2 sets to 1)
                Text("\(wins[winnerIndex]) \(vm.strings.setsTo) \(wins[1 - winnerIndex])")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                    .padding(.bottom, 36)
                
                // Play Again reset button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        vm.closeWinnerModalAndReset()
                    }
                }) {
                    Text(vm.strings.playAgain)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 180, height: 48)
                        .background(Color(red: 0, green: 113/255, blue: 227/255))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0, green: 113/255, blue: 227/255).opacity(0.2), radius: 8)
                }
            }
        }
        .onAppear {
            generateConfetti()
            playCelebrationMelody()
        }
    }
    
    private func getSetWins() -> [Int] {
        var wins = [0, 0]
        for w in vm.setWinners {
            if let index = w {
                wins[index] += 1
            }
        }
        return wins
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .yellow]
        var newParticles: [ConfettiParticle] = []
        let now = Date().timeIntervalSinceReferenceDate
        for _ in 0..<75 {
            newParticles.append(
                ConfettiParticle(
                    startX: Double.random(in: -50...400),
                    startY: Double.random(in: -100...0),
                    width: Double.random(in: 6...12),
                    height: Double.random(in: 6...12),
                    color: colors.randomElement()!,
                    speedY: Double.random(in: 120...240),
                    speedX: Double.random(in: -40...40),
                    spawnTime: now
                )
            )
        }
        particles = newParticles
    }
    
    private func playCelebrationMelody() {
        #if os(iOS)
        // Strong notification success haptic
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(.success)
        
        // Sequence of heavy haptic impulses to simulate a strong physical rumble
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                impactGenerator.impactOccurred()
            }
        }
        #endif
        
        // Sequenced System Beeps
        let notes: [UInt32] = [1052, 1053, 1054, 1057]
        for i in 0..<notes.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                AudioServicesPlaySystemSound(1104)
            }
        }
    }
}

// MARK: - Confetti Particle Animation Struct
struct ConfettiParticle {
    let startX: Double
    let startY: Double
    let width: Double
    let height: Double
    let color: Color
    let speedY: Double
    let speedX: Double
    let spawnTime: Double
}

// MARK: - Native SwiftUI Canvas-Based Fireworks View
struct FireworkView: View {
    @State private var particles: [ExplodingParticle] = []
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for p in particles {
                    let age = timeline.date.timeIntervalSince(p.spawnDate)
                    if age < p.lifetime {
                        let progress = age / p.lifetime
                        let currentRadius = p.maxRadius * progress
                        let x = p.centerX + cos(p.angle) * currentRadius
                        let y = p.centerY + sin(p.angle) * currentRadius + (p.gravity * age * age)
                        let opacity = 1.0 - progress
                        
                        context.opacity = opacity
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - p.size/2, y: y - p.size/2, width: p.size, height: p.size)),
                            with: .color(p.color)
                        )
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            spawnFirework()
        }
        .onAppear {
            // Spawn initial bursts
            for _ in 0..<3 {
                spawnFirework()
            }
        }
    }
    
    private func spawnFirework() {
        let centerX = CGFloat.random(in: 40...340)
        let centerY = CGFloat.random(in: 80...320)
        let colors: [Color] = [.red, .blue, .yellow, .green, .orange, .pink, .purple, Color(red: 0, green: 113/255, blue: 227/255)]
        let color = colors.randomElement()!
        
        let now = Date()
        let count = 16
        for i in 0..<count {
            let angle = Double(i) * (2 * Double.pi / Double(count))
            let speed = Double.random(in: 60...130)
            let particle = ExplodingParticle(
                centerX: centerX,
                centerY: centerY,
                angle: angle,
                maxRadius: speed,
                size: CGFloat.random(in: 3...6),
                color: color,
                spawnDate: now,
                lifetime: Double.random(in: 0.7...1.0),
                gravity: CGFloat.random(in: 25...40)
            )
            particles.append(particle)
        }
        
        // Keep array size light
        if particles.count > 250 {
            particles.removeFirst(80)
        }
    }
}

struct ExplodingParticle {
    let centerX: CGFloat
    let centerY: CGFloat
    let angle: Double
    let maxRadius: Double
    let size: CGFloat
    let color: Color
    let spawnDate: Date
    let lifetime: Double
    let gravity: CGFloat
}

// MARK: - SwiftUI Preview
#Preview {
    ContentView()
}
