# Xcode Cloud CI/CD Setup for Lich+

This project uses Xcode Cloud for CI/CD with automatic App Store submission via fastlane.

## How It Works

1. **Clone**: Xcode Cloud clones the repository
2. **Post-Clone**: `ci_scripts/ci_post_clone.sh` installs CocoaPods and Bundler dependencies
3. **Build**: Xcode Cloud builds and signs the app
4. **Post-Build**: `ci_scripts/ci_post_xcodebuild.sh` runs after successful archive builds
5. **Submit**: Fastlane's `xcode_cloud_submit` lane uploads the signed app to App Store Connect

## Setup Instructions

### 1. Create Xcode Cloud Workflow

1. Open `lich-plus.xcodeproj` in Xcode
2. Go to **Product > Xcode Cloud > Create Workflow**
3. Configure the workflow:
   - **Name**: `Release` (IMPORTANT: must be exactly "Release" for auto-submission)
   - **Repository**: Select your repository
   - **Start Condition**: Choose one:
     - **Tag**: `v*` (recommended for releases)
     - **Branch**: `main` (for continuous deployment)
   - **Environment**: macOS (latest)
   - **Actions**: Archive (App Store)

**Note**: The post-xcodebuild script only runs auto-submission for workflows named "Release". For other workflows, it will skip the submission step.

### 2. Configure Environment Variables

In Xcode Cloud workflow settings, add these **Secret** environment variables:

| Variable | Value | Description |
|----------|-------|-------------|
| `ASC_KEY_ID` | `6257224LBZ` | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | `c419fd84-aa0b-4d05-9688-19d736cc2575` | App Store Connect Issuer ID |
| `ASC_KEY_CONTENT` | (base64 content) | Base64-encoded .p8 key content |

**To get ASC_KEY_CONTENT:**
```bash
base64 -i AuthKey_6257224LBZ.p8 | tr -d '\n'
```

### 3. Test the Setup

**Option A: Tag-based deployment (recommended)**
```bash
# Create and push a version tag
git tag v1.0.1
git push origin v1.0.1
```

**Option B: Manual trigger**
1. Go to Xcode Cloud in Xcode
2. Click **Start Build** on your workflow
3. Select branch/tag to build

### 4. Verify Submission

1. Check Xcode Cloud build logs for submission status
2. Go to App Store Connect > TestFlight to see the uploaded build

## File Structure

```
lich-plus/
├── ci_scripts/
│   ├── ci_post_clone.sh         # Installs dependencies after clone
│   ├── ci_pre_xcodebuild.sh     # Pre-build setup
│   └── ci_post_xcodebuild.sh    # Uploads to App Store Connect
├── .ruby-version                 # Ruby version for rbenv
├── fastlane/
│   ├── Fastfile                  # Includes xcode_cloud_submit lane
│   ├── Appfile                   # App configuration
│   ├── .env                      # Local credentials (not committed)
│   └── metadata/
│       ├── en-US/
│       │   └── release_notes.txt # English release notes
│       └── vi/
│           └── release_notes.txt # Vietnamese release notes
├── Gemfile                       # Ruby dependencies
└── XCODE_CLOUD_SETUP.md          # This file
```

## Available Fastlane Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `xcode_cloud_submit` | Auto-submission from Xcode Cloud | Called by post-build script |
| `beta` | Build and upload to TestFlight | `bundle exec fastlane beta` |
| `release` | Build and submit to App Store | `bundle exec fastlane release version:X.Y.Z` |
| `build_only` | Build IPA without uploading | `bundle exec fastlane build_only` |
| `test` | Run all tests | `bundle exec fastlane test` |

## Updating Release Notes

Edit the release notes before creating a release tag:

```bash
# Edit release notes
vim fastlane/metadata/en-US/release_notes.txt
vim fastlane/metadata/vi/release_notes.txt

# Commit and tag
git add fastlane/metadata/
git commit -m "Update release notes for v1.0.1"
git tag v1.0.1
git push origin main --tags
```

## Troubleshooting

### Build succeeds but submission fails

1. Check Xcode Cloud build logs for the post-build script output
2. Verify all environment variables are set correctly
3. Ensure `ci_scripts/ci_post_xcodebuild.sh` is executable (`chmod +x`)

### API Key authentication errors

1. Verify the API key has **Admin** access in App Store Connect
2. Check that `ASC_KEY_CONTENT` is properly base64-encoded
3. Regenerate the API key if expired

### Missing dependencies

If bundle install fails in Xcode Cloud:
1. Ensure `Gemfile` and `Gemfile.lock` are committed
2. Check that the Gemfile specifies compatible fastlane version

## Local Development

For local testing (not via Xcode Cloud):

```bash
# Install dependencies
bundle install

# Test the build
bundle exec fastlane build_only

# Deploy to TestFlight
bundle exec fastlane beta

# Deploy to App Store
bundle exec fastlane release version:1.0.1
```

## Notes

- The post-build script only runs for **archive** builds (not test builds)
- Submission happens automatically after successful App Store archive
- Release notes are read from `fastlane/metadata/*/release_notes.txt`
- Build number is managed by Xcode Cloud automatically
