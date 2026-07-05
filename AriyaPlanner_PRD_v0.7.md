# AriyaPlanner — Product Requirements Document v0.7

**Product:** AriyaPlanner — the AI event planner for Nigerian families
**Company:** AkomzyAi Consulting Ltd
**Date:** 10 June 2026
**Status:** Draft v0.7 (v0.5: 7-day trial + value-based conversion gate · v0.6: PWA-first architecture · v0.7: §11a Adjacent Verticals — corporate events, diaspora, Hire-a-Coordinator — documented as deferred/out-of-launch-scope)
**Companion document:** Competitive Teardown v0.1 (10 June 2026)
**Wedge:** Local Nigerian host, Lagos first, Abuja second. Diaspora tier deferred to Phase 2.

---

## 1. One-Line Summary

AriyaPlanner turns the family WhatsApp chaos of planning a Nigerian wedding, burial, birthday or naming ceremony into a coordinated plan — culturally correct programs, transparent naira budgets, committee workstreams, contribution tracking and vendor coordination — delivered where families already are: WhatsApp, backed by a web dashboard.

## 2. Problem Statement

Nigerian events are large, frequent, expensive and committee-planned. The average modern wedding costs ~₦13m across multiple ceremonies; burials are planned in 2–6 weeks under grief and family pressure; the hospitality sector turns over ₦1.2tn+ annually. Yet the entire process runs on a family WhatsApp group, a notebook of contributions, Instagram DMs to unvetted vendors, and the memory of whichever aunt is "coordinating."

The specific failures AriyaPlanner targets:

1. **No coordination layer.** Workstreams (food, drinks, venue, souvenirs, aso-ebi) are owned by different relatives with no shared state. Things fall through; everyone blames everyone.
2. **No contribution visibility.** Family levies and pledges are universal and emotionally charged. Who pledged, who paid, who is owed a reminder — all tracked informally, a recurring source of family conflict.
3. **No cultural program tooling.** A Yoruba engagement, an Igbo burial sequence, a Muslim naming ceremony each have a correct run-of-show. Hosts reconstruct these from memory and elders; Western tools and generic AI get them wrong.
4. **Opaque vendor pricing.** No reliable naira price bands; quotes vary wildly; negotiation is exhausting; reliability is unknowable until the day.
5. **Day-of chaos.** No single document says who arrives when, who to call, and what happens if the canopy man doesn't show.

Existing alternatives fail structurally: EventPlanner.ng is a static directory; Vowthread is a weddings-only discovery marketplace; Western AI planners (ItsaYes, Nupt.ai, TheWeddingPlanner.ai) assume one couple, USD budgets, email vendors and 12-month timelines; professional planners serve only the luxury tier. Nobody models the committee, the contributions, the culture, or the burial.

## 3. Target Users & Personas

**P1 — The Chief Host (primary payer).** 28–55, middle-class Lagos/Abuja, smartphone-first, lives on WhatsApp. Planning their own wedding, a parent's burial, a milestone birthday, or a child's naming ceremony. Budget ₦2m–₦20m. Wants control, visibility, and not to be embarrassed. Pays the per-event pass.

**P2 — The Committee Member.** Sibling, in-law, friend assigned a workstream. Joins free via WhatsApp invite. Needs: a clear task list, their slice of the budget, an easy way to log quotes and payments. They are the viral loop — every event onboards 5–15 of them.

**P3 — The Contributor.** Extended family/friends who pledge money but don't plan. Touchpoint: pledge confirmation and payment nudges via WhatsApp. Lightest-weight user; seeds the Phase 2 payments layer.

**P4 — The Vendor (Phase 1: passive; Phase 3: customer).** Caterer, decorator, DJ, MC/alaga, photographer, small-chops vendor, aso-ebi merchant, funeral home. In v1 they exist as records (BYOV or seed registry); in Phase 3 they claim profiles and pay for verification and leads.

