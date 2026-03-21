# Feature Roadmap

**Vision:** An intelligent, personalized, automatic RSS feed generator with long-term memory.

**Core insight:** The current system is *stateless in the way that matters*. It knows what titles it wrote (dedup fingerprints), but it doesn't know what it *learned*. The leap from "search-and-summarize tool" to "intelligent researcher" is fundamentally about memory — and everything else builds on that.

---

## Phase 1: Long-term Knowledge Memory

**Goal:** Transform state from dedup fingerprints into accumulated knowledge.

**The problem today:** After 10 runs, the agent knows exactly as much as it did on run 1. It avoids repeating titles, but it can't say "here's what I know about this topic so far" or "this story has been developing for 3 weeks." Each run starts from scratch intellectually.

### What changes

**State schema expansion** — `.state/<feed_id>.json` gains a `knowledge` object:

```json
{
  "last_run": "...",
  "entries": [...],
  "knowledge": {
    "brief": "2-3 paragraph running summary of what's known about this topic",
    "key_entities": ["Meta MSL", "Avocado model", "Grand Teton cluster"],
    "active_threads": [
      {
        "thread": "Avocado model delay",
        "status": "ongoing",
        "first_seen": "2026-03-19",
        "last_updated": "2026-03-21",
        "updates": 2,
        "summary": "Initially expected Q1, pushed to May. Performance gaps vs Gemini 2.5."
      }
    ]
  }
}
```

**feed.py new commands:**

| Command | Purpose |
|---------|---------|
| `feed.py knowledge <feed_id>` | Dump current knowledge brief (for agent to read) |
| `feed.py learn <feed_id> --brief "..." --entities "e1,e2" --threads '<json>'` | Update knowledge after a research cycle |

**Agent protocol changes:**
- **Before researching:** Read knowledge brief to orient. "I already know X, Y, Z about this topic. Let me look for what's new."
- **After writing entries:** Synthesize what was learned into a knowledge update. Update active threads (new, ongoing, resolved). Call `feed.py learn`.
- **Thread continuity:** When an entry relates to an active thread, reference it naturally: "Following the Avocado delay reported on March 19..."

### Done when
- After 3 consecutive runs on a feed, the knowledge brief accurately summarizes the topic's state
- Active threads are tracked and referenced in new entries
- Agent demonstrably uses prior knowledge to write better-contextualized entries

### Files touched
- `feed.py` — add `knowledge` and `learn` commands, extend state schema
- `.claude/agents/research.md` — add knowledge read/write steps to protocol
- `.claude/settings.json` — allow new feed.py commands

---

## Phase 2: Intelligent Research

**Goal:** Use accumulated memory to research smarter — better queries, source tracking, cross-feed awareness, story follow-up.

**The problem today:** The agent uses generic search queries derived from the feed description. It doesn't know which sources were useful before, can't follow up on developing stories, and treats each feed as completely independent.

### What changes

**Source tracking in state:**

```json
{
  "knowledge": {
    "source_quality": {
      "arxiv.org": { "useful_hits": 5, "last_used": "2026-03-21" },
      "techcrunch.com": { "useful_hits": 2, "last_used": "2026-03-20" },
      "blogspam.example": { "useful_hits": 0, "skip": true }
    }
  }
}
```

**Config additions:**

```yaml
feeds:
  - id: meta-news
    # ... existing fields ...
    prefer_sources:
      - arxiv.org
      - ai.meta.com
      - research.facebook.com
    skip_sources:
      - seekingalpha.com   # financial noise
```

**Agent upgrades:**

| Capability | How |
|-----------|-----|
| **Context-aware search** | Use knowledge brief to frame queries. Instead of generic "Meta AI news", search "Meta Avocado model May release update" because the brief knows that's the active thread |
| **Thread follow-up** | For each active thread with status=ongoing, generate a targeted search query |
| **Adaptive depth** | If 2 initial queries find nothing, try 2 more with different angles before skipping. Currently it's fixed at 2-4 |
| **Source preferences** | Prefer sources from config + high-quality sources from history. Skip known-bad sources |
| **Cross-feed notes** | When researching feed A and finding something relevant to feed B, note it. Add a `cross_references` field to entries |

