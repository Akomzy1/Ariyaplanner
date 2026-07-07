# CLAUDE.md — AriyaPlanner

AI event planner for Nigerian families and workplaces: weddings, burials, birthdays, naming ceremonies, office celebrations (office = launch event type, unmarketed; family-and-culture remains the positioning lead). Turns family WhatsApp chaos into a coordinated plan — culturally correct programs, naira budgets, committee workstreams, contribution tracking, vendor coordination, day-of command centre. Lagos/Abuja first. Built and owned by Ariya Planner Ltd (Nigeria), 100% Nigerian-owned.

Read this file fully before writing any code. It applies to every prompt in the build pack.

---

## 0. NON-NEGOTIABLE #1 — DESIGN FIDELITY TO THE PROTOTYPE HTML

The Claude Design prototype HTML files in `/design-prototype/` are the **single source of truth for all UI**. This is a hard constraint, not a suggestion:

- **Strictly follow and align with the prototype HTML.** Match layout, spacing, colors, typography, component structure, copy tone, and interaction patterns exactly as prototyped. When implementing any screen, open the corresponding prototype file first and replicate it.
- Extract design tokens (colors, type scale, spacing, radii, shadows) **from the prototype HTML/CSS** into `tailwind.config.ts` + `styles/tokens.css` in Prompt 5, then consume tokens everywhere. Never hardcode hex values in components.
- **Do not invent UI.** No new components, layouts, or visual treatments that don't exist in the prototype. If a needed state (loading, empty, error) isn't prototyped, derive it minimally from existing prototype patterns and flag it in the PR description as `DESIGN-GAP:`.
- **Both registers are law:** celebration (emerald/gold/cream) and memorial (sage/slate/bronze) exist in the prototype. Every screen that can render a burial event must implement the memorial register exactly as prototyped. Register is driven by `events.mode` (`celebration` | `memorial`), never by ad-hoc styling.
- If prototype and PRD conflict on **visuals**, the prototype wins. If they conflict on **behaviour/logic**, the PRD + skills win. If genuinely ambiguous, stop and ask — do not guess.
- Expected prototype files (adjust to actual export names in Prompt 5 and record the mapping in `/design-prototype/MANIFEST.md`):
  `00-design-system.html`, `01-homepage.html`, `02a-event-weddings.html`, `02b-event-burials.html`, `02c-event-office.html`, `03a-pricing.html`, `03b-price-index.html`, `04-architect.html` (intake + plan view, both registers), `05a-committee-board.html` (incl. F2a suggestion queue + member suggest entry), `05b-contribution-ledger.html`, `05c-day-of-command-centre.html` (incl. offline state + trial-gate locked state), `06-recap-card.html` (post-event shareable recap, both registers).

## 1. Stack (locked)

- **Next.js 14 (App Router)** on Vercel, TypeScript strict. Installable **PWA**: manifest, icon set, service worker (Serwist or next-pwa), custom add-to-home-screen prompt, offline shell.
- **Supabase**: Postgres + RLS on every table, Auth (WhatsApp-number OTP via SMS/WA), Storage (fabric photos, PDFs).
- **Claude API**: Sonnet-class for Architect conversation + drafting; Haiku-class for classification/extraction/nudge copy. All agent outputs that modify program/budget/tasks go through **schema-validated tool calls (Zod)** — never freeform JSON parsing.
- **Paystack**: Event Pass checkout (₦50,000), webhooks. Phase 2: contribution collection, escrow.
- **WhatsApp Business Cloud API**: template + session messages, webhook receiver. See `skills/whatsapp-flows`.
- shadcn/ui as the component base, restyled to prototype tokens. PostHog analytics. Resend (email fallback only). PDF via `@react-pdf/renderer` or server-side Playwright print — pick one in Prompt 22 and stick to it.

## 2. Architecture principles (house rules)

