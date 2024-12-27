# muhaddil_machines (FiveM)

A FiveM script that adds several machines to improve user experience.

## Features

- Vending machines for drinks and snacks
- Water coolers with a timeout feature
- Food stands with various items
- News sellers with newspapers
- Custom animations for interactions
- Configurable framework support (ESX and QBCore)
- Debug mode for development
- Auto version checker

## Installation

1. Clone or download the repository.
2. Add the resource to your `resources` folder.
3. Add `start muhaddil_machines` to your `server.cfg`.

## Configuration

You can configure the script by editing the [config.lua](config.lua) file. Here are some of the options available:

- `DebugMode`: Enable or disable debug mode.
- `Framework`: Choose between 'esx' or 'qb'.
- `UseOXNotifications`: Use OX notifications or frameworks.
- `ThirstRemoval`: Amount of thirst removed by water coolers.
- `WaterCoolerTimeout`: Timeout duration for water coolers.
- `VisibleProp`: Show or hide props during animations.
- `ShowWaitNotification`: Show notification when water cooler is on timeout.
- `MaxDrinksBeforeKill`: Maximum drinks before player death.
- `CountDrinksPlace`: Count drinks before or after drinking.

## Usage

### Vending Machines

Interact with vending machines to buy drinks and snacks. The available items and their prices are configured in the [config.lua](config.lua) file.

### Water Coolers

Interact with water coolers to drink water. The script includes a timeout feature to prevent excessive use.

### Food Stands

Interact with food stands to buy various food items. The available items and their prices are configured in the [config.lua](config.lua) file.

### News Sellers

Interact with news sellers to buy newspapers. The available items and their prices are configured in the [config.lua](config.lua) file.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

<p>
  <img src="https://github.com/Muhaddil/muhaddil-machines/blob/main/preview/Machine2.png?raw=true" width="400" style="display:inline-block; margin-right: 10px;" />
  <img src="https://github.com/Muhaddil/muhaddil-machines/blob/main/preview/WaterCoolers.png?raw=true" width="400" style="display:inline-block;" />
</p>
