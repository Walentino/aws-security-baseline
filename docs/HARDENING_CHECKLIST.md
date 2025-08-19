# Week 6 – Finish & Harden (AWS Security Baseline)

## A. Terraform hygiene
- [ ] Run `terraform fmt` at repo root and in each example
- [ ] Run `terraform validate` in each example (read-only)
- [ ] Run `terraform plan -out tfplan` (no apply yet)
- [ ] (Optional) Switch local state to S3 backend with DynamoDB lock

## B. Identity-first controls
- [ ] Root account: MFA on, access keys = 0, billing alerts on
- [ ] Break-glass user: MFA on, no API keys, minimal policy
- [ ] IAM Access Analyzer enabled (account or org level)
- [ ] (If using AWS Organizations) SCPs attached for non-TLS, region restrictions, and dangerous actions

## C. Detection & logging
- [ ] CloudTrail trail ON; log file validation ON; writing to a logs bucket
- [ ] GuardDuty enabled (regions in scope) and sending notifications
- [ ] Security Hub enabled; AWS Foundational Security Best Practices (AFSBP) subscribed
- [ ] AWS Config recorder ON; at least core rules enabled

## D. Data protection
- [ ] S3: versioning + server-side encryption default; account-level Public Access Block = true
- [ ] TLS-only (`aws:SecureTransport`) enforced in bucket policies
- [ ] (If needed) KMS keys created, rotation ON, aliases documented

## E. Operations
- [ ] Tags: `Environment, Owner, CostCenter, DataClass` applied
- [ ] Budgets + cost alerts configured
- [ ] Backups/lifecycle (e.g., Glacier) documented and tested
- [ ] Incident notifications wired to SNS/Email/Slack

## F. Quick verify commands (read-only)
```bash
aws accessanalyzer list-analyzers --region us-east-1 --profile <profile>
aws guardduty list-detectors --region us-east-1 --profile <profile>
aws cloudtrail describe-trails --include-shadow-trails --profile <profile>

## G. Rollback rehearsal
- [x] Ran `terraform -chdir=examples/dev-s3 plan -destroy -out tfdestroy.plan`
- [x] Documented result in RUNBOOK (YYYY-MM-DD): **No changes. No objects need to be destroyed.**
