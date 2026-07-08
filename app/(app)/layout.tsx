// Authed PWA route group: architect, committee, ledger, vendors, day-of.
// Auth gating (unauthenticated → marketing) is wired in Prompt 3; the memorial
// register is applied per-event within this subtree once events load (P7/P11).
// For now this is a structural pass-through so the group resolves.
export default function AppLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return <>{children}</>;
}
