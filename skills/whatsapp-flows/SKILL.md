---
name: whatsapp-flows
description: The complete WhatsApp interaction model. Use when building the webhook receiver, outbound send infrastructure, message templates, agent-in-WhatsApp parsing, nudges, broadcasts, or vendor briefings. Covers the 24-hour window rule, the template catalogue, the individual-threads doctrine, and privacy rules.
---

# WhatsApp Flows — SKILL

## Doctrine: individual threads, never groups

Every participant (committee member, contributor, vendor) talks to the AriyaPlanner business number on their **own 1:1 thread**. The Business API does not support bot-in-group participation, and the product forbids it anyway: privacy (contribution amounts never visible to third parties), no public shaming (nudges go only to the responsible person), role-tailored content (each thread carries only that person's tasks). AriyaPlanner replaces the need for the chaotic family group; it does not join it. "Broadcasts" = the same template sent to N individual threads; replies tally centrally.

## The 24-hour window rule (shapes everything)

- User messaged us within 24h → **session window open** → free-form messages allowed (agent replies, follow-ups).
- Window closed → only **pre-approved template messages** may be sent.
- Therefore: all system-initiated messages are templates; all conversational agent replies are session messages. `lib/wa/window.ts` computes window state from `wa_messages` and is unit-tested. Every outbound send checks window state first; if closed and no template fits, queue for web-app notification instead. **Template submission to Meta starts week 1 — launch dependency.**

## Template catalogue (v1 — names are canonical, build exactly these)

| Template | To | Trigger | Body sketch |
|---|---|---|---|
| `committee_invite` | member | host adds member | "{host} has added you to coordinate {workstream} for {event} on {date}. You have {n} tasks. Reply 1 to see them." |
| `task_nudge` | task owner | due date proximity (private) | "Hi {name}, {task} is due in {days} days. Reply DONE, or HELP for options." |
| `contribution_reminder` | contributor | host-controlled schedule | "Gentle reminder about your pledge of {amount} for {event}. Pay to {account}. Reply PAID when done." |
| `aso_ebi_announcement` | buyer list | host triggers | "Aso-ebi for {event} is ready — {price} per unit. Pay to {account}. Reply DONE when paid." |
| `vendor_day_before` | each confirmed vendor | T-1 day, auto | "Tomorrow you report to {coordinator} ({phone}). Arrival: {time}. Setup: {zone}. Balance due: {status}. Reply HERE when you arrive." |
| `vendor_checkin_ack` | vendor | vendor replies HERE | "Checked in — thank you. {coordinator} has been notified." |
| `day_of_digest` | day-of coordinator | event morning | run-of-show summary + link |
| `event_recap` | committee | post-event | recap + vendor rating link |

Memorial events: every template has a memorial variant (register per `skills/memorial-tone`) — submit both variants to Meta.

## Inbound handling (`/api/wa/webhook`)

1. Verify signature; upsert user by phone; log to `wa_messages`; open session window.
2. Route: structured replies first (DONE/PAID/HERE/1) → deterministic handlers. Otherwise → Haiku classifier: {task_update | vendor_quote | question | contribution | other} → tool-called extraction (Zod) → update DB → confirm in-thread ("Logged: caterer quote ₦8,000/head for 200 — that's mid-range for Lagos. Budget updated.").
3. Money-affecting extractions (quotes, payments) always echo back for confirmation before final commit if confidence < high.
4. Never send unsolicited marketing. Opt-out: STOP honoured immediately per thread, logged.

## Tone

Warm, brief, Nigerian-natural ("Well done!", "No wahala" acceptable in celebration register; NEVER in memorial). One idea per message. No walls of text — link to the PWA for anything heavy.
