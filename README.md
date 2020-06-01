# PoopDeck { Working Title }

Baby activity data tracking and visualization. HealthKit for Babies, synced between parents phones for $0.99/m|$9.99/yr. Timeline of baby events and milestones, visualize averages, predict nap times. 

<details>
<summary>PoopDeck on iPhone 11</summary>

![iPhone 11 Screenshot](iPhone11Screenshot.png)

</details>

## Getting Started

### Prerequisites

Xcode 11.5

Checkout and install [Server App](https://github.com/calvinchestnut/BabyServer)

### Installing

No dependencies other than [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Open in Xcode

If not a registered iOS developer, make sure to select a simulator in the Target List. Running on device may be possible with correct iCloud account.

### Configure server address

Open file `BabyTracker/Environment.swift`

Edit value of `BabyServerBase` to point to the server in use

Run app again with new address

## Current State

MVP Accomplished. Can add, edit, duplicate, and delete all event types and  

### TODO

##### MVP

- Account support
- Siri shortcuts integration
- Design pass using proper assets
- Event Type filter 
- Auto pop form on Save
- Choose an IAP packagae

##### Follow on

- Mac and iPad Support 
- WatchOS App
