## Purpose

This document defines the authoritative operational guide for AI-assisted contributors working in the `mixlib-cli` repository. It standardizes how tasks are clarified, planned, implemented, tested, documented, and delivered—especially when driven by Jira issues and iterative prompt-based collaboration. It enforces compliance (DCO, coverage, protected file safety), codifies branching + PR conventions, and describes integration points (CI, Expeditor, labels, automation). Use this as the single source of truth for workflow execution.

---
## Repository Structure

Concise directory tree (non-vendored, depth-limited). Each line includes a brief purpose.

```
.
├── CHANGELOG.md              # Project changelog (Expeditor manages updates)
├── CODE_OF_CONDUCT.md        # Community conduct policy (protected)
├── CONTRIBUTING.md           # Contribution guidelines (reference only)
├── Gemfile                   # Development dependencies bundler entrypoint
├── LICENSE                   # Apache 2.0 license (protected; never modify)
├── NOTICE                    # Notice file (protected)
├── Rakefile                  # Rake tasks (specs, docs)
├── README.md                 # Project overview and usage
├── VERSION                   # Current gem version (bumped by Expeditor)
├── mixlib-cli.gemspec        # Gem specification & metadata
├── .rubocop.yml              # Cookstyle/Rubocop configuration
├── .expeditor/               # Expeditor automation (release, versioning)
│   ├── config.yml            # Expeditor pipeline + subscription rules
│   ├── verify.pipeline.yml   # Buildkite verification pipeline definition
│   ├── run_linux_tests.sh    # Linux test + bundle caching helper
│   ├── run_windows_tests.ps1 # Windows test runner
│   └── update_version.sh     # Syncs VERSION file to code
├── .github/
│   ├── CODEOWNERS            # Ownership mapping (enforced reviewers)
│   ├── dependabot.yml        # Dependency update automation
│   ├── ISSUE_TEMPLATE/       # Issue templates (bug/enhancement/support/design)
│   └── workflows/            # GitHub Actions CI workflows
│       ├── unit.yml          # Matrix RSpec unit tests (Windows + Ruby versions)
│       ├── lint.yml          # Lint (Cookstyle/Rubocop) pipeline
│       └── ci-main-pull-request-checks.yml # Centralized org pipeline stub
├── lib/                      # Library source code
│   └── mixlib/
│       ├── cli.rb            # Core CLI mixin implementation
│       └── cli/
│           ├── formatter.rb  # Option formatting utilities
│           └── version.rb    # VERSION constant (synced from VERSION file)
├── spec/                     # RSpec test suite
│   ├── spec_helper.rb        # RSpec configuration
│   └── mixlib/
│       ├── cli_spec.rb       # Tests for Mixlib::CLI behaviors
│       └── cli/
│           └── formatter_spec.rb # Tests for formatter helpers
└── .github/copilot-instructions.md # (This file)
```