**P5 — The Diaspora Host (Phase 2).** UK/US-based Nigerian planning an event "back home." Highest willingness to pay; deferred until local vendor data and trust signals make the concierge tier credible.

## 4. Positioning

*For Nigerian families planning weddings, burials and celebrations together, AriyaPlanner is the AI event planner that turns family WhatsApp chaos into a coordinated plan — culturally correct programs, transparent naira budgets, committee workstreams and contribution tracking — unlike vendor directories and Western wedding apps that assume one person plans alone.*

Strategic posture (from Teardown v0.1): lead with **coordination, not discovery**. The marketplace is earned in Phase 3 from coordination data; we do not fight Vowthread's listings war at launch.

## 5. v1 Scope — Six Locked Features

### F1. Event Architect (AI agent — the front door)

Conversational intake on WhatsApp or web: event type, tradition/culture (Yoruba / Igbo / Hausa / Edo / cross-cultural / "keep it simple"), religion (Christian / Muslim / traditional / mixed), date(s), city, guest count band, budget band, and event-specific qualifiers (e.g., for burials: religion-driven timeline, village component yes/no, wake-keep yes/no).

Outputs, generated within the first session:

- **Program:** a culturally correct multi-ceremony run-of-show. Weddings: introduction → traditional engagement → white wedding → reception (with correct Yoruba alaga ijoko/iduro roles, Igbo wine-carrying sequence, etc. as applicable). Burials: Christian wake-keep → service of songs → funeral service → interment → reception, or Muslim janazah rapid-timeline variant; Igbo ikwa ozu considerations flagged where relevant. Naming ceremonies: 7th/8th-day variants by tradition.
- **Budget:** line-item naira budget from the Price Band Engine (see F1a), at three tiers (Manage / Standard / Premium), totals checked against the stated budget band with trade-off suggestions.
- **Workstream plan:** the checklist regrouped into 5–8 assignable committee workstreams with deadlines back-calculated from event date, runway-adjusted per F1b.

Behavioural rules: the agent **recommends and drafts; it never books, pays, or commits**. Every irreversible action (sending money, confirming a vendor) requires explicit human confirmation and is recorded to the audit log. Cultural content is generated from a curated, versioned **Cultural Program Library** (structured templates per ethnicity × religion × event type), not free generation — the LLM personalises and sequences from vetted templates. This library is the moat; it ships with ~12 core templates and grows.

#### F1b. Runway-Aware Planning (locked design principle)

Every plan is computed from the **runway** — event date minus start date — and the plan's *structure*, not just its deadlines, adapts to it:

- **Long runway (4+ months):** conventional sequencing — venue/date locked first; vendors booked in price-advantage order (early deposits lock prices against naira inflation); comfortable production lead times for aso-ebi and printing.
- **Short runway (2–8 weeks — the burial norm):** **triage, not compression.** Critical-path logic identifies date-blocking items (venue, funeral home, interment permits), hard-lead-time items (custom aso-ebi production 2–3 weeks; at 18 days out the agent proactively offers ready-made/simplified alternatives rather than scheduling the impossible), maximally parallelisable work across workstreams, and items to cut or simplify. A 3-week plan is structurally different from a 6-month plan — never the same checklist with tighter dates.
- **Feasibility honesty at intake:** given an unrealistic runway (e.g. 10 days to a 500-guest wedding), the agent states plainly what is and isn't achievable and proposes a scoped-down plan — no fantasy schedules.
- **Drift replanning:** when tasks slip mid-flight, the agent recomputes the critical path and alerts the Event Coordinator with slack-based warnings ("decorator decision has 4 days of slack before it threatens venue setup").

Mechanics: each task template carries `lead_time_days`, `dependencies`, and `criticality`; scheduling is **deterministic critical-path computation**, with the LLM providing explanation, trade-off framing and alternative suggestions on top — reliable where it must be, intelligent where it helps.

#### F1a. Price Band Engine

