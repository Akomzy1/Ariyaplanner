import type { Metadata } from "next";
import { SignOutButton } from "@/components/auth/sign-out-button";
import { createClient } from "@/lib/db/supabase/server";

export const metadata: Metadata = {
  title: "Event Architect",
};

// P1/P3 SCAFFOLD STUB for the "/architect" authed route. The conversational
// intake + plan view is implemented from `04-architect.html` in Prompts 7, 8
// and 11. For now it confirms the session and offers sign-out.
export default async function ArchitectPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <main className="mx-auto flex min-h-dvh max-w-xl flex-col items-center justify-center gap-4 px-6 text-center">
      <h1 className="text-xl font-semibold text-foreground">Event Architect</h1>
      <p className="text-sm text-muted-foreground">
        Signed in{user?.phone ? ` as ${user.phone}` : ""}. The intake and plan
        view arrive in Prompts&nbsp;7–11.
      </p>
      <SignOutButton />
    </main>
  );
}
