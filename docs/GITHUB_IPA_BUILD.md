# GitHub IPA build setup

Facezero can build a real iPhone `.ipa` on GitHub Actions, but iOS device builds require Apple code signing.

## Required repository secrets

Go to:

`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Add these secrets:

| Secret | Meaning |
| --- | --- |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |
| `BUILD_CERTIFICATE_BASE64` | Base64 encoded `.p12` signing certificate |
| `P12_PASSWORD` | Password for the `.p12` certificate |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 encoded `.mobileprovision` profile |
| `KEYCHAIN_PASSWORD` | Any strong temporary CI keychain password |

## Optional repository variables

Go to:

`Settings` → `Secrets and variables` → `Actions` → `Variables`

| Variable | Default | Meaning |
| --- | --- | --- |
| `IOS_BUNDLE_ID` | `com.tekdev.facezero` | Bundle ID used by the app and provisioning profile |
| `EXPORT_METHOD` | `development` | Use `development`, `ad-hoc`, or `app-store` depending on your profile |

For quick real-device testing, start with `development` export and a development provisioning profile that includes your iPhone UDID.

## Convert signing files to base64

On macOS:

```bash
base64 -i Certificates.p12 | pbcopy
```

Paste the clipboard value into `BUILD_CERTIFICATE_BASE64`.

For the provisioning profile:

```bash
base64 -i Facezero.mobileprovision | pbcopy
```

Paste the clipboard value into `BUILD_PROVISION_PROFILE_BASE64`.

## Run the build

1. Open the GitHub repo.
2. Go to `Actions`.
3. Select `Build iOS IPA`.
4. Click `Run workflow`.
5. Download the `Facezero-IPA` artifact after the workflow succeeds.

## Install on iPhone

For direct device install, the provisioning profile must include the target iPhone UDID. You can install the IPA with Apple Configurator, Xcode Devices window, or another trusted device-management method.

## Notes

- The simulator cannot test ARKit face tracking because Facezero needs the TrueDepth camera.
- GitHub-hosted runners can compile the app, but they cannot magically bypass Apple signing.
- If signing fails, confirm the certificate, provisioning profile, bundle ID, and Team ID all match.
