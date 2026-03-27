# FlowDash Mobile 📊⚡

A native iOS dashboard for managing your n8n automation workflows on the go. Monitor, trigger, and manage your workflows from anywhere with a clean, dark-themed interface.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

---

## ✨ Features

### 🔗 N8N Integration
- **Connect to any n8n instance** — Self-hosted or n8n Cloud
- **Secure API Key authentication** — Your credentials, your control
- **Connection testing** — Verify before saving
- **Persistent credentials** — Secure local storage with Keychain

### 📋 Workflow Management
- **View all workflows** — List with active/inactive status
- **Toggle activation** — Enable/disable workflows with a tap
- **Manual triggering** — Run workflows on demand
- **Real-time updates** — Pull-to-refresh for latest status

### 📊 Execution Monitoring
- **Track execution history** — See what ran and when
- **Status filtering** — Filter by Success, Failed, Running, Waiting
- **Execution details** — Duration, timestamps, error messages
- **Infinite scroll** — Load more executions as you scroll

### 🎨 Beautiful Design
- **Dark-first interface** — Easy on the eyes
- **Glass-morphism cards** — Modern, elegant styling
- **Status color coding** — Green (success), Red (failed), Orange (running), Yellow (waiting)
- **Smooth animations** — Polished transitions and micro-interactions

---

## 🏗️ Architecture

```
FlowDashMobileApp/
├── FlowDashMobileAppApp.swift         # App entry point
├── ContentView.swift                  # Navigation coordinator
├── Models/
│   ├── Workflow.swift                 # Workflow model
│   └── Execution.swift                # Execution model with status
├── Services/
│   ├── N8NAPIService.swift           # n8n REST API client
│   └── StorageService.swift          # Secure credential storage
├── ViewModels/
│   ├── AppViewModel.swift            # App state management
│   ├── WorkflowsViewModel.swift      # Workflow list logic
│   └── ExecutionsViewModel.swift     # Execution tracking
├── Views/
│   ├── WelcomeView.swift             # Landing screen
│   ├── OnboardingView.swift          # First-time guide
│   ├── SetupView.swift               # Instance connection
│   ├── MainTabView.swift             # Tab container
│   ├── DashboardView.swift           # Workflow list
│   ├── WorkflowDetailView.swift      # Workflow details + executions
│   ├── ExecutionsTabView.swift       # All executions view
│   ├── ExecutionDetailView.swift     # Single execution details
│   ├── SettingsView.swift            # App settings
│   └── ToastView.swift               # Toast notifications
└── Utilities/
    └── TimeAgo.swift                 # Human-readable timestamps
```

---

## 🚀 Getting Started

### Prerequisites
- **macOS 14.0+**
- **Xcode 15.0+**
- **iOS 17.0+** device or simulator
- **n8n instance** (self-hosted or n8n Cloud)
- **n8n API key**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aiagentmackenzie-lang/flowdash-mobile-app.git
   cd flowdash-mobile-app
   ```

2. **Open in Xcode**
   ```bash
   open FlowDashMobileApp.xcodeproj
   ```

3. **Get your n8n API key**
   - Log into your n8n instance
   - Go to **Settings** → **API**
   - Generate or copy your API key

4. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd+R` to build and run

---

## 🔑 n8n API Setup

### Getting Your API Key

1. **Log into your n8n instance**
2. **Navigate to Settings**:
   - Click your profile picture (top right)
   - Select **Settings**
3. **Go to the API tab**
4. **Generate or copy your API key**

### Supported n8n Versions

- n8n Cloud: ✅ Fully supported
- Self-hosted: ✅ Requires public URL or VPN access
- Minimum n8n version: **1.0**

---

## 📱 Screens

### Welcome & Onboarding
- Clean landing with get-started flow
- Brief introduction to FlowDash features
- One-tap connection setup

### Connection Setup
- URL input with validation
- Secure API Key entry (show/hide toggle)
- Connection testing before saving
- Error handling with helpful messages

### Dashboard (Workflows)
- List of all workflows
- Active/inactive toggle switches
- Last updated timestamps
- Pull-to-refresh
- Navigation to workflow details

### Workflow Detail
- Workflow status with toggle
- **Trigger button** for manual execution
- Recent executions list
- Execution status and duration

### Executions Tab
- Complete execution history
- Filter by status (All, Success, Failed, Running, Waiting)
- Infinite scroll pagination
- Workflow name display
- Tap to view execution details

### Execution Detail
- Full execution information
- Status with visual indicator
- Start/stop timestamps
- Duration calculation
- Error message display (if failed)

### Settings
- View connection details (masked)
- Connection testing
- Edit connection credentials
- Dark mode toggle
- Disconnect option with confirmation

---

## 🎨 Design System

### Colors
| Element | Color |
|---------|-------|
| Background | Pure Black (`#000000`) |
| Card Background | White 6% opacity |
| Accent | Blue (`#0A84FF`) |
| Success | Green (`#30D158`) |
| Failed | Red (`#FF453A`) |
| Running | Orange (`#FF9F0A`) |
| Border | White 6% opacity |

### Typography
- System fonts with dynamic sizing
- Monospaced timestamps for clarity
- Consistent hierarchy throughout

### Components
- Glass-morphism cards with subtle borders
- Status badges with colored backgrounds
- Progress indicators for loading states
- Toast notifications for feedback

---

## 🛠️ Technical Stack

| Component | Technology |
|-----------|------------|
| Framework | SwiftUI |
| Language | Swift 5.9+ |
| Architecture | MVVM with `@Observable` |
| Networking | URLSession |
| Persistence | UserDefaults + Keychain |
| Icons | SF Symbols |

---

## 🔒 Security

- **API Key Storage** | Credentials stored securely in iOS Keychain
- **Local-only** | No backend server, data stays on your device
- **n8n Communication** | Direct HTTPS connection to your instance
- **Masked Display** | API key partially hidden in settings

---

## 🌍 Supported n8n Features

### ✅ Current
- [x] List all workflows
- [x] Activate/deactivate workflows
- [x] Trigger workflows manually
- [x] List executions
- [x] Filter executions by status
- [x] View execution details

### 🚧 Future
- [ ] Edit workflow JSON
- [ ] Create new workflows
- [ ] Duplicate workflows
- [ ] Delete workflows
- [ ] Webhook URL display
- [ ] Execution replay
- [ ] Notification integration

---

## 🐛 Troubleshooting

### "Invalid credentials or URL"
- Verify your n8n instance URL includes `https://`
- Check that your API key is correct
- Ensure your n8n instance is publicly accessible

### "Could not connect to server"
- Check your internet connection
- Verify your n8n instance is running
- For self-hosted: ensure firewall/VPN allows connection

### Workflows not appearing
- Make sure you have workflows in your n8n instance
- Check that your API key has proper permissions
- Try refreshing the dashboard

---

## 🤝 Contact & Support

Designed by **Raphael Main** and **Agent Mackenzie**.

For questions, feedback, or collaboration:

**📧 Email:** aiagent.mackenzie@gmail.com

---

## 🙏 Acknowledgments

- Powered by [n8n](https://n8n.io) — The workflow automation platform
- Icons by [SF Symbols](https://developer.apple.com/sf-symbols/)
- Built with SwiftUI

---

## 📝 License

**Copyright © 2026 Raphael. All rights reserved.**

This software is proprietary and confidential. No part of this project may be used, copied, modified, distributed, or reproduced without explicit written permission from the owner.

---

<p align="center">
  <strong>FlowDash</strong> — 
  <em>Workflow Automation at Your Fingertips</em> 📱
</p>
