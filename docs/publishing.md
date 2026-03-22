# Publishing Your Feeds

Feeds are RSS XML files in the `feeds/` directory. To make them accessible to feed readers, you need to serve them over HTTP.

## GitHub Pages (recommended)

The included `publish.sh` script handles this automatically.

### Setup

1. Create the gh-pages branch:
   ```bash
   git checkout --orphan gh-pages
   git rm -rf .
   git commit --allow-empty -m "init gh-pages"
   git push origin gh-pages
   git checkout main
   ```

2. Enable GitHub Pages in your repo settings:
   - Go to Settings > Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages`, root `/`
   - Save

3. Set your `base_url` in `config.yaml`:
   ```yaml
   settings:
     base_url: "https://yourusername.github.io/cc-deepfeed"
   ```
   If using a custom domain, set that instead.

4. Run `make publish` or `bash publish.sh` after each research cycle. The orchestrator (`run-research.sh`) does this automatically.

### What publish.sh does

1. Generates `index.html` and OPML from your config
2. Copies XML + assets to a temp directory
3. Commits to `gh-pages` branch and pushes
4. Pings WebSub hub (if configured) for instant reader updates
5. Returns to your working branch

## Alternative: Any Static Host

The `feeds/` directory contains plain XML files. Serve them from anywhere:

```bash
# rsync to a VPS
rsync -avz feeds/ user@server:/var/www/feeds/

# AWS S3
aws s3 sync feeds/ s3://my-bucket/feeds/ --content-type application/xml

# Netlify (drop feeds/ folder)
```

Set `base_url` to match wherever you host them.

## Local Testing

For development, serve feeds locally:

```bash
python -m http.server 8080 -d feeds/
# Add http://localhost:8080/daily-briefings.xml to your reader
```

Some RSS readers also support `file://` URLs directly.

## WebSub for Instant Updates

By default, feed readers poll for updates (typically every 30-60 minutes). WebSub makes updates instant.

Add to your `config.yaml`:

```yaml
settings:
  websub_hub: "https://pubsubhubbub.appspot.com"
```

This is Google's free WebSub hub, supported by Feedly, Inoreader, and other major readers. After each publish, the hub is pinged and readers fetch the new content immediately.
