# Setting up iOS Signing for GitHub Actions

To build an iOS app (`.ipa`) via GitHub Actions, you need to provide your Apple Developer signing credentials as GitHub Secrets.

## Prerequisites
- An active [Apple Developer Program](https://developer.apple.com/programs/) enrollment.
- Access to a Mac (for exporting certificates) OR a valid `.p12` certificate file generated elsewhere.

## Required Secrets

You need to add the following secrets to your GitHub Repository (Settings -> Secrets and variables -> Actions -> New repository secret):

| Secret Name | Description |
|---|---|
| `BUILD_CERTIFICATE_BASE64` | The Base64 encoded string of your Distribution Certificate (`.p12` file). |
| `P12_PASSWORD` | The password used to protect the `.p12` file. |
| `BUILD_PROVISION_PROFILE_BASE64` | The Base64 encoded string of your `.mobileprovision` file. |
| `KEYCHAIN_PASSWORD` | A temporary password for the keychain created on the runner. You can set this to any random string (e.g., `foobar`). |
| `APPLE_TEAM_ID` | Your Apple development Team ID (found in [Apple Developer Account](https://developer.apple.com/account) -> Membership). |

## Step-by-Step Instructions

### 1. Export Signing Certificate (.p12)
1.  Open **Keychain Access** on your Mac.
2.  Select **login** keychain and **My Certificates** category.
3.  Find your **Apple Distribution** certificate (or iPhone Distribution).
4.  Right-click it and select **Export**.
5.  Save it as `certificate.p12`.
6.  Enter a strong password when prompted (this will be `P12_PASSWORD`).

### 2. Get Provisioning Profile (.mobileprovision)
1.  Go to [Apple Developer Portal - Profiles](https://developer.apple.com/account/resources/profiles/list).
2.  Create a new **Distribution** profile (Store or Ad Hoc).
    *   **Ad Hoc**: For testing on specific registered devices.
    *   **App Store**: For TestFlight and App Store submission.
3.  Select your App ID and the Distribution Certificate you exported in Step 1.
4.  Download the profile (e.g., `app.mobileprovision`).

### 3. Convert to Base64
You need to convert the binary files to a Base64 string to store them as text secrets.

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\certificate.p12")) | Set-Clipboard
# Paste into GitHub Secret BUILD_CERTIFICATE_BASE64

[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\app.mobileprovision")) | Set-Clipboard
# Paste into GitHub Secret BUILD_PROVISION_PROFILE_BASE64
```

**On Mac/Linux:**
```bash
base64 -i certificate.p12 | pbcopy
# Paste into GitHub Secret BUILD_CERTIFICATE_BASE64

base64 -i app.mobileprovision | pbcopy
# Paste into GitHub Secret BUILD_PROVISION_PROFILE_BASE64
```

### 4. Configure GitHub Secrets
1. Go to your GitHub repository.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Add each secret listed in the "Required Secrets" table above.

## Triggering the Build
Once the secrets are set:
1.  Push a commit to the `main` branch.
2.  Or manually trigger the workflow from the **Actions** tab.