**feed.py additions:**

| Command | Purpose |
|---------|---------|
| `feed.py sources <feed_id>` | Show source quality ratings |
| `feed.py learn` extended | Accept `--sources '<json>'` for source quality updates |

### Done when
- Search queries visibly incorporate prior knowledge (verifiable in logs)
- Active threads get explicit follow-up searches
- Source quality is tracked and influences research strategy
- Cross-feed connections appear in entries when relevant

### Files touched
- `feed.py` — extend `learn` command with source tracking, add `sources` command
- `.claude/agents/research.md` — context-aware search protocol, thread follow-up, source preferences
- `config.yaml` schema — `prefer_sources`, `skip_sources` fields

---

## Phase 3: Feedback & Personalization

**Goal:** The system adapts to what the user actually values, not just what the config says.

**The problem today:** The config is static. If the user consistently finds chip architecture entries more useful than org-change entries, the agent has no way to know. There's no feedback channel.

### What changes

**Feedback mechanism:**

```bash
# Rate an entry
python feed.py rate <feed_id> <guid> --score 1-5 --note "want more like this"

# Quick feedback
python feed.py rate <feed_id> <guid> --good
python feed.py rate <feed_id> <guid> --bad

# View inferred interests
python feed.py interests <feed_id>
```

**Feedback stored in state:**

```json
{
  "feedback": {
    "ratings": [
      {
        "guid": "...",
        "score": 5,
        "note": "great depth on chip architecture",
        "date": "2026-03-21"
      }
    ],
    "inferred_preferences": {
      "more": ["chip architecture", "training infrastructure", "benchmark results"],
      "less": ["org changes", "hiring news"],
      "preferred_depth": "deep"
    }
  }
}
```

**Agent behavior:**
- Read feedback before researching each feed
- Infer preferences from ratings: high-rated entries → more of that topic/depth/style
- Adjust entry priority: entries matching preferred patterns get richer treatment
- Add an `importance` tag to entries (high / medium / low) based on inferred relevance
- Periodically (every ~10 runs) generate a feedback summary: "Based on your ratings, you seem most interested in X. Should I adjust the feed description?"

**Config addition:**

```yaml
feeds:
  - id: meta-news
    evolve: true  # allow description to suggest updates based on feedback
```

### Done when
- User can rate entries via `feed.py rate`
- Agent visibly adjusts research focus based on accumulated ratings
- Entries have importance tags
- `feed.py interests` shows a reasonable interest profile after 5+ ratings

### Files touched
- `feed.py` — add `rate`, `interests` commands, extend state schema
- `.claude/agents/research.md` — read feedback, adjust research, add importance tags

---

## Phase 4: Automation, Reliability & Discoverability

**Goal:** Runs unattended on schedule, recovers from failures, easy to discover and subscribe.

**The problem today:** Runs are manual (`@research` or `claude -p`). All feeds process in one agent call — if it fails midway, some feeds are updated and others aren't. There's no index page, no OPML, no status dashboard.

### What changes

**Per-feed isolation:**

```bash
# Run one specific feed
@research meta-news

# Headless single-feed
claude -p "@research run meta-news"
```

The agent processes only the requested feed(s). Default (no args) still runs all.

**Scheduling config:**

```yaml
feeds:
  - id: meta-news
    schedule: twice-daily   # daily | twice-daily | weekly
  - id: soccer
    schedule: daily
  - id: umich-a2
    schedule: weekly
```

```bash
# Generate crontab entries from config
python feed.py crontab
# Output:
# 0 8,20 * * * cd /path && claude -p "@research run meta-news"
# 0 9 * * * cd /path && claude -p "@research run soccer"
# 0 10 * * 1 cd /path && claude -p "@research run umich-a2"
```

