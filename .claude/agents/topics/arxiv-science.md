# arXiv Science Papers

## Scope

Notable papers from arXiv across the natural sciences, mathematics, and interdisciplinary research. Focus on work that is technically significant, broadly interesting, or represents a methodological breakthrough.

- Physics (hep-th, hep-ph, astro-ph, cond-mat, quant-ph)
- Mathematics (math.AG, math.NT, math.PR, math.CO)
- Computational biology and bioinformatics (q-bio)
- Chemistry and materials science (cond-mat, physics.chem-ph)
- Earth and environmental science (physics.ao-ph, physics.geo-ph)
- Cross-disciplinary work (e.g., ML applied to physics, computational methods for biology)

## Skip

- Papers that are purely incremental (minor improvements on known methods)
- AI/ML papers (covered by ai-research topic)
- Papers without clear results or that are purely speculative
- Preprints that are just conference submissions without novel content

## Research Strategy

**Mandatory first step — crawl arXiv listings.** Before any web searches, use WebFetch on these URLs and extract papers from the last 2 weeks:

1. `https://arxiv.org/list/astro-ph/recent` — astrophysics
2. `https://arxiv.org/list/quant-ph/recent` — quantum physics
3. `https://arxiv.org/list/cond-mat/recent` — condensed matter
4. `https://arxiv.org/list/hep-th/recent` — high energy physics theory
5. `https://arxiv.org/list/math/recent` — mathematics
6. `https://arxiv.org/list/q-bio/recent` — quantitative biology

For each listing, identify papers with high engagement (many comments, cross-listings) or from well-known groups. WebFetch the abstract page for promising papers.

**Then do broader research:**
7. Search science news outlets (Nature News, Science Magazine, Quanta Magazine, Physics Today) for coverage of recent arXiv papers
8. Search for preprints that received significant attention on academic Twitter/Bluesky
9. Check retractions, corrections, or controversies around recent high-profile papers

**Verification rule:** Every claim must trace to a real arXiv paper (with arXiv ID) or published article. Do not write about papers you cannot link to.

**Article date:** Always pass the paper's original arXiv submission date via `--pub-date` when adding entries.

## Writing Style

**Target: 600-800 words per entry.**

Write like a science journalist who understands the technical depth — accessible but not dumbed down.

- **Structure**: what was the question, what did they find, how did they do it, why does it matter
- **Include the arXiv ID** (e.g., arXiv:2503.12345) and link to the paper
- **Be concrete**: include specific measurements, confidence levels, comparisons to prior results
- **Contextualize**: how does this fit into the broader field? What problem does it advance?
- **End with implications** or open questions the work raises
- **Avoid jargon without explanation**: if you use a technical term, briefly explain it for a general scientific audience
