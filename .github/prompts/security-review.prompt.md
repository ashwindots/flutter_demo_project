---
agent: agent
description: Five-pillar security and quality audit for any scope of the codebase. Run before every release and after every major feature. Produces a structured finding table sorted by severity.
argument-hint: "Feature path to audit (e.g. lib/features/customer_booking) or 'all' for the full codebase. Optionally list recently changed files."
---

# Security & Quality Review

Scope: `${input:targetScope}`
Recent changes (optional): `${input:recentChanges}`

**Authoritative rules:** The five pillars are defined in `copilot-instructions.md` sections
`## Security`, `## Reliability`, `## Maintainability`, `## Coverage`, and `## Duplication`.
Read those sections before executing each phase — they are the source of truth. This prompt
operationalises them as a structured audit.

---

## How this prompt works

Work through each pillar in order. For every finding:

- Record it in the **Finding Table** at the end.
- Assign a severity: 🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Info.
- Propose a concrete fix.

Do not modify any file until all five pillars are analysed. Then fix all 🔴 findings
automatically. Present 🟠/🟡/🟢 findings and ask before fixing unless `autoFix: true` was
passed.

---

## Pillar 1 – Security

Search every `.dart` file in scope, plus `android/`, `ios/`, `pubspec.yaml`, and `main.dart`.
Use the `## Security` section of `copilot-instructions.md` as your checklist, covering:
**Secrets & Keys**, **Local Storage**, **Bloc State**, **WebView**, **Network**, **Fallback / Placeholder Data**.

Additional search hints:

- Hardcoded secrets: look for `String.fromEnvironment` absence, base64 blobs, JWT-shaped strings, `sk_` prefixes.
- `badCertificateCallback: (_, __, ___) => true` → flag immediately as 🔴.
- `cleartext-traffic-permitted="true"` in `network_security_config.xml` → flag as 🔴.

---

## Pillar 2 – Reliability

Use the `## Reliability` section of `copilot-instructions.md` as your checklist, covering:
**Repository Methods** (no self-recursion), **Error Handling**, **State Consistency**, **Dependencies**.

Additional search hint: grep for repo methods where the last call in the body matches the method's own name — that is self-recursion.

---

## Pillar 3 – Maintainability

Use the `## Maintainability` section of `copilot-instructions.md` as your checklist, covering:
**Single Source of Truth**, **Dependency Direction**, **Code Size Limits**, **Environment Switching**.

---

## Pillar 4 – Coverage

Use the `## Coverage` section of `copilot-instructions.md` as your checklist, covering:
**Bloc Tests** (min 3 cases per handler), **AC Traceability** (`group('AC coverage', ...)`), **Test Isolation**.

---

## Pillar 5 – Duplication

Use the `## Duplication` section of `copilot-instructions.md` as your checklist, covering:
**Constants**, **UI Patterns**, **Model Consolidation**.

---

## Finding Table

After completing all five pillars, populate this table:

| #   | Severity | Pillar | File (line) | Finding | Recommended Fix |
| --- | -------- | ------ | ----------- | ------- | --------------- |

Sort by severity descending (🔴 first). Then:

1. **Auto-fix all 🔴 Critical findings** — apply code changes immediately.
2. **Present 🟠/🟡/🟢 findings** — propose fixes and await confirmation before applying.
3. **Summarise** the total finding count per severity and confirm which are resolved vs. outstanding.
