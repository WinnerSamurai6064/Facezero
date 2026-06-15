# Facezero

Facezero is a native iOS prototype for real-time face masking using Apple’s ARKit face tracking stack.

## First prototype scope

- Live TrueDepth face tracking through `ARFaceTrackingConfiguration`
- SwiftUI controls for mask style selection
- Front-camera AR preview with a lightweight face mesh overlay
- Built-in procedural sample character mask
- Generated app icon and sample mask texture for real package testing
- SideStore-first IPA packaging with no paid Apple Developer signing secrets

## Requirements

- iPhone with TrueDepth / Face ID support
- iOS 17+ target
- SideStore for the no-$99 test install path

Face tracking will not work properly in the simulator because it requires the TrueDepth camera.

## SideStore route

This repo is set up for the no-$99 testing path.

Recommended flow:

1. Open GitHub Actions.
2. Run `Build SideStore IPA`.
3. Download the `Facezero-SideStore-IPA` artifact.
4. Import the IPA into SideStore.
5. Let SideStore sign and install it on your iPhone.
6. Launch Facezero and grant camera permission.

There are no Apple Developer signing secrets required for this route.

## Active GitHub workflow

```text
.github/workflows/ios-sidestore-ipa.yml
```

This workflow generates visual assets, generates the Xcode project, builds the iPhone app bundle without CI signing, packages it as an IPA, and uploads the artifact.

## Open locally

This starter includes an `XcodeGen` project file.

```bash
brew install xcodegen
python3 scripts/generate_assets.py
xcodegen generate
open Facezero.xcodeproj
```

Then run on a real Face ID iPhone.

## Next phase

- Improve sample character proportions after real iPhone testing
- Wire video recording and local export
- Add custom USDZ / SCN character import
- Add mouth/jaw blend-shape hooks
- Add neck/head rotation tuning controls
- Add low-poly model validation guidance
