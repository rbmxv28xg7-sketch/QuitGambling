# QuitGambling Project Guidelines

## Testing & Deployment
- Never suggest, build for, or upload to TestFlight.
- All testing on real hardware must be performed locally via `xcrun devicectl`.

## Submission & Pitch Formatting
- When writing contest submissions, hackathon form answers (Devpost style), or pitch summaries:
  - Output strictly as bullet points.
  - Do not use any emojis or icons.
  - Do not use markdown tables.
  - Keep each bullet point short, direct, and concise.

## Git & Asset Hygiene
- Never track `build/`, derived data, root screenshots, or Python scripts in Git.
- Always ensure assets in `Sources/Resources/Assets.xcassets/` and `Sources/Resources/` (icons, videos, audio) remain tracked.