A maintained dataset of Lagos/Abuja price bands per vendor category (decor ₦300k–₦1.5m standard; DJ ₦150k–₦500k; catering per-head bands; etc.), seeded from public 2026 data and founder research, then continuously improved by observed BYOV quotes (anonymised, aggregated). Powers: budget generation, "is this quote fair?" checks, and the public **Ariya Price Index** content engine (Section 11).

### F2. Committee Mode

The Chief Host creates the event and invites members by WhatsApp link/number into named workstreams (Food & Drinks, Venue & Decor, Souvenirs, Aso-ebi, Program & MC, Logistics, Finance). Per workstream: task list with deadlines, budget allocation, vendor slots, and a member-visible activity feed. The agent chases: overdue-task nudges to the owner (not the whole group — no public shaming by default; the Coordinator sees the full status board). Role-based permissions: Chief Host (all), Event Coordinator (all operational), Workstream Lead (own workstream + read others), Member (assigned tasks), Viewer (read-only — for the uncle who must feel included).

**Human coordination hierarchy (locked design principle):** every event has one named human at the apex of coordination. The **Event Coordinator** role defaults to the Chief Host but is explicitly assignable — in practice the celebrant often isn't the operator (the bride's older sister runs the wedding; a capable cousin runs the burial while the first son hosts). Reporting lines: each vendor reports to the Workstream Lead who engaged them → Workstream Leads report to the Event Coordinator → the AI agent is the connective tissue underneath (task chasing, risk surfacing — e.g. "decorator hasn't confirmed delivery, 9 days out" — drafting follow-ups, keeping the Coordinator's status board current). The agent makes one human coordinator superhumanly informed; it never replaces them, and it never commits or pays on anyone's behalf.

Trial: full committee setup available during the 7-day trial. Event Pass: unlimited members.

### F3. Contribution & Levy Tracking

Ledger of pledges and payments per contributor: pledged amount, received amount, channel (transfer/cash), date, recorded-by. Gentle automated WhatsApp reminders to contributors on a schedule the Chief Host controls (default: one reminder, polite, no amounts disclosed to third parties). Family-levy mode for burials: per-branch levies (e.g., "each child ₦500k, each grandchild ₦100k") with branch rollups. Privacy rule: contribution data visible only to Chief Host and Finance workstream lead; never broadcast.

v1 records money; it does not move money. Phase 2 adds Paystack collection links and escrow. The ledger is **append-only with corrections as new entries** — never silent edits — because contribution disputes are family-relationship-critical.

### F4. Vendor Management — BYOV + Seed Registry + Shortlists

Three supply mechanisms (per the locked vendor strategy):

- **BYOV (primary):** hosts log vendors they're already talking to — name, category, phone/IG, quotes. The system structures quote comparison side-by-side (price, what's included, deposit terms), drafts WhatsApp negotiation messages, tracks deposits/balances, and slots confirmed vendors into the day-of call sheet.
- **Seed Registry:** 50–100 manually vetted Lagos vendors per launch (across owambe categories **and** the burial set: funeral homes, caskets, hearse/transport, canopies, program printers), with verified price bands. Free founding-vendor profiles in exchange for pricing transparency.
- **Agent shortlists:** when a line item has no vendor, the agent recommends 3–5 from registry + high-signal BYOV pool matched to budget tier, and drafts the quote request. Booking/payment remain off-platform in v1.

**Unified vendor entity model (locked):** BYOV and registry vendors are the same entity type with flags (`verified`, `claimed`) and dedup on phone number. A vendor imported by multiple hosts accrues signal (appearance count, quote ranges, outcome ratings) and becomes a claimable profile — this is what makes the Phase 3 marketplace cheap to switch on. Post-event, hosts rate vendors on three axes: showed up on time / delivered as quoted / would recommend.

### F5. Aso-ebi Manager

Fabric/style record with photos and price per unit (and per gele/cap add-ons); buyer list with sizes where relevant; payment status per buyer; pickup/delivery tracking; automated "aso-ebi available, here's how to pay" WhatsApp broadcast drafted by the agent on the Chief Host's behalf. Small feature, outsized cultural resonance, highly demo-able and marketable.

