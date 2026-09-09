# GameJam 2026 — "Degrees of Freedom"
### Planning Doc — BUET Robotics Society Intra GameJam

**Dev window:** 10–17 Sept (11:59 PM) · **Showcase:** 18 Sept, 10:00 AM, ECE Building
**Theme note (from organizers):** the robot/joint artwork is *not* the constraint — interpret "Degrees of Freedom" (DoF) however you want, as long as the connection is meaningful.

---

## 1. How we're reading the theme

"Degrees of Freedom" doesn't have to mean a robot arm. Useful framings to brainstorm from:

- **Literal (physics/mechanics):** how many independent axes something can move/rotate along (X, Y, rotation, scale...). Games can *restrict, grant, or juggle* these axes as the core mechanic.
- **Choice/constraint:** "freedom" as in options available to the player — a game about gaining or losing choices.
- **Social/personal freedom:** more narrative — freedom from rules, control, surveillance, expectation. Powerful but harder to make "fun after 1000 plays" in 7 days.
- **Freedom vs. control (co-op):** splitting one entity's degrees of freedom across multiple players who must cooperate.

Because judging weighs **Gameplay & Fun (30%)** and **Creativity (25%)** far more than **Technical Achievement (10%)**, we should pick the *mechanical/literal* framing — it's the one that turns directly into a tight, replayable core loop without needing a big narrative or art budget.

---

## 2. Selection criteria (why these ideas and not others)

| Criterion | Why it matters here |
|---|---|
| **1 core mechanic, learnable in <10s** | Judges and visitors will pick it up cold at the showcase. |
| **Procedural/random content** | So the game doesn't get stale after 1000 plays — no hand-authored level list to run out of. |
| **Small art footprint** | Shapes/particles > sprites. Saves days for polish & juice instead of asset creation. |
| **Score/run-based, not narrative** | Faster to build, naturally "just one more try" replayable, easy to demo in 60–90s video. |
| **Strong, honest theme tie** | Judged explicitly (20%) — mechanic should *be* about degrees of freedom, not just reference it in flavor text. |

---

## 3. Game concept shortlist

### 🥇 Option A — "1 AXIS" (top-down dodge/survival, RECOMMENDED)
You normally move freely in 2D (2 degrees of freedom: X + Y). Every few seconds a "constraint field" hits the arena and strips you down to **1 axis** (X-only or Y-only movement) for a stretch, while hazards keep spawning in full 2D. Power-ups can *grant back* a temporary 3rd DoF (dash, rotation-shot, time-slow). Endless survival, score = time survived + orbs collected.
- **Why it fits:** DoF is *literally* the mechanic, not a theme skin.
- **Feasibility:** Single scene, circle/square colliders, no animation needed. Buildable by day 3, then pure polish.
- **Replayability:** Procedural hazard patterns + increasing difficulty curve = classic "one more run" hook (Crossy Road / Downwell style).
- **Risk:** Needs tight game-feel (screen shake, hit-stop, sound) or it reads as flat — budget time for juice.

### 🥈 Option B — "TETHER" (local co-op, 2–4 players)
One ship/blob has 4 degrees of freedom: move-X, move-Y, rotate, scale. Each connected player controls **exactly one** of those axes (via keyboard zones or separate controllers) and must communicate to navigate an obstacle course / thread through gaps together.
- **Why it fits:** Splits DoF across people — a fresh, very literal but *social* reading of the theme.
- **Feasibility:** Medium — needs simple physics + input remapping per player, but no AI, no complex levels (procedurally rotate/scatter obstacles).
- **Replayability:** High *if* played with friends (which fits a showcase full of teams) — but weaker as a solo/judge play-test unless you simulate the other axes with AI/auto-pilot as a single-player fallback.
- **Risk:** Local co-op is harder to demo to a judge playing alone — mitigate with a single-player "control all 4 with keys, but reduced reaction window" mode.

### 🥉 Option C — "SLACK" (ragdoll/DoF golf-physics puzzler)
Get a jointed ragdoll (2–3 segments) into a goal zone. You don't control the ragdoll directly — you can only **lock/unlock specific joints' degrees of freedom** for a limited "budget" per level, then let physics (gravity, momentum) do the rest, like a puzzle-golf hybrid.
- **Why it fits:** Directly reifies "degrees of freedom" as the resource you spend.
- **Feasibility:** Riskiest — needs a working 2D physics ragdoll (Box2D/Godot physics joints) tuned to feel good; that tuning can eat days.
- **Replayability:** Great if procedural level generator works (endless "par" challenges); weak if you end up hand-building 10 fixed levels.
- **Verdict:** Fun concept, but higher technical risk for a 7-day solo/small-team jam — treat as a stretch pick only if the team already knows a physics engine well.

### Honorable mention — "ONE MORE HINGE" (idle/incremental)
You unlock new degrees of freedom (new movement types) as permanent upgrades between runs of a short obstacle gauntlet, roguelite-style (Vampire-Survivors-lite meta progression). Good replay hook, but a meta-progression system is more scope than a 7-day jam needs — keep as a stretch goal bolt-on to Option A rather than its own game.

---

## 4. Recommendation

