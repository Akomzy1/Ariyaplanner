---
name: cultural-programs
description: How AriyaPlanner generates culturally correct Nigerian event programs. Use when building or modifying the Architect agent, program generation, ceremony sequencing, the program_templates table, or any UI that renders a run-of-show. Covers template schema, the 12 launch templates, retrieval rules, and the hard rule against free-generating ritual content.
---

# Cultural Programs — SKILL

## The one rule that governs everything

**The LLM never free-generates ritual or ceremony content.** Programs are assembled from human-curated, versioned templates in `program_templates`. The LLM's job is to SELECT the right template(s), SEQUENCE ceremonies across dates, PERSONALISE names/times/venues, and EXPLAIN — never to invent what happens in a Yoruba engagement or an Igbo burial. Wrong ritual content destroys trust irreparably; this is the product's moat and its biggest liability.

## Template schema (`program_templates`)

```sql
program_templates (
  id uuid pk,
  event_type text,        -- wedding | burial | birthday | naming
  culture text,           -- yoruba | igbo | hausa | edo | cross | neutral
  religion text,          -- christian | muslim | traditional | mixed | neutral
  name text,              -- "Yoruba Traditional Engagement"
  version int,            -- bump on any content change; never edit in place
  reviewed_by text,       -- cultural consultant sign-off, REQUIRED before is_live
  is_live boolean default false,
  blocks jsonb            -- ordered ceremony blocks, see below
)
```

Each `blocks` entry: `{ order, title, description, duration_min, default_time_hint, roles: ["alaga_ijoko", "mc", ...], vendor_categories: ["catering","decor",...], optional: bool, notes }`.

## Launch library (13 templates; all except Office Celebration require consultant review before `is_live`)

Weddings: Yoruba traditional engagement · Igbo traditional (wine-carrying) · Hausa (Fatiha-led) · White wedding + reception (culture-neutral, pairs with any traditional).
Burials: Christian sequence (wake-keep → service of songs → funeral service → interment → reception) · Muslim janazah (compressed 24–72h timeline) — Igbo `ikwa ozu` considerations included as flagged optional blocks in the Christian/traditional variants.
Naming: Yoruba (7th/8th-day) · Christian/Muslim neutral variant (Muslim variant includes 7th-day aqiqah). **Naming templates MUST carry cultural procurement tasks as blocks:** the Yoruba symbolic items list (honey, kola nut, bitter kola, alligator pepper, salt, sugar/sugarcane, water, palm oil, dried fish — each with its meaning noted in the program), officiant arrangement (pastor/imam/elder), and for the Muslim variant the **aqiqah ram** as a time-critical procurement task (1–2 day lead). Igbo naming variant: consultant-flagged template gap, not improvised.
Birthdays: milestone adult (40th/50th/70th) · standard celebration.
Office celebration ×1: end-of-year party / retirement send-off / company milestone — culture-neutral, **no ritual content, therefore no consultant gate: ships `is_live=true`**; default workstreams swap Aso-ebi for a Colleagues/Logistics split; intake skips culture/religion questions.
Plus: cross-cultural wedding combiner rules · culture-neutral fallback.

## Assembly rules for the Architect

1. Retrieve candidates by `(event_type, culture, religion)`; fall back culture→`cross`→`neutral`, never sideways to a different culture.
2. Multi-ceremony events (trad + white wedding) = multiple templates sequenced across `events.dates[]`; enforce ordering constraints (introduction before engagement; engagement typically before or same-week as white wedding).
3. Personalisation may change: names, times, venue, optional-block inclusion, block order within `optional` freedom. It may NOT change: block titles' ritual meaning, required roles, or insert unlisted ritual acts.
4. Every generated program renders the footer line: *"Confirm details with your family elders — traditions vary by family and town."* Non-removable.
5. Unknown culture/combination requested → agent says plainly it doesn't yet have a vetted template, offers the neutral structure, and logs `template_gap` to analytics. Never improvise.
6. Memorial events: apply `skills/memorial-tone` to all copy in and around the program.

## Versioning

Templates are immutable once live: changes create `version + 1`; existing events keep the version they were generated with (`ceremonies.template_version`). Consultant name recorded on every version.