Protected / DO NOT MODIFY without explicit approval: `LICENSE`, `NOTICE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `.github/workflows/*` (unless task explicitly targets them), `.expeditor/config.yml`.

---
## Tooling & Ecosystem

| Aspect | Details |
|--------|---------|
| Primary Language | Ruby (>= 3.1) |
| Package Type | RubyGem (`mixlib-cli`) |
| Test Framework | RSpec (see `spec_helper.rb`) |
| Linting | Cookstyle (Rubocop variant) via `cookstyle --chefstyle -c .rubocop.yml` |
| Tasks | `rake spec`, `rake docs` |
| CI (GH Actions) | `unit.yml`, `lint.yml`, `ci-main-pull-request-checks.yml` |
| Release Automation | Expeditor (.expeditor) + Rubygems publish pipeline |
| Coverage Tooling | Not explicitly configured; recommend adding SimpleCov for coverage tracking if needed (see Testing & Coverage section). |
| Dependency Updates | Dependabot (`dependabot.yml`) |

Implicit Coverage Expectation: Maintain or raise overall effective test coverage above 80%. If formal measurement missing, implement SimpleCov in `spec/spec_helper.rb` (only if a task explicitly requires coverage instrumentation) and iterate until thresholds are met.

---
## MCP (Jira) Integration

All Jira interactions MUST use the `atlassian-mcp-server` MCP endpoint (not ad-hoc HTTP or manual copy). When a Jira ID is provided (e.g., `ABC-123`):

1. Acquire Issue:
   - Action (conceptual invocation): `atlassian-mcp-server.getJiraIssue(issueIdOrKey=ABC-123)`
2. Parse Fields:
   - Summary, Description
   - Acceptance Criteria (parse bullet lists / Gherkin blocks)
   - Story Points (if present)
   - Linked Issues (dependencies, blockers)
3. Produce a Structured Plan:
   - Design Overview
   - Impacted Files / Classes
   - Data / API considerations
   - Test Strategy (unit + edge cases)
   - Risk & Mitigations
4. Present plan to user with confirmation gate.
5. Proceed ONLY after explicit “yes”.

Example Interaction Pattern:
```
Input Jira ID: ABC-123
-> Fetch via MCP
-> Extract acceptance criteria
-> Draft Plan (Design | Files | Tests | Edge Cases | Risks)
-> Ask: Continue to implementation? (yes/no)
```

If NO Jira ID is supplied: treat the request as a freeform enhancement; still create a structured plan and request confirmation.

---
## Workflow Overview (High-Level)

1. Intake & Clarify (Jira fetch if ID present)
2. Repo Analysis (structure, constraints, test gaps)
3. Implementation Plan (design + test additions)
4. User Confirmation Gate
5. Incremental Implementation (code + tests)
6. Lint & Static Validation
7. Test & Coverage Enforcement (>= 80%)
8. Commit (with DCO sign-off)
9. Branch Push & PR Creation
10. PR Description (HTML, coverage delta, risk)
11. Label Application (mapping + repository labels)
12. Post-Change Summary & Next Steps Prompt
13. Additional iterations until acceptance

Every major step ends with: (a) brief summary, (b) remaining checklist, (c) prompt: `Continue to next step? (yes/no)`.

---
## Detailed Step Instructions

### 1. Intake & Clarify
Gather: Jira ID (if any), goal, constraints, performance/security implications. If Jira ID -> run MCP fetch (see MCP section).

### 2. Analyze Repository
Identify impacted components (e.g., adding a new option handling feature affects `lib/mixlib/cli.rb` and corresponding specs). Note any missing tests or edge cases.

### 3. Plan Implementation
Produce structured deliverables:
- Design Summary
- API / Interface Changes (backwards compatibility statement)
- Files to Add/Modify/Delete
- Test Cases (happy path, failure modes, edge conditions, deprecations)
- Coverage Impact Forecast
- Risks & Mitigations

### 4. Confirm Plan
Ask user explicitly: `Continue to next step? (yes/no)`.

### 5. Create Branch
Branch name MUST be exactly the Jira ID (e.g., `ABC-123`). If no Jira ID, use kebab-case slug (e.g., `improve-option-validation`).

Commands:
```bash
git fetch origin
git checkout -b ABC-123
```

Idempotency: If branch exists locally, reuse it. If remote exists and diverged, halt and request guidance (avoid force-push).

### 6. Implement Incrementally
Follow minimal cohesive change sets:
1. Update library code
2. Add/update specs
3. Run `bundle exec rake spec`
4. If failures -> iterate.

### 7. Lint & Style
```bash
gem install cookstyle
cookstyle --chefstyle -c .rubocop.yml
```
Resolve offenses before commit.

### 8. Tests & Coverage
Run:
```bash
bundle exec rake spec
```
If coverage instrumentation is enabled (SimpleCov optional), ensure >= 80%. If below:
1. Identify low-coverage files / branches
2. Add targeted specs
3. Re-run tests

### 9. Commit with DCO
Each commit message format:
```
<concise subject> (ABC-123)

<body explaining rationale, impacts, risks>

Signed-off-by: Full Name <email@example.com>
```
Reject / rewrite any commit lacking valid DCO line.

Add changes:
```bash
git add .
git commit -m "Support deprecated option mapping (ABC-123)" -m "Adds mapping logic..." -s
```
(`-s` inserts sign-off if `user.name` and `user.email` are configured; verify correctness.)

### 10. Push Branch
```bash
git push -u origin ABC-123
```

### 11. Open Pull Request
Use GitHub CLI:
```bash
gh pr create --fill --head ABC-123 --base main
```
Then update description using HTML template (see PR Template section below).

### 12. Apply Labels
Map from Jira type or manually apply (see Labels Reference). Add Expeditor bump labels only if version-impacting change (public API change or feature/major). Avoid misuse of `Skip` labels unless directed.

### 13. Post-Implementation Summary
Summarize:
- Changed files
- Spec results (pass/fail count)
- Coverage delta (if measured)
- Risk assessment
- Next recommended tasks

### 14. Further Iterations
Perform review-driven adjustments while preserving DCO compliance. Squash only if policy allows; ensure final commit(s) maintain sign-offs.

---
## Branching & PR Standards

| Category | Rule |
|----------|------|
| Branch Naming | Exact Jira ID (`ABC-123`) or semantic slug if no Jira. |
| Base Branch | Usually `main` (verify). Historical references to `master` exist—confirm default branch before PR. |
| Draft PR | Use when implementation or tests incomplete or awaiting design approval. |
| Ready PR | All tests green, lint clean, coverage >= 80%, description filled, risks documented. |
| Required Checks | Lint (`lint`), Unit (`unit`), Central pipeline stub (may include secret scan). All must pass before merge. |
| Labels | Apply aspect + platform + Expeditor bump labels if applicable. |
| Re-run Workflows | Via PR UI “Re-run failed jobs” or `gh run rerun <run-id>`. |
| Merge Strategy | Prefer squash for clarity unless preserving granular history is required. Ensure final commit retains DCO sign-off. |
| Forbidden | Force-push to `main`/`master`, direct merges without review, altering protected policy files. |

---
## PR Description (HTML Template)

If no repo PR template exists, use:
```html
<h2>Summary</h2>
<p>Concise explanation of what and why.</p>

<h2>Jira</h2>
<p><a href="https://your-jira.example.com/browse/ABC-123">ABC-123</a></p>

<h2>Changes</h2>
<ul>
  <li>Modified: lib/mixlib/cli.rb – added deprecated option value mapper</li>
  <li>Added: spec covering new mapping + edge cases</li>
</ul>

<h2>Tests & Coverage</h2>
<p>All RSpec tests pass. Coverage: 82% (+3%).</p>

<h2>Risk & Mitigations</h2>
<ul>
  <li>Parsing regression risk – mitigated by expanded spec cases.</li>
  <li>Backward compatibility maintained: existing APIs unchanged.</li>
</ul>

<h2>DCO</h2>
<p>All commits signed off.</p>
```

---
## Commit & DCO Policy

All commits MUST include a Developer Certificate of Origin sign-off line:
```
Signed-off-by: Full Name <email@example.com>
```
Rules:
1. Reject generation of non-compliant commit messages.
2. The sign-off name/email must match the contributor’s declared identity.
3. Amending commits: `git commit --amend -s --no-edit` adds sign-off.
4. Bulk sign-off: `git rebase -i` followed by `--amend -s` per commit.

---
## Testing & Coverage

Run tests:
```bash
bundle install
bundle exec rake spec
```

Add new tests for all new logic paths (include invalid inputs, edge-case flows, deprecated option mapping, exception cases). If introducing coverage tooling:

Example (optional) addition to `spec/spec_helper.rb`:
```ruby
# Optional: coverage instrumentation if required by task
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage 80
    add_filter 'spec/'
  end
end
```
Invoke with:
```bash
COVERAGE=1 bundle exec rake spec
```

Coverage Enforcement Loop:
1. Run tests with coverage
2. Identify low coverage modules (e.g., conditionals in `cli.rb`)
3. Write targeted specs
4. Re-run until >= 80%

---
## Labels Reference

Standard Mapping Guidance:
- Feature / Enhancement → consider `Aspect: Performance`, `Aspect: Stability`, etc., plus Expeditor bump label if user-facing change.
- Bug Fix → appropriate `Aspect:` + possible version bump label if public API changed.
- Security Fix → add `Aspect: Security` (expedited review priority).

Repository Labels (name – description):

```
Aspect: Documentation – How do we use this project?
Aspect: Integration – Works correctly with other projects or systems.
Aspect: Packaging – Distribution of the projects 'compiled' artifacts.
Aspect: Performance – Works without negatively affecting the system running it.
Aspect: Portability – Does this project work correctly on the specified platform?
Aspect: Security – Can an unwanted third party affect the stability or look at privileged information?
Aspect: Stability – Consistent results.
Aspect: Testing – Does the project have good coverage, and is CI working?
Aspect: UI – User interaction & visual design aspects.
Aspect: UX – User experience, function, accessibility.
dependencies – Pull requests that update a dependency file.
Expeditor: Bump Version Major – Triggers major version bump.
Expeditor: Bump Version Minor – Triggers minor version bump.
Expeditor: Skip All – Skip all merge actions.
Expeditor: Skip Changelog – Skip changelog update.
Expeditor: Skip Habitat – Skip Habitat package build.
Expeditor: Skip Omnibus – Skip omnibus release build.
Expeditor: Skip Version Bump – Skip version bump.
hacktoberfest-accepted – Accepted Hacktoberfest PR.
oss-standards – OSS repository standardization.
Platform: AWS – AWS platform relevance.
Platform: Azure – Azure platform relevance.
Platform: Debian-like – Debian derivatives support.
Platform: Docker – Docker usage relevance.
Platform: GCP – Google Cloud Platform relevance.
Platform: Linux – General Linux relevance.
Platform: macOS – macOS relevance.
Platform: RHEL-like – RHEL family relevance.
Platform: SLES-like – SUSE family relevance.
Platform: Unix-like – Generic Unix relevance.
```

---
## CI / Expeditor Integration

### GitHub Actions
- `unit.yml`: Runs matrix of Ruby versions (3.1, 3.4) on Windows for unit tests.
- `lint.yml`: Runs Cookstyle lint on `pull_request` and pushes to `main` (confirm default branch alignment—some workflows reference `master` in badges; prefer consistency).
- `ci-main-pull-request-checks.yml`: Stub invoking centralized org composite workflow providing secret scan (Trufflehog), complexity checks, SBOM generation, and optional future scans.

Re-run: Use PR UI or `gh run list` + `gh run rerun <id>`.

### Expeditor
Located in `.expeditor/`:
- Automates version bump + changelog + gem build on merge.
- Labels control semantic version increment:
  - `Expeditor: Bump Version Minor`
  - `Expeditor: Bump Version Major`
- Skip labels allow selective bypass.
- On merge to release branch: sequence: bump -> sync version constant -> update changelog -> build gem -> (on promotion) publish.
- Do NOT manually edit version tags—let automation proceed.

### Buildkite
`verify.pipeline.yml` orchestrates multi-Ruby and multi-platform validations supporting Expeditor-driven pipeline.

---
## Security & Protected Files

Never modify without explicit instruction:
- `LICENSE`, `NOTICE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`
- `.expeditor/config.yml` (unless release automation change requested)
- `.github/workflows/*` (unless CI enhancement task explicitly assigned)
- Secrets, tokens, credentials, or environment variable definitions.

Never:
- Commit secrets / access tokens
- Force-push to protected branches (`main`, `master`, `release/**`)
- Merge PRs.
- Delete workflow or policy files

If a task appears to require secret or CI modification: pause and request confirmation.

---
## Prompts Pattern (Interaction Model)

Each major operation MUST end with:
```
Summary: <one-line>
Remaining Steps:
[ ] Step N ...
...
Continue to next step? (yes/no)
```
If user says `no`, provide options: revise plan, abort, or gather more data.

Examples:
```
Implemented deprecated option mapping logic.
Remaining Steps:
[ ] Add new RSpec examples
[ ] Run lint
[ ] Run tests + coverage
[ ] Commit & push
Continue to next step? (yes/no)
```

---
## Environment Preparation

Prerequisites: Ruby >= 3.1, Bundler.

Setup:
```bash
git clone https://github.com/chef/mixlib-cli.git
cd mixlib-cli
bundle install
```

Run specs:
```bash
bundle exec rake spec
```

Optional docs:
```bash
rake docs
```

Optional local coverage (if instrumentation added):
```bash
COVERAGE=1 bundle exec rake spec
```

GitHub CLI Auth (DO NOT reference shell profile modifications):
```bash
gh auth login
```

---
## Validation & Exit Criteria

Completion requires ALL:
1. Plan approved (if Jira-backed, acceptance criteria mapped to tests).
2. Code changes implemented with backward compatibility (unless major bump justified & labeled).
3. New / updated RSpec tests added for all new logic & edge cases.
4. All tests pass across supported Ruby versions locally or in CI.
5. Lint passes with zero blocking offenses.
6. Effective coverage >= 80% (or improved if already above threshold).
7. Commits contain valid DCO sign-offs.
8. PR opened with HTML sections filled (Summary, Jira, Changes, Tests & Coverage, Risk & Mitigations, Labels Applied, DCO).
9. Appropriate labels applied (aspect + version bump if needed).
10. No unauthorized modifications to protected files or secrets.
11. CI workflows green (or documented transient flake with rerun plan).
12. User (or reviewer) confirmation to finalize/merge workflow.

If any criterion unmet => iterate; do not mark task complete.

---
## Idempotency Guidelines

On re-run of an AI-assisted workflow:
1. Detect existing branch: if exists and matches Jira ID, reuse.
2. If PR already open: update description/labels instead of duplicating.
3. When coverage instrumentation already present, avoid re-injecting.
4. Avoid duplicate test cases—additive tests must cover distinct logic.

---
## Safety & Guardrails Summary

- Never alter secrets or pipeline security scanning without explicit approval.
- Prefer additive non-breaking changes; flag potential breaking changes early.
- Avoid large refactors bundled with feature additions—separate concerns.
- Provide rollback guidance if change is risky.

---
## Quick Reference Commands

```bash
# Create branch
git checkout -b ABC-123

# Run specs
bundle exec rake spec

# Lint
gem install cookstyle
cookstyle --chefstyle -c .rubocop.yml

# Commit with sign-off
git add .
git commit -m "Improve option validation (ABC-123)" -s

# Push & create PR
git push -u origin ABC-123
gh pr create --fill --head ABC-123 --base main
```

---
## Final Notes

When uncertain—pause, summarize context, ask for confirmation with: `Continue to next step? (yes/no)`.

Adherence to this document ensures consistent, compliant, and auditable contribution execution.

---

## AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant

--- 

**End of Operational Instructions**
