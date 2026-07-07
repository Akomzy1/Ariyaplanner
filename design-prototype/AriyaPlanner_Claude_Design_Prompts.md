# AriyaPlanner — Claude Design Prompt Pack

*For use with the Relume wireframe import · Ariya Planner Ltd · v1.0*

---

## How to use this pack

These prompts are designed to be dropped into Claude Design alongside your imported Relume wireframe. Run them in sequence. **Prompt 0 establishes the visual system and must be run first** — every screen after it inherits the same brand tokens, the dual celebration/memorial colour registers, and the typography, so you never have to re-explain the tone-switch on each screen.

Prompts 1–3 cover the marketing surfaces that came out of Relume. Prompts 4–5 are the in-app product screens, which Relume cannot meaningfully wireframe because they are interactive application UI — these are designed natively in Claude Design. Several prompts deliberately render both a celebration and a memorial version of a screen, because that tone-switch is the most distinctive and most easily-botched part of the product.

**Sequence:** Prompt 0 (brand system) → Prompt 1 (homepage) → Prompt 2 (event-type pages) → Prompt 3 (pricing + price index) → Prompt 4 (AI Event Architect) → Prompt 5 (committee, ledger, command centre).

---

## Prompt 0 — Brand & Visual System

**Run this first, before any screen.**

```
Establish the visual design system for AriyaPlanner, an AI event-planning platform 
for Nigerian families (weddings, burials, birthdays, naming ceremonies). Apply this 
system consistently to every screen I design next.

BRAND PERSONALITY: warm, trustworthy, culturally rooted, human, calm-competent. 
It belongs to Nigerian family life — NOT a glossy Silicon Valley SaaS, NOT sterile 
minimalism, NOT a Western wedding-tech aesthetic. Premium through warmth and care, 
not through coldness.

COLOR — two registers from one system:
- Celebration register (weddings, birthdays, naming, default): deep emerald green as 
  primary, warm gold/ochre as accent, soft cream/off-white backgrounds, charcoal 
  text. Rich but not loud. Draws on Nigerian celebration warmth without clichéd 
  kente-print backgrounds.
- Memorial register (burials): the SAME system desaturated — muted sage/slate 
  instead of bright emerald, soft stone/grey neutrals, the gold dialled back to a 
  quiet bronze. Calm, dignified, never grey-depressing. No celebratory motifs, 
  no confetti, ever.

TYPOGRAPHY: a warm humanist serif for headings (approachable, editorial, has 
character) paired with a clean readable sans for body and UI. Generous sizing, 
comfortable line-height. Should feel like considered editorial, not a dashboard.

VISUAL LANGUAGE: rounded-but-not-bubbly corners; soft natural shadows; real warmth 
in imagery (Nigerian families, events, fabrics, food — authentic, not stock-glossy); 
naira (₦) shown natively in all pricing/budget UI; subtle gold-line dividers as a 
recurring motif. Iconography simple and friendly.

ACCESSIBILITY: strong contrast, large tap targets (mobile-first — most users are on 
phones), legible at small sizes.

Output a design system: color tokens (both registers), type scale, spacing, button 
styles, card styles, form/input styles, and a component starter set.
```

> **Why this prompt:** It is load-bearing. Running it first means the dual-register colour system propagates to every screen, so the celebration-vs-memorial tone-switch never has to be re-explained.

---

## Prompt 1 — Marketing Homepage

```
Using the AriyaPlanner design system (celebration register) and my imported Relume 
wireframe, design the marketing homepage as a polished, mobile-first landing page.

Sections in order:
- Hero: warm headline about turning family WhatsApp chaos into a coordinated plan. 
  Primary CTA "Start your event", secondary "See how it works". Supporting line: 
  "A planner charges ₦1,000,000 to coordinate a ₦10m event. AriyaPlanner does it 
  for ₦50,000." Hero imagery: authentic Nigerian celebration warmth.
- Live trust counter: "X,XXX events planned with AriyaPlanner" with city filter chips.
- The problem: the family group chat, the contribution notebook, unvetted vendors, 
  day-of chaos — shown empathetically.
- How it works, 4 steps with icons: (1) Tell the AI about your event (2) Get a 
  culturally-correct program + naira budget (3) Invite your family into roles 
  (4) Coordinate everyone on WhatsApp through to the day.
- Event types: 5 cards — Weddings, Burials, Birthdays, Naming ceremonies, Office 
  celebrations (Burials card subtly calmer in tone; Office card professional-warm, 
  visually quieter than the family cards — present, not headline).
- Feature highlights: AI Event Architect, Committee Mode, Contribution Tracking, 
  Aso-ebi Manager, Vendor Coordination, Day-of Command Centre.
- WhatsApp section: show a realistic WhatsApp chat mockup of the AriyaPlanner 
  assistant messaging a family member with their tasks.
- Testimonials.
- Pricing teaser: single ₦50,000 Event Pass, 7-day free trial.
- Final CTA + footer.

Make it feel warm, premium and trustworthy. Mobile-first, then desktop.
```

---

## Prompt 2 — Event-Type Pages (template + Burials variant)