1. **Agents recommend and draft; humans decide and commit.** No agent action books a vendor, sends money, or sends an outbound message without explicit human confirmation, except pre-scheduled system templates (nudges/briefings) the host has enabled. Every irreversible action writes to `audit_log`.
2. **Deterministic where it must be reliable; LLM where it helps.** Scheduling = deterministic critical-path math (`skills/runway-scheduler`). Cultural programs = retrieved from versioned templates (`skills/cultural-programs`), never free-generated ritual content. Budgets = computed from `price_bands`. The LLM explains, personalises, drafts, extracts.
3. **Append-only money data.** `contributions` and `audit_log` never UPDATE/DELETE rows; corrections are new rows referencing the original (`corrects_id`). Enforce via RLS + revoked UPDATE/DELETE.
4. **Individual WhatsApp threads, never groups.** Privacy: contribution amounts visible only to Chief Host + Finance lead; nudges go privately to the responsible person only. No public shaming.
5. **Memorial mode is sacred.** `events.mode = 'memorial'` switches register, copy, defaults, and suppresses all upsells. Rules in `skills/memorial-tone` override everything except safety.
6. **PWA offline for the moments that matter.** Day-of command centre caches run-of-show + vendor contacts; degrade gracefully elsewhere.
7. **Naira-native.** All money is integer **kobo** in the DB, formatted ₦ with `Intl.NumberFormat('en-NG')`. No floats for money, ever.

## 3. Data model (authoritative summary)

`users` · `events` (type, mode celebration|memorial, culture, religion, dates[], city, budget_band, status, runway_days, date_mode fixed|birth_plus_n, expected_window, trigger_recorded_at, event_coordinator_id, day_of_coordinator_id, trial_started_at, pass_paid_at) · `ceremonies` · `workstreams` · `tasks` (lead_time_days, dependencies uuid[], criticality, due_date, status, owner_id) · `committee_members` (role: chief_host|event_coordinator|workstream_lead|member|viewer) · `contributions` (append-only; corrects_id) · `vendors` (unified: phone-deduped, verified, claimed, events_served) · `vendor_engagements` (quotes jsonb, deposit_kobo, balance_kobo, status, check_in_at, ratings) · `aso_ebi_items` + `aso_ebi_orders` · `suggestions` (suggester_id, workstream, item, est_kobo nullable, status: pending|approved|declined, resolved_by) · `tips` (versioned advisory library: event_type × workstream × runway_stage × guest_band, body, register variants) · `idea_assets` (owned/licensed reference images: category, storage_path, license_source, license_note) · `event_ideas` (generated ideas: event_id, prompt_context, title, est_kobo nullable, asset_ids uuid[], status: shown|accepted|dismissed, materialised_suggestion_id) · `price_bands` (category × city × tier, versioned) · `program_templates` (versioned, human-curated) · `milestones` · `wa_messages` (in/out log, template_name, window_state) · `audit_log` (append-only).

## 4. Repository layout

```
/app                 # Next.js App Router (marketing + app + api routes)
  /(marketing)/      # homepage, event pages, pricing, price-index
  /(app)/            # authed PWA: architect, committee, ledger, vendors, day-of
  /api/wa/webhook    # WhatsApp inbound
  /api/paystack/webhook
/lib/agents/         # architect.ts, scribe.ts, dispatcher.ts (nudge orchestration)
/lib/scheduler/      # critical-path engine (pure, unit-tested)
/lib/wa/             # send, templates, window logic
/lib/db/             # supabase clients, queries, zod schemas
/skills/             # the five SKILL.md files — READ THE RELEVANT ONE BEFORE CODING ITS DOMAIN
/design-prototype/   # Claude Design HTML exports — SOURCE OF TRUTH FOR UI
/supabase/migrations
```

## 5. Conventions

TypeScript strict, no `any`. Server components by default; client only for interactivity. Zod at every boundary (API, agent tools, webhooks). Errors: never swallow; user-facing copy warm and plain ("Something went wrong saving that quote — try again"), memorial-register-aware. Tests: Vitest for `/lib/scheduler`, `/lib/wa/window`, budget math; one Playwright smoke per phase. Env vars in `.env.example`, never committed secrets. Commits: conventional (`feat:`, `fix:`), one prompt = one commit minimum.

## 6. Do NOT

- Do not restyle, "improve", or modernise the prototype design.
- Do not free-generate cultural/ritual content or invent price data.
- Do not send any WhatsApp message type not defined in `skills/whatsapp-flows`.
- Do not use floats for money, groups for WhatsApp, or UPDATE on append-only tables.
- Do not add features not in the current prompt — no scope creep, flag ideas as `FUTURE:` comments.
- Do not show upsells, promos, or celebratory copy inside a memorial event.

## 7. Definition of done (every prompt)

Builds clean (`pnpm build`), lints clean, relevant tests pass, screen matches prototype side-by-side, RLS verified for new tables, `DESIGN-GAP:` notes listed if any, committed.
