# AriyaPlanner — Claude Code Build Prompt Pack v1.0

**28 sequenced prompts · prototype-first build · AkomzyAi Consulting Ltd**

Prerequisites in the repo before Prompt 1: `CLAUDE.md` at root, `/skills/` (all five SKILL.md files), `/design-prototype/` containing the Claude Design HTML exports.

---

## STANDING INSTRUCTION — paste at the top of EVERY prompt

```
Read CLAUDE.md fully before starting. Non-negotiable #1 applies: the HTML files in
/design-prototype/ are the single source of truth for all UI. STRICTLY FOLLOW AND
ALIGN WITH THE PROTOTYPE HTML — match its layout, spacing, colors, typography,
component structure, copy tone, and both visual registers (celebration + memorial)
exactly. Do not restyle, "improve", or invent UI. Consume design tokens only; never
hardcode values. If a needed state isn't prototyped, derive it minimally from
existing prototype patterns and flag it as DESIGN-GAP in your summary. If the
prototype and PRD conflict on visuals, the prototype wins; on behaviour, the PRD and
/skills win; if ambiguous, stop and ask. Read the relevant SKILL.md before coding
its domain. Do only what this prompt asks; flag ideas as FUTURE: comments. Finish
with the Definition of Done checklist from CLAUDE.md.
```

---

## PHASE 0 — Foundation (Prompts 1–5)

**P1 — Repo + PWA scaffold.** Initialise Next.js 14 (App Router, TS strict, pnpm) per the CLAUDE.md repo layout. PWA: manifest (name "AriyaPlanner", theme colors from prototype tokens — placeholder until P5, icons in /public/icons), service worker via Serwist with an offline shell page, custom add-to-home-screen prompt component (dismissible, not the browser default). shadcn/ui installed. Vercel config. `.env.example` with all keys named. Acceptance: `pnpm build` clean; Lighthouse recognises installable PWA.

**P2 — Supabase schema + RLS.** Create all migrations for the data model in CLAUDE.md §3 exactly, including append-only enforcement on `contributions` and `audit_log` (revoke UPDATE/DELETE; `corrects_id` pattern), `tasks` scheduling fields, `vendors` phone-dedup unique index, `suggestions` (member suggestion→approval flow, PRD F2a), `wa_messages`. RLS on every table: event-scoped access via `committee_members` role; contribution amounts readable only by chief_host + finance workstream lead. Acceptance: RLS tests pass for each role (write a small pgTAP or Vitest+service-role harness).

**P3 — Auth (WhatsApp-number OTP).** Supabase phone auth, NG-normalised (+234) numbers, OTP flow styled per prototype auth pages. Session handling for the (app) group; unauthenticated → marketing pages. Acceptance: full signup/login on mobile viewport matches prototype.

**P4 — Seed data.** Implement `program_templates` and `price_bands` seed migrations per `skills/cultural-programs` (12 templates as structured blocks — content drafted, `is_live=false`, `reviewed_by` empty pending consultants) and `skills/price-bands` (full Lagos CSV, Abuja ±10%). Seed one demo event ("Mummy's 70th", celebration) and one memorial demo ("Papa's farewell") for development. Acceptance: seeds idempotent; demo events render once UI exists.

**P5 — Design token extraction + component base.** Parse `/design-prototype/*.html` and extract the complete token set (both registers) into `tailwind.config.ts` + `styles/tokens.css` with `data-register` theming. Restyle shadcn primitives (button, card, input, tabs, badge, dialog) to match `00-design-system.html` exactly. Create `/design-prototype/MANIFEST.md` mapping prototype files → app routes. Acceptance: a /styleguide dev route rendering every primitive side-by-side visually indistinguishable from the prototype in both registers.

## PHASE 1 — Core planning product (Prompts 6–16)

**P6 — Marketing pages.** Homepage, event-type pages (weddings celebration / burials memorial), pricing, price-index hub — implementing `01`, `02a`, `02b`, `03a`, `03b` prototypes pixel-faithfully. Price Index renders live from `price_bands` per the skill. Static/ISR. Acceptance: side-by-side match, mobile-first, memorial page passes the `skills/memorial-tone` checklist.

**P7 — Architect intake (UI).** The conversational intake from `04-architect.html`: chat surface with selectable chips (event type, culture, religion, city, guest band, budget band, dates), streaming responses, register switches live the moment burial is selected. State persisted to `events` draft. Acceptance: matches prototype including memorial variant.

