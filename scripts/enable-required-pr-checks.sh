#!/usr/bin/env bash
# Add `PR checks / backend` and `PR checks / frontend` (from
# .github/workflows/pr-checks.yml) as required status checks on `main`.
#
# GitHub won't accept a context as required until it has seen the check run at
# least once, so run this AFTER the first PR has triggered the workflow.
#
# This is a PUT against the branch protection endpoint — it fully replaces the
# protection config. The body below mirrors the baseline documented in
# CLAUDE.md's "One-time setup" section (PR required with 0 approvals, linear
# history, admin bypass disabled, no force-push, no deletion). If you have
# customized protection beyond that baseline, edit the body before running.
#
# Requires: gh CLI authenticated against an account with admin on the repo, run
# from inside a clone of the repo.

set -euo pipefail

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
BRANCH="main"

echo "Setting required status checks on ${REPO}@${BRANCH}..."

gh api -X PUT "/repos/${REPO}/branches/${BRANCH}/protection" \
  -H "Accept: application/vnd.github+json" \
  --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["PR checks / backend", "PR checks / frontend"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": false
}
JSON

echo
echo "Required checks now:"
gh api "/repos/${REPO}/branches/${BRANCH}/protection/required_status_checks" \
  --jq '{strict, contexts}'
