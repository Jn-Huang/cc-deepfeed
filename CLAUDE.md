# rss-research

Deep research briefings delivered as RSS feeds.

## How It Works

- Config files define topics in plain English (each with its own state + knowledge memory)
- `config.yaml` is Jimmy's feed, `config-gf.yaml` is GF's feed
- `@research` agent searches, synthesizes, and writes RSS entries
- `feed.py` handles RSS XML generation and per-topic dedup state
- Each config produces its own combined feed XML (e.g., `daily-briefings.xml`, `gf-briefings.xml`)
- Each entry gets a `<category>` tag with its topic ID
- `publish.sh` pushes to GitHub Pages (gh-pages branch) and pings WebSub hub for instant Feedly updates
- Topics with `sync_to` (e.g., `random-knowledge`) are written to both feeds

## Architecture

- **One XML per config:** Each config has a `combined_feed` setting that determines its XML filename. All topics in a config go to that feed.
- **Shared topics:** Topics with `sync_to: ["other-config.yaml"]` write entries to both feeds via `--sync-to`. State is shared (same `.state/` dir) so knowledge and dedup stay in sync.
- **WebSub:** Feeds declare a PubSubHubbub hub. `publish.sh` pings `pubsubhubbub.appspot.com` for all XMLs after each push.
- **Scheduling:** macOS launchd (`com.jimmy.rss-research`) runs daily at 9:07 AM via `claude -p "@research run the research cycle"`.
- **Remote:** Uses SSH (`git@github.com:...`) for auth in headless/cron contexts (HTTPS + osxkeychain doesn't work from launchd).

## Usage

Run the research cycle by invoking the agent:

```
@research                                  # all feeds (config.yaml)
@research meta-news                        # single feed
@research --config config-gf.yaml          # all GF feeds
@research --config config-gf.yaml daily-news  # single GF feed
@research --dry-run                        # preview without writing
```

Or for headless/cron use:

```bash
claude -p "@research run the research cycle"
claude -p "@research --config config-gf.yaml run the research cycle"
```

## feed.py Reference

All commands accept `--config <path>` (default: `config.yaml`).

```bash
# Core (per-config combined feed, per-topic state)
python feed.py init --name "Daily Briefings" --description "..."
python feed.py add <feed_id> --title "..." --content "<p>...</p>" --sources "url1,url2" --image "https://..." --run-id "..." --sync-to "config-gf.yaml"
python feed.py prune --keep 50
python feed.py list <feed_id>
python feed.py state <feed_id>

# Knowledge
python feed.py knowledge <feed_id>
python feed.py learn <feed_id> --brief "..." --entities "e1,e2" --threads '<json>'

# Operations
python feed.py status
python feed.py rollback <feed_id>
python feed.py log <feed_id> --started "..." --finished "..." --entries-added 4

# Discoverability
python feed.py opml --base-url "https://..."
python feed.py index-html --base-url "https://..."

# GF config example
python feed.py --config config-gf.yaml status
python feed.py --config config-gf.yaml add product-design --title "..." --content "..."
```
