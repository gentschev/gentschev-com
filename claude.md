# gentschev.com

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
│   └── pages_controller.rb      # Home page
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   └── pages/
│       └── home.html.erb        # Main single-page layout
├── helpers/
│   ├── charts_helper.rb         # SVG chart generation
│   └── substack_helper.rb       # RSS fetching/caching
├── services/
│   ├── github_contributions.rb  # GitHub API integration
│   └── substack_feed.rb         # Substack RSS parsing
├── javascript/controllers/
│   ├── contributions_chart_controller.js  # Chart tooltips
│   └── expandable_list_controller.js      # Show more/less
├── assets/
│   └── images/                  # Nature photos/illustrations
config/
├── routes.rb                    # root to pages#home
└── content/
    ├── projects.yml             # Project definitions
    └── interests.yml            # Interest list
```

## Environment Variables

For local development, create a `.env` file (gitignored):
```
GITHUB_TOKEN=ghp_your_token_here
```

For production (Railway), set `GITHUB_TOKEN` in the environment variables dashboard.

## Commands

```bash
# Development
bin/dev                          # Start Rails server (loads .env automatically)

# Deployment
git push origin main             # Railway auto-deploys from main
```
