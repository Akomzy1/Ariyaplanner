import { type NextRequest, NextResponse } from "next/server";

// WhatsApp Business Cloud API inbound webhook.
// P1 provides only the Meta verification handshake (GET) so the endpoint can be
// registered. Signature verification, logging to wa_messages, the structured
// reply handlers (DONE/PAID/HERE/1) and the Haiku classify→extract pipeline are
// implemented in P17/P19 (see skills/whatsapp-flows).

export async function GET(request: NextRequest) {
  const params = request.nextUrl.searchParams;
  const mode = params.get("hub.mode");
  const token = params.get("hub.verify_token");
  const challenge = params.get("hub.challenge");

  const verifyToken = process.env.WHATSAPP_WEBHOOK_VERIFY_TOKEN;

  if (mode === "subscribe" && verifyToken && token === verifyToken) {
    return new NextResponse(challenge ?? "", { status: 200 });
  }

  return new NextResponse("Forbidden", { status: 403 });
}

export async function POST() {
  // FUTURE (P17/P19): verify X-Hub-Signature-256, log inbound, route replies.
  // Meta requires a prompt 200 to avoid retries; inbound handling is not wired yet.
  return NextResponse.json({ received: true }, { status: 200 });
}
