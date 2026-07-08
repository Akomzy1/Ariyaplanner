import type { NextRequest } from "next/server";
import { updateSession } from "@/lib/db/supabase/middleware";

export async function middleware(request: NextRequest) {
  return updateSession(request);
}

export const config = {
  // Run on all routes except static assets, the service worker, and the webhook
  // endpoints (which authenticate by signature, not session).
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|sw.js|manifest.webmanifest|icons/|api/wa/|api/paystack/|.*\\.(?:png|jpg|jpeg|svg|gif|webp|ico)$).*)",
  ],
};
