---
name: runway-scheduler
description: The deterministic critical-path scheduling engine. Use when building task generation, deadline back-calculation, short-runway triage, drift replanning, feasibility checks, or the runway indicator UI. The scheduler is pure math; the LLM only explains its output.
---

# Runway Scheduler — SKILL

## Principle

Scheduling is **deterministic critical-path computation** in `/lib/scheduler` (pure functions, fully unit-tested). The LLM never computes dates, slack, or feasibility — it receives the scheduler's structured output and explains trade-offs in human terms. Reliable where it must be, intelligent where it helps.

## Inputs

- `runway_days` = event_date − today (recomputed on every plan view).
- Task templates per event type, each with: `lead_time_days` (production/booking time), `dependencies` (uuid[]), `criticality` (`blocking` | `important` | `nice`), `parallelisable_by_workstream` (bool).

## Algorithm (Prompt 10 implements exactly this)

1. Topological sort tasks by dependencies (cycle = data error, throw).
2. Backward pass from event date: `latest_start = min(dependent.latest_start) − lead_time_days`; `due_date = latest_start + lead_time_days`.
3. Forward pass from today for `earliest_start`; **slack = latest_start − earliest_start**.
4. Critical path = chain(s) with slack ≤ 0 buffer threshold (default 2 days).
5. Feasibility per task: `infeasible` if `latest_start < today`.

## Runway modes (structure changes, not just dates)

- **Comfortable (slack ≥ 14d on critical path):** conventional sequencing; surface "book early to lock price" ordering (deposits hedge naira inflation).
- **Tight (0 < slack < 14d):** compress: mark parallelisable tasks, shorten nice-to-haves, weekly → twice-weekly nudge cadence.
- **Triage (any blocking task infeasible — the burial norm at 2–6 weeks):** the scheduler emits `infeasible_tasks[]` + `alternatives_needed[]`; the Architect then swaps template alternatives (e.g., `aso_ebi_custom` lead 21d → `aso_ebi_ready_made` lead 5d) and states the trade-off plainly. A 3-week plan is structurally different from a 6-month plan — never the same checklist with tighter dates.

## Feasibility honesty (intake gate)

If >30% of blocking tasks are infeasible at intake (e.g., 10 days to a 500-guest wedding), the Architect must say plainly what is and isn't achievable and propose a scoped-down plan. No fantasy schedules — the scheduler's verdict is non-negotiable input to the conversation.

## Drift replanning

Nightly job + on-task-completion recompute. When a task's slack crosses thresholds, emit events: `slack_warning` (≤4d: "decorator decision has 4 days of slack before it threatens venue setup") → Event Coordinator via `task_nudge` mechanics; `now_infeasible` → Architect proposes alternatives. All alerts reference concrete tasks and day counts from scheduler output — the LLM may rephrase, never re-derive numbers.

## Testing (required)

Golden tests: 6-month wedding, 3-week Christian burial, 48-hour Muslim janazah (compressed template must schedule feasibly), drift scenario (task slips → correct new critical path), cycle detection, infeasible-intake detection. These six must pass before any prompt that consumes the scheduler.
