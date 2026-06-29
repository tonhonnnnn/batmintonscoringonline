class BadmintonApp {
  constructor() {
    this.state = {
      playerNames: ["Player 1", "Player 2"],
      scores: [0, 0], // Logical scores [Player 1, Player 2]
      sets: [
        [null, null], // Set 1
        [null, null], // Set 2
        [null, null]  // Set 3
      ],
      setWinners: [null, null, null],
      activeSet: 0,
      server: 0, // Logical player index serving: 0 or 1
      swappedSides: false, // True if Player 1 is on visual Right, Player 2 on visual Left
      isMatchOver: false,
      pointHistory: [], // Array of scorer indices: [0, 0, 1, 0, ...] for current match
      setPointHistories: [[], [], []], // Point sequence for each set
      historyStack: [] // Multi-level undo stack
    };

    this.initElements();
    this.bindEvents();
    this.updateUI();
  }

  initElements() {
    this.el = {
      cardP1: document.getElementById('card-p1'),
      cardP2: document.getElementById('card-p2'),
      scoreP1: document.getElementById('score-p1'),
      scoreP2: document.getElementById('score-p2'),
      nameP1: document.getElementById('name-p1'),
      nameP2: document.getElementById('name-p2'),
      serveP1: document.getElementById('serve-p1'),
      serveP2: document.getElementById('serve-p2'),
      serveTextP1: document.getElementById('serve-text-p1'),
      serveTextP2: document.getElementById('serve-text-p2'),
      setRows: [
        document.getElementById('set-row-0'),
        document.getElementById('set-row-1'),
        document.getElementById('set-row-2')
      ],
      setScoresL: [
        document.getElementById('set-score-l0'),
        document.getElementById('set-score-l1'),
        document.getElementById('set-score-l2')
      ],
      setScoresR: [
        document.getElementById('set-score-r0'),
        document.getElementById('set-score-r1'),
        document.getElementById('set-score-r2')
      ],
      btnUndo: document.getElementById('btn-undo'),
      btnSwitchSides: document.getElementById('btn-switch-sides'),
      statsModal: document.getElementById('stats-modal'),
      winnerModal: document.getElementById('winner-modal'),
      winnerName: document.getElementById('winner-name'),
      winnerScoreLine: document.getElementById('winner-score-line'),
      confettiContainer: document.getElementById('confetti-container'),
      timelineChart: document.getElementById('timeline-chart'),
      
      // Stats values
      statValLTotal: document.getElementById('stat-val-l-total'),
      statValRTotal: document.getElementById('stat-val-r-total'),
      statBarLTotal: document.getElementById('stat-bar-l-total'),
      statBarRTotal: document.getElementById('stat-bar-r-total'),
      
      statValLStreak: document.getElementById('stat-val-l-streak'),
      statValRStreak: document.getElementById('stat-val-r-streak'),
      statBarLStreak: document.getElementById('stat-bar-l-streak'),
      statBarRStreak: document.getElementById('stat-bar-r-streak')
    };
  }

  bindEvents() {
    // Switch sides button
    this.el.btnSwitchSides.addEventListener('click', () => this.switchSides());

    // Setup visual highlights on card tap (haptic feel)
    this.setupCardHaptics(this.el.cardP1);
    this.setupCardHaptics(this.el.cardP2);

    // Keyboard controls for scorekeeper convenience
    document.addEventListener('keydown', (e) => {
      if (this.state.isMatchOver) return;
      // Exclude input typing
      if (document.activeElement.tagName === 'INPUT') return;

      if (e.key === 'a' || e.key === 'A' || e.key === 'ArrowLeft') {
        this.scorePoint(0); // Left visual card
      } else if (e.key === 'd' || e.key === 'D' || e.key === 'ArrowRight') {
        this.scorePoint(1); // Right visual card
      } else if ((e.key === 'z' || e.key === 'Z') && (e.ctrlKey || e.metaKey)) {
        this.undo();
      }
    });
  }

  setupCardHaptics(card) {
    card.addEventListener('pointerdown', () => {
      card.style.transform = 'scale(0.95)';
    });
    card.addEventListener('pointerup', () => {
      card.style.transform = '';
    });
    card.addEventListener('pointerleave', () => {
      card.style.transform = '';
    });
  }

  // Save state snapshot for Undo
  pushHistory() {
    const snapshot = JSON.stringify({
      scores: [...this.state.scores],
      sets: this.state.sets.map(set => [...set]),
      setWinners: [...this.state.setWinners],
      activeSet: this.state.activeSet,
      server: this.state.server,
      isMatchOver: this.state.isMatchOver,
      pointHistory: [...this.state.pointHistory],
      setPointHistories: this.state.setPointHistories.map(h => [...h])
    });
    this.state.historyStack.push(snapshot);
  }

  // Handle Score Tap: visualIndex is 0 (Left Card) or 1 (Right Card)
  scorePoint(visualIndex) {
    if (this.state.isMatchOver) return;

    // Save state for undo
    this.pushHistory();

    // Map visual index to logical player index
    const logicalPlayer = this.state.swappedSides ? (1 - visualIndex) : visualIndex;

    this.playAudioFeedback();
    this.triggerHapticFeedback();

    // Increment score
    this.state.scores[logicalPlayer]++;
    this.state.server = logicalPlayer; // Winner of rally serves next
    
    // Log point history
    this.state.pointHistory.push(logicalPlayer);
    this.state.setPointHistories[this.state.activeSet].push(logicalPlayer);

    // Apply pop animation on the score number
    const targetScoreEl = visualIndex === 0 ? this.el.scoreP1 : this.el.scoreP2;
    targetScoreEl.classList.remove('score-pop');
    void targetScoreEl.offsetWidth; // Trigger reflow
    targetScoreEl.classList.add('score-pop');

    this.checkSetStatus();
    this.updateUI();
  }

  checkSetStatus() {
    const s0 = this.state.scores[0];
    const s1 = this.state.scores[1];
    let setWinner = null;

    // Badminton rule: First to 21, must lead by 2. Cap at 30.
    if (s0 >= 21 && (s0 - s1 >= 2)) {
      setWinner = 0;
    } else if (s1 >= 21 && (s1 - s0 >= 2)) {
      setWinner = 1;
    } else if (s0 === 30) {
      setWinner = 0;
    } else if (s1 === 30) {
      setWinner = 1;
    }

    if (setWinner !== null) {
      // Lock the set score
      this.state.sets[this.state.activeSet] = [s0, s1];
      this.state.setWinners[this.state.activeSet] = setWinner;

      // Count total sets won by each player
      const wins = [0, 0];
      this.state.setWinners.forEach(w => {
        if (w !== null) wins[w]++;
      });

      // Best of 3 sets: first to win 2 sets wins the match
      if (wins[0] === 2 || wins[1] === 2) {
        this.state.isMatchOver = true;
        this.state.scores = [s0, s1]; // Keep score as is
        this.showWinner(wins[0] === 2 ? 0 : 1);
      } else {
        // Prepare next set
        this.state.activeSet++;
        this.state.scores = [0, 0];
        // The winner of the previous set serves first in the next set
        this.state.server = setWinner; 
      }
    }
  }

  undo() {
    if (this.state.historyStack.length === 0) return;

    const snapshotStr = this.state.historyStack.pop();
    const snapshot = JSON.parse(snapshotStr);

    // Restore state
    this.state.scores = snapshot.scores;
    this.state.sets = snapshot.sets;
    this.state.setWinners = snapshot.setWinners;
    this.state.activeSet = snapshot.activeSet;
    this.state.server = snapshot.server;
    this.state.isMatchOver = snapshot.isMatchOver;
    this.state.pointHistory = snapshot.pointHistory;
    this.state.setPointHistories = snapshot.setPointHistories;

    this.playAudioFeedback(400, 0.05); // Deeper tone for undo
    this.updateUI();
  }

  switchSides() {
    this.state.swappedSides = !this.state.swappedSides;
    this.updateUI();
  }

  updatePlayerName(playerIndex, newName) {
    this.state.playerNames[playerIndex] = newName.trim() || `Player ${playerIndex + 1}`;
    this.updateUI();
  }

  confirmNewMatch() {
    if (confirm("ต้องการเริ่มแมตช์ใหม่ใช่หรือไม่? คะแนนที่กำลังเล่นอยู่จะหายไป")) {
      this.resetMatch();
    }
  }

  resetMatch() {
    this.state.scores = [0, 0];
    this.state.sets = [
      [null, null],
      [null, null],
      [null, null]
    ];
    this.state.setWinners = [null, null, null];
    this.state.activeSet = 0;
    this.state.server = 0;
    this.state.isMatchOver = false;
    this.state.pointHistory = [];
    this.state.setPointHistories = [[], [], []];
    this.state.historyStack = [];
    this.updateUI();
  }

  // Renders state changes to the DOM
  updateUI() {
    // 1. Identify visual orientation
    // visualLeft corresponds to Player index depending on swappedSides
    const leftPlayerIdx = this.state.swappedSides ? 1 : 0;
    const rightPlayerIdx = this.state.swappedSides ? 0 : 1;

    // 2. Render Score Cards content
    this.el.scoreP1.textContent = this.padZero(this.state.scores[leftPlayerIdx]);
    this.el.scoreP2.textContent = this.padZero(this.state.scores[rightPlayerIdx]);

    this.el.nameP1.value = this.state.playerNames[leftPlayerIdx];
    this.el.nameP2.value = this.state.playerNames[rightPlayerIdx];

    // 3. Render Service Indicator
    // Left serve active if left player is serving
    const isLeftServing = this.state.server === leftPlayerIdx;
    const isRightServing = this.state.server === rightPlayerIdx;

    if (isLeftServing && !this.state.isMatchOver) {
      this.el.serveP1.classList.add('active');
      const score = this.state.scores[leftPlayerIdx];
      // Even score -> Right service court, Odd score -> Left service court
      this.el.serveTextP1.textContent = score % 2 === 0 ? "RIGHT SERVE" : "LEFT SERVE";
    } else {
      this.el.serveP1.classList.remove('active');
    }

    if (isRightServing && !this.state.isMatchOver) {
      this.el.serveP2.classList.add('active');
      const score = this.state.scores[rightPlayerIdx];
      this.el.serveTextP2.textContent = score % 2 === 0 ? "RIGHT SERVE" : "LEFT SERVE";
    } else {
      this.el.serveP2.classList.remove('active');
    }

    // 4. Render Sets table
    // Important: Left column of SETS displays Player 0, Right column displays Player 1
    for (let s = 0; s < 3; s++) {
      const row = this.el.setRows[s];
      const scoreL = this.el.setScoresL[s];
      const scoreR = this.el.setScoresR[s];

      const setVal = this.state.sets[s];
      const winner = this.state.setWinners[s];

      // Remove classes
      row.className = 'set-row';
      scoreL.className = 'set-score left';
      scoreR.className = 'set-score right';

      if (s === this.state.activeSet && !this.state.isMatchOver) {
        row.classList.add('active');
        // Show active score counting up
        scoreL.textContent = this.state.scores[0];
        scoreR.textContent = this.state.scores[1];
      } else if (setVal[0] !== null) {
        row.classList.add('completed');
        scoreL.textContent = setVal[0];
        scoreR.textContent = setVal[1];

        // Bold the set winner's score
        if (winner === 0) {
          scoreL.classList.add('winner');
        } else if (winner === 1) {
          scoreR.classList.add('winner');
        }
      } else {
        scoreL.textContent = '-';
        scoreR.textContent = '-';
      }
    }

    // Disable buttons appropriately
    this.el.btnUndo.disabled = this.state.historyStack.length === 0;
    this.el.btnUndo.style.opacity = this.state.historyStack.length === 0 ? '0.4' : '1';
  }

  padZero(num) {
    return num < 10 ? `0${num}` : num;
  }

  // Synthesis-based clean audio feedback
  playAudioFeedback(frequency = 700, duration = 0.06) {
    try {
      const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
      const oscillator = audioCtx.createOscillator();
      const gainNode = audioCtx.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioCtx.destination);

      oscillator.type = 'sine';
      oscillator.frequency.value = frequency;

      // Soft click sound envelope
      gainNode.gain.setValueAtTime(0.08, audioCtx.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + duration);

      oscillator.start();
      oscillator.stop(audioCtx.currentTime + duration);
    } catch (e) {
      console.warn("Web Audio API is not permitted or supported yet.");
    }
  }

  triggerHapticFeedback() {
    if (navigator.vibrate) {
      navigator.vibrate(10);
    }
  }

  // Slide stats modal up and calculate values
  toggleStatsModal(show) {
    if (show) {
      this.calculateStats();
      this.el.statsModal.classList.add('active');
    } else {
      this.el.statsModal.classList.remove('active');
    }
  }

  calculateStats() {
    // 1. Total Points
    let totalP0 = 0;
    let totalP1 = 0;

    // Sum sets
    this.state.sets.forEach(s => {
      if (s[0] !== null) {
        totalP0 += s[0];
        totalP1 += s[1];
      }
    });

    // Add current live scores
    if (!this.state.isMatchOver) {
      totalP0 += this.state.scores[0];
      totalP1 += this.state.scores[1];
    }

    this.el.statValLTotal.textContent = totalP0;
    this.el.statValRTotal.textContent = totalP1;

    // Calculate bar percentage
    const grandTotal = totalP0 + totalP1;
    let pctLTotal = 50;
    let pctRTotal = 50;
    if (grandTotal > 0) {
      pctLTotal = Math.round((totalP0 / grandTotal) * 100);
      pctRTotal = 100 - pctLTotal;
    }
    this.el.statBarLTotal.style.width = `${pctLTotal}%`;
    this.el.statBarRTotal.style.width = `${pctRTotal}%`;

    // 2. Streaks (longest run of consecutive points)
    let maxStreak0 = 0;
    let maxStreak1 = 0;
    let currentStreak0 = 0;
    let currentStreak1 = 0;

    this.state.pointHistory.forEach(scorer => {
      if (scorer === 0) {
        currentStreak0++;
        currentStreak1 = 0;
        if (currentStreak0 > maxStreak0) maxStreak0 = currentStreak0;
      } else {
        currentStreak1++;
        currentStreak0 = 0;
        if (currentStreak1 > maxStreak1) maxStreak1 = currentStreak1;
      }
    });

    this.el.statValLStreak.textContent = maxStreak0;
    this.el.statValRStreak.textContent = maxStreak1;

    const grandStreak = maxStreak0 + maxStreak1;
    let pctLStreak = 50;
    let pctRStreak = 50;
    if (grandStreak > 0) {
      pctLStreak = Math.round((maxStreak0 / grandStreak) * 100);
      pctRStreak = 100 - pctLStreak;
    }
    this.el.statBarLStreak.style.width = `${pctLStreak}%`;
    this.el.statBarRStreak.style.width = `${pctRStreak}%`;

    // 3. Render point sequence graph
    this.el.timelineChart.innerHTML = '';
    const currentSetPoints = this.state.setPointHistories[this.state.activeSet];
    
    if (currentSetPoints.length === 0) {
      const placeholder = document.createElement('div');
      placeholder.style.color = 'var(--text-secondary)';
      placeholder.style.fontSize = '13px';
      placeholder.style.textAlign = 'center';
      placeholder.style.width = '100%';
      placeholder.textContent = 'ยังไม่มีคะแนนในเซตนี้';
      this.el.timelineChart.appendChild(placeholder);
    } else {
      currentSetPoints.forEach((scorer) => {
        const bar = document.createElement('div');
        bar.className = `timeline-bar ${scorer === 0 ? 'left-point' : 'right-point'}`;
        // Set fixed height or vary it slightly for visuals
        bar.style.height = '40px';
        this.el.timelineChart.appendChild(bar);
      });
    }
  }

  showWinner(winnerIndex) {
    const winnerName = this.state.playerNames[winnerIndex];
    this.el.winnerName.textContent = `${winnerName} ชนะการแข่งขัน!`;

    // Format score line (e.g. 2 Sets to 1)
    const wins = [0, 0];
    this.state.setWinners.forEach(w => {
      if (w !== null) wins[w]++;
    });
    this.el.winnerScoreLine.textContent = `${wins[winnerIndex]} เซต ต่อ ${wins[1 - winnerIndex]}`;

    // Pop the overlay
    this.el.winnerModal.classList.add('active');
    
    // Play celebratory tone sequence
    this.playCelebrationMelody();

    // Spawn confetti
    this.spawnConfetti();
  }

  playCelebrationMelody() {
    const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
    notes.forEach((freq, index) => {
      setTimeout(() => {
        this.playAudioFeedback(freq, 0.15);
      }, index * 150);
    });
  }

  spawnConfetti() {
    this.el.confettiContainer.innerHTML = '';
    const colors = ['#0071e3', '#34c759', '#ff9500', '#ff2d55', '#af52de'];
    
    for (let i = 0; i < 50; i++) {
      const confetti = document.createElement('div');
      confetti.className = 'confetti';
      confetti.style.left = `${Math.random() * 100}%`;
      confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
      confetti.style.animationDelay = `${Math.random() * 2}s`;
      confetti.style.width = `${Math.random() * 8 + 6}px`;
      confetti.style.height = `${Math.random() * 14 + 8}px`;
      this.el.confettiContainer.appendChild(confetti);
    }
  }

  closeWinnerModalAndReset() {
    this.el.winnerModal.classList.remove('active');
    this.resetMatch();
  }
}

// Instantiate App
window.addEventListener('DOMContentLoaded', () => {
  window.app = new BadmintonApp();
});
