<div align="center">
  <img src="assets/icon_3d.jpg" alt="PomoFlow Icon" width="128" />
  
  # PomoFlow for macOS
  
  **An advanced, privacy-first, hybrid time tracking and Pomodoro application for macOS.**
  
  ![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
  ![macOS](https://img.shields.io/badge/macOS-14.0+-black.svg)
  ![License](https://img.shields.io/badge/License-MIT-blue.svg)
  ![Architecture](https://img.shields.io/badge/Architecture-SwiftPM-success.svg)
</div>

---

PomoFlow is designed for freelancers, developers, and anyone who needs to combine billing and productivity seamlessly. Built entirely with SwiftUI, it offers a premium glassmorphic interface alongside enterprise-level focus and security features.

## ✨ Key Features

### 🍅 Hybrid Tracking
Combine traditional task-based time tracking (to calculate hourly rates and billable hours) with the proven Pomodoro Technique for maximum focus.

<div align="center">
  <img src="assets/screenshot1.png" alt="Main Interface" width="600" style="border-radius: 12px; box-shadow: 0 4px 14px rgba(0,0,0,0.2);" />
</div>

### ⚡ Menu Bar "Live Timer"
Keep an eye on your remaining focus time right from your system status bar without opening the main app. Click the icon to instantly pause or start your Pomodoros.

<div align="center">
  <img src="assets/screenshot3.png" alt="Menu Bar" width="500" style="border-radius: 12px; box-shadow: 0 4px 14px rgba(0,0,0,0.2);" />
</div>

### 📊 Advanced Reports & CSV Export
View beautiful dashboard metrics of your daily progress, streaks, and earnings, and export detailed CSV reports with a single click.

<div align="center">
  <img src="assets/screenshot2.png" alt="Reports" width="600" style="border-radius: 12px; box-shadow: 0 4px 14px rgba(0,0,0,0.2);" />
</div>

### 🛡 Strict Focus Mode & Global Keyboard Shortcuts
When a Pomodoro session starts, the app can automatically hide all other applications, leaving you in a distraction-free environment. 
Start, pause, or check your Pomodoro status from anywhere in macOS using customizable global hotkeys (`Cmd + Option + P`, `Cmd + Option + O`, etc.).

---

## 🚀 How to Use PomoFlow

Thanks to our automated GitHub Actions release pipeline, installing PomoFlow is incredibly easy. You don't need to compile anything.

1. Go to the [Releases](https://github.com/chamakov/PomoFlow/releases) page of this repository.
2. Download the latest `PomoFlow.dmg` file.
3. Open the `.dmg` and drag **PomoFlow** to your `/Applications` folder.
4. Launch the app and start focusing!

*Note: Data is saved locally using macOS File Protection (`.completeFileProtectionUnlessOpen`). Your productivity data never leaves your machine.*

---

## 🛠 How to Contribute

We welcome contributions from the community! PomoFlow uses an innovative architecture built entirely with the **Swift Package Manager (SwiftPM)**. There are no `.xcodeproj` files, preventing annoying merge conflicts and keeping the codebase clean.

### Prerequisites for Development
- macOS 14.0 (Sonoma) or newer.
- Swift 5.9+ (included with Xcode 15+ or Command Line Tools).

### Building and Running
We provide a convenient bash script to compile and run the application directly from the terminal.

```bash
# 1. Clone the repository
git clone https://github.com/chamakov/PomoFlow.git
cd PomoFlow

# 2. Compile and run
./Scripts/compile_and_run.sh
```

### Packaging for Release (Local)
While our CI/CD pipeline handles releases automatically, you can generate a `.app` bundle locally to test distribution:

```bash
./Scripts/package_app.sh release
```

### Mac App Store & Sandboxing
If you intend to fork this project and submit it to the Mac App Store:
1. You must enable the App Sandbox.
2. Edit `Scripts/package_app.sh` and uncomment the entitlements for `com.apple.security.app-sandbox` and `com.apple.security.automation.apple-events`.

## 🤝 Community & Support
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/chamakov/PomoFlow/issues).

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
