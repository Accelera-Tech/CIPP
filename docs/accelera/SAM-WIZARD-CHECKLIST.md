# CIPP SAM Setup Wizard — Ashley's Checklist

Everything below is interactive (Partner Center login + MFA) and is **your** part.
Deployment is done; stop-point honored — nothing touched in any client tenant, no GDAP invites.
Source: docs.cipp.app (service account, conditional access, setup wizard pages), pulled 2026-07-21.

## A. Before you start — have ready

- [ ] Partner Center access working (partner tenant), and a Global Admin login in the **Accelera partner tenant** for the wizard's consent steps.
- [ ] Your CIPP UI login works (I invite you via SWA Role Management with role `admin` — invite link is NOT emailed, I hand it to you; it expires, accept promptly).
- [ ] Decide whether the service account gets a mailbox (needed only if you want CIPP email notifications/exports — a shared mailbox is acceptable).

## B. Create the dedicated service account (`cipp-sam@accelera.tech`)

In entra.microsoft.com (partner tenant):

1. New user → internal. UPN: `cipp-sam@...`, Display Name containing **"CIPP"** or **"Service"** (e.g. "CIPP Service Account") — CIPP's permission checker looks for that string. Strong password into Key Vault.
2. **Groups**: add to **AdminAgents** (mandatory — Partner API access). GDAP `M365 GDAP *` groups: skip for now — they get created/assigned at tenant onboarding, which we are explicitly not doing yet.
3. **Entra roles** (temporary, for the wizard run): **Application Administrator**, **Privileged Role Administrator**, **User Administrator**. If the wizard's app-registration step fails with permission errors, temporarily bump to **Global Administrator**, rerun, then drop it. Docs recommend removing App Admin / User Admin right after setup completes.

## C. MFA + Conditional Access for the service account

- **Microsoft MFA only** (Authenticator). No Duo/third-party. Register MFA **before** the first login attempt anywhere.
- Exclude `cipp-sam@` from **every existing** CA policy in the partner tenant.
- Create one dedicated policy — name it `CIPP Service Account Conditional Access Policy`:
  - Include: only `cipp-sam@`
  - All cloud apps; Grant: require MFA
  - Session: sign-in frequency = **every time**
  - **No** exclusions, **no** trusted-location carve-outs on this policy.
- Client-tenant CA exclusions (service-provider exclusion for our tenant ID): **later**, at GDAP onboarding — out of scope today.

## D. Wizard click-order (in the CIPP UI)

1. Log into the CIPP UI (URL in DEPLOYMENT.md) with your invited `admin` user.
2. Application Settings → **Setup Wizard** (or the first-run banner) → choose **"First Setup"**.
3. **Application Registration** step → click **Authenticate** → sign in **as `cipp-sam@`** (not your own account), complete Microsoft MFA, accept the consent prompts. This mints the CIPP-SAM multi-tenant app + refresh token (lands in Key Vault automatically).
   - Known failure: "Response status code does not indicate success" → new-tenant "Password addition restriction" policy in Entra → Enterprise Applications → Application Policies: set "All applications with exclusions" and exclude **CIPP-SAM**, wait a few minutes, retry.
4. **Tenant Configuration** step → select **"Connect to Partner Tenant"** (we're a Microsoft Partner; this is also CyberDrain's recommendation).
5. **Baselines** step → pick **CyberDrain Templates** (recommended) — review before applying anything to tenants later.
6. **Notifications** step → set alert email(s); only works if `cipp-sam@` (or the chosen sender) has a mailbox. Test-send from this screen.
7. **Optional features** step → review; nothing is mandatory. Finish.
8. Afterwards: remove the temporary Entra roles from `cipp-sam@` (keep AdminAgents), and confirm CIPP Settings → Permissions check is green.

**STOP.** Tenant Onboarding / GDAP Invite Wizard is deliberately not on this list.
