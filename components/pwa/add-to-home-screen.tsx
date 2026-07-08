"use client";

import { useEffect, useState } from "react";
import { X } from "lucide-react";

// Custom, dismissible add-to-home-screen prompt (P1 requirement: NOT the browser
// default mini-infobar). We intercept `beforeinstallprompt`, suppress the native
// UI, and surface our own banner that the user can accept or dismiss; dismissal
// is remembered so we do not nag.
//
// DESIGN-GAP: the prototype does not include an install-prompt design. This is a
// minimal, token-consuming treatment derived from existing patterns; Prompt 5
// should align it to the final component styling if a design is added.

const DISMISS_KEY = "ariya:a2hs-dismissed";

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

export function AddToHomeScreen() {
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(
    null,
  );
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    if (window.localStorage.getItem(DISMISS_KEY) === "1") return;

    const onBeforeInstall = (event: Event) => {
      event.preventDefault();
      setDeferred(event as BeforeInstallPromptEvent);
      setVisible(true);
    };

    const onInstalled = () => {
      setVisible(false);
      setDeferred(null);
    };

    window.addEventListener("beforeinstallprompt", onBeforeInstall);
    window.addEventListener("appinstalled", onInstalled);
    return () => {
      window.removeEventListener("beforeinstallprompt", onBeforeInstall);
      window.removeEventListener("appinstalled", onInstalled);
    };
  }, []);

  const dismiss = () => {
    setVisible(false);
    if (typeof window !== "undefined") {
      window.localStorage.setItem(DISMISS_KEY, "1");
    }
  };

  const install = async () => {
    if (!deferred) return;
    await deferred.prompt();
    await deferred.userChoice;
    setDeferred(null);
    setVisible(false);
  };

  if (!visible) return null;

  return (
    <div
      role="dialog"
      aria-label="Install AriyaPlanner"
      className="fixed inset-x-3 bottom-3 z-50 mx-auto flex max-w-md items-center gap-3 rounded-xl border border-border bg-card p-3 text-card-foreground shadow-lg"
    >
      <div
        aria-hidden
        className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-primary text-lg font-semibold text-primary-foreground"
      >
        A
      </div>
      <div className="min-w-0 flex-1">
        <p className="text-sm font-medium">Add AriyaPlanner to your phone</p>
        <p className="text-xs text-muted-foreground">
          Open it like an app, and keep the day-of essentials offline.
        </p>
      </div>
      <button
        type="button"
        onClick={install}
        className="shrink-0 rounded-lg bg-primary px-3 py-2 text-xs font-semibold text-primary-foreground"
      >
        Add
      </button>
      <button
        type="button"
        onClick={dismiss}
        aria-label="Dismiss"
        className="shrink-0 rounded-lg p-1.5 text-muted-foreground hover:text-foreground"
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}
