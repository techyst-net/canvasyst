# Canvasyst

A local-first knowledge workspace: docs, whiteboard (edgeless canvas), tables and
databases in one editor, with real-time collaboration, offline editing and an
optional AI assistant.

## Architecture

| Layer | Detail |
|---|---|
| `blocksuite/` | The editor framework — block schemas, widgets, edgeless canvas |
| `packages/frontend/core` | Web application shell and modules |
| `packages/frontend/apps/electron` | Desktop app (Electron) |
| `packages/frontend/admin` | Self-host admin and setup UI |
| `packages/backend/server` | NestJS GraphQL server |
| `packages/backend/native` | Rust native modules |
| Data | PostgreSQL, Redis, S3-compatible object storage |

## Local setup

```sh
yarn install
yarn dev              # web client
yarn dev:electron     # desktop client
```

Self-hosting uses `.docker/selfhost/compose.yml` with a `config.json` derived
from `.docker/selfhost/config.example.json`.

See [OPERATIONS.md](./OPERATIONS.md) for configuration, ports and deployment
requirements.

## Branding

| Surface | Where |
|---|---|
| Brand palette override | `packages/frontend/component/src/theme/zeshan-brand.css` |
| Sign-in lockup | `packages/frontend/component/src/components/auth-components/logo.tsx` |
| Admin and setup logos | `packages/frontend/admin/src/modules/{setup,auth}/logo.svg` |
| Favicons (8 sizes) and app icons | `packages/frontend/core/public/` |
| Desktop icons, all four channels | `packages/frontend/apps/electron/resources/icons/` — including the macOS `.icns` bundles |
| Wordmark image | `packages/frontend/core/public/imgs/affine-text-logo.png` |
| Product name | swept across 302 files |

### The palette lives in an external package

Design tokens are published in **`@toeverything/theme`** (an npm dependency,
now maintained at `toeverything/design`), so the accent hue cannot be changed by
editing these sources. `theme/index.ts` imports that stylesheet first, so a new
`zeshan-brand.css` imported **last** wins by cascade order — the supported way
to retint without patching `node_modules`.

The override sets `--affine-brand-color`, `--affine-primary-color`, the full
`--affine-blue-*` ramp and the `--affine-v2-*` tokens that newer editor widgets
use. Separately, the 71 hardcoded uses of the upstream accent `#1E96EB`
(including alpha variants like `#1E96EB14`) were replaced in place, across 41
files.

**Verify the rendered accent once dependencies are installed** — the exact token
set can only be confirmed against the installed package.

### Telemetry is now off by default

Upstream shipped `enabled: true` in `packages/frontend/track/src/state.ts`, and
the telemetry service calls `tracker.people.set({ $email, $name, $avatar })`
with the signed-in account's details.

It is now `enabled: false`. Note *why* that is sufficient: `identify()` and
`people.set()` only write to in-memory context, and that context is attached to
events. Events reach the network exclusively through `dispatchEvents`, which is
gated on `enabled` — so with tracking off nothing queues, `flushTelemetry()` is
a no-op, and the account details are never transmitted. Call
`tracker.opt_in_tracking()` to enable it deliberately.

Server-side GA4 telemetry was already inert: `ga4.measurementId` and
`ga4.apiSecret` default to empty strings.

### Deliberately left unchanged

- **`AFFiNE*` and `Affine*` CamelCase identifiers** — `AFFiNELogger`,
  `AffineTextAttributes` (211 uses), `AffineEditorContainer`, `AffineSchemas`
  and dozens more. Real exported symbols; the word-boundary sweep does not
  touch them.
- **`LICENSE`, `LICENSE-MIT` and `packages/backend/server/LICENSE`** verbatim,
  along with every `Copyright (c) 2022-present TOEVERYTHING PTE. LTD.` line.
- **`@affine/*` workspace package names** and the `affine` appstream id — both
  are resolution identifiers.

### Not covered

Tests, e2e specs and the `blocksuite/docs-site` developer documentation still
carry upstream names. None ship in the running product.

## Provenance and licence

MIT for most of the tree; **`packages/backend/` and
`packages/common/native` are under a separate Enterprise Edition licence.**
See [UPSTREAM.md](./UPSTREAM.md) — this split matters if you plan to
redistribute or run the server in production.
