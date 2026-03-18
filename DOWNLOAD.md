# 📥 Download & Setup Guide

## Quick Start (3 Steps)

### 1. Download the Project

**Option A: Direct ZIP Download**
```bash
# Click the green "Code" button on GitHub → "Download ZIP"
# Or use this direct link:
https://github.com/gedeonkoh/Zenit-iOS/archive/refs/heads/main.zip
```

**Option B: Git Clone (Recommended)**
```bash
git clone https://github.com/gedeonkoh/Zenit-iOS.git
cd Zenit-iOS
```

### 2. Open in Xcode
```bash
open Zenit.xcodeproj
```

**Important:** Make sure you open `Zenit.xcodeproj` (the Xcode project file), NOT the `Zenit/` folder directly.

### 3. Run the App

1. Select a simulator or device:
   - **iPhone 15 Pro** (recommended for ProMotion 120Hz)
   - Any iOS 17.0+ device/simulator

2. Press `⌘ + R` or click the ▶ Play button

3. App launches in ~5 seconds ✨

---

## System Requirements

### Minimum Requirements
- **macOS:** Sonoma 14.0+ (Ventura 13.5+ may work)
- **Xcode:** 15.0 or later
- **iOS Deployment Target:** 17.0+
- **Swift:** 5.9+

### Recommended Setup
- **Mac:** M1/M2/M3 chip (faster builds)
- **RAM:** 8GB+ (16GB ideal)
- **Storage:** 15GB free space (Xcode + simulators)
- **Display:** Retina display to see the glassmorphism magic

---

## Folder Structure

After downloading, your folder should look like this:

```
Zenit-iOS/
├── Zenit.xcodeproj/          ← OPEN THIS IN XCODE
│   └── project.pbxproj
├── Zenit/
│   ├── App/
│   │   ├── ZenitApp.swift
│   │   └── Components/
│   ├── Views/
│   │   ├── Home/
│   │   ├── Focus/
│   │   ├── Tasks/
│   │   ├── Mood/
│   │   └── Habits/
│   ├── Design/
│   ├── Models/
│   └── ViewModels/
├── README.md
└── DOWNLOAD.md               ← You are here
```

---

## Troubleshooting

### ❌ "Zenit.xcodeproj not found"
**Problem:** You opened the wrong folder.  
**Solution:**
```bash
cd Zenit-iOS  # Make sure you're in the root directory
open Zenit.xcodeproj
```

### ❌ "No such module 'SwiftUI'"
**Problem:** Wrong Xcode version or iOS deployment target.  
**Solution:**
1. Check Xcode version: `Xcode → About Xcode` (must be 15.0+)
2. Check deployment target: Project settings → Deployment Info → iOS 17.0

### ❌ "Failed to prepare device for development"
**Problem:** Simulator not ready or corrupt.  
**Solution:**
```bash
# Reset simulator
xcrun simctl erase all

# Or delete and re-download from Xcode:
Xcode → Settings → Platforms → iOS → Download
```

### ❌ "Code signing issue" or "Provisioning profile"
**Problem:** Trying to run on a real device without Apple Developer account.  
**Solution:**
- Use a simulator (no account needed)
- OR sign in with your Apple ID: Xcode → Settings → Accounts → Add Apple ID

### ❌ "Build failed with 300+ errors"
**Problem:** Corrupted Xcode cache or derived data.  
**Solution:**
```bash
# Clean build folder
Product → Clean Build Folder (Shift + ⌘ + K)

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
⌘ + B
```

---

## First Launch

When you run Zenit for the first time:

✅ **Sample data is auto-generated:**
- 3 demo tasks ("Finish Zenit README", "Review PRs", "Team standup")
- 7 days of mood history
- 2 habits ("Morning Workout", "Read 30 min")
- 2 completed focus sessions

✅ **All features are unlocked** (no paywalls, no sign-up)

✅ **Data persists** using `@AppStorage` (UserDefaults)

---

## Customization

### Change App Name
1. Select `Zenit` target in Xcode
2. General → Display Name → Type new name
3. Rebuild

### Change Bundle Identifier  
1. Select `Zenit` target
2. Signing & Capabilities → Bundle Identifier
3. Change from `com.zenit.app` to `com.yourname.app`

### Change Colors/Theme
Edit `Zenit/Design/ZenitTheme.swift`:
```swift
static let accent = Color(hex: "#6CAFF7")  // Change this!
static let background = Color.black        // Or this!
```

---

## Building for Device (Optional)

If you want to run on your iPhone:

1. **Plug in your iPhone** (iOS 17.0+)

2. **Trust your Mac:**
   - iPhone prompt: "Trust This Computer?" → Trust
   - Enter iPhone passcode

3. **Sign the app:**
   - Xcode → Project → Signing & Capabilities
   - Team → Add your Apple ID
   - Xcode auto-generates a provisioning profile

4. **Enable Developer Mode (iOS 16+):**
   - iPhone: Settings → Privacy & Security → Developer Mode → ON
   - Restart iPhone

5. **Build and run:**
   - Select your iPhone from device list
   - Press ⌘ + R
   - First install takes ~30 seconds

6. **Trust the developer:**
   - iPhone: Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

---

## No Dependencies!

Zenit is 100% native SwiftUI with **ZERO external dependencies**:
- ❌ No CocoaPods
- ❌ No Swift Package Manager (SPM)
- ❌ No Carthage
- ❌ No npm/yarn/whatever

Just clone, open, and run. That's it.

---

## Performance Notes

### Simulator vs. Real Device

| Feature | Simulator (M1 Mac) | Real iPhone 15 Pro |
|---------|-------------------|--------------------|
| Build time | 5-8 seconds | 15-20 seconds |
| Frame rate | 60 FPS (capped) | 120 FPS (ProMotion) |
| Animations | Smooth | Buttery smooth |
| Haptics | ❌ Not supported | ✅ Full support |

**Recommendation:** Develop on simulator, test final build on device for full experience.

---

## Advanced: Export as IPA (App Store)

If you want to distribute Zenit:

1. **Archive the app:**
   ```
   Product → Archive (⌘ + B with Generic iOS Device selected)
   ```

2. **Export IPA:**
   - Window → Organizer → Archives tab
   - Select "Zenit" → Distribute App
   - Choose distribution method:
     - **Development:** For your devices only
     - **Ad Hoc:** For up to 100 testers
     - **App Store:** Public release (needs paid Apple Developer account)

3. **Install IPA:**
   - Drag `.ipa` file to Xcode → Window → Devices and Simulators
   - Select device → "+" → Select IPA

---

## Getting Help

### Still stuck?

1. **Check Xcode logs:**
   - View → Debug Area → Show Debug Area (⌘ + Shift + Y)
   - Look for red errors

2. **Google the error:**
   - Copy full error message
   - Search: `[error message] site:stackoverflow.com`

3. **Open an issue:**
   - https://github.com/gedeonkoh/Zenit-iOS/issues
   - Include:
     - Xcode version (`Xcode → About Xcode`)
     - macOS version (`About This Mac`)
     - Full error log (copy from Xcode)

---

## Next Steps

Once the app is running:

1. ✅ Read the [README.md](README.md) for feature details
2. ✅ Explore the codebase:
   - Start with `ZenitApp.swift` (app entry point)
   - Check out `Views/` for UI screens
   - Peek at `Design/ZenitTheme.swift` for colors
3. ✅ Customize and make it yours!
4. ✅ Star the repo ⭐ if you found this useful

---

<div align="center">

**Happy coding! 🚀**

Built with ☕ and SwiftUI

[← Back to README](README.md)

</div>
