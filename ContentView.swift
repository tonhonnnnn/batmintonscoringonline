import SwiftUI
import Combine
import AudioToolbox
import AVFoundation

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
    let matchDuration: TimeInterval
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
    @Published var maxPoints: Int = 21
    @Published var setsToWin: Int = 2
    @Published var isVoiceEnabled: Bool = true
    @Published var matchDuration: TimeInterval = 0
    private var timer: Timer? = nil
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    @Published var showStats: Bool = false
    @Published var showWinnerOverlay: Bool = false
    @Published var showLangDropdown: Bool = false
    
    private var historyStack: [MatchStateSnapshot] = []
    
    init() {
        let savedLang = UserDefaults.standard.string(forKey: "badminton_lang") ?? "th"
        self.lang = savedLang
        self.playerNames = TRANSLATIONS[savedLang]!.defaultPlayers
        
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
        #endif
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
            playerNames: playerNames,
            matchDuration: matchDuration
        )
        historyStack.append(snapshot)
    }
    
    func scorePoint(playerIndex: Int) {
        guard !isMatchOver else { return }
        
        startTimerIfNeeded()
        pushHistory()
        playFeedback()
        
        scores[playerIndex] += 1
        server = playerIndex
        
        pointHistory.append(playerIndex)
        setPointHistories[activeSet].append(playerIndex)
        
        let oldActiveSet = activeSet
        checkSetStatus()
        
        if !isMatchOver && activeSet == oldActiveSet {
            speakScore()
        }
    }
    
    private func checkSetStatus() {
        let s0 = scores[0]
        let s1 = scores[1]
        var winner: Int? = nil
        
        let winPoint = maxPoints
        let maxCap = maxPoints + 9
        
        if s0 >= winPoint && (s0 - s1 >= 2) {
            winner = 0
        } else if s1 >= winPoint && (s1 - s0 >= 2) {
            winner = 1
        } else if s0 == maxCap {
            winner = 0
        } else if s1 == maxCap {
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
            
            if wins[0] == setsToWin || wins[1] == setsToWin {
                isMatchOver = true
                showWinnerOverlay = true
                stopTimer()
                speakScore(matchWinner: setWinner, finalScore: [s0, s1])
            } else {
                activeSet += 1
                scores = [0, 0]
                server = setWinner
                speakScore(setWinner: setWinner, finalScore: [s0, s1])
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
        matchDuration = snapshot.matchDuration
        
        if !isMatchOver {
            showWinnerOverlay = false
        }
        
        speakScore()
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
    
    // MARK: - Voice Score Announcer
    func speakScore(setWinner: Int? = nil, matchWinner: Int? = nil, finalScore: [Int]? = nil) {
        guard isVoiceEnabled else { return }
        
        let speechString: String
        
        if let matchWin = matchWinner, let score = finalScore {
            let leading = max(score[0], score[1])
            let trailing = min(score[0], score[1])
            let winnerName = playerNames[matchWin]
            
            if lang == "th" {
                speechString = "จบการแข่งขัน \(winnerName) ชนะ ด้วยคะแนน \(leading) ต่อ \(trailing)"
            } else if lang == "ja" {
                speechString = "マッチ終了 \(winnerName) の勝ち、\(leading) たい \(trailing)"
            } else if lang == "zh" {
                speechString = "比赛结束 \(winnerName) 获胜，比分 \(leading) 比 \(trailing)"
            } else if lang == "ko" {
                speechString = "경기 종료 \(winnerName) 승리, 스코어 \(leading) 대 \(trailing)"
            } else {
                speechString = "Match won by \(winnerName), \(leading) to \(trailing)"
            }
        } else if let setWin = setWinner, let score = finalScore {
            let leading = max(score[0], score[1])
            let trailing = min(score[0], score[1])
            let winnerName = playerNames[setWin]
            
            if lang == "th" {
                speechString = "จบเซต \(winnerName) ชนะ \(leading) ต่อ \(trailing)"
            } else if lang == "ja" {
                speechString = "ゲームウォン バイ \(winnerName)、\(leading) たい \(trailing)"
            } else if lang == "zh" {
                speechString = "单局结束 \(winnerName) 获胜，比分 \(leading) 比 \(trailing)"
            } else if lang == "ko" {
                speechString = "세트 종료 \(winnerName) 승리, 스코어 \(leading) 대 \(trailing)"
            } else {
                speechString = "Set won by \(winnerName), \(leading) to \(trailing)"
            }
        } else {
            let s0 = scores[0]
            let s1 = scores[1]
            
            if s0 == 0 && s1 == 0 {
                if lang == "th" {
                    speechString = "เริ่มเล่น ศูนย์ เท่า"
                } else if lang == "ja" {
                    speechString = "ラブ オール プレイ"
                } else if lang == "zh" {
                    speechString = "开始比赛 零平"
                } else if lang == "ko" {
                    speechString = "러브 올 플레이"
                } else {
                    speechString = "Love all, play"
                }
            } else {
                let serverScore = scores[server]
                let receiverScore = scores[1 - server]
                
                let isMatchPt = isMatchPoint(for: 0) || isMatchPoint(for: 1)
                let isSetPt = isSetPoint(for: 0) || isSetPoint(for: 1)
                
                var baseScoreStr = ""
                if serverScore == receiverScore {
                    if lang == "th" {
                        baseScoreStr = "\(serverScore) เท่า"
                    } else if lang == "ja" {
                        baseScoreStr = "\(serverScore) オール"
                    } else if lang == "zh" {
                        baseScoreStr = "\(serverScore) 平"
                    } else if lang == "ko" {
                        baseScoreStr = "\(serverScore) 올"
                    } else {
                        baseScoreStr = "\(serverScore) all"
                    }
                } else {
                    if lang == "th" {
                        baseScoreStr = "\(serverScore) ต่อ \(receiverScore)"
                    } else if lang == "ja" {
                        baseScoreStr = "\(serverScore) たい \(receiverScore)"
                    } else if lang == "zh" {
                        baseScoreStr = "\(serverScore) 比 \(receiverScore)"
                    } else if lang == "ko" {
                        baseScoreStr = "\(serverScore) 대 \(receiverScore)"
                    } else {
                        baseScoreStr = "\(serverScore), \(receiverScore)"
                    }
                }
                
                if isMatchPt {
                    let matchPointPlayer = isMatchPoint(for: 0) ? 0 : 1
                    let name = playerNames[matchPointPlayer]
                    if lang == "th" {
                        speechString = "\(baseScoreStr), แมตช์พอยท์ \(name)"
                    } else if lang == "ja" {
                        speechString = "\(baseScoreStr), マッチポイント \(name)"
                    } else if lang == "zh" {
                        speechString = "\(baseScoreStr), 赛点 \(name)"
                    } else if lang == "ko" {
                        speechString = "\(baseScoreStr), 매치 포인트 \(name)"
                    } else {
                        speechString = "\(baseScoreStr), Match Point \(name)"
                    }
                } else if isSetPt {
                    let setPointPlayer = isSetPoint(for: 0) ? 0 : 1
                    let name = playerNames[setPointPlayer]
                    if lang == "th" {
                        speechString = "\(baseScoreStr), เกมพอยท์ \(name)"
                    } else if lang == "ja" {
                        speechString = "\(baseScoreStr), เกมポイント \(name)"
                    } else if lang == "zh" {
                        speechString = "\(baseScoreStr), 局点 \(name)"
                    } else if lang == "ko" {
                        speechString = "\(baseScoreStr), 세트 포인트 \(name)"
                    } else {
                        speechString = "\(baseScoreStr), Game Point \(name)"
                    }
                } else {
                    speechString = baseScoreStr
                }
            }
        }
        
        let utterance = AVSpeechUtterance(string: speechString)
        if lang == "th" {
            utterance.voice = AVSpeechSynthesisVoice(language: "th-TH")
        } else if lang == "ja" {
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        } else if lang == "zh" {
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        } else if lang == "ko" {
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        utterance.rate = 0.52
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Timer Management
    func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isMatchOver else { return }
            self.matchDuration += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    var matchDurationString: String {
        let hours = Int(matchDuration) / 3600
        let minutes = (Int(matchDuration) % 3600) / 60
        let seconds = Int(matchDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Set & Match Point Helpers
    func isSetPoint(for playerIndex: Int) -> Bool {
        if isMatchOver { return false }
        let myScore = scores[playerIndex]
        let opponentScore = scores[1 - playerIndex]
        let winPoint = maxPoints
        
        if myScore >= winPoint - 1 {
            if myScore > opponentScore && (myScore - opponentScore >= 1) {
                return true
            }
            if myScore == winPoint - 1 && opponentScore < winPoint - 1 {
                return true
            }
        }
        return false
    }
    
    func isMatchPoint(for playerIndex: Int) -> Bool {
        guard isSetPoint(for: playerIndex) else { return false }
        var wins = [0, 0]
        for w in setWinners {
            if let winnerIndex = w {
                wins[winnerIndex] += 1
            }
        }
        return wins[playerIndex] == setsToWin - 1
    }
    
    // MARK: - Settings Translation Helpers
    func getSettingsString(key: String) -> String {
        let thStrings = [
            "settings": "ตั้งค่าการแข่งขัน",
            "maxPoints": "เล่นถึง (แต้ม)",
            "setsToWin": "จำนวนเซตตัดสิน",
            "voiceAnnouncer": "เสียงขานคะแนน",
            "bestOf3": "ชนะ 2 ใน 3 เซต",
            "bestOf1": "เซตเดียวจบ",
            "enabled": "เปิด",
            "disabled": "ปิด"
        ]
        let enStrings = [
            "settings": "Match Settings",
            "maxPoints": "Points Limit",
            "setsToWin": "Match Format",
            "voiceAnnouncer": "Voice Announcer",
            "bestOf3": "Best of 3 Sets",
            "bestOf1": "Best of 1 Set",
            "enabled": "On",
            "disabled": "Off"
        ]
        let jaStrings = [
            "settings": "試合設定",
            "maxPoints": "ゲームポイント",
            "setsToWin": "マッチ形式",
            "voiceAnnouncer": "主審音声",
            "bestOf3": "3ゲーム中2ゲーム先取",
            "bestOf1": "1ゲーム先取",
            "enabled": "オン",
            "disabled": "オフ"
        ]
        let dict = lang == "th" ? thStrings : (lang == "ja" ? jaStrings : enStrings)
        return dict[key] ?? key
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
    @State private var showSettingsSheet = false
    
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
        .sheet(isPresented: $showSettingsSheet) {
            SettingsSheetView(vm: vm)
        }
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("Badminton Score"),
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
            ZStack {
                // Centered Brand Logo Title & Timer
                VStack(spacing: 6) {
                    headerLogo
                    
                    Text(vm.matchDurationString)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 134/255, green: 134/255, blue: 139/255))
                }
                
                // Left-aligned actions
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
                }
                
                // Right-aligned actions
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Settings Button
                        Button(action: { showSettingsSheet = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        }
                        
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
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
            
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
            .padding(.top, 64) // Creates space below header logo
            
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
        ZStack(alignment: .top) {
            // Top-left/right control buttons pinned to safe edges
            HStack {
                // Switch Sides (Left)
                Button(action: { vm.switchSides() }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
                
                Spacer()
                
                // Language switcher (Right)
                Button(action: { vm.showLangDropdown.toggle() }) {
                    Image(systemName: "globe")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                        .frame(width: 38, height: 38)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .zIndex(5)
            
            // Main Content Rows
            HStack(spacing: 32) {
                Spacer()
                
                // Left Score Card
                let leftIdx = vm.swappedSides ? 1 : 0
                scoreCardView(playerIndex: leftIdx, alignLeft: true)
                    .frame(maxWidth: 220)
                    .frame(maxHeight: 220) // Proportional sizing
                
                // Center column controls
                VStack(spacing: 8) {
                    // Compact header logo
                    headerLogo
                        .scaleEffect(0.7)
                        .padding(.top, 16)
                    
                    // Sets log list
                    setsListView
                        .scaleEffect(0.8)
                        .frame(height: 70)
                    
                    Spacer(minLength: 4)
                    
                    // Compact Actions
                    VStack(spacing: 6) {
                        // New Match
                        Button(action: { showingResetAlert = true }) {
                            Text(vm.strings.btnNewMatch)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 30)
                                .background(Color(red: 0, green: 113/255, blue: 227/255))
                                .clipShape(Capsule())
                        }
                        
                        // Undo & Progress side-by-side
                        HStack(spacing: 6) {
                            Button(action: { vm.undo() }) {
                                Text(vm.strings.btnUndo)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                                    .frame(width: 57, height: 28)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.5))
                            }
                            .disabled(!vm.canUndo)
                            .opacity(vm.canUndo ? 1.0 : 0.4)
                            
                            Button(action: { vm.showStats = true }) {
                                Text(vm.strings.btnProgress)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
                                    .frame(width: 57, height: 28)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 0.5))
                            }
                        }
                    }
                }
                .frame(width: 140)
                
                // Right Score Card
                let rightIdx = vm.swappedSides ? 0 : 1
                scoreCardView(playerIndex: rightIdx, alignLeft: false)
                    .frame(maxWidth: 220)
                    .frame(maxHeight: 220) // Proportional sizing
                
                Spacer()
            }
            .padding(.top, 40)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Subviews & UI Components
    
    // Custom Score Card view component
    private func scoreCardView(playerIndex: Int, alignLeft: Bool) -> some View {
        VStack(spacing: 12) {
            // Editable Player Name text fields
            TextField("", text: Binding(
                get: { vm.playerNames[playerIndex] },
                set: { vm.updatePlayerName(index: playerIndex, name: $0) }
            ))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(Color(red: 29/255, green: 29/255, blue: 31/255))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.01))
            .cornerRadius(8)
            
            // Card Tap Target
            Button(action: { vm.scorePoint(playerIndex: playerIndex) }) {
                ZStack {
                    let isSetPt = vm.isSetPoint(for: playerIndex)
                    let isMatchPt = vm.isMatchPoint(for: playerIndex)
                    
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white)
                        .shadow(color: isMatchPt ? Color(red: 255/255, green: 179/255, blue: 0/255).opacity(0.3) : (isSetPt ? Color(red: 255/255, green: 115/255, blue: 0/255).opacity(0.2) : Color.black.opacity(0.04)), radius: isSetPt ? 20 : 15, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(isMatchPt ? Color(red: 255/255, green: 179/255, blue: 0/255).opacity(0.8) : (isSetPt ? Color(red: 255/255, green: 115/255, blue: 0/255).opacity(0.6) : Color.black.opacity(0.02)), lineWidth: isSetPt ? 2.5 : 1)
                        )
                        .overlay(
                            VStack {
                                if isMatchPt {
                                    Text("MATCH POINT")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(red: 255/255, green: 179/255, blue: 0/255))
                                        .clipShape(Capsule())
                                        .padding(.top, -10)
                                } else if isSetPt {
                                    Text("SET POINT")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(red: 255/255, green: 115/255, blue: 0/255))
                                        .clipShape(Capsule())
                                        .padding(.top, -10)
                                }
                            },
                            alignment: .top
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
            .aspectRatio(verticalSizeClass == .compact ? nil : 0.74, contentMode: .fit)
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
                    .fill(Color.white.opacity(0.15))
                    .background(.ultraThinMaterial, in: Capsule())
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
            .clipShape(Capsule())
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
    @State private var celebrationTimer: Timer? = nil
    @State private var tickCount: Int = 0
    
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
            startCelebrationHaptics()
        }
        .onDisappear {
            stopCelebrationHaptics()
        }
    }
    
    private func startCelebrationHaptics() {
        #if os(iOS)
        stopCelebrationHaptics()
        
        tickCount = 0
        // Play tick 0 immediately
        AudioServicesPlaySystemSound(4095)
        let firstGen = UINotificationFeedbackGenerator()
        firstGen.notificationOccurred(.success)
        
        celebrationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            tickCount += 1
            
            // Limit to 10 minutes (600 seconds -> 4000 ticks)
            if tickCount >= 4000 {
                stopCelebrationHaptics()
                return
            }
            
            if tickCount % 10 == 0 {
                AudioServicesPlaySystemSound(4095)
            }
            
            if tickCount % 2 == 0 {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } else {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred(intensity: 1.0)
            }
        }
        #endif
    }
    
    private func stopCelebrationHaptics() {
        celebrationTimer?.invalidate()
        celebrationTimer = nil
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
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    
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
            for _ in 0..<Int.random(in: 1...2) {
                spawnFirework()
            }
        }
        .onAppear {
            for _ in 0..<5 {
                spawnFirework()
            }
        }
    }
    
    private func spawnFirework() {
        let centerX = CGFloat.random(in: 40...340)
        let centerY = CGFloat.random(in: 80...320)
        let colors: [Color] = [
            Color(red: 255/255, green: 59/255, blue: 48/255),    // Neon Red
            Color(red: 255/255, green: 149/255, blue: 0/255),   // Neon Orange
            Color(red: 255/255, green: 204/255, blue: 0/255),   // Neon Yellow
            Color(red: 52/255, green: 199/255, blue: 89/255),    // Neon Green
            Color(red: 0/255, green: 199/255, blue: 190/255),   // Neon Teal
            Color(red: 50/255, green: 173/255, blue: 230/255),   // Neon Blue
            Color(red: 175/255, green: 82/255, blue: 222/255),  // Neon Purple
            Color(red: 255/255, green: 45/255, blue: 85/255)    // Neon Pink
        ]
        let color = colors.randomElement()!
        
        let now = Date()
        let count = 28
        for i in 0..<count {
            let angle = Double(i) * (2 * Double.pi / Double(count))
            let speed = Double.random(in: 70...170)
            let particle = ExplodingParticle(
                centerX: centerX,
                centerY: centerY,
                angle: angle,
                maxRadius: speed,
                size: CGFloat.random(in: 4...8),
                color: color,
                spawnDate: now,
                lifetime: Double.random(in: 0.8...1.3),
                gravity: CGFloat.random(in: 30...50)
            )
            particles.append(particle)
        }
        
        if particles.count > 500 {
            particles.removeFirst(100)
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

// MARK: - Match Rules & Voice Announcer Settings Sheet
struct SettingsSheetView: View {
    @ObservedObject var vm: MatchViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(vm.getSettingsString(key: "settings"))) {
                    Picker(vm.getSettingsString(key: "maxPoints"), selection: $vm.maxPoints) {
                        Text("11").tag(11)
                        Text("15").tag(15)
                        Text("21").tag(21)
                    }
                    .pickerStyle(.segmented)
                    
                    Picker(vm.getSettingsString(key: "setsToWin"), selection: $vm.setsToWin) {
                        Text(vm.getSettingsString(key: "bestOf1")).tag(1)
                        Text(vm.getSettingsString(key: "bestOf3")).tag(2)
                    }
                    .pickerStyle(.menu)
                    
                    Toggle(vm.getSettingsString(key: "voiceAnnouncer"), isOn: $vm.isVoiceEnabled)
                        .tint(Color(red: 0, green: 113/255, blue: 227/255))
                }
            }
            .navigationTitle(vm.getSettingsString(key: "settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text(vm.lang == "th" ? "เสร็จสิ้น" : "Done")
                            .bold()
                            .foregroundColor(Color(red: 0, green: 113/255, blue: 227/255))
                    }
                }
            }
        }
    }
}
