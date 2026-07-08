import type { Metadata, Viewport } from "next";
import "./globals.css";
import { AddToHomeScreen } from "@/components/pwa/add-to-home-screen";

export const metadata: Metadata = {
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_APP_URL ?? "http://localhost:3000",
  ),
  applicationName: "AriyaPlanner",
  title: {
    default: "AriyaPlanner — plan your celebration, together",
    template: "%s · AriyaPlanner",
  },
  description:
    "AriyaPlanner turns family WhatsApp chaos into a coordinated plan — culturally correct programmes, naira budgets, committee workstreams and a day-of command centre for Nigerian weddings, burials, birthdays and naming ceremonies.",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "AriyaPlanner",
  },
  formatDetection: { telephone: false },
};

export const viewport: Viewport = {
  // Placeholder theme colour — Prompt 5 sets this from the prototype tokens.
  themeColor: "#0B6B3A",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  // Default register is celebration. Memorial events set data-register="memorial"
  // at the event shell — register is driven by events.mode, never hand-picked by
  // components (CLAUDE.md §0, skills/memorial-tone).
  return (
    <html lang="en" data-register="celebration" suppressHydrationWarning>
      <body className="min-h-dvh bg-background text-foreground antialiased">
        {children}
        <AddToHomeScreen />
      </body>
    </html>
  );
}
