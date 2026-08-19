# gentschev.com

[![CI](https://github.com/gentschev/gentschev-com/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/gentschev/gentschev-com/actions/workflows/ci.yml)

Personal website for Gentschev — a centralized hub for projects, writing, and interests.

## Project Overview

A clean, positive, and playful single-page site that showcases side projects, pulls in recent writing from Substack, and maintains an organic list of interests (reading, organizations, places, people, etc.). The design draws inspiration from nature — forests, mountains, oceans, and solarpunk cityscapes.

**Domain:** gentschev.com
**Status:** v1 development

## Design Principles

### Aesthetic
- **Clean + Playful:** Polished basics with room for personality and future easter eggs
- **Nature-Forward:** Photography and illustrations featuring forests, mountains, oceans, solarpunk environments
- **Visual Rhythm:** Alternating layout — content and imagery switch sides as you scroll
- **Warm & Positive:** Inviting, not corporate; curious generalist energy

### Color Palette
- **Primary:** Deep forest green or ocean blue
- **Background:** Warm off-white / soft cream
- **Accents:** Sunset coral or golden hour amber
- **Text:** Near-black with good contrast

### Inspiration
- Our World in Data (clear information design)
- 2000s Flash animations (moments of delight, subtle motion)
- Pinterest boards: /gentschev/illustration/, /gentschev/city-art/
- Thinkers: Stewart Brand, Kevin Kelly, Clay Shirky, Seth Godin

## Technical Stack

- **Framework:** Rails 8.1.1 with Hotwire (Turbo + Stimulus)
- **CSS:** Tailwind CSS
- **Database:** PostgreSQL
- **Deployment:** Railway (GitHub integration)
- **Email (future):** Resend

## Site Structure

Single page with four main sections, alternating layout:

```
┌─────────────────────────────────────────┐
│              GENTSCHEV                  │  Hero: name + GitHub contributions chart
├───────────────────┬─────────────────────┤
│  [Nature Image]   │    PROJECTS         │  Image left, content right
├───────────────────┼─────────────────────┤
│    WRITING        │  [Nature Image]     │  Content left, image right
├───────────────────┼─────────────────────┤
│  [Nature Image]   │    INTERESTS        │  Image left, content right
├───────────────────┴─────────────────────┤
│              CONNECT                    │  Social links footer
└─────────────────────────────────────────┘
```

**Mobile:** Sections stack vertically; images become section headers/dividers.

## Content

### Projects (hardcoded for now)
1. **Homeschool Tools** — homeschooltools.net — Homeschool curriculum directory
2. **Harvest Tales** — Enriched wine descriptions for wine shops (not yet public)
3. **Division Eight** — Spec and submittal matching for construction openings (early stage)

### Writing
Recent posts pulled from Substack RSS feed (https://gentschev.substack.com/feed)
- Cache and refresh periodically
- Display 3-5 most recent posts with titles and dates

### Interests
Single organic list without categories — reading, organizations, places, people, tools, etc.
- Hardcoded for v1
- Future: Amazon wishlist integration for reading

### GitHub Contributions Chart
- Displays a smooth SVG line chart of daily contributions in the header
- Data fetched from GitHub GraphQL API, cached for 6 hours
- Requires `GITHUB_TOKEN` environment variable with `read:user` scope
- Renders nothing gracefully if token is missing or API fails
- Hover/touch tooltips show date and contribution count

### Social Links
- Substack: https://gentschev.substack.com/
- X/Twitter: https://x.com/gentschev
- GitHub: https://github.com/gentschev
- LinkedIn: https://www.linkedin.com/in/gentschev/

### Hosted Documents
Standalone PDFs served at short, branded URLs, so documents can be shared
directly rather than pointing people at LinkedIn or a cloud-storage link.
Resumes are the first use; the mechanism is general.

- Live at `/resume-ai-agents`. Bare `/resume` redirects to the first entry in the YAML.
- PDFs live in `resumes/`, **not** `public/`. Anything in `public/` is served with a
  one-year `cache-control` (see `config/environments/production.rb`), which would pin a
  stale document in visitors' browsers long after it was replaced. `ResumesController`
  sets a 15-minute cache instead, so an updated PDF propagates quickly.
- `X-Robots-Tag: noindex` keeps these out of search results — they're for people who are
  handed the link, not for discovery.
- Downloads get the readable `download_name` from the YAML (e.g. `Greg Gentschev Resume -
  AI Agents.pdf`) rather than the URL slug, while the URL itself stays extensionless.
- The `/resume` redirect is a **302, not the `redirect()` default of 301** — a permanent
  redirect is cached indefinitely and would strand people on the old primary variant.
- Unknown slugs 404. The filename passed to `send_file` is looked up from the config keys
  and never taken from the URL, which keeps Brakeman's `SendFile` check clean without an
  ignore entry.

**Adding a variant:** drop the PDF in `resumes/` and add an entry to
`config/content/resumes.yml`. Routes are generated from that file, so no route or
controller changes are needed.

## Development Guidelines

### Content Management
- Projects and interests are hardcoded in a single, easy-to-edit location
- No admin interface for v1 — edit code directly
- Substack integration via RSS parsing

### Styling
- Use Tailwind utilities; extract components only when truly repeated
- Maintain consistent spacing rhythm
- Images should be high quality; use Unsplash placeholders initially

### Future Considerations
- Easter eggs and playful interactions
- Seasonal or time-of-day theme variations
- Database-driven content with admin interface
- Additional interest categories
- Amazon wishlist integration
- Individual pages for deep content

## File Organization

```
app/
├── controllers/
│   ├── pages_controller.rb      # Home page
│   └── resumes_controller.rb    # Resume/document PDFs at /resume-<variant>
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   └── pages/
│       └── home.html.erb        # Main single-page layout
├── helpers/
│   ├── application_helper.rb    # Shared view helpers
│   └── charts_helper.rb         # SVG chart generation
├── services/
│   ├── github_contributions.rb  # GitHub API integration
│   └── substack_feed.rb         # Substack RSS fetching/parsing/caching
├── javascript/controllers/
│   ├── contributions_chart_controller.js  # Chart tooltips
│   └── expandable_list_controller.js      # Show more/less
├── assets/
│   └── images/                  # Nature photos/illustrations
config/
├── routes.rb                    # root to pages#home; resume routes from resumes.yml
└── content/
    ├── projects.yml             # Project definitions
    ├── interests.yml            # Interest list
    └── resumes.yml              # Resume variants (slug, file, download name)
resumes/                         # Resume PDFs (deliberately not in public/)
└── ai-agents.pdf
```

## Environment Variables

For local development, create a `.env` file (gitignored):
```
GITHUB_TOKEN=ghp_your_token_here
```

For production (Railway), set `GITHUB_TOKEN` in the environment variables dashboard.

## CI / Continuous Integration

GitHub Actions runs on every push to `main` and on pull requests (`.github/workflows/ci.yml`). **CI failures block Railway deploys** — Railway only deploys commits that pass.

### Jobs

| Job | What it checks |
|-----|---------------|
| `scan_ruby` | Brakeman static security analysis |
| `scan_js` | `importmap audit` for JS dependency vulnerabilities |
| `lint` | RuboCop style enforcement |
| `test` | Rails unit/integration tests |
| `system-test` | Rails system tests (Capybara) |

### Brakeman Policy

Prefer fixing code over adding entries to `config/brakeman.ignore`. Ignore entries hide real issues and rot over time. If a warning is genuinely a false positive, fix the code pattern that triggers it (e.g., use `Net::HTTP` instead of shelling out to `curl`).

### Testing Notes

- Service tests live in `test/services/`, helper tests in `test/helpers/`.
- **Minitest 6 no longer bundles `minitest/mock`**, so `Object#stub` / `Minitest::Mock` are unavailable. Tests that need to isolate network calls swap the target method with `define_singleton_method` and restore it in an `ensure` block (see `test/services/github_contributions_test.rb` and `substack_feed_test.rb`). Add the `minitest-mock` gem if fuller mocking is ever needed.
- The test environment uses `:null_store` for the cache, so tests that exercise caching behavior temporarily swap in an `ActiveSupport::Cache::MemoryStore`.

## Commands

```bash
# Development
bin/dev                          # Start Rails server (loads .env automatically)

# CI / Quality (run before pushing)
bin/ci                           # Run full CI suite locally (same checks as GitHub Actions)
bin/rubocop                      # Lint Ruby code
bin/brakeman --no-pager          # Security scan (use bundle exec to skip --ensure-latest)
bin/rails test                   # Run unit/integration tests
bin/rails test:system            # Run system tests

# Deployment
git push origin main             # Railway auto-deploys from main (CI must pass)
```
