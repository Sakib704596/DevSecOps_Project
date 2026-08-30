# Runbook: CI Pipeline Fails at Trivy Scan or Secret Scanning

## Symptoms
The `Build, Scan, and Push Docker Image` job fails specifically at
the "Scan image with Trivy" step, or the `Secret Scanning` job fails.

## Diagnosis steps — Trivy failure
1. Read the job log table directly — it lists each vulnerable
   package, CVE ID, severity, and (if available) a fixed version.
2. Check whether the flagged package is actually used by the
   application, or is part of the base image's own tooling (e.g. npm
   itself, not an application dependency). Real case observed: a
   CRITICAL CVE was found in npm's own bundled dependencies (tar,
   sigstore, picomatch), not in any application code.
3. Cross-check: `app/node_modules/...` entries in the scan output vs.
   `usr/local/lib/node_modules/npm/...` entries — the former is your
   code, the latter is base-image tooling.

## Fix — Trivy
- If it's a real application dependency: `npm audit fix` and commit
  the updated `package-lock.json`.
- If it's unused base-image tooling: remove it from the final image
  stage in the Dockerfile (e.g. `rm -rf` npm/npx/corepack/yarn in a
  production image that only ever runs `node app.js`, never `npm`
  itself). This directly reduces attack surface, not just resolves
  the specific CVE.

## Diagnosis steps — Secret scanning failure
1. Check the Gitleaks output for the specific file and line flagged.
2. Confirm whether it's a real secret (rotate it immediately, in
   Vault/wherever it belongs, and remove it from the commit — consider
   the credential compromised) or a known-safe placeholder pattern
   (e.g. AWS's own published example key `AKIAIOSFODNN7EXAMPLE`, which
   most scanners specifically allowlist and will NOT flag — if testing
   the scanner deliberately, use a realistic but non-official fake
   pattern instead, e.g. `AKIA` + random alphanumeric characters).

## Fix — Secret scanning
- Remove the secret from the current commit.
- If it was ever pushed to a remote branch, treat it as compromised
  regardless of removal — rotate the actual credential.
