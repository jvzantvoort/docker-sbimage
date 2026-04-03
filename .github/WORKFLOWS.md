# GitHub Actions Workflows Documentation

This repository uses multiple GitHub Actions workflows for comprehensive CI/CD, security, and maintenance automation.

## Workflows Overview

### 1. Build and Publish (`build.yml`)

**Triggers:**
- Push to `master` branch
- Tag push matching `sbimage-*`
- Pull requests to `master`
- Weekly scheduled security scan (Sundays 2 AM UTC)

**Features:**

#### Security Enhancements
- ✅ **Hadolint**: Dockerfile linting before build
- ✅ **Trivy**: Vulnerability scanning of built images
- ✅ **SARIF upload**: Security results to GitHub Security tab
- ✅ **Pinned actions**: All actions use SHA256 pins for security
- ✅ **SBOM generation**: Software Bill of Materials
- ✅ **Provenance**: Build attestation for supply chain security

#### Quality Gates
- ✅ **Smoke tests**: Automated container testing on PRs
  - Sphinx installation verification
  - Key packages validation (Ansible, Django)
  - Healthcheck functionality
  - Git availability
- ✅ **Multi-platform builds**: amd64 and arm64
- ✅ **Build caching**: GitHub Actions cache for faster builds

#### Release Management
- ✅ **Automatic releases**: GitHub Releases for tags
- ✅ **Changelog generation**: Auto-generated from git commits
- ✅ **Version extraction**: From `sbimage-*` tags
- ✅ **Release notes**: Comprehensive with usage instructions

#### Monitoring
- ✅ **Build summaries**: Detailed step summary in GitHub UI
- ✅ **Job dependencies**: Proper workflow orchestration

**Jobs:**
1. `lint` - Dockerfile validation
2. `build-and-test` - Build, test, and push images
3. `security-scan` - Vulnerability scanning (post-build)
4. `release` - Create GitHub Release (tags only)
5. `summary` - Build status summary

### 2. Dependabot (`dependabot.yml`)

**Features:**
- ✅ **GitHub Actions updates**: Weekly on Mondays
- ✅ **Docker base image updates**: Weekly on Tuesdays
- ✅ **Python packages updates**: Weekly on Wednesdays
- ✅ **Grouped updates**: Sphinx extensions grouped together
- ✅ **Security prioritization**: Security updates grouped and prioritized
- ✅ **Conventional commits**: Proper commit message prefixes

**Configuration:**
- Max 5 PRs for GitHub Actions
- Max 3 PRs for Docker
- Max 10 PRs for Python packages
- Auto-labeled for easy filtering

### 3. Cleanup Old Images (`cleanup.yml`)

**Triggers:**
- Weekly scheduled (Sundays 3 AM UTC)
- Manual trigger via workflow_dispatch

**Features:**
- ✅ **Automatic cleanup**: Removes old untagged images
- ✅ **Retention policy**: Keeps last 10 versions
- ✅ **Registry optimization**: Reduces storage costs
- ✅ **Safe deletion**: Only untagged versions

### 4. Security Audit (`security-audit.yml`)

**Triggers:**
- Daily scheduled (6 AM UTC)
- Manual trigger via workflow_dispatch

**Features:**

#### Python Dependency Audit
- ✅ **Safety check**: Scans requirements.txt for known vulnerabilities
- ✅ **JSON reports**: Machine-readable output
- ✅ **Artifact retention**: 30-day report storage
- ✅ **Summary reporting**: Vulnerability counts in GitHub UI

#### Container Audit
- ✅ **Trivy scanning**: Latest image security scan
- ✅ **SARIF upload**: Integration with GitHub Security
- ✅ **Multi-severity**: Critical, High, and Medium vulnerabilities
- ✅ **Table format**: Human-readable summary

### 5. Update Dependencies (`update-deps.yml`)

**Triggers:**
- Monthly scheduled (1st of month at 4 AM UTC)
- Manual trigger with update type selection (patch/minor/major)

**Features:**
- ✅ **pip-review integration**: Automated update checking
- ✅ **Draft PR creation**: Safe review process
- ✅ **Update summary**: Lists all available updates
- ✅ **Conventional commits**: Proper PR titles
- ✅ **Checklist**: PR includes validation checklist
- ✅ **Auto-labeling**: Dependencies and Python labels

## Security Best Practices

### Action Version Pinning
All actions use SHA256 pins instead of semantic versions:
```yaml
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

This prevents supply chain attacks from compromised action versions.

### Permissions
Workflows use minimal permissions following the principle of least privilege:
```yaml
permissions:
  contents: read      # Read repository
  packages: write     # Push to GHCR
  security-events: write  # Upload security results
```

### Security Scanning
Multiple layers of security scanning:
1. **Build time**: Hadolint for Dockerfile best practices
2. **Post-build**: Trivy for vulnerability scanning
3. **Daily**: Automated security audits
4. **Dependencies**: Safety checks for Python packages

## Release Process

### Automatic Releases
1. Create a tag: `git tag sbimage-1.2.3`
2. Push tag: `git push origin sbimage-1.2.3`
3. GitHub Actions automatically:
   - Builds multi-platform images
   - Runs security scans
   - Creates GitHub Release
   - Generates changelog
   - Publishes to GHCR

### Manual Releases
1. Go to Actions → Build and Publish
2. Click "Run workflow"
3. Select branch and trigger manually

## Maintenance Tasks

### Weekly
- Sunday 2 AM: Scheduled security scan
- Sunday 3 AM: Cleanup old images
- Monday: Dependabot checks GitHub Actions
- Tuesday: Dependabot checks Docker base
- Wednesday: Dependabot checks Python packages

### Daily
- 6 AM: Security audit of dependencies and images

### Monthly
- 1st at 4 AM: Dependency update check

## Monitoring and Alerts

### GitHub UI
- **Actions tab**: View all workflow runs
- **Security tab**: View vulnerability reports (SARIF)
- **Pull requests**: Dependabot and update PRs
- **Releases**: Auto-generated releases with changelogs

### Build Summaries
Each workflow provides detailed summaries:
- Build status
- Test results
- Security scan results
- Update availability

## Container Registry

**Location**: `ghcr.io/jvzantvoort/sbimage`

**Available Tags:**
- `latest` - Latest build from master
- `<version>` - Semantic version (e.g., `1.2.3`)
- `<major>` - Major version (e.g., `1`)
- `<major.minor>` - Minor version (e.g., `1.2`)
- `<branch>-<sha>` - Branch-specific builds
- `pr-<number>` - Pull request builds

## Contributing

When contributing, workflows will automatically:
1. Lint your Dockerfile changes
2. Build multi-platform images
3. Run smoke tests
4. Report results in PR

All PRs must pass these checks before merging.

## Troubleshooting

### Failed Security Scan
Check the Security tab for detailed vulnerability reports. Update affected packages in `requirements.txt`.

### Failed Build
Review the workflow logs in the Actions tab. Common issues:
- Dependency conflicts
- Dockerfile syntax errors
- Network issues during package installation

### Dependabot PRs
Review and merge Dependabot PRs regularly to keep dependencies updated and secure.

## Future Improvements

Potential additions:
- [ ] Performance benchmarking
- [ ] Image size tracking
- [ ] Docker Hub publishing
- [ ] Slack/Discord notifications
- [ ] Custom vulnerability thresholds
- [ ] Automated rollback on failures
- [ ] Integration tests with real projects
