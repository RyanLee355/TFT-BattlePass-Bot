# TFT-BattlePass-Bot
A fully automatic bot to play the game of Teamfight Tactics (TFT) automatically without any user input.\
Developed using `AutoHotkey 2.0.2 64-bit`.

## Motivation and Rewards
This project was inspired by myself playing League of Legends, trying to grind the LOL Battle Pass. For those who don't know, as of writing this, playing TFT contributes towards the LOL battlepass. Hence, by being able to run a bot to play TFT for me, I'd essentially be able to grind the BP. (Spoilers: It worked!)

Here's the proof. Realistically, you'd have to grind 24/7 for weeks to obtain level 400+ on the battlepass. Thanks to my bot, this was now possible. The rewards you see below are the results of running the bot throughout the day whilst I was at lectures, and also overnight whilst I was sleeping.<br/>
![image](https://github.com/user-attachments/assets/828c192a-3939-480e-ad28-c4f551b9aa2a)
![image](https://github.com/user-attachments/assets/c28b3abb-449c-470f-a63c-726d01bbb7f8)
![image](https://github.com/user-attachments/assets/a1de1309-cf78-44da-a195-818673ff40f5)

## Features and Functions
This bot is a state-managed algorithm, meaning that it switches intelligently between different states. For example, it will observe which 'mode' (PvP, PvE, champ/item selection, etc.) it is currently in, and make an informed decision. The model is intelligent, and selects its stage based on previous decisions and results by updating its weights. It is also a 'naive' model, such that it assumes board/item/champ states using an internal buffer. This is due to the inability to read from the screen at a higher level.

It has the ability to:
- Save money (until an % interest threshold is reached)
- Spend money on champs/rerolls
- Upgrade champ stars
- Naively equip items
- **Bypass Cheat Detection**: By utilising a bezier curve algorithm, mouse movements are randomised and mimick human behavior. This was previously used in an attempt to avoid cheat detection.

## Installation & Execution
*! WARNING ! This bot has since been deprecated due to the introduction of Riot's Vanguard for TFT*

Prefacing the bot, you will need to install the scripting language 'Autohotkey' (stable on 2.0.2).\
Once installed, run `tft.ahk`. This will begin the script. Nothing should happen except for an AHK icon on the taskbar.\
To begin, press `RCtrl`.\
To exit, press `Esc`. This will stop the script and exit AHK entirely. You will need to re-run the script.

## Configuration
Depending on the status of your game (i.e. already in-game), modifying the `gameStatus` variable will allow the bot to adapt. Otherwise it will bug out.\
You can also configure it to run only once via `SingleRun`.
