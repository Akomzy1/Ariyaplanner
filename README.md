# AriyaPlanner

The AI event planner for Nigerian families and workplaces — weddings, burials,
birthdays, naming ceremonies and office celebrations. Turns family WhatsApp chaos
into a coordinated plan: culturally correct programmes, naira budgets, committee
workstreams, contribution tracking, vendor coordination and a day-of command
centre. Lagos/Abuja first. Built and owned by **Ariya Planner Ltd** (Nigeria).

This repo is built prompt-by-prompt from `AriyaPlanner_Build_Prompts_v1.md`.
Read `CLAUDE.md` first — the design prototype in `/design-prototype/` is the
single source of truth for all UI, and `/skills/` holds the domain rules.

## Stack

Next.js 14 (App Router, TypeScript strict) · installable PWA (Serwist) ·
Supabase (Postgres + RLS, Auth, Storage) · Claude API · Paystack ·
WhatsApp Business Cloud API · Tailwind + shadcn/ui · deployed on Vercel.

## Getting started

Requires Node ≥ 18.17 and pnpm 9 (`corepack` or `npm i -g pnpm@9`).

```bash
pnpm install
cp .env.example .env.local   # fill in as each prompt needs them
pnpm dev                     # http://localhost:3000
```

### Scripts

| Script            | What it does                                  |
| ----------------- | --------------------------------------------- |
| `pnpm dev`        | Dev server (service worker disabled)          |
| `pnpm build`      | Production build                              |
| `pnpm start`      | Serve the production build                     |
| `pnpm lint`       | ESLint (next/core-web-vitals + typescript)     |
| `pnpm typecheck`  | `tsc --noEmit`                                 |
| `pnpm format`     | Prettier                                       |
| `pnpm icons`      | Regenerate placeholder PWA icons               |

### Corporate networks / TLS

If `pnpm install` fails with `UNABLE_TO_VERIFY_LEAF_SIGNATURE`, your network
injects a corporate root CA that Node's bundled CA bundle doesn't trust. Point
Node at the OS certificate store:

```bash
export NODE_OPTIONS=--use-system-ca   # Windows: setx NODE_OPTIONS --use-system-ca
```

## PWA

- Manifest: `app/manifest.ts` → `/manifest.webmanifest`
- Service worker: `app/sw.ts` (Serwist) → `public/sw.js`, with an `/offline` shell
- Install prompt: `components/pwa/add-to-home-screen.tsx` (custom, dismissible)
- Icons: `pnpm icons` writes placeholder solids; the branded set lands with P5.

The service worker is **disabled in development** so its cache never masks local
changes. To exercise it, run `pnpm build && pnpm start`.

## Layout

```
app/                 App Router — (marketing) + (app) groups, api routes
components/           UI + PWA components (shadcn/ui in components/ui)
lib/                  agents · scheduler · wa · db (filled per prompt)
skills/              domain SKILL.md files — read before coding a domain
design-prototype/    Claude Design HTML exports — source of truth for UI
supabase/migrations/ schema, seeds, RLS (P2/P4)
```
