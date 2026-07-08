// Nigerian phone-number normalization to E.164 (+234…), used by WhatsApp-number
// OTP auth (P3) and everywhere a phone is stored or deduped (vendors, invites).
//
// Accepts the common shapes Nigerians type — 08031234567, 8031234567,
// +2348031234567, 234 803 123 4567, with spaces/dashes/parens — and returns a
// canonical +234XXXXXXXXXX, or null if it is not a valid NG mobile number.
//
// NG mobile national numbers are 10 digits whose network digit is 7, 8 or 9
// (070…, 080…, 081…, 090…, 091…, 070…). Landlines are out of scope for auth.

const NG_NATIONAL = /^[789]\d{9}$/;

export function normalizeNgPhone(raw: string | null | undefined): string | null {
  if (!raw) return null;

  let digits = raw.replace(/[^\d]/g, "");

  // Strip the country code, then a national trunk 0, in that order.
  if (digits.startsWith("234")) digits = digits.slice(3);
  if (digits.startsWith("0")) digits = digits.slice(1);

  if (!NG_NATIONAL.test(digits)) return null;
  return `+234${digits}`;
}

export function isValidNgPhone(raw: string | null | undefined): boolean {
  return normalizeNgPhone(raw) !== null;
}

// Presentational form: +234 803 123 4567
export function formatNgPhone(raw: string | null | undefined): string | null {
  const e164 = normalizeNgPhone(raw);
  if (!e164) return null;
  const n = e164.slice(4); // 10 national digits
  return `+234 ${n.slice(0, 3)} ${n.slice(3, 6)} ${n.slice(6)}`;
}
