## Airspot Map Handoff: Secure, Time‑Bound, Compressed GET Flow

This document proposes a robust, production‑grade mechanism to send device readings (deviceId, current CO2, last N records) from the mobile app to the map web app when the user taps the Map icon in a Live Activity (iOS) or Foreground Notification (Android).

### Goals

- Ensure only our app can submit valid data to the map web app.
- Prevent request tampering, replay, and spam.
- Support passing up to ~500 records without exceeding URL limits.
- Keep keys out of source control and enable rotation.

### TL;DR (GET‑only handoff)

1. Tap Map icon opens a deep link into the app (not a direct `https://map...`).
2. App gathers the payload (deviceId, current CO2, last ~500 readings), compresses, and signs it with a build‑time secret; optional asymmetric signing.
3. App constructs a GET URL to `https://map.airspothealth.com` that carries the payload either as:
   - Query string: `?v=1&kid=...&alg=HS256&enc=gzip&iat=...&exp=...&nonce=...&payload=<b64url>&sig=<b64url>`
   - Or URL fragment (preferred for large data): `#v=1&kid=...&alg=HS256&enc=gzip&iat=...&exp=...&nonce=...&payload=<b64url>&sig=<b64url>`
4. App opens the browser with that URL (pure GET from the app’s perspective).
5. The map web app reads the parameters (query or fragment), verifies signature and time window, decompresses, and ingests the records. Backend stores `nonce` to prevent replay and applies rate limiting.

Notes:

- Fragment keeps the initial GET small and avoids URL length/proxy limits; the page’s JS then posts the fragment to the backend for validation.
- If you must avoid client→server POST from the web app, place data in the query so the server sees it on the initial GET. Ensure infra URL length limits are sufficient.

---

## 1) Data Model

Minimal payload fields (extendable):

```json
{
  "v": 1, // version
  "deviceId": "ASC-XXXXXX",
  "co2": 812, // current reading (ppm)
  "records": [
    // last N records (recommended ~500)
    { "ts": 1736360400123, "co2": 810 },
    { "ts": 1736360460123, "co2": 815 }
  ],
  "iat": 1736360400, // issued-at (seconds)
  "exp": 1736360460, // expiry (seconds, e.g. iat+60)
  "nonce": "b2d7..." // 16–24 random bytes base64url
}
```

Notes:

- `records` can be augmented with `temp`, `humidity`, etc., later.
- Keep timestamps as epoch milliseconds inside records; `iat/exp` in seconds.

## 2) Compression

- Serialize payload to JSON.
- Compress using gzip (or brotli) to reduce size.
- Encode as base64url for transport.

Field naming for GET transport (query or fragment):

```
v=1&kid=map-key-2025-01&alg=HS256&enc=gzip&iat=1736360400&exp=1736360460&payload=<base64url(gzip(JSON))>&sig=<base64url(HMAC_SHA256(kid_key, payload_bytes))>
```

Signing the compressed bytes ensures integrity of the exact data that will be decoded.

## 3) Authentication and Integrity

### Option A (GET‑only baseline): HMAC with build‑time secret

- App signs the compressed payload bytes with HMAC‑SHA256 using a symmetric secret injected at build time via `--dart-define`.
- Server stores the corresponding secret identified by `kid` and verifies signature.
- Pros: simple, fast. Cons: secret resides in client app and can be reverse‑engineered; mitigate with short TTL, rotation, and rate limiting.

### Option B (More robust): Asymmetric signatures or attestation

- Use asymmetric signatures (e.g., Ed25519): app signs payload with a private key; web app verifies with public key. Reduces risk from client secret extraction.
- Or add platform attestation (Play Integrity / DeviceCheck via App Check) to harden origin.

We can start with Option A and plan to migrate to Option B.

## 4) Web App and Backend Validation (GET transport)

Base URL: `https://map.airspothealth.com`

Two integration modes:

- Query mode (server receives data on initial GET):

  - The app constructs a long query string including `payload` and `sig`.
  - The map server parses and validates on the initial GET, then renders the page.
  - Ensure infra (CDN, load balancer, server) supports long URLs (target ≥16KB).

- Fragment mode (preferred for large data):
  - The app places all fields in the URL fragment (`#...`).
  - The web client JS reads the fragment, then POSTs it to a backend validation endpoint to verify/decompress/ingest.
  - Keeps initial GET small and robust across proxies.

Validation steps (backend):

1. Look up secret by `kid`; reject if unknown/disabled.
2. Compute `HMAC_SHA256(secret, payload_bytes)` and compare with `sig` (constant‑time).
3. Decompress `payload` → JSON; validate schema and limits (e.g., records ≤ 1000, total uncompressed size ≤ 256KB).
4. Check `iat` ≤ now ≤ `exp` and `exp - iat` ≤ 120s.
5. Check `nonce` is unseen within the validity window (store nonce/invalidate on first use).
6. Rate limit by `deviceId`, IP, and overall.