**P8 — Architect agent (backend).** `lib/agents/architect.ts`: Sonnet-class, system prompt encoding CLAUDE.md principles, Zod tool schema `create_event_plan` (event fields + template selection + budget tier). Template retrieval per `skills/cultural-programs` rules incl. fallback + `template_gap` logging + the non-removable elders footer. Acceptance: golden intake transcripts (Yoruba wedding, Christian burial, Muslim janazah) produce valid, correctly-templated plans.

**P9 — Budget engine.** Deterministic budget builder from `price_bands` (kobo math, per-head multiplication, tier midpoints, over-budget downgrade proposals per skill). Quote-fairness function. Unit tests incl. rounding. Acceptance: budget for demo events matches hand-computed fixtures.

**P10 — Runway scheduler.** Implement `/lib/scheduler` exactly per `skills/runway-scheduler`: topo sort, backward/forward pass, slack, critical path, feasibility, triage outputs, drift recompute. Acceptance: the six golden tests in the skill pass.

**P11 — Plan view.** The three-tab plan view from `04-architect.html`: PROGRAM (ceremony timeline from templates), BUDGET (line items, tiers, total vs band), TASKS (grouped by workstream, due dates from scheduler), runway indicator (comfortable/tight/triage states). Both registers. Acceptance: demo wedding + demo memorial match prototype.

**P12 — Committee Mode + suggestions.** Implement `05a-committee-board.html`: workstream cards (lead, progress, budget allocation), roles per CLAUDE.md, invite-by-WhatsApp-number flow (creates pending member; actual WA send lands in P18 — until then, shareable invite link). Role-gated permissions enforced by RLS from P2. **Suggestion → approval flow (PRD F2a):** members submit suggestions (any workstream); Event Coordinator gets a private approve/discuss/decline queue (dashboard + later WA); approve materialises a budget line (price band or estimate-pending) + task credited to the suggester; decline notifies gently and privately. Direct plan editing (budget lines, tasks, custom program blocks) for Chief Host/Event Coordinator only; custom program blocks insert alongside — never modify — vetted template blocks. Acceptance: matches prototype; role matrix tested incl. member-cannot-edit/can-suggest; approval materialisation correct; estimate-pending path works for unbanded items.

**P13 — Task engine + nudge scheduling (deterministic core).** Task CRUD, DONE flow, dispatcher (`lib/agents/dispatcher.ts`) computing who-gets-nudged-when from scheduler output + mode-aware cadence (memorial 1.5×). Nudges queue to `wa_messages` outbox (send infra in P17). In-app notification fallback. Acceptance: simulated clock tests produce correct nudge queue for both registers.

**P14 — Contribution ledger.** Implement `05b-contribution-ledger.html`: pledges, received, status tags, corrections-as-new-rows, branch levies for memorial (per-branch rollups), reminder scheduling (host-controlled), privacy per CLAUDE.md, memorial "support" language variant. Acceptance: append-only verified (UPDATE attempt fails), both register variants match prototype.

**P15 — BYOV vendors + quote comparison.** Vendor entity (phone-deduped, unified flags), per-event `vendor_engagements`, quote entry + side-by-side comparison UI, fairness badges from P9, deposit/balance tracking (kobo), Scribe (`lib/agents/scribe.ts`, Haiku) drafting negotiation messages for copy-paste. Acceptance: importing the same phone twice merges signal; comparison UI matches prototype patterns.

**P16 — Trial + Event Pass (Paystack).** 7-day trial starts at event creation; value-based gate: locking day-of command centre, sending vendor briefings, and PDF export require `pass_paid_at`. Paystack checkout (₦50,000, kobo), webhook verification, audit_log entries. Memorial guard: pass surface presented once, quietly, zero promo styling. Acceptance: gate matrix tested (trial active/expired × paid/unpaid); webhook idempotent.

## PHASE 2 — WhatsApp + execution layer (Prompts 17–24)

**P17 — WA send infrastructure.** `lib/wa/`: Cloud API client, template + session senders, window computation (`window.ts`, unit-tested per skill), outbox worker draining `wa_messages` with retries + rate limiting, STOP handling. Acceptance: window logic tests pass; outbox survives API failure with retry.

