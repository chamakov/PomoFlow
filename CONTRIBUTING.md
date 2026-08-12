# Contributing to PomoFlow

First off, thank you for considering contributing to PomoFlow! It's people like you that make PomoFlow such a great tool for productivity and focus.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for PomoFlow. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

*   **Use the GitHub issue search** — check if the issue has already been reported.
*   **Check if the issue has been fixed** — try to reproduce it using the latest `main` branch.
*   **Submit a bug report** by creating a new issue. Explain the problem and include additional details to help maintainers reproduce the problem.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for PomoFlow, including completely new features and minor improvements to existing functionality.

*   **Use the GitHub issue search** — check if the enhancement has already been suggested.
*   **Submit an enhancement suggestion** by creating a new issue. Provide a step-by-step description of the suggested enhancement in as many details as possible.

### Your First Code Contribution

Unsure where to begin contributing to PomoFlow? You can start by looking through these `good first issue` and `help wanted` issues:

*   **Good first issues** - issues which should only require a few lines of code, and a test or two.
*   **Help wanted issues** - issues which should be a bit more involved than `beginner` issues.

#### Local Development

PomoFlow is built purely with Swift Package Manager (SwiftPM), with no `.xcodeproj` file. This makes the project extremely lightweight and easy to compile.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chamakov/PomoFlow.git
   cd PomoFlow
   ```
2. **Build and run via terminal:**
   ```bash
   chmod +x ./Scripts/compile_and_run.sh
   ./Scripts/compile_and_run.sh
   ```
3. **Or build with Xcode:**
   Simply double-click the `Package.swift` file. Xcode will open the package and resolve dependencies natively. Select the "PomoFlow" executable target and hit Run (⌘R).

### Pull Requests

*   Fill in the required template
*   Do not include issue numbers in the PR title
*   Include screenshots and animated GIFs in your pull request whenever possible.
*   End all files with a newline.

Thank you!
