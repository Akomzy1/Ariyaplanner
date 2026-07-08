import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Offline",
};

// Offline shell shown when a document navigation fails with no network.
// Copy is deliberately calm and register-neutral (no celebratory vocabulary,
// no exclamation marks) so it reads correctly for a memorial event too
// (skills/memorial-tone). The full offline command-centre experience is P21.
export default function OfflinePage() {
  return (
    <main className="mx-auto flex min-h-dvh max-w-md flex-col items-center justify-center gap-4 px-6 text-center">
      <div
        aria-hidden
        className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10 text-2xl font-semibold text-primary"
      >
        A
      </div>
      <h1 className="text-xl font-semibold text-foreground">
        You are offline
      </h1>
      <p className="text-sm text-muted-foreground">
        AriyaPlanner needs a connection to load this page. Anything already saved
        to this device stays available — reconnect and it will sync.
      </p>
    </main>
  );
}