Response example (from the validation endpoint to the web client):

```json
{
  "ok": true,
  "ingested": true
}
```

## 5) Mobile App Flow

### 5.1 Change notification click to deep link into the app (Recommended)

- iOS Live Activity and Android Foreground Notification actions should open an app route (e.g., `airspothealth://map-handoff`) instead of directly opening the website.
- Flutter route `'/map-handoff'` handles:
  1. Gathering the latest readings.
  2. Building, compressing, and signing (and optionally encrypting) the payload.
  3. Constructing the final GET URL to `https://map.airspothealth.com` with query or fragment parameters.
  4. Launching the browser with that URL.

### 5.2 Build‑time secrets via `--dart-define`

Provide at build time (never commit):

- `MAP_HMAC_KEY` – base64url (preferred) or hex secret used to HMAC‑sign the COMPRESSED payload bytes.
- `MAP_HMAC_KID` – key id label for rotation (e.g., `map-key-2025-01`). If you do not plan to rotate keys initially, you can keep a static value; add rotation later without breaking older clients.
  (No API base is needed in GET‑only mode.)

Flutter build examples:

```bash
flutter build ios \
  --dart-define=MAP_HMAC_KEY=base64url_secret_value \
  --dart-define=MAP_HMAC_KID=map-key-2025-01

flutter build apk \
  --dart-define=MAP_HMAC_KEY=base64url_secret_value \
  --dart-define=MAP_HMAC_KID=map-key-2025-01
```

Use CI secrets to inject these values.

### 5.3 Flutter signing/compression example (build GET URL)

```dart
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io' show gzip;
import 'package:crypto/crypto.dart' as crypto;

class MapHandoffService {
  final String kid = const String.fromEnvironment('MAP_HMAC_KID');
  final String secretB64 = const String.fromEnvironment('MAP_HMAC_KEY');

  Uint8List _base64UrlDecode(String input) {
    String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return Uint8List.fromList(base64.decode(normalized));
  }

  String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  String _randomNonce(int length) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return _base64UrlEncode(bytes);
  }

  Uri buildMapUrl({
    required String deviceId,
    required int currentCo2,
    required List<Map<String, dynamic>> records,
    bool useFragment = true,
  }) {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = {
      'v': 1,
      'deviceId': deviceId,
      'co2': currentCo2,
      'records': records,
      'iat': nowSec,
  'exp': nowSec + 180,
    };

    final jsonBytes = utf8.encode(json.encode(payload));
    final compressed = gzip.encode(jsonBytes);

    final secret = _base64UrlDecode(secretB64);
    final hmac = crypto.Hmac(crypto.sha256, secret);
    final sigBytes = hmac.convert(compressed).bytes;

    final params = {
      'v': '1',
      'kid': kid,
      'alg': 'HS256',
      'enc': 'gzip',
      'iat': nowSec.toString(),
  'exp': (nowSec + 180).toString(),
      'payload': _base64UrlEncode(compressed),
      'sig': _base64UrlEncode(sigBytes),
    };

    final base = Uri.parse('https://map.airspothealth.com');
    if (useFragment) {
      final fragment = params.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      return base.replace(fragment: fragment);
    } else {
      return base.replace(queryParameters: params);
    }
  }
}
```

Notes:

- Prefer `base64Url` without padding for compact strings.
- Keep TTL short (≤ 60s) to reduce replay window.

#### FAQ: Why two defines; why not just one key?

- You need exactly one secret for signing (`MAP_HMAC_KEY`). The second define (`MAP_HMAC_KID`) is not a secret; it is a label that lets the web app choose which server‑side key to use for verification. This enables painless key rotation without forcing all old app versions to break.
- We sign the entire compressed payload (not just `deviceId`) so that `co2`, `records`, and the time window (`iat/exp`) cannot be tampered with. If only `deviceId` were signed, an attacker could modify readings or timestamps while keeping the same signed deviceId.

## 6) Web App Flow (`map.airspothealth.com`)

- Query mode: server parses GET query directly, validates, ingests, and renders result.
- Fragment mode: client JS reads `window.location.hash`, sends it as JSON to a backend validation endpoint, receives validation result, and renders or shows error.

Client JS (fragment mode) outline:

```js
const parts = new URLSearchParams(window.location.hash.slice(1));
const body = Object.fromEntries(parts.entries());
const res = await fetch("/api/map-handoff/validate", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(body),
});
const json = await res.json();
if (!json.ok) {
  /* show error */
} else {
  /* render */
}
```

## 7) Key Management and Rotation

