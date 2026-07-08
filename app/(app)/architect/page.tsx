import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Event Architect",
};

// P1 SCAFFOLD STUB for the "/architect" authed route.
// The conversational intake + plan view is implemented from `04-architect.html`
// in Prompts 7, 8 and 11. This stub only establishes the (app) route group.
export default function ArchitectPage() {
  return (
    <main className="mx-auto flex min-h-dvh max-w-xl flex-col items-center justify-center gap-3 px-6 text-center">
      <h1 className="text-xl font-semibold text-foreground">Event Architect</h1>
      <p className="text-sm text-muted-foreground">
        The intake and plan view arrive in Prompts&nbsp;7–11.
      </p>
    </main>
  );
}