**Build Option A ("1 AXIS")** as the primary target, with Option B's "split control" idea kept as a possible **stretch mode** (e.g., a 2-player variant unlocked later) if time allows. This gives:
- A guaranteed, demoable, judge-friendly build by mid-week.
- Theme connection that's impossible to miss (literally titled around DoF).
- Small, focused scope that leaves days 5–7 for polish, sound, and the presentation video — which is where jam games usually win or lose points (Polish & Presentation = 15%, plus Gameplay & Fun = 30%).

*(Swap in Option B or C later in this doc once the team picks — this file is meant to be edited as we fine-tune.)*

---

## 5. MVP scope (Option A)

**Core loop (must-have):**
1. Player controls a shape in a bounded arena, full 2D movement by default.
2. Hazards (simple shapes) spawn and move toward/across the arena; touching one ends the run.
3. Every N seconds, a "Constraint Field" event locks movement to X-only or Y-only for a duration (clear visual/audio cue).
4. Score increases over time + bonus orbs to collect.
5. Difficulty ramps (spawn rate/speed) the longer you survive.
6. Game over → score, "run again" instantly (no loading screens — replayability depends on near-zero friction between runs).

**Stretch goals (only after MVP is fully working and fun):**
- Power-up that grants a temporary extra DoF (dash / short teleport / rotate-shield).
- Simple local leaderboard (top 5 runs this session).
- Screen shake, hit-stop, particle burst, and a punchy SFX pack for feedback.
- Palette/theme pass (color shifts as difficulty rises).
- Optional 2-player "shared constraint" mode (co-op flavor of Option B, added on top).

**Explicitly out of scope for 7 days:** cutscenes/story, hand-built level list, custom character animation rigs, save systems beyond a session high score.

---

## 6. Day-by-day plan

> Dates below use the rulebook's real dates. Times are Bangladesh (UTC+6).

| Day | Date | Focus | Deliverable by end of day |
|---|---|---|---|
| 1 | 10 Sept | Theme reveal (12:00 AM) → lock concept, create GitHub repo, first real commit, set up engine project, core movement (free 2D) | Player can move in an empty arena; repo has its real first commit |
| 2 | 11 Sept | Hazard spawning + collision + game-over/restart loop | A bare but complete "die and retry" loop |
| 3 | 12 Sept | Constraint Field mechanic (axis lock) + visual/audio cue + difficulty ramp | The actual "degrees of freedom" mechanic is playable and clearly readable |
| 4 | 13 Sept | Scoring, orb pickups, tuning spawn curves, first playtest pass with teammates/friends | Feels like a real, if ugly, game |
| 5 | 14 Sept | Juice pass: screen shake, particles, SFX, basic UI (score, game over screen, restart), stretch power-up | Game feels good, not just functional |
| 6 | 15 Sept | Art/visual pass (palette, simple shapes → polished shapes or minimal sprites), build export test (Windows + Web), fix bugs from playtesting | Exportable, installable build that runs clean on another machine |
| 7 | 16 Sept | Buffer day: bug fixes only, no new features after midday. Start writing itch.io page copy, screenshots, credits list | Feature-frozen build; content for submission page drafted |
| — | 17 Sept | Record & edit the 60–90s Gameplay Presentation Video, final GitHub commit + tag `submission-v1`, full submission package uploaded to itch.io **before 11:59 PM** | Submitted, tested on a second machine/browser |
| — | 18 Sept | Showcase & judging (10:00 AM, ECE Building) — bring a charged laptop + any adapters/controllers | Live demo |

**Golden rule for scope control:** if a feature isn't done by the end of Day 5, it becomes a stretch goal or gets cut — Days 6–7 are protected for stability and submission quality, not new mechanics. A small polished game beats a bigger broken one per the judging criteria's own explicit note.

---

## 7. Suggested tech stack

- **Engine:** Godot (fast 2D iteration, easy Web + Windows export, free) — or GameMaker if the team already knows it. Avoid Unreal/Unity unless someone is already fluent; setup/export overhead isn't worth it for a 7-day 2D arcade game.
- **Version control:** GitHub repo created fresh today, first commit **after** 10 Sept 12:00 AM (rulebook requirement). Commit often with real messages — no squashing/backdating.
- **Audio:** freesound.org (credit required) or a couple of quick SFX made with a tool like sfxr/jsfxr — free, fast, fits a minimal art style.
- **Hosting/build:** itch.io page set up early (even empty) so upload mechanics are tested well before the deadline, per the organizers' "start submission 1–2 days early" advice.

---

## 8. Submission package checklist (from the rulebook)

- [ ] Team name, member names, game title, short description
- [ ] Gameplay Presentation Video (60–90s, shows title, core loop, theme connection)
- [ ] Screenshots
- [ ] itch.io page with Windows build and/or Web build, tested on a second machine/browser
- [ ] GitHub repository link (first commit ≥ 10 Sept 12:00 AM, final commit < 17 Sept 11:59 PM, tagged e.g. `submission-v1`)
- [ ] Engine/framework/tools used
- [ ] Run instructions and controls
- [ ] Credits for external assets/libraries/significant AI-generated content
- [ ] Known bugs or limitations listed
- [ ] Charged demo laptop + adapters/controllers for 18 Sept

---

## 9. Open questions to fine-tune next

- Final game title / visual style direction (palette, shape language, minimal vs. more illustrated).
- Exact axis-lock telegraph (color change? screen border? countdown bar?) — needs to be instantly readable.
- Whether to build the 2-player stretch mode at all, or spend that time on juice instead.
- Who owns which day's tasks if team > 1 person.