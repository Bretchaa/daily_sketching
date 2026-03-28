# Daily Sketching — Project Context for Claude

## Who I am
I'm Adrien, a non-technical Product Manager. I have very low experience with JavaScript frameworks and frontend code. I need clear explanations when you touch technical concepts — don't assume I know what things mean. Prefer simple solutions over clever ones.

## Product Vision
**Duolingo for drawing.** A daily habit app that makes drawing practice accessible and sticky.

- One challenge per day, same for all users
- Max 15 minutes a day
- Daily streaks and gamification to build the habit
- Long term: structured drawing classes in multiple styles (gesture, portrait, still life, etc.)
- Target devices: mobile and tablet first (people draw on iPads)

## Tech Stack
- **Rails 7.2** — full-stack backend, keep it that way
- **Hotwire** (Turbo + Stimulus) — for interactivity, do NOT suggest React or other JS frameworks
- **Tailwind CSS 3 + DaisyUI** — for styling
- **SQLite** — database
- **Cloudflare R2** — image storage at `assets.dailysketching.app`
- **PWA** — service worker scaffolded for future mobile install + push notifications

## Key Architectural Decisions
- **No React, ever** — Adrien is non-technical, one codebase (Rails full-stack) is essential
- **Deterministic daily poses** — `DailyPicker` uses seeded RNG (Zlib.crc32 on theme+date) so all users see the same poses each day
- **Static image manifest** — `config/image_manifest.json` lists available poses by theme, avoids runtime R2 API calls
- **Stateless for now** — no user auth yet, this is the next big milestone

## Current State (as of March 2026)
MVP is complete and working:
- `/` — home page
- `/today` — loads today's challenge, generates 5 poses
- `/draw/:step` — timed drawing session, auto-advances, redirects to `/done`

## What's Next
1. User accounts + authentication
2. Daily streaks
3. Gamification (XP, badges, level-ups)
4. Drawing classes / structured curriculum

## How to Work With Me
- Always explain what you're doing and why, in plain language
- Prefer the simplest solution that works
- Don't suggest frontend framework migrations
- When proposing changes, tell me what file you're editing and what it does before touching it
- Flag anything that could break the existing flow
