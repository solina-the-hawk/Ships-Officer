# Ship's Officer (for Achaea)

A comprehensive, all-in-one nautical Mudlet package for the MUD *Achaea, Dreams of Divine Lands*. 

**Ship's Officer** is designed to be the ultimate bridge console for captains and ship owners. By routing all commands through a single master alias (`so`), it consolidates everything you need to build, manage, sail, and fight with your ship into a unified, modular UI.

## ⚓ Current Modules

### Shipfitter's Aide (`so aide ...`)
A robust crafting and pricing utility for shipfitters. Crafting in Achaea can be incredibly math-heavy; this module allows you to build a "shopping list" of complex equipment (like hulls, riggings, and cannons), automatically dissolves them down into their base materials (iron, wood, cloth, rope, animal fat), and scrapes the live market to tell you exactly how much gold you need.
* **Live Market Estimation:** Automatically queries the Achaean commodity market (`cm list`) to calculate your total cost, using staggered commands to respect equilibrium.
* **Persistent Nominal Prices:** The scraper automatically saves the prices it finds, allowing you to instantly do "average cost" estimates later without having to sit through another live market scan.

### Navigator (`so map ...`)
*(Work in Progress)* A dedicated, toggleable graphical user interface (GUI) designed to display your position and chart regions on the Achaean Sea Wilderness map.
* Pans and zooms a high-resolution map image directly inside your Mudlet client.

---

## 🗺️ The Roadmap: Upcoming Modules

The vision for Ship's Officer is to have a dedicated "officer" for every aspect of Achaean seafaring. The following modules are currently planned for future releases:

* **The Quartermaster (`so qm ...`)**
  * Tracking for crew wages, morale, daily provisions, and ship's ammunition reserves.
* **The Purser (`so purser ...` or `so trader ...`)**
  * Trade deal monitoring, port price comparisons, and profit/loss tracking.
* **The Bosun (`so bosun ...`)**
  * Sea monster hunting timers, tool management (harpoons, bait), and a Goldeneyes-style profit-splitting calculator for the hunting party.
* **The Pilot (`so pilot ...`)**
  * Voyage progress monitoring, ETA estimations, and waypoint tracking.
* **The Master Gunner (`so gunner ...`)**
  * A ship combat awareness suite, providing tactical readouts, subsystem damage tracking, and combat alerts.

---

## 🛠️ Installation

1. Download the latest `Shipsofficer.xml` (or `.mpackage`) file from the Releases page.
2. Open Mudlet and navigate to the **Package Manager**.
3. Click **Install**, select the downloaded file, and click Open.
4. Type `so help` in your command line to verify it installed correctly.

## 📜 Usage & Commands

All commands are routed through the master `so` alias. 

| Command | Description |
| :--- | :--- |
| `so` or `so help` | Displays the master help manual and directory. |
| **Map Commands** | |
| `so map <region>` | Pans and zooms the map GUI to the specified location. |
| `so map show` / `hide` | Toggles the visibility of the map interface. |
| **Aide Commands** | |
| `so aide equip` | Lists all available ship equipment you can add to your list. |
| `so aide equip <amount> <equipment>` | Adds the required materials for a piece of ship equipment to your list (e.g., `so aide equip 1 ballista`). |
| `so aide add <amount> <commodity>` | Adds raw materials or ship commodities directly to your list. |
| `so aide calc <amount> <commodity>` | Instantly calculates the base materials for a single ship commodity without affecting your list. |
| `so aide list` | Displays your currently queued list and the total base commodities needed. |
| `so aide cost` | Instant gold estimation based on your historically saved prices. |
| `so aide cost now` | Scrapes the live commodity market to calculate exact current costs and updates your saved historical prices. *(Requires equilibrium)* |
| `so aide clear` | Empties your current shopping list. |

## ⚙️ Under the Hood
To edit the commodity conversion rates or add new ship equipment to the calculator, open the `Ship's Officer - Core` script in Mudlet and edit the `ShipsOfficer.Aide.recipes` or `ShipsOfficer.Aide.equipment` tables at the top of the file.