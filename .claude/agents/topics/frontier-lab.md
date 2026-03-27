# Frontier Lab Updates

## Scope

Research, engineering, and product updates from the top AI labs building frontier models.

**Labs to track:**
- Anthropic (Claude, Claude Code, agent SDK)
- OpenAI (GPT, o-series reasoning models, Codex, API)
- Google DeepMind (Gemini, AlphaFold, research)
- xAI (Grok)
- Meta AI (Llama, open-source releases)
- Mistral
- DeepSeek

**What to cover:**
- New model releases, capabilities, and technical details
- Developer tools and platform updates (APIs, SDKs, CLI tools, agent frameworks)
- Research engineering: inference optimization, fine-tuning, deployment patterns
- Open-source releases and ecosystem tools from these labs
- Pricing changes, rate limits, context window updates
- Safety and alignment work with concrete findings
- Internal research papers and technical blog posts from these labs
- Head-to-head comparisons and benchmark showdowns between labs

## Skip

- Funding rounds, valuations, and corporate finance news
- Hiring announcements and org chart shuffles
- Regulatory/policy debates unless they directly change a lab's product
- Vague roadmap promises without shipped artifacts
- Celebrity endorsements or mainstream media hype pieces

## Research Strategy

**Mandatory first step — crawl official sources.** Before any web searches, use WebFetch on these URLs and extract recent posts from the last 2 weeks. This is non-negotiable:

1. `https://www.anthropic.com/research` — Anthropic research blog
2. `https://www.anthropic.com/news` — Anthropic product/company news
3. `https://openai.com/blog` — OpenAI blog
4. `https://deepmind.google/discover/blog/` — Google DeepMind blog
5. `https://ai.meta.com/blog/` — Meta AI blog
6. `https://mistral.ai/news` — Mistral news

For each page, extract post titles and dates. If any post is from the last 2 weeks and not already in state, WebFetch that post for full details.

**Then do broader research:**
7. Search GitHub for recent releases from these orgs (anthropics, openai, google-deepmind, meta-llama, mistralai, deepseek-ai)
8. Search Twitter/X, Reddit (r/LocalLLaMA, r/ClaudeAI, r/ChatGPT, r/MachineLearning), and Hacker News for community reactions and discoveries
9. Check arXiv for new papers authored by researchers at these labs
10. Compare across labs when multiple ship similar capabilities in the same period

**Verification rule:** Every claim must trace to a real, fetchable source URL. If you cannot find a primary source for a story, do not write about it. Rumors and leaks require at least 2 independent sources.

## Writing Style

**Target: 600-800 words per entry.**

Write for a senior engineer who works with these models daily and needs to know what shipped, what changed, and what it means for their stack.

- **Lead with what shipped**: Version numbers, model names, concrete capabilities — not "exciting times in AI"
- **Technical substance**: Architecture details, benchmark numbers, API changes, code examples where relevant
- **Cross-lab context**: How does this compare to what other labs offer? Is this catching up or breaking new ground?
- **Practical impact**: What can developers do now that they couldn't before? What should they migrate to or away from?
- **Credit the source**: Link to the official announcement, paper, or GitHub release
