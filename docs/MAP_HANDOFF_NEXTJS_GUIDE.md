### Map Handoff (Next.js) Implementation Guide

This doc explains how to accept a signed, time‑bound, compressed handoff from the mobile app and show the Add dialog without user login when a valid handoff is present.

### Overview

- Mobile opens `https://map.airspothealth.com` with a signed payload using either:
  - Query params: `?v=1&kid=...&alg=HS256&enc=gzip&iat=...&exp=...&payload=<b64url>&sig=<b64url>`
  - Fragment (preferred): `#v=1&kid=...&alg=HS256&enc=gzip&iat=...&exp=...&payload=<b64url>&sig=<b64url>`
- You must verify signature and timing before trusting content.
- If valid, bypass the usual login check and show the Add dialog prefilled with data.

### Expected Payload (after verification/decompression)

```
{
  v: 1,
  deviceId: string,         // platform-local ID
  canonicalId: string,      // cross-platform BLE name or serial fallback
  co2: number,              // current ppm
  records: Array<{ ts: number; co2: number }>, // last ~500 points
  iat: number,              // issued-at (sec)
  exp: number,              // expiry (sec)
}
```

### Security Requirements

- alg must be HS256; enc must be gzip.
- Verify HMAC over the compressed bytes, not the JSON string.
- Check iat/exp (≤ 180 sec TTL) and reject if outside window.
- Rate-limit by canonicalId and IP.

### Environment Variables

- MAP_HMAC_KEYS_JSON: JSON mapping of kid→secret (base64url without padding preferred)
  - Example: `{ "map-key-2025-01": "K0wJ..." }`
    (Redis is not required; we are not using nonce.)

### Handling Fragment Mode (client)

If you choose fragment mode, parse it on the client and POST to an API route for verification and ingestion.

```ts
// app/(routes)/page.tsx or a dedicated handoff page
useEffect(() => {
  const hash = window.location.hash.startsWith("#")
    ? window.location.hash.slice(1)
    : "";
  if (!hash) return;
  const params = Object.fromEntries(new URLSearchParams(hash).entries());
  fetch("/api/handoff/ingest", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(params),
  })
    .then((r) => r.json())
    .then((res) => {
      if (res.ok) {
        // Show Add dialog prefilled; bypass login gating for this session
        // e.g., set state: setHandoffData(res.data)
      } else {
        // Show error toast/banner
      }
    })
    .catch(() => {
      /* show error */
    });
}, []);
```

### Next.js API: Verification and Ingest

Create `/api/handoff/ingest` (App Router or Pages API) to verify and store.

```ts
// /app/api/handoff/ingest/route.ts (Next.js App Router)
import { NextRequest, NextResponse } from "next/server";
import crypto from "node:crypto";
import zlib from "node:zlib";

function b64urlToBuffer(input: string): Buffer {
  const normalized = input.replace(/-/g, "+").replace(/_/g, "/");
  const pad =
    normalized.length % 4 === 2 ? "==" : normalized.length % 4 === 3 ? "=" : "";
  return Buffer.from(normalized + pad, "base64");
}

function getSecretForKid(kid: string): Buffer | null {
  const json = process.env.MAP_HMAC_KEYS_JSON;
  if (!json) return null;
  const map = JSON.parse(json) as Record<string, string>;
  const key = map[kid];
  if (!key) return null;
  try {
    return b64urlToBuffer(key);
  } catch {
    // fallback: treat as raw utf8
    return Buffer.from(key, "utf8");
  }
}

function safeEqual(a: Buffer, b: Buffer): boolean {
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

export async function POST(req: NextRequest) {
  try {
    const { kid, alg, enc, payload, sig, iat, exp } = await req.json();
    if (alg !== "HS256" || enc !== "gzip") {
      return NextResponse.json(
        { ok: false, error: "bad_alg" },
        { status: 400 }
      );
    }
    const secret = getSecretForKid(kid);
    if (!secret) {
      return NextResponse.json(
        { ok: false, error: "unknown_kid" },
        { status: 401 }
      );
    }

    const payloadBytes = b64urlToBuffer(payload);
    const sigBytes = b64urlToBuffer(sig);
    const expected = crypto
      .createHmac("sha256", secret)
      .update(payloadBytes)
      .digest();
    if (!safeEqual(expected, sigBytes)) {
      return NextResponse.json(
        { ok: false, error: "bad_sig" },
        { status: 401 }
      );
    }

    const jsonBytes = zlib.gunzipSync(payloadBytes);
    const data = JSON.parse(jsonBytes.toString("utf8")) as any;

    // schema checks
    if (!data || typeof data.co2 !== "number" || !data.deviceId) {
      return NextResponse.json(
        { ok: false, error: "bad_payload" },
        { status: 400 }
      );
    }
    if (Array.isArray(data.records) && data.records.length > 1000) {
      return NextResponse.json(
        { ok: false, error: "too_many_records" },
        { status: 400 }
      );
    }

    // time window
    const now = Math.floor(Date.now() / 1000);
    if (data.iat > now || now > data.exp || data.exp - data.iat > 120) {
      return NextResponse.json(
        { ok: false, error: "bad_timing" },
        { status: 401 }
      );
    }

    // TODO: rate limit by canonicalId/IP
    // TODO: persist record or pass to domain service

    return NextResponse.json({ ok: true, data }, { status: 200 });
  } catch (e) {
    return NextResponse.json(
      { ok: false, error: "server_error" },
      { status: 500 }
    );
  }
}
```

### UI Integration

- Normal flow (no handoff): gate Add dialog by login status.
- Handoff flow present (verified): bypass login gating and open the Add dialog directly, prefilled with `canonicalId`/`deviceId` and `co2/records`.
- Show an error banner if verification fails.

### Validation Matrix

- bad_sig → reject (401)
- bad_alg/enc → reject (400)
  - bad_timing (expired/too early/TTL > 180s) → reject (401)
- too_many_records/uncompressed size too large → reject (400)

### Notes

- Prefer fragment mode to avoid proxy/server URL limits; query mode works if infra supports long URLs.
- Keep keys in env only. Rotate by changing `kid` and adding new entry in `MAP_HMAC_KEYS_JSON`; keep old for a grace period.
- Log failures with IP, kid, canonicalId (if available) for abuse detection.
