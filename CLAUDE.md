# rss-research

Deep research briefings delivered as RSS feeds.

## How It Works

- `config.yaml` defines topics in plain English
- `@research` agent searches, synthesizes, and writes RSS entries
- `feed.py` handles RSS XML generation and dedup state
- Output goes to `feeds/*.xml` — standard RSS 2.0, works with any reader

## Usage

Run the research cycle by invoking the agent:

```
@research              # all feeds
@research meta-news    # single feed
@research --dry-run    # preview without writing
```

Or for headless/cron use:

```bash
claude -p "@research run the research cycle"
claude -p "@research run meta-news"
```

## feed.py Reference

```bash
# Core (single combined feed, per-topic state)
python feed.py init --name "Daily Briefings" --description "..."
python feed.py add <feed_id> --title "..." --content "<p>...</p>" --sources "url1,url2" --run-id "..."
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
```
