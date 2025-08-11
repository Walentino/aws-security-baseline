# iam-baseline

Creates:
- Strong account password policy
- Break-glass Administrator role with trust policy that **requires MFA** (`aws:MultiFactorAuthPresent = true`).

> Minimal, safe starting point for IAM security. Future improvements will add boundaries, SSO, and guardrails.

