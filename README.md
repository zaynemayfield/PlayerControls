# PlayerControls Addon

An addon designed to work with the **mod-player-control** AzerothCore module, providing quick commands for:
- **Speed control** (s1–s4)
- **Teleportation** to preset locations (T)
- **Teleport back** to previous locations (TB)
- **Teleport to a friend** or party member (TF)
- A quick **Back** button that executes `/say tb`

---

## Requirements

- **World of Warcraft 3.3.5a client** (ChromieCraft-compatible).
- An **AzerothCore** server with the [mod-player-control](https://github.com/azerothcore) module (or a compatible fork) installed.
- The **PlayerControls** addon folder placed inside your WoW `Interface/AddOns/` directory.

---

## Features

1. **Speed Control**  
   - **UP** and **DOWN** buttons on the main frame cycle between speed commands `s1, s2, s3, s4, s5`.  
   - Also supports a **key binding** (“Cycle Speed”) for quick cycling.

2. **Teleport (T)**  
   - Click **T** to open a list of preset teleport locations (loaded from `TeleportLocations.lua` or configured in-code).  
   - Filter results in real time by typing in the edit box.  
   - Clicking a location teleports you there via `/say t <location>`.

3. **Teleport to Friend (TF)**  
   - Click **TF** to open a window listing:
     - Online party/raid members  
     - Online friends from your friend list  
   - Displays each entry as **`Name - Class`**.  
   - Filter in real time by typing text in the edit box.  
   - Clicking a name sends `/say app <name>` to the server, allowing **mod-player-control** to handle the teleport.  
   - You can also type a **custom name** and press **Go** or **Enter** to teleport to someone not in your friend/party list.

4. **Teleport Back (TB)**  
   - Click **TB** to open a window listing recent teleport locations (tracked by the addon).  
   - Clicking a location teleports you there via `/say t <location>` and updates your teleport history.

5. **Back** (Instant `/say tb`)  
   - A **Back** button on the main frame sends `/say tb` immediately to return you to your previous location without opening a window.

6. **Exclusive Windows**  
   - Only **one** of **T**, **TF**, or **TB** can be open at a time. Opening any of them automatically closes the others.

---

## Installation

1. **Download or Clone** this repository into your WoW **AddOns** folder:

World of Warcraft 3.3.5a
└── Interface
    └── AddOns
        └── PlayerControls
            ├── PlayerControls.lua
            ├── PlayerControls.toc
            ├── TeleportLocations.lua
            ├── Bindings.xml
            └── README.md

2. Make sure the folder name is **PlayerControls** (matching the `.toc` file).
3. In your **AzerothCore** server, install or enable the **mod-player-control** module so the `/say` commands will be recognized.

---

## Usage

- **Main Frame**  
- By default, it appears at the **bottom-right** of your screen.  
- **UP / DOWN**: Increase or decrease movement speed.  
- **Back**: Immediately sends `/say tb`.  
- **T**: Opens the **Teleport** window (location list).  
- **TF**: Opens the **Teleport-to-Friend** window.  
- **TB**: Opens the **Teleport Back** window (history list).

- **Teleport Locations**  
- Managed by `TeleportLocations.lua`. You can customize or add new entries (e.g. “Stormwind”, “Darnassus”, etc.).

- **Teleport to Friend**  
- Lists only **online** party/raid members and online friends.  
- Displays each entry as **`Name - Class`** for convenience.  
- Clicking a name sends `/say app <name>` to the server.  
- Type a custom name and click **Go** or **Enter** if the person isn’t in your list.

- **Teleport Back**  
- Shows your last 8 teleports (tracked by `AddToPreviousLocations` in **PlayerControls.lua`).  
- Selecting a location teleports you there and pushes it to the history again.

- **Key Binding**  
- In **Key Bindings** \> **Player Controls**, set a key for **“Cycle Speed”** to quickly change movement speeds without clicking.

---

## Customization

- **Edit `TeleportLocations.lua`** to add or remove default teleport destinations.
- **Adjust frame sizes or positions** by changing `.SetSize` and `.SetPoint` calls in **PlayerControls.lua`.
- **Modify the maximum tracked “previous locations”** by editing the logic in `AddToPreviousLocations(location)` (e.g., change `8` to a different number).

---

## Troubleshooting

- **Addon not appearing?**  
- Make sure it’s **enabled** in the AddOns list at the WoW character select screen.  
- Check that your **.toc** file has the correct **Interface** version for 3.3.5a (e.g., `## Interface: 30300`).

- **Commands not recognized?**  
- Verify that your AzerothCore server has **mod-player-control** installed and loaded.  
- Check your server console/logs for any script errors.

---

## License

This project is distributed as open source. Feel free to modify or integrate it with your own projects.

---

## Credits

- **Author**: Zayne  
- **Powered by**: AzerothCore, mod-player-control  
- **Thanks** to the ChromieCraft community for testing and feedback.
