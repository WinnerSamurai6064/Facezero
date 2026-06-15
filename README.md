# Facezero

Facezero is a native iOS prototype for real-time face masking using Apple’s ARKit face tracking stack.

## First prototype scope

- Live TrueDepth face tracking through `ARFaceTrackingConfiguration`
- SwiftUI controls for mask style selection
- Front-camera AR preview with a lightweight face mesh overlay
- Record button placeholder state so capture/export can be wired next
- Native-only direction using SwiftUI, ARKit, SceneKit, and AVFoundation-friendly permissions

## Requirements

- Xcode 15+
- iPhone with TrueDepth / Face ID support
- iOS 17+ target

Face tracking will not work properly in the simulator because it requires the TrueDepth camera.

## Build the IPA on GitHub

The repo includes a GitHub Actions workflow at:

```text
.github/workflows/ios-ipa.yml
```

It can generate the Xcode project, archive Facezero, export a signed `.ipa`, and upload it as a workflow artifact.

For setup, read:

```text
docs/GITHUB_IPA_BUILD.md
```

Required signing secrets:

- `APPLE_TEAM_ID`
- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `BUILD_PROVISION_PROFILE_BASE64`
- `KEYCHAIN_PASSWORD`

Optional variables:

- `IOS_BUNDLE_ID`, default `com.tekdev.facezero`
- `EXPORT_METHOD`, default `development`

For real iPhone testing, use a development provisioning profile that includes your iPhone UDID.

## Open locally

This starter includes an `XcodeGen` project file.

```bash
brew install xcodegen
xcodegen generate
open Facezero.xcodeproj
```

Then run on a real Face ID iPhone.

## Next phase

- Wire video recording and local export
- Add custom USDZ / SCN character import
- Add mouth/jaw blend-shape hooks
- Add neck/head rotation tuning controls
- Add low-poly model validation guidance
