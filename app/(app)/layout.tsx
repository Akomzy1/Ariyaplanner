import { redirect } from "next/navigation";
import { hasSupabaseEnv } from "@/lib/db/supabase/env";
import { createClient } from "@/lib/db/supabase/server";

export const dynamic = "force-dynamic";

// Authed PWA route group: architect, committee, ledger, vendors, day-of.
// This server layout gates EVERY route in the group — unauthenticated visitors
// are sent to /login. The memorial register is applied per-event within the
// subtree once events load (P7/P11).
export default async function AppLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  if (!hasSupabaseEnv()) redirect("/login");

  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  return <>{children}</>;
}