**P18 — Template flows.** Implement the full catalogue from `skills/whatsapp-flows` (both register variants), wire triggers: committee_invite (P12), task_nudge (P13), contribution_reminder (P14), aso_ebi_announcement (P20 stub), vendor_day_before + checkin (P21), day_of_digest, event_recap. Template bodies exported to a submission doc for Meta. Acceptance: each trigger produces correct template + variables in outbox; memorial variants selected by mode.

**P19 — Inbound agent.** `/api/wa/webhook`: signature verify, logging, structured-reply handlers (DONE/PAID/HERE/1), Haiku classify→extract pipeline with Zod tools — classes now {task_update | vendor_quote | question | contribution | suggestion | other}; suggestions extract to the F2a structure and route privately to the Event Coordinator — low-confidence echo-confirm for money items, in-thread confirmations per skill examples. Acceptance: fixture inbound messages (task done, pasted caterer quote, PAID) mutate DB correctly and reply appropriately.

**P20 — Aso-ebi manager.** Items (photo via Supabase Storage, unit price), buyer list, per-buyer payment status, pickup tracking, announcement broadcast (individual sends), DONE-reply tallying. Celebration register only by default (memorial events rarely use it; if enabled, memorial copy applies). Acceptance: end-to-end from item creation → broadcast → reply tally.

**P21 — Day-of Command Centre + offline.** Implement `05c` exactly: run-of-show, vendor arrival checklist with live HERE check-ins, deposit/balance flags, escalation list; Day-of Coordinator assignment (required before event date; defaults from Event Coordinator). Service-worker caching of run-of-show + vendor contacts; the prototype's offline state. Vendor day-before briefing job (T-1, gated on pass). Acceptance: airplane-mode test shows cached command centre matching prototype offline state.

**P22 — PDFs.** Program PDF + day-of call sheet PDF (pick renderer, document choice), styled to prototype print aesthetic, both registers, gated on pass. Acceptance: generated PDFs visually consistent with plan view for both demo events.

**P23 — Memorial full pass.** Sweep every surface against the `skills/memorial-tone` checklist: copy layer audit, theme attribute coverage, promo guards, WA memorial variants, the grep test for forbidden tokens in memorial namespace. Acceptance: checklist 100%; demo memorial event walkthrough contains zero celebration-register leakage.

**P24 — Milestones + recap.** Success-qualified platform counter (≥70% task completion at event date), homepage counter wiring with city chips, per-vendor `events_served`, post-event shareable recap card (prototype-derived, celebration + memorial variants), returning-host surfacing of past vendors/committee. Acceptance: counter only increments for qualifying events; recap renders both registers.

## PHASE 3 — Launch hardening (Prompts 25–28)

**P25 — Admin.** Minimal internal admin (role-gated): template review/publish (`is_live` + `reviewed_by`), price-band version approval (BYOV aggregates), vendor registry management + `verified` flag, event health dashboard. Acceptance: consultant can publish a template without touching SQL.

**P26 — Analytics.** PostHog: funnel (intake → plan → committee ≥3 → pass paid), nudge effectiveness, template_gap events, trial-gate hits, WA delivery rates. No PII in event payloads. Acceptance: events fire in dev with correct shapes.

**P27 — Privacy + audit (NDPR).** Privacy policy + terms pages (prototype legal styling), NDPR-oriented: consent copy at signup, data-deletion request flow (soft-delete + purge job), audit_log coverage review for all irreversible actions, Supabase backups documented. Acceptance: deletion flow exercisable end-to-end in dev.

**P28 — QA, seed demo, deploy.** Full Playwright smoke: create wedding → plan → invite → quote → pay pass → briefing queued → command centre offline. Same for memorial with janazah timeline. Fix findings. Production env checklist (Meta templates approved? Paystack live keys? domains?). Deploy to Vercel production. Acceptance: both smokes green in CI; production URL live behind a launch flag.

---

## Sequencing rules

Run strictly in order — later prompts assume earlier acceptance criteria hold. One prompt = at least one commit. If a prompt's acceptance criteria can't be met without violating the standing instruction (prototype fidelity), stop and surface the conflict rather than improvising. Week-1 human tasks in parallel with P1–P5: Meta business verification + template submission; cultural consultant outreach for template review (blocks `is_live`, not development).
