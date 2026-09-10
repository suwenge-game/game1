/* DeskGame 2048 — self-developed merge puzzle
 * Original implementation: 4x4 (classic), 3x3 (sprint), 5x5 (expert).
 * Keyboard (arrows/WASD) + touch swipe. Score + best saved locally.
 */
(function () {
  "use strict";

  var CONFIGS = {
    3: { label: "3×3 Sprint", winTile: 512 },
    4: { label: "4×4 Classic", winTile: 2048 },
    5: { label: "5×5 Expert", winTile: 4096 }
  };
  var LS_KEY = "dg2048-best-v1";

  function loadBest() {
    try {
      var raw = localStorage.getItem(LS_KEY);
      var obj = raw ? JSON.parse(raw) : {};
      return typeof obj === "object" && obj !== null ? obj : {};
    } catch (e) { return {}; }
  }

  function saveBest(best) {
    try { localStorage.setItem(LS_KEY, JSON.stringify(best)); } catch (e) {}
  }

  function Game(host) {
    this.host = host;
    this.size = 4;
    this.grid = [];
    this.score = 0;
    this.best = loadBest();
    this.won = false;
    this.over = false;
    this.build();
    this.newGame();
  }

  Game.prototype.build = function () {
    var h = this.host;
    h.innerHTML =
      '<div class="dg2048-head">' +
        '<div class="dg2048-scores">' +
          '<div class="dg2048-score"><span class="dg2048-label">Score</span><span class="dg2048-value dg2048-score-val">0</span></div>' +
          '<div class="dg2048-score"><span class="dg2048-label">Best</span><span class="dg2048-value dg2048-best-val">0</span></div>' +
        '</div>' +
        '<div class="dg2048-controls">' +
          '<select class="dg2048-size" aria-label="Board size">' +
            '<option value="3">3×3 Sprint</option>' +
            '<option value="4" selected>4×4 Classic</option>' +
            '<option value="5">5×5 Expert</option>' +
          '</select>' +
          '<button type="button" class="dg2048-new" aria-label="Start new game">New Game</button>' +
        '</div>' +
      '</div>' +
      '<div class="dg2048-board-wrap">' +
        '<div class="dg2048-board" role="grid" aria-label="2048 board"></div>' +
        '<div class="dg2048-overlay" hidden>' +
          '<div class="dg2048-overlay-card">' +
            '<h3 class="dg2048-overlay-title"></h3>' +
            '<p class="dg2048-overlay-text"></p>' +
            '<div class="dg2048-overlay-actions">' +
              '<button type="button" class="dg2048-continue">Keep Playing</button>' +
              '<button type="button" class="dg2048-again">New Game</button>' +
            '</div>' +
          '</div>' +
        '</div>' +
      '</div>' +
      '<p class="dg2048-hint">Use arrow keys / WASD, or swipe on touch screens.</p>';

    this.el = {
      size: h.querySelector(".dg2048-size"),
      newBtn: h.querySelector(".dg2048-new"),
      board: h.querySelector(".dg2048-board"),
      score: h.querySelector(".dg2048-score-val"),
      best: h.querySelector(".dg2048-best-val"),
      overlay: h.querySelector(".dg2048-overlay"),
      title: h.querySelector(".dg2048-overlay-title"),
      text: h.querySelector(".dg2048-overlay-text"),
      continueBtn: h.querySelector(".dg2048-continue"),
      againBtn: h.querySelector(".dg2048-again")
    };

    this.el.size.addEventListener("change", (function () {
      this.size = parseInt(this.el.size.value, 10);
      this.newGame();
    }).bind(this));

    this.el.newBtn.addEventListener("click", (function () {
      this.newGame();
    }).bind(this));

    this.el.continueBtn.addEventListener("click", (function () {
      this.overlay(false);
    }).bind(this));

    this.el.againBtn.addEventListener("click", (function () {
      this.newGame();
    }).bind(this));

    // keyboard
    document.addEventListener("keydown", (function (e) {
      var k = e.key;
      var dir = null;
      if (k === "ArrowUp" || k === "w" || k === "W") dir = "up";
      else if (k === "ArrowDown" || k === "s" || k === "S") dir = "down";
      else if (k === "ArrowLeft" || k === "a" || k === "A") dir = "left";
      else if (k === "ArrowRight" || k === "d" || k === "D") dir = "right";
      if (dir) {
        e.preventDefault();
        this.move(dir);
      }
    }).bind(this));

    // touch swipe
    var startX = 0, startY = 0, tracking = false;
    h.addEventListener("touchstart", (function (e) {
      if (e.touches.length !== 1) return;
      startX = e.touches[0].clientX;
      startY = e.touches[0].clientY;
      tracking = true;
    }).bind(this), { passive: true });

    h.addEventListener("touchend", (function (e) {
      if (!tracking) return;
      tracking = false;
      var dx = e.changedTouches[0].clientX - startX;
      var dy = e.changedTouches[0].clientY - startY;
      var ax = Math.abs(dx), ay = Math.abs(dy);
      if (Math.max(ax, ay) < 24) return;
      var dir = ax > ay ? (dx > 0 ? "right" : "left") : (dy > 0 ? "down" : "up");
      e.preventDefault();
      this.move(dir);
    }).bind(this), { passive: false });
  };

  Game.prototype.newGame = function () {
    var n = this.size;
    this.grid = [];
    for (var r = 0; r < n; r++) {
      this.grid[r] = new Array(n).fill(0);
    }
    this.score = 0;
    this.won = false;
    this.over = false;
    this.spawn();
    this.spawn();
    this.render();
  };

  Game.prototype.spawn = function () {
    var empties = [];
    for (var r = 0; r < this.size; r++) {
      for (var c = 0; c < this.size; c++) {
        if (this.grid[r][c] === 0) empties.push([r, c]);
      }
    }
    if (!empties.length) return;
    var pick = empties[Math.floor(Math.random() * empties.length)];
    this.grid[pick[0]][pick[1]] = Math.random() < 0.9 ? 2 : 4;
  };

  // returns { line: merged line (target direction), gained }
  Game.prototype.mergeLine = function (vals) {
    var moved = vals.filter(function (v) { return v !== 0; });
    var out = [];
    var gained = 0;
    for (var i = 0; i < moved.length; i++) {
      if (i + 1 < moved.length && moved[i] === moved[i + 1]) {
        out.push(moved[i] * 2);
        gained += moved[i] * 2;
        i++;
      } else {
        out.push(moved[i]);
      }
    }
    while (out.length < this.size) out.push(0);
    return { line: out, gained: gained };
  };

  Game.prototype.move = function (dir) {
    if (this.over) return;
    var n = this.size;
    var moved = false;
    var gained = 0;

    function extract(g, index) {
      var arr = [];
      for (var i = 0; i < n; i++) {
        if (dir === "left") arr.push(g[index][i]);
        else if (dir === "right") arr.push(g[index][n - 1 - i]);
        else if (dir === "up") arr.push(g[i][index]);
        else arr.push(g[n - 1 - i][index]);
      }
      return arr;
    }
    function write(g, index, arr) {
      for (var i = 0; i < n; i++) {
        if (dir === "left") g[index][i] = arr[i];
        else if (dir === "right") g[index][n - 1 - i] = arr[i];
        else if (dir === "up") g[i][index] = arr[i];
        else g[n - 1 - i][index] = arr[i];
      }
    }

    for (var line = 0; line < n; line++) {
      var src = extract(this.grid, line);
      var res = this.mergeLine(src);
      if (res.line.join(",") !== src.join(",")) {
        write(this.grid, line, res.line);
        moved = true;
        gained += res.gained;
      }
    }

    if (!moved) {
      // 无有效移动：若棋盘已死局（无空格且无相邻相同），仍然结束
      if (!this.canMove()) {
        this.over = true;
        this.showOver();
      }
      return;
    }

    this.score += gained;
    this.spawn();
    this.render();

    if (!this.won && this.hasTile(CONFIGS[this.size].winTile)) {
      this.won = true;
      this.showWin();
    } else if (!this.canMove()) {
      this.over = true;
      this.showOver();
    }
  };

  Game.prototype.hasTile = function (v) {
    for (var r = 0; r < this.size; r++) {
      for (var c = 0; c < this.size; c++) {
        if (this.grid[r][c] === v) return true;
      }
    }
    return false;
  };

  Game.prototype.canMove = function () {
    var n = this.size;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (this.grid[r][c] === 0) return true;
        if (c + 1 < n && this.grid[r][c] === this.grid[r][c + 1]) return true;
        if (r + 1 < n && this.grid[r][c] === this.grid[r + 1][c]) return true;
      }
    }
    return false;
  };

  Game.prototype.overlay = function (show) {
    this.el.overlay.hidden = !show;
  };

  Game.prototype.showWin = function () {
    this.el.title.textContent = "You Win!";
    this.el.text.textContent = "Tile " + CONFIGS[this.size].winTile + " reached. Keep going for a higher score.";
    this.el.continueBtn.style.display = "";
    this.overlay(true);
  };

  Game.prototype.showOver = function () {
    this.el.title.textContent = "Game Over";
    this.el.text.textContent = "No more moves. Final score: " + this.score + ".";
    this.el.continueBtn.style.display = "none";
    this.overlay(true);
  };

  Game.prototype.render = function () {
    var n = this.size;
    var frag = document.createDocumentFragment();
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        var v = this.grid[r][c];
        var cell = document.createElement("div");
        cell.className = "dg2048-tile dg2048-v" + v;
        cell.setAttribute("role", "gridcell");
        cell.setAttribute("aria-label", v === 0 ? "empty" : String(v));
        cell.textContent = v === 0 ? "" : v;
        frag.appendChild(cell);
      }
    }
    this.el.board.replaceChildren(frag);
    this.el.board.className = "dg2048-board dg2048-size-" + n;
    this.el.score.textContent = this.score;
    var bestFor = this.best[this.size] || 0;
    if (this.score > bestFor) {
      this.best[this.size] = this.score;
      saveBest(this.best);
      bestFor = this.score;
    }
    this.el.best.textContent = bestFor;
  };

  function initAll() {
    var hosts = document.querySelectorAll("[data-dg2048]");
    for (var i = 0; i < hosts.length; i++) {
      new Game(hosts[i]);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initAll);
  } else {
    initAll();
  }

  // export for tests
  window.DG2048 = { Game: Game, mergeLine: function (vals) { var g = new Game(document.createElement("div")); return g.mergeLine(vals); }, CONFIGS: CONFIGS };
})();
