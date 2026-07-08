import { NextResponse } from "next/server";

// Paystack webhook receiver.
// FUTURE (P16): verify the X-Paystack-Signature HMAC (SHA512 over the raw body
// with PAYSTACK_SECRET_KEY), handle charge.success idempotently to set
// events.pass_paid_at, and write an audit_log entry. P1 is a buildable stub.
export async function POST() {
  return NextResponse.json({ received: true }, { status: 200 });
}
