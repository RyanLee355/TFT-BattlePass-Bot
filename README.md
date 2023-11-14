# TFT-BattlePass-Bot
A entry-level bot to play the game of TFT automatically without any user input.\
Developed using `AutoHotkey 2.0.2 64-bit`.

## Installation & Execution
Prefacing the bot, you will need to install the scripting language 'Autohotkey' (stable on 2.0.2).\
Once installed, run `tft.ahk`. This will begin the script. Nothing should happen except for an AHK icon on the taskbar.\
To begin, press `RCtrl`.\
To exit, press `Esc`. This will stop the script and exit AHK entirely. You will need to re-run the script.\

## Configuration
Depending on the status of your game (i.e. already in-game), modifying the `gameStatus` variable will allow the bot to adapt. Otherwise it will bug out.\
You can also configure it to run only once via `SingleRun`.\