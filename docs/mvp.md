# Daily Sketching — MVP

## Goal
Help users practice drawing every day through a daily challenge.

## Guideline
Always explain your actions in details 

## User Flow (MVP)
1. User lands on `/` (Home).
2. User clicks **Start today’s challenge**.
3. User is redirected to `/today` (`ChallengesController#today`).
4. The daily challenge is prepared (poses generated if missing) and displayed.

## Pages

### Home (`/`)
- Main message: “Practice drawing. Every day.”
- Primary CTA: button linking to `/today`
- Minimal content: title, tagline, CTA (logo optional)

### Today’s Challenge (`/today`)
- Displays today’s challenge
- Shows a list of poses (image + duration) in order
- (MVP) User can start and navigate through poses

## Data (Summary)
- **Challenge**: `date`, `theme`, `poses`
- **Pose**: `image_url`, `duration_seconds`, `position`

## Technical Constraints
- Rails + TailwindCSS + daisyUI
- Home view: `app/views/home/index.html.erb`
- CTA must use the existing route helper (e.g. `today_challenge_path`)
- Layout (`app/views/layouts/application.html.erb`) must stay a layout only (head + yield), no homepage content hardcoded.

## Acceptance Criteria
- [ ] Design matches the MVP design (see `docs/design/design.jpeg`)
- [ ] CTA correctly navigates to `/today`
- [ ] Home is responsive (mobile + desktop)
- [ ] No console or Rails errors on load