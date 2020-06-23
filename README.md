# PoopDeck { Working Title }

Baby activity data tracking and visualization. HealthKit for Babies. Timeline of baby events and milestones, visualize averages, predict nap times + feedings

<details>
<summary>PoopDeck on iPhone 11</summary>

![iPhone 11 Screenshot](iPhone11Screenshot.png)

</details>

## Getting Started

### Prerequisites

Xcode 11.5

### Installing

No dependencies other than [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12)

Open in Xcode

If not a registered iOS developer, make sure to select a simulator in the Target List. Running on device may be possible with correct iCloud account.

## UIDocument

PoopDeck reads and writes BabyLogs, custom files that use the `.bblg` extension. As such, PoopDeck requires no accounts, but with iCloud Drive supports document collaboration with basic

<details>

<summary>Bugs</summary>

- In early implementations conflict resolution resulted in lost data when a `BBLG` was open on two devices at the same time. Conflict resolution and file update receiver have both been refactored since then, but this bug hasn't been tested since then in favor of focusing on a 'single user' experience at a time. For now avoid opening 'prime' data on multiple devices

</details>

## Siri/Shortcuts

`branch: siri`

PoopDeck would be a perfect Shourtcuts app. Letting an automation log a nap or a feeding would make the app fully useful and accessible without ever opening it on any device.

An ideal implementation would allow read/write queries on the event store, so the following phrases perform as intended:

- "Hey Siri, when was Sophia's last nap?"
- "Hey Siri, log three minutes of Tummy Time?"
- "Hey Siri, when was her last nap longer then an hour?"

The queries should/would be available in Shortcuts as well, usually returning the date of the last event as a result value.

<details>
<sumary>Current State</summary>

Have an Intent Extension and an initial `Get Last Diaper Change` intent. Accepted inputs are the Date to filter by (defaults to now), and the `state` of the Diaper (wet, poopy, etc). It shows up correctly in Shortcuts and works with Siri, and my Intent is triggered. I was able to pass the file URL Bookmark Data, which is how I've been restoring application state, so the intent is to have the Intent (heh) open the correct Document (or accept it as input if needed)

Currently it seems I've not scoped the file access permissions correctly, because the Intent Extension shows an error when trying to decode the bookmark that doesn't apper in the iOS App Target. I need to revisit UIDocument access from extensions

**REMINDER: WWDC**

Have a reservation request for a siri intents lab

</details>

## Current State

##### Working

- Mult-Baby support
- Syncing + Conflict Resolution
- State restoration
- Multi-window support
- View all events in summary


### TODO

##### MVP

- Design pass using proper assets
- About Screen

##### Known Bugs

- Creating new document creates `MyBabyLog.bblg`, and after setting baby info it saves with the new baby name as the filename. But `MyBabyLog.bblg` remains. Delete the old file, or move rather than create
- Saving document should update the name as well
- If 'use emoji' is selected in Baby Info the BabyName is lost

##### Follow on

- Siri shortcuts integration
- Mac and iPad Support 
- WatchOS App
