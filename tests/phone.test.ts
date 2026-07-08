import { describe, expect, it } from "vitest";
import { formatNgPhone, isValidNgPhone, normalizeNgPhone } from "@/lib/auth/phone";

describe("normalizeNgPhone", () => {
  it("normalizes every common NG input to +234XXXXXXXXXX", () => {
    const expected = "+2348031234567";
    for (const input of [
      "08031234567",
      "8031234567",
      "+2348031234567",
      "2348031234567",
      "+234 803 123 4567",
      "0803-123-4567",
      "(0803) 123 4567",
      " 0803 123 4567 ",
    ]) {
      expect(normalizeNgPhone(input)).toBe(expected);
    }
  });

  it("accepts 7/8/9 network prefixes", () => {
    expect(normalizeNgPhone("07012345678")).toBe("+2347012345678");
    expect(normalizeNgPhone("09012345678")).toBe("+2349012345678");
    expect(normalizeNgPhone("08123456789")).toBe("+2348123456789");
  });

  it("rejects invalid numbers", () => {
    for (const bad of [
      "",
      null,
      undefined,
      "0123456789", // network digit 1
      "0803123456", // too short
      "080312345678", // too long
      "+1 415 555 0100", // not NG
      "abcdefghij",
      "234",
    ]) {
      expect(normalizeNgPhone(bad)).toBeNull();
    }
  });
});

describe("isValidNgPhone / formatNgPhone", () => {
  it("validates and formats", () => {
    expect(isValidNgPhone("08031234567")).toBe(true);
    expect(isValidNgPhone("0123")).toBe(false);
    expect(formatNgPhone("08031234567")).toBe("+234 803 123 4567");
    expect(formatNgPhone("bad")).toBeNull();
  });
});
