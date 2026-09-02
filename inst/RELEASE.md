# Release Process for `rlichess`

This guide documents the standard versioning and release lifecycle for the **rlichess** package.

---

## 1. Versioning Scheme

`rlichess` follows semantic versioning aligned with tidyverse conventions (`major.minor.patch[.dev]`):

- **In-Development Version:** `0.1.0.9000` (ends in `.9000+`)
- **Official Release Version:** `0.1.0` (3 digits: `X.Y.Z`)

---

## 2. Release Steps

### Step 1: Bump Version and Finalize `NEWS.md`
1. Update `DESCRIPTION`:
   ```r
   Version: 0.1.0
   ```
2. Update `NEWS.md` to ensure the `# rlichess 0.1.0` section reflects all merged features and fixes.

### Step 2: Run Full Verification Locally
```r
# 1. CRAN Compliance Check
rcmdcheck::rcmdcheck(args = c("--as-cran", "--no-manual"))

# 2. Live API Integration Test Suite
Sys.setenv(LICHESS_TEST_LIVE = "true")
testthat::test_file("tests/testthat/test-live-api.R")
```

### Step 3: Commit, Push, and Merge to `main`
```bash
git add DESCRIPTION NEWS.md
git commit -m "chore(release): bump version to 0.1.0"
git push origin feature/bump-version-0.1.0
# Create and merge PR to main
```

### Step 4: Tag the Release
From the latest `main` branch:
```bash
git checkout main
git pull origin main

# Create and push annotated version tag
git tag v0.1.0
git push origin v0.1.0
```

### Step 5: Automated GitHub Actions
Upon pushing the `v*.*.*` tag:
1. **`.github/workflows/release.yaml`** automatically creates a GitHub Release with changelog extracted from `NEWS.md`.
2. **`.github/workflows/live-tests.yaml`** automatically runs the live integration test suite against the Lichess API.
3. **`.github/workflows/pkgdown.yaml`** deploys the updated documentation site.

---

## 3. Post-Release: Open Next Development Cycle

Immediately after release, bump `DESCRIPTION` back to development mode:
```r
# DESCRIPTION
Version: 0.1.0.9000  # or 0.2.0.9000 for next minor release
```

Add a new section at the top of `NEWS.md`:
```markdown
# rlichess (development version)

* Ongoing improvements and bug fixes.
```

Commit and push:
```bash
git commit -am "chore: start next development iteration"
git push origin main
```