```
Using the AriyaPlanner design system and Relume wireframe, design the event-type 
landing page template, then produce two versions:

VERSION A — Weddings (celebration register): hero specific to weddings, 
wedding-specific pain points (multiple ceremonies, aso-ebi, big guest lists, vendor 
coordination), how AriyaPlanner handles each, CTA to start.

VERSION B — Burials (MEMORIAL register — this is critical): switch entirely to the 
muted memorial palette. Calm, dignified, plain language. Headline framed as 
"Plan a befitting farewell" — never "burial party". Acknowledge the difficulty once, 
simply, then be practical: short timelines, family committees, contribution/levy 
tracking, vendor coordination under pressure. NO exclamation marks, no celebratory 
imagery, no confetti, gentle CTA ("Begin planning, one step at a time"). This page 
must feel emotionally different from the wedding page while clearly the same product.

VERSION C — Office celebrations (celebration register, professional-warm): 
end-of-year parties, retirement send-offs, company milestones. Pain points: one 
overloaded organiser, colleague committees, vendor sourcing on a work budget. Tone: 
warm but workplace-appropriate — less familial, no cultural/ritual content, clean 
and efficient. Same components as A, quieter imagery (office gatherings, not 
weddings). CTA "Plan your office celebration". This page exists for SEO and 
discoverability — it should feel like part of the family, not the flagship.
```

> **Why this prompt:** The memorial register is the most distinctive and most easily-botched part of the product. Rendering both versions side by side is how you catch any drift back toward party styling.

---

## Prompt 3 — Pricing & Ariya Price Index

```
Using the AriyaPlanner design system, design two pages from my Relume wireframe:

PRICING PAGE: single plan — ₦50,000 flat Event Pass per event, 7-day free trial. 
A clear side-by-side comparison vs hiring a traditional planner (10% of event cost 
= ₦1m on a ₦10m event), an included-features list, and a pricing FAQ. Make the value 
contrast the hero of the page.

ARIYA PRICE INDEX HUB: an SEO content hub for cost guides ("The Real Cost of a Lagos 
Wedding 2026", "What a Befitting Burial Actually Costs", per-category vendor price 
guides). Design a featured cost-breakdown module (a clean ₦ price-band visual: 
category, low/standard/premium ranges) plus an article grid. This is the acquisition 
engine — make the data feel authoritative and shareable.
```

---

## Prompt 4 — In-App: AI Event Architect (core screen)

```
Using the AriyaPlanner design system, design the in-app AI Event Architect 
experience — the core product screen. This is NOT in the Relume wireframe; design it 
fresh as application UI, mobile-first.

Screens:
- Conversational intake: a warm chat interface where the AI Architect interviews the 
  host (event type, culture/tradition, religion, date, city, guest count, budget). 
  Show selectable chips for quick answers, not just a text box.
- The generated plan view, with three tabs: PROGRAM (a culturally-correct 
  multi-ceremony run-of-show as an elegant timeline), BUDGET (line-item naira budget 
  with Manage/Standard/Premium tiers, totals vs budget band), and TASKS (the 
  checklist grouped into committee workstreams, with deadlines).
- A "runway" indicator showing days until the event and whether the timeline is 
  comfortable or tight (for short-runway/burial cases).

Show both a celebration-register version (a wedding) and a memorial-register version 
(a burial) of the plan view so the tone-switch is visible.
```

---

## Prompt 5 — In-App: Committee Board, Ledger & Command Centre

```
Using the AriyaPlanner design system, design three core in-app screens (application 
UI, mobile-first, not in the Relume wireframe):

1. COMMITTEE BOARD: the Event Coordinator's view of all workstreams (Food & Drinks, 
Venue & Decor, Aso-ebi, Finance, etc.) as cards showing assigned lead, task progress, 
and budget allocation. Show the human roles clearly (Chief Host, Event Coordinator, 
Workstream Leads). Include a member-invite flow via WhatsApp number.

2. CONTRIBUTION LEDGER: a dignified view of who pledged what and who has paid — 
contributor list, pledged vs received amounts in ₦, status tags, and a gentle 
"send reminder" action. Show a burial/Memorial variant using "support" language and 
the muted palette. Privacy-forward (amounts visible only to host/finance lead).

3. DAY-OF COMMAND CENTRE: the Day-of Coordinator's mobile screen — minute-by-minute 
run-of-show, a vendor arrival checklist with tick-off and live check-in status, 
deposit/balance flags per vendor, and an escalation contact list ("if X fails, 
call Y"). Design for one-handed use under pressure on event day. Include an offline 
state showing cached run-of-show and vendor contacts (the PWA must work with poor 
venue signal).
```

> **Why this prompt:** The day-of command centre is used live, often on bad venue signal. Designing the offline/degraded state explicitly is what makes the PWA trustworthy at the highest-stakes moment.

---

## After Claude Design

Once the designs are approved, the next pipeline step is the sequenced Claude Code build prompt pack. Before that, the CLAUDE.md and SKILL.md set should be written — they encode the cultural-program library, price bands, WhatsApp flows, memorial tone, and the critical-path scheduler that the build prompts will rely on.
