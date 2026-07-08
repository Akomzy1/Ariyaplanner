// P1 SCAFFOLD PLACEHOLDER for the "/" route.
// The real homepage is implemented from `01` (AriyaPlanner Homepage) prototype
// in Prompt 6. This placeholder only exists so the app builds and serves an
// installable shell during Phase 0 — it is intentionally minimal and is not a
// design deliverable. DESIGN-GAP: none — the prototype homepage supersedes this.
export default function HomePage() {
  return (
    <main className="mx-auto flex min-h-dvh max-w-xl flex-col items-center justify-center gap-5 px-6 text-center">
      <div
        aria-hidden
        className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary text-3xl font-semibold text-primary-foreground"
      >
        A
      </div>
      <h1 className="text-2xl font-semibold tracking-tight text-foreground">
        AriyaPlanner
      </h1>
      <p className="max-w-md text-balance text-sm text-muted-foreground">
        The AI event planner for Nigerian families and workplaces. The homepage
        lands in Prompt&nbsp;6 — this is the Phase&nbsp;0 scaffold.
      </p>
    </main>
  );
}