**Discoverability:**

```bash
# Generate OPML file for all feeds
python feed.py opml --base-url "https://user.github.io/rss-research"
# Output: feeds/index.opml

# publish.sh also generates index.html listing all feeds with subscribe links
```

**Operational tooling:**

```bash
# Status dashboard — all feeds at a glance
python feed.py status
# Output:
# Feed            Last Run              Entries  Health
# meta-news       2h ago (2026-03-21)   9/30     OK
# tech-products   2h ago (2026-03-21)   2/30     OK
# soccer          2h ago (2026-03-21)   2/30     OK
# umich-a2        2h ago (2026-03-21)   4/30     OK
```

**Structured logging:**

Each run appends to `.logs/<feed_id>/<date>.json`:

```json
{
  "feed_id": "meta-news",
  "started": "2026-03-21T04:06:19Z",
  "finished": "2026-03-21T04:08:41Z",
  "queries": ["Meta MSL latest 2026", "Avocado model release update"],
  "sources_consulted": 12,
  "entries_added": 4,
  "entries_skipped": 1,
  "threads_updated": ["Avocado delay"],
  "errors": []
}
```

**Error recovery:**
- Agent catches errors per-feed and continues to next feed
- Failed feeds are reported but don't block others
- `feed.py rollback <feed_id>` removes entries from the most recent run

**Dry run:**

```bash
@research --dry-run
# Shows: planned queries, active threads to follow up, estimated output — without writing anything
```

### Done when
- Single-feed runs work (`@research meta-news`)
- `feed.py crontab` generates valid crontab entries from config schedules
- `feed.py opml` generates valid OPML
- `publish.sh` generates an `index.html` alongside feeds
- `feed.py status` shows all-feeds dashboard
- Structured logs written per run
- Failure in one feed doesn't block others

### Files touched
- `feed.py` — add `opml`, `status`, `crontab`, `rollback` commands, structured logging
- `.claude/agents/research.md` — per-feed mode, dry-run mode, error isolation, logging
- `publish.sh` — generate index.html
- `config.yaml` schema — `schedule` field

---

## Implementation Order & Dependencies

```
Phase 1 ──→ Phase 2 ──→ Phase 3
  (memory)    (intelligence)  (personalization)
                                    │
                                    ↓
                               Phase 4
                            (automation)
```

- Phase 2 depends on Phase 1 (intelligence requires memory)
- Phase 3 depends on Phase 1 (feedback needs state infrastructure)
- Phase 3 can start in parallel with Phase 2
- Phase 4 is independent — can be done anytime, but most valuable after 1-3

## What the product feels like after each phase

| Phase | User experience |
|-------|----------------|
| **Today** | Run manually. Get decent briefings. No memory between runs. Each run starts from zero |
| **After 1** | Entries reference ongoing stories naturally. The agent *knows things* about your topics. Briefings feel like they come from someone who's been following the beat |
| **After 2** | Noticeably smarter: follows up on developing stories, finds better sources, connects dots across feeds. Less noise, more signal |
| **After 3** | Rate a few entries and the system adapts. Topics you care about get deeper coverage. Topics that bore you quietly fade. Entries are tagged by importance |
| **After 4** | Set it and forget it. Feeds update on schedule. OPML import into any reader. Dashboard tells you everything is healthy. Failures don't cascade |

## Non-goals (for now)

These are valuable but out of scope for the next few days:
- **Multi-user / collaborative feeds** — adds auth, permissions, conflict resolution complexity
- **RAG over past entries** — requires embedding infrastructure
- **Image/media extraction** — RSS readers handle this inconsistently
- **Interactive refinement UI** — a CLI feedback command is enough for now
- **Digest/rollup mode** — weekly summaries are nice but not core to the intelligence story
