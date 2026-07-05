---
name: memorial-tone
description: The register rules for burial/memorial events. Use when writing ANY user-facing copy, template, UI state, or agent behaviour that can render inside an event where mode='memorial'. These rules override default copy and marketing behaviour everywhere.
---

# Memorial Tone — SKILL

## Why this exists

Burial planning is a launch feature and the sharpest wedge — but a family planning a funeral must never feel they are inside party software. `events.mode = 'memorial'` switches the entire register. Getting this wrong is a brand-ending failure; it is enforced in code, not left to taste.

## Register rules (hard)

1. **No exclamation marks. No emoji. No celebratory vocabulary** (party, celebrate!, exciting, amazing, let's go). Plain, calm, warm.
2. **Acknowledge loss once, simply, at intake** — "We're sorry for your loss. Let's take this one step at a time." — then be steadily practical. Never repeat condolences on every screen; never perform grief.
3. **Framing vocabulary:** "plan a befitting farewell", "memorial planning", "service", "programme", "support" (not "contributions/levies" in user-facing copy where avoidable), "guests" (not "party guests"). NEVER "burial party".
4. **No upsells, promos, cross-sells, or discount language anywhere inside an active memorial event.** The only purchase surface is the initial Event Pass, presented once, quietly. Enforce with a `mode`-aware guard around every promo component.
5. **Visual register:** memorial tokens from the prototype (sage/slate primaries, stone neutrals, bronze accent). No confetti, no celebratory illustrations, no bright emerald/gold. Driven by a top-level `data-register="memorial"` theme attribute — components never hand-pick memorial colors.
6. **Pace:** reminders default gentler and less frequent (nudge window 1.5× celebration default). Muslim compressed timelines: the agent adapts matter-of-factly — never apologises for the speed, never dramatizes it.
7. **Grief support is out of scope.** The product helps by reducing chaos, not counselling. If a user expresses acute distress, respond with brief human warmth and continue practically; do not roleplay as a grief counsellor.

## Copy transformations (examples)

| Celebration register | Memorial register |
|---|---|
| "Let's plan something beautiful! 🎉" | "Let's take this one step at a time." |
| "Your event is coming together nicely!" | "Arrangements are coming together steadily." |
| "Time to party — 3 days to go!" | "Three days to the service. Here's what remains." |
| "Invite your squad!" | "Invite family members to help coordinate." |
| "Congratulations on completing your plan!" | "Your arrangements are complete." |

## Implementation checklist (every UI/copy prompt must pass)

- [ ] All strings routed through the copy layer (`t(key, register)`) — no hardcoded user-facing strings in components that can render in memorial mode.
- [ ] Theme attribute switches tokens; visually verified against `02b-event-burials.html` and the memorial plan view in `04-architect.html`.
- [ ] Promo/upsell components wrapped in the memorial guard.
- [ ] WhatsApp templates: memorial variants exist and are selected by `events.mode`.
- [ ] The word "party", "!", and emoji do not appear anywhere reachable from a memorial event (add a lint-style test that greps the memorial copy namespace).
