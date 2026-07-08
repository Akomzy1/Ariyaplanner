"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createClient } from "@/lib/db/supabase/client";
import { formatNgPhone, normalizeNgPhone } from "@/lib/auth/phone";

// DESIGN-GAP: there is no auth/login screen in /design-prototype/. This is a
// minimal, token-consuming treatment derived from the design system; Prompt 5
// should reconcile it if a login design is added.

type Step = "phone" | "otp";

export function LoginForm() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("phone");
  const [phoneInput, setPhoneInput] = useState("");
  const [e164, setE164] = useState("");
  const [code, setCode] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function sendCode(event: React.FormEvent) {
    event.preventDefault();
    setError(null);

    const normalized = normalizeNgPhone(phoneInput);
    if (!normalized) {
      setError("Enter a valid Nigerian mobile number, e.g. 0803 123 4567.");
      return;
    }

    setBusy(true);
    try {
      const supabase = createClient();
      const { error: sendError } = await supabase.auth.signInWithOtp({
        phone: normalized,
        options: { channel: "sms" },
      });
      if (sendError) throw sendError;
      setE164(normalized);
      setStep("otp");
    } catch (err) {
      setError(messageFor(err));
    } finally {
      setBusy(false);
    }
  }

  async function verifyCode(event: React.FormEvent) {
    event.preventDefault();
    setError(null);

    if (!/^\d{6}$/.test(code)) {
      setError("Enter the 6-digit code we sent you.");
      return;
    }

    setBusy(true);
    try {
      const supabase = createClient();
      const { error: verifyError } = await supabase.auth.verifyOtp({
        phone: e164,
        token: code,
        type: "sms",
      });
      if (verifyError) throw verifyError;
      router.push("/architect");
      router.refresh();
    } catch (err) {
      setError(messageFor(err));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="w-full max-w-sm space-y-6">
      <div className="space-y-2 text-center">
        <div
          aria-hidden
          className="mx-auto flex h-14 w-14 items-center justify-center rounded-2xl bg-primary text-2xl font-semibold text-primary-foreground"
        >
          A
        </div>
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          {step === "phone" ? "Welcome to AriyaPlanner" : "Enter your code"}
        </h1>
        <p className="text-sm text-muted-foreground">
          {step === "phone"
            ? "Sign in with your WhatsApp number to plan and coordinate your event."
            : `We sent a 6-digit code to ${formatNgPhone(e164) ?? e164}.`}
        </p>
      </div>

      {step === "phone" ? (
        <form onSubmit={sendCode} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="phone">Phone number</Label>
            <Input
              id="phone"
              name="phone"
              type="tel"
              inputMode="tel"
              autoComplete="tel"
              placeholder="0803 123 4567"
              value={phoneInput}
              onChange={(e) => setPhoneInput(e.target.value)}
              disabled={busy}
              autoFocus
            />
          </div>
          {error ? <p className="text-sm text-destructive">{error}</p> : null}
          <Button type="submit" className="w-full" disabled={busy}>
            {busy ? "Sending…" : "Send code"}
          </Button>
        </form>
      ) : (
        <form onSubmit={verifyCode} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="code">6-digit code</Label>
            <Input
              id="code"
              name="code"
              type="text"
              inputMode="numeric"
              autoComplete="one-time-code"
              maxLength={6}
              placeholder="123456"
              value={code}
              onChange={(e) => setCode(e.target.value.replace(/\D/g, ""))}
              disabled={busy}
              autoFocus
            />
          </div>
          {error ? <p className="text-sm text-destructive">{error}</p> : null}
          <Button type="submit" className="w-full" disabled={busy}>
            {busy ? "Verifying…" : "Verify and continue"}
          </Button>
          <button
            type="button"
            onClick={() => {
              setStep("phone");
              setCode("");
              setError(null);
            }}
            className="w-full text-center text-sm text-muted-foreground hover:text-foreground"
            disabled={busy}
          >
            Use a different number
          </button>
        </form>
      )}
    </div>
  );
}

function messageFor(err: unknown): string {
  const raw = err instanceof Error ? err.message : String(err);
  if (/not configured/i.test(raw)) {
    return "Sign-in isn't set up yet — add your Supabase project to enable it.";
  }
  if (/invalid|expired|token/i.test(raw)) {
    return "That code didn't work. Check it and try again, or resend.";
  }
  return "Something went wrong — please try again in a moment.";
}
