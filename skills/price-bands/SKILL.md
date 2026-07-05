---
name: price-bands
description: The naira price intelligence layer. Use when building budget generation, quote fairness checks, the Ariya Price Index pages, the price_bands table, or BYOV quote ingestion. Covers schema, seeded 2026 Lagos bands, budget math rules, and the update pipeline.
---

# Price Bands — SKILL

## Purpose

`price_bands` powers three things: (1) line-item budget generation at Manage/Standard/Premium tiers, (2) "is this quote fair?" checks on BYOV quotes, (3) the public Ariya Price Index content. It is DATA, versioned and sourced — the LLM never invents a price.

## Schema

```sql
price_bands (
  id uuid pk,
  category text,          -- decor | catering_per_head | dj | mc | alaga | photography |
                          -- videography | venue | small_chops | cake | souvenirs | aso_ebi_unit |
                          -- ushers | security | canopy_rentals | funeral_home | casket |
                          -- hearse_transport | program_printing | live_band
  city text,              -- lagos | abuja
  tier text,              -- manage | standard | premium
  low_kobo bigint, high_kobo bigint,
  unit text,              -- flat | per_head | per_unit
  source text,            -- 'seed-2026-research' | 'byov-aggregate'
  effective_from date, version int
)
```

## Seed values (Lagos, 2026 launch — verify/extend during Prompt 4; kobo in DB, ₦ shown here)

| Category | Manage | Standard | Premium |
|---|---|---|---|
| Decor (flat) | ₦150k–300k | ₦300k–1.5m | ₦2m–5m+ |
| DJ (flat) | ₦80k–150k | ₦150k–500k | ₦500k–1.2m |
| Catering (per head) | ₦3.5k–6k | ₦6k–10k | ₦10k–20k |
| Photography (flat) | ₦100k–200k | ₦200k–600k | ₦600k–1.5m |
| MC (flat) | ₦50k–100k | ₦100k–350k | ₦350k–800k |
| Casket | ₦150k–400k | ₦400k–1.2m | ₦1.2m–5m |

(Full seed CSV built in Prompt 4 covers all categories; treat the above as anchors, not the complete set. Abuja seeded at Lagos ±10% until real data lands.)

## Budget math rules

- Money is **integer kobo** end-to-end. Display via `formatNaira()` util only.
- Budget line = band midpoint by default; per-head categories multiply by guest count band midpoint.
- Total vs `events.budget_band`: if over, the Architect proposes tier downgrades on the largest lines first and says so plainly — never silently trims.
- Quote fairness check: within band → "fair / mid-range"; ≤15% above high → "slightly above typical"; >15% → "above typical for [city] — worth negotiating; want me to draft the message?" Never call a vendor a cheat; frame as ranges.

## Update pipeline

BYOV quotes (from `vendor_engagements.quotes`) aggregate nightly into candidate bands (`source='byov-aggregate'`) once a category×city has ≥15 quotes in 90 days; new versions are proposed, human-approved in admin before going live. Seed data never edited in place — versioned like templates.

## Price Index pages

Render live from `price_bands` (standard tier ranges, low/high), with "last updated" from `effective_from`. This keeps SEO content honest and self-updating.
