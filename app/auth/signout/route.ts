import { NextResponse } from "next/server";
import { hasSupabaseEnv } from "@/lib/db/supabase/env";
import { createClient } from "@/lib/db/supabase/server";

export async function POST(request: Request) {
  if (hasSupabaseEnv()) {
    const supabase = createClient();
    await supabase.auth.signOut();
  }
  return NextResponse.redirect(new URL("/login", request.url), {
    status: 303,
  });
}