- Maintain keys by `kid` on the server. Example naming: `map-key-YYYY-MM`.
- Inject key via CI/CD at build time (`--dart-define`).
- Rotate regularly (e.g., monthly) and support multiple active `kid`s on server.
- Revoke compromised keys server-side immediately.

## 8) Replay and Abuse Protection

- Enforce `exp` ≤ 60–120s.
- Store `nonce` for the validity window; reject duplicates.
- Single-use token for web retrieval.
- Rate limit by `deviceId` and IP.
- Optional: require minimum inter‑arrival time between submissions per device.

## 9) URL Size and Alternatives

- Prefer fragment mode for large payloads. Fragments are not sent to the server on initial GET, avoiding proxy/server line limits; the client then POSTs the fragment to backend.
- If you require strictly “no client POST,” place the data in the query string. Validate infra URL limits (target ≥16KB). Consider trimming `records` or downsampling.

## 10) Platform Integration Details

### Android (Foreground Notification)

- Current: Map icon opens `https://map.airspothealth.com` directly.
- Change: Set the Map action `PendingIntent` to launch a deep link `airspothealth://map-handoff` (handled by Flutter). The app then builds the signed URL and launches the browser.

Where to change in your code:

```startLine:endLine:android/app/src/main/java/com/air/spot/airspothealth/ForegroundNotificationService.java
382:391
```

### iOS (Live Activity)

- Current: Live Activity map button uses custom scheme `airspothealth://open_map`.
- Change: Update to `airspothealth://map-handoff` (optionally include `deviceId`). Flutter handles building the signed GET URL and opens the browser.

Where it is today:

```startLine:endLine:ios/LiveActivityWidget/LiveActivityWidgetLiveActivity.swift
294:303
```

## 11) Backend Pseudocode (Verification)

```ts
// Node/TypeScript-style pseudocode (fragment mode validation)
app.post("/api/map-handoff/validate", async (req, res) => {
  const { kid, alg, enc, payload, sig } = req.body;
  if (alg !== "HS256" || enc !== "gzip")
    return res.status(400).send({ error: "bad_alg" });
  const secret = await keyStore.get(kid);
  if (!secret) return res.status(401).send({ error: "unknown_kid" });

  const payloadBytes = base64url.decode(payload);
  const sigBytes = base64url.decode(sig);
  if (!timingSafeEqual(hmacSha256(secret, payloadBytes), sigBytes)) {
    return res.status(401).send({ error: "bad_sig" });
  }

  const jsonBytes = gunzip(payloadBytes);
  const data = JSON.parse(utf8Decode(jsonBytes));

  if (!data.deviceId || typeof data.co2 !== "number") {
    return res.status(400).send({ error: "bad_payload" });
  }
  if ((data.records?.length ?? 0) > 1000) {
    return res.status(400).send({ error: "too_many_records" });
  }

  const now = Math.floor(Date.now() / 1000);
  if (data.iat > now || now > data.exp || data.exp - data.iat > 120) {
    return res.status(401).send({ error: "bad_timing" });
  }

  if (!(await nonceStore.tryUse(data.nonce, data.exp))) {
    return res.status(409).send({ error: "replay" });
  }

  // rate limit guard here
  // Ingest records here ...
  return res.json({ ok: true, ingested: true });
});
```

## 12) Testing Checklist

- Deep link opens the app from both iOS Live Activity and Android Notification.
- When offline or URL exceeds limits, app shows a friendly error and does not open the map.
- Replays with same nonce are rejected.
- Over‑sized payloads are rejected (server/client as applicable).
- Key rotation: deploy server with new `kid`, then ship app with updated `kid`.

## 13) Security Considerations

- Client-side secrets are extractable; mitigate with short TTL, key rotation, and rate limiting. Plan migration to attestation.
- All endpoints must be HTTPS only.
- Validate and cap input sizes to prevent resource exhaustion.
- Log suspicious activity; implement IP/device reputation if needed.

## 14) Work Breakdown

- Mobile

  - Implement route `'/map-handoff'` handler and `MapHandoffService` to build signed GET URLs.
  - Wire notification/Live Activity taps to deep link into the route.
  - Add `--dart-define` usage in build scripts/CI.

- Backend

  - Implement a validation/ingest endpoint (e.g., `POST /api/map-handoff/validate`) and nonce store.
  - Key store with `kid` → secret, rotation support.
  - Rate limiting and logging.

- Web
  - Query mode: validate on initial GET.
  - Fragment mode: client JS posts fragment to backend, then renders.

---

This design meets all requirements: passes deviceId/CO2/history, is time‑bound, tamper‑evident, replay‑resistant, avoids URL size limits via compression and server‑mediated token exchange, and supports build‑time keys with rotation.
