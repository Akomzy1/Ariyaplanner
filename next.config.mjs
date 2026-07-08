import withSerwistInit from "@serwist/next";

// PWA service worker (Serwist). Source lives at app/sw.ts, compiled to public/sw.js.
// Disabled in dev so the SW cache never masks local changes; auto-registers in prod.
const withSerwist = withSerwistInit({
  swSrc: "app/sw.ts",
  swDest: "public/sw.js",
  disable: process.env.NODE_ENV === "development",
  register: true,
  reloadOnOnline: true,
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
};

export default withSerwist(nextConfig);