### F6. Day-of Command Centre

Auto-generated from the program + confirmed vendors: minute-by-minute run-of-show; vendor call sheet (arrival time, contact, deposit/balance status, setup notes); escalation list ("if X fails, call Y"); printable PDF + live WhatsApp version pinned to the committee. Post-event: vendor ratings prompt and a contribution-ledger closing summary.

**Day-of Coordinator (named human, required before event date):** assigned in the Command Centre; defaults to the Event Coordinator but is deliberately delegable — the planning coordinator may be in the front row at her own mother's funeral and should not be taking vendor calls. The Day-of Coordinator is the single point of command: the one name and phone number on every vendor's call sheet, the recipient of vendor check-ins, and the holder of the escalation tree. Their mobile view: minute-by-minute run-of-show, vendor arrival checklist (tick-off on phone), escalation contacts.

**Vendor day-before briefing (automated):** each confirmed vendor receives a WhatsApp message the day before — "Tomorrow you report to [Day-of Coordinator name, number]. Arrival: [time]. Setup zone: [location/notes]. Balance due: [status]." Vendors reply-to-check-in on arrival; the Coordinator's checklist updates live. This single flow addresses the most common Nigerian event-day failure: vendors not knowing who is in charge until they arrive and ask around.

**Phase 2/3 extension — Hire-a-Coordinator:** a vetted pool of freelance professional day-of coordinators (and alaga/MC-adjacent professionals) bookable through the platform, for families without a capable in-family operator. Rationale: high-margin add-on; effectively mandatory for the diaspora tier (the remote host cannot be the day-of human); converts professional planners from displaced incumbents into platform supply. Explicitly out of v1 scope — ops-heavy, quality-risk-bearing. v1 assumes the family supplies the human; AriyaPlanner makes that human ten times more effective.

## 6. Memorial Mode (tone specification)

Burial planning is a launch feature, and it must not feel like party software. Memorial Mode is the same engine, tone-switched:

- **Register:** calm, respectful, plain. No exclamation marks, no emoji, no celebratory copy ("Let's plan something beautiful" → "Let's take this one step at a time"). The agent acknowledges loss once, simply, at intake — then is steadily practical. Grief support is out of scope; the product helps by reducing chaos, not by counselling.
- **Visual register:** muted palette variant of the brand system; no confetti motifs anywhere in the funnel a Memorial user can see.
- **Defaults:** reminders gentler and less frequent; contribution language uses "support" framing; religious-timeline awareness (Muslim burials may be ~24–48h — the agent compresses the plan rather than apologising for the timeline).
- **Naming:** in-product it is "Memorial planning"; marketing language is "plan a befitting farewell" (the culturally resonant phrase), never "burial party."
- **Hard rule:** no upsell prompts inside an active Memorial event beyond the initial Event Pass purchase.

## 7. Architecture & Stack

Standard AkomzyAi stack, consistent with house principles (agents reason and recommend; deterministic systems decide and act on anything irreversible; append-only audit ledger for money and commitments):

