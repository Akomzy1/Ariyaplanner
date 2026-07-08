// Marketing route group: homepage, event-type pages, pricing, price index.
// These surfaces are always celebration/neutral at the shell level; the burial
// event page swaps to the memorial register within its own subtree (P6).
export default function MarketingLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return <>{children}</>;
}
