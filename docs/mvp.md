# Daily Sketching — MVP

## Goal
Help users practice drawing every day through a simple, focused daily challenge.

The MVP must prioritize:
- speed of access
- consistency (same challenge for everyone each day)
- minimal friction

## Guideline
Always explain your actions in detail.  
Prefer simple, explicit solutions over clever abstractions.

---

## User Flow (MVP)

1. User lands on `/` (Home).
2. User clicks **Start today’s challenge**.
3. User is redirected to `/today` (`ChallengesController#today`).
4. The daily challenge is prepared:
   - the challenge for today is loaded (by date)
   - poses are generated **only if missing**
5. User starts the drawing session and navigates through poses sequentially.

---

## Pages

### Home (`/`)
Purpose: entry point, zero friction.

- Main message: **“Practice drawing. Every day.”**
- Short supporting tagline (optional)
- Primary CTA: **Start today’s challenge**
- CTA links to `/today`
- Minimal content only:
  - title
  - tagline
  - CTA
  - logo optional

---

### Today’s Challenge (`/today`)
Purpose: explain the challenge and launch the session.

- Displays today’s challenge:
  - theme
  - focus text
  - tip
  - example image (optional)
- Prepares the poses for today:
  - poses are generated only once per day
  - order is fixed for the day
- User can start the drawing session

---

### Drawing Session (`/draw/:step`)
Purpose: pure practice.

- Displays:
  - one image (pose)
  - countdown timer
  - current step / total steps
- Automatically advances when the timer ends
- No UI distractions

---

## Data Model

### Challenge
Represents the daily challenge (1 per day).

Fields:
- `date`
- `theme`
- `focus`
- `tip`
- `example_image_url`

Associations:
- `has_many :poses`

---

### Pose
Represents a single drawing pose in the session.

Fields:
- `image_url`
- `duration_seconds`
- `position`

Associations:
- `belongs_to :challenge`

---

## Image Handling (Important)

### Storage
- All images are stored in **Cloudflare R2**
- Images are **not stored in the Git repository**
- Images are served publicly via: https://assets.dailysketching.app/


### Folder Structure (in R2)
poses/
gesture/
portrait/
long_poses/
examples/
gesture/
portrait/


---

## Image Manifest (Source of Truth)

The application does **not** list files from Cloudflare at runtime.

Instead:
- A static manifest defines which images exist per theme
- The manifest is committed to Git

Location:config/image_manifest.json


Example structure:
```json
{
  "gesture": {
    "poses": [
      "poses/gesture/pose_0001.jpg",
      "poses/gesture/pose_0002.jpg"
    ],
    "examples": [
      "examples/gesture/example_01.png"
    ]
  }
}


One-time Utility Script

A helper script exists to generate the image manifest from local folders.

Location:

script/generate_image_manifest.rb


Usage:

ruby script/generate_image_manifest.rb


This script:

scans public/poses and public/examples

generates config/image_manifest.json

is run only during development

images can be deleted locally after generation

Technical Constraints

Ruby on Rails

TailwindCSS + daisyUI

Home view:
app/views/home/index.html.erb

CTA must use route helpers (e.g. today_challenge_path)

Layout (app/views/layouts/application.html.erb) must remain a layout only
(head + yield, no homepage content)

Acceptance Criteria

 Home design matches MVP design (docs/design/design.jpeg)

 CTA correctly navigates to /today

 /today loads without errors

 Poses are generated once per day

 Images load from assets.dailysketching.app

 Drawing flow works end-to-end

 No Rails or console errors

 Mobile and desktop responsive