- **Web app (PWA-first):** Next.js 14 (App Router) on Vercel, built as an installable Progressive Web App — Chief Host/Coordinator dashboard (budget, program editor, committee board, vendor comparison, ledger, day-of command centre). Native iOS/Android apps deferred until traction justifies the cost (standard "mobile deferred past Phase 3" default). PWA requirements: web app manifest + icon set, a tasteful custom "Add to Home Screen" prompt (not the browser default), service-worker caching for offline/poor-network resilience (the day-of command centre must cache the run-of-show and vendor contact list so a coordinator with bad signal in a venue still has them), and graceful degraded states. Push notifications are handled via WhatsApp, not web push — sidestepping the PWA's weakest area (unreliable iOS web push) by design.
- **Messaging:** WhatsApp Business API (Cloud API) — committee interactions, agent chat, nudges, broadcasts. Template messages registered for: invites, task nudges, contribution reminders, aso-ebi broadcast, day-of call sheet. Web fallback for everything (WhatsApp throughput limits and template approval are a launch dependency — start Meta verification immediately; lesson from Quorum's WhatsApp-secondary decision).
- **Data:** Supabase (Postgres + RLS + Auth via WhatsApp-number OTP; Storage for fabric photos, program PDFs).
- **AI:** Claude API. Sonnet-class model for Event Architect conversation and drafting; Haiku-class for nudge generation, classification and extraction (quote parsing from pasted vendor messages). Cultural Program Library and Price Band Engine are **data, not prompts** — versioned tables the agent retrieves from; agent outputs that modify program/budget go through schema-validated tool calls.
- **Payments:** Paystack — v1 only for Event Pass purchase. Phase 2: contribution collection links, then milestone escrow for vendor payments (deposit → delivery confirmation → release).
- **PDF generation:** programs and call sheets (server-side).
- **Analytics:** PostHog.

### Agent roster (v1 — deliberately small)

1. **Architect** — intake, program generation, budget generation, replanning on changes.
2. **Coordinator** — task/nudge orchestration, deadline back-calculation, committee status summaries (mostly deterministic with LLM-drafted message bodies).
3. **Scribe** — drafting: vendor negotiation messages, broadcasts, programs, post-event thank-yous; quote extraction from pasted text/screenshots.

(Resist the multi-agent fleet here — three is enough for v1; Sentinel-style separation is unnecessary because no agent touches money.)

### Core data model (entities)

`users` · `events` (type, mode: celebration|memorial, culture, religion, dates, city, budget_band, status, runway_days, event_coordinator_id, day_of_coordinator_id) · `ceremonies` (per-event sequence) · `workstreams` · `tasks` (lead_time_days, dependencies, criticality) · `committee_members` (role: chief_host|event_coordinator|workstream_lead|member|viewer, workstream) · `contributions` (append-only ledger) · `vendors` (unified entity; verified/claimed flags; phone-dedup; events_served counter) · `vendor_engagements` (per-event vendor slot: quotes, deposits, status, check_in_at, ratings) · `aso_ebi_items` + `aso_ebi_orders` · `price_bands` (category × city × tier, versioned) · `program_templates` (Cultural Program Library, versioned) · `milestones` (platform counters, success-qualified) · `audit_log` (append-only).

## 8. Monetisation

| Tier | Price | Includes |
|---|---|---|
| **7-day Trial** | ₦0 | Full Architect plan, program, budget, committee setup, BYOV. Conversion gate is value-based, not calendar-only (see below) |
| **Event Pass** | **₦50,000 one-off per event** (launch price) | Everything in trial, unlocked + execution layer: locked day-of command centre, automated vendor day-before briefings, final PDF exports (program + call sheet), full contribution ledger reminders, aso-ebi broadcasts. Covers all event types: burial events automatically run in Memorial mode (same pass, same price — tone-switched register, no mid-event upsells, never discount-marketed) |
| Phase 2 | take-rate | Paystack contribution collection (1% capped) → vendor escrow (2–3%) |
| Phase 2/3 | £/$ | Diaspora concierge tier |
| Phase 3 | ₦ subs | Vendor verification + lead subscriptions |

**Trial design (locked):** no free tier — a free tier is structurally wrong for a one-off product, since most events are planned in a single concentrated push and a free tier simply lets the whole event be planned for nothing. Instead, a **7-day trial with a value-based conversion gate**. The trial gives full planning intelligence (Architect plan, program, budget, committee setup); payment is required to unlock the **execution layer** — locking the day-of command centre, sending vendor day-before briefings, and exporting final PDFs. Rationale: a flat calendar trial misfires on this product — a 6-month-runway wedding host exhausts 7 days nowhere near needing to pay, while a short-runway burial host could be paywalled mid-event at the worst possible moment. Gating on the first high-value/irreversible execution action (not the calendar alone) means the host experiences the entire planning value, hits the wall exactly when output becomes operationally valuable, and a grieving short-runway host is never blocked at a cruel moment. The 7 days is the soft nudge; the feature gate is the real conversion mechanism.

**Pricing anchor:** a typical Nigerian event planner charges ~10% of total event cost — ₦1,000,000 on a ₦10m event. AriyaPlanner's ₦50,000 flat pass is 0.5% of that same event: the core marketing line is *"a planner charges ₦1m; AriyaPlanner coordinates the same event for ₦50k."* The higher price point also signals seriousness in a market where cheap reads as unreliable. Episodic per-event pricing beats subscriptions for episodic behaviour.

**Held in reserve (not launch):** budget-tiered passes if 90-day data shows ₦50k choking conversion on smaller events (birthdays/naming ceremonies at ₦1–3m budgets, where ₦50k is ~2–5% of spend) — e.g. ₦25k under ₦3m / ₦50k standard / premium tier for ₦20m+ events. Monitor conversion by event type before acting.

## 9. GTM (launch 90 days)

1. **Burial-first acquisition message** alongside wedding content: "Plan a befitting farewell without family wahala" — urgent, underserved, zero competition for the keyword space. Channel: Facebook (older demographic skew), church/mosque community partnerships, funeral home referral arrangements (they are vendors in the registry, not competitors).
2. **Ariya Price Index** content engine: "The Real Cost of a Lagos Wedding 2026," "What a befitting burial actually costs," per-category explainers — SEO + TikTok/IG carousels, all powered by the Price Band Engine. This is the compounding acquisition asset.
3. **Committee virality:** every Event Pass onboards 5–15 members who experience the product free at the most emotionally memorable moments of family life.
4. **Vendor seeding sprint:** 50–100 founding vendors (Lagos) recruited pre-launch via Instagram outreach; free profiles for verified price bands. (On-ground task — candidate shared scope with LuxStay Lagos ops, decision needed.)
5. **Milestone & track-record engine:** because usage is episodic, visible track record does the trust work that subscription familiarity normally does. Public landing-page counter ("X events planned with AriyaPlanner," segmentable by city/event type) where an event counts only if it meets the north-star bar (§10) — the number must mean something. Per-vendor counters on profiles ("served N AriyaPlanner events" — feeds Phase 3 marketplace credibility). Post-event shareable recap card for the family (committee size, vendors, tasks completed) timed to when guests are posting event photos. Internal milestone beats (event #100, #1,000) as marketing moments. Returning-host memory: past events, trusted vendors and committee contacts pre-loaded on the next event ("your caterer from Mum's 70th is available") — episodic is not one-off; Nigerian families have recurring events.
6. Launch geography: Lagos only for 90 days; Abuja at month 4.

## 10. Success Metrics

North star: **events that reach their event date with ≥70% tasks completed on AriyaPlanner** (a proxy for "we actually coordinated this event").

Supporting: trial-to-paid conversion (target 15% of trials started); committee members per paid event (target ≥6); week-4 committee member → new event creation rate (viral coefficient, target ≥0.15 in 6 months); BYOV vendors logged per event (target ≥5); contribution ledger usage on burials (target ≥80% of Memorial events); price-index organic traffic.

## 11. Build Phasing

- **Phase 0 (weeks 1–4):** PWA scaffold (Next.js 14 + manifest + service worker + offline shell); schema + auth + event/committee/task core; Cultural Program Library v1 (12 templates: Yoruba/Igbo/Hausa × wedding; Christian/Muslim × burial; naming ×2; birthday ×2); Price Band Engine v1 (seeded). Meta business verification + WhatsApp template submission **starts week 1**.
- **Phase 1 (weeks 5–10):** Architect agent end-to-end (web first, WhatsApp as templates clear); Committee Mode; contribution ledger; BYOV + quote comparison; Event Pass via Paystack.
- **Phase 2 (weeks 11–14):** Aso-ebi manager; day-of command centre + PDFs; Memorial register full pass; vendor seed registry live; ratings.
- **Launch (week 14–16):** Lagos soft launch — target 25 real events (mixed: ≥5 burials) before paid marketing.
- **Post-launch phases:** P2 = contribution collection + escrow + diaspora tier; P3 = vendor marketplace switch-on (claimable profiles, subscriptions, leads).

Standard methodology applies next: CLAUDE.md + SKILL.md set (suggested: `cultural-programs`, `price-bands`, `whatsapp-flows`, `memorial-tone`), then the sequenced Claude Code prompt pack (est. 30–35 prompts).

## 11a. Adjacent Verticals (Deferred — on record, out of launch scope)

The core engine (Architect → program + budget; runway-aware scheduling; workstreams; vendor shortlist + quote comparison; day-of command centre) is event-type-agnostic. Several adjacent verticals are therefore reachable but deliberately excluded from v1 to protect focus and the cultural-depth positioning. Each is documented here so the decision is recorded, not rediscovered.

- **Corporate / office events.** Two distinct tiers. (1) *Informal* — office Christmas parties, team get-togethers, staff retirements, small company milestones — resemble social celebrations and the existing engine handles them almost as-is (effectively a birthday-shaped event with a company paying); these can be quietly supported early without building a corporate product. (2) *Formal* — conferences, product launches, AGMs, sponsor-driven events — are a genuinely different product (Cvent/Bizzabo territory) requiring a net-new template library (run-of-sheet, AV/stage, registration, speaker/sponsor logistics), approval-based budgeting (budget owner + finance approval chain, POs/invoices/procurement rather than family pledges/levies), and a B2B motion (buyer is an office manager/EA/HR/events agency, channel skews email/dashboard over WhatsApp). **Strategic caution:** adding "corporate events" to the launch story blurs the sharp cultural-family positioning into generic, crowded, undifferentiated "event planning software" and weakens differentiation vs Vowthread and Western tools. Verdict: support informal office get-togethers opportunistically because the engine already can; build the formal corporate vertical only as a **Phase 3+** product with its own templates, approval-based budgeting and B2B sales motion, after the consumer wedge is winning.
- **Diaspora concierge tier** (Phase 2/3) — see §3 P5 and §8: GBP/USD-priced remote planning with on-ground vendor verification; deferred until local vendor data and trust signals make it credible.
- **Hire-a-Coordinator** (Phase 2/3) — see §F6: vetted freelance day-of coordinator pool; near-mandatory for the diaspora tier; converts professional planners into supply.

The discipline across all three is identical: the engine generalises, but each new vertical brings a different buyer, channel, or template set, so none is opened until the family/social wedge has demonstrated traction.

## 12. Risks & Open Questions

- **Vowthread velocity:** they may add planning tools; our counter is committee + culture + burials + speed. Monitor monthly.
- **WhatsApp API dependency:** template rejections or throughput caps would force web-first launch — acceptable but weaker. Mitigated by starting verification week 1 and designing full web parity.
- **Cultural correctness liability:** wrong program content damages trust irreparably. Mitigation: Library is human-curated and reviewed by cultural consultants per ethnicity before shipping; agent never free-generates ritual sequences; in-product "verify with your family elders" framing.
- **Contribution-data sensitivity:** family money data demands strict privacy defaults (NDPR registration, RLS, role-gated visibility). DPIA-style review before launch even though UK GDPR doesn't apply — NDPA/NDPR does.
- **Founder bandwidth / LuxStay overlap:** shared Lagos vendor ops is an efficiency or a distraction depending on sequencing. Decision needed before vendor seeding sprint.
- **Open:** ariyaplanner.com/.ng availability + CAC search; Igbo/Hausa cultural consultant sourcing; per-head catering band research depth for Price Index v1; budget-tiered pricing trigger thresholds (see §8 reserve).

---

*Next documents in sequence: CLAUDE.md → SKILL.md ×4 → Build Prompt Pack v1.*
