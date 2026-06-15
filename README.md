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

## SideStore route

For the no-$99 testing path, use SideStore to sign and install the IPA on your iPhone.

Recommended flow:

1. Let GitHub Actions compile/package Facezero.
2. Download the generated IPA artifact.
3. Import the IPA into SideStore.
4. Let SideStore sign it with your Apple ID flow.
5. Refresh it through SideStore when needed.

Read:

```text
docs/SIDESTORE_BUILD.md
```

## Paid Apple Developer route

The repo also includes a signed GitHub Actions workflow at:

```text
.github/workflows/ios-ipa.yml
```

It can generate the Xcode project, archive Facezero, export a signed `.ipa`, and upload it as a workflow artifact when Apple signing secrets are available.

For setup, read:

```text
docs/GITHUB_IPA_BUILD.md
```

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
