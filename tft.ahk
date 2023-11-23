SetWorkingDir A_InitialWorkingDir
#MaxThreads 2


RCtrl:: 
{ 
	; Game Settings
	gameStatus := 0 ; 0=In Menu, 1=In Loading, 2=In Game
	SingleRun := 0 ; 0=Run Infinitely, 1=Stop after 1 iteration

	; Variables
	doubleClick := false
	functionsRandomized := false
	minChampPriceToBuy := 0
	functionArray := []
	itemArray := [[294, 749], [340, 720], [302, 687], [352, 668], [324, 634], [333, 593]]

	; Carousel Variables
	carousel_path1 := [[1017, 731], [1198, 685], [1248, 545], [1223, 386], [991, 370]]
	carousel_path2 := [[909, 738], [765, 678], [660, 502], [788, 444]]

	; Stages Variables
	currentStage := 0
	stage_array := ["Stage_1", "Stage_2", "Stage_3", "Stage_4"]
	stage_dirPath := "*5 Stages\"

	; Tactician Level Variables
	currentLevel := 1
	tacticianLevel_array := ["Lvl2", "Lvl3", "Lvl4", "Lvl5", "Lvl6", "Lvl7", "Lvl8"]
	tacticianLevel_dirPath := "*5 Levels\"

	; Gold Balance Variables
	currentGold := 0
	currentGold_array := ["10Gold", "20Gold", "30Gold", "40Gold", "50Gold", "60Gold", "70Gold", "80Gold", "90Gold", "100Gold"]
	currentGold_dirPath := "*5 Gold\"

	; Bench Bought Champion Tracking
	targetBenchSlot := 1 ; Used to communicate between SELL CHAMP and BUY CHAMP
	champBench_xCoordsArray := [411, 532, 666, 794, 897, 1007, 1124, 1253, 1369]
	BenchTracker := [0, 0, 0, 0, 0, 0, 0, 0, 0] ; 9 Slots, defaulted to 0 stars
	champBench_dirPath := "ChampGolds\"
	champBench_goldArray := ["2Gold", "3Gold", "4Gold", "5Gold"]
	champValue := 0

	; Board Champions --> Start [1][3] with 1, since default champions preloaded 
	; X, Y, value, stars
	board_Positions := [[965, 645, 1, 0], [904, 570, 0, 0], [964, 494, 0, 0], [1094, 645, 0, 0], [1024, 563, 0, 0], [1085, 494, 0, 0], [1216, 645, 0, 0], [1147, 567, 0, 0], [1198, 491, 0, 0]]


	; Game Playing Variables
	champsBoughtStage := 0
	firstAugment := true


; Functions
	sleepTimeGen(lo, hi) {
		return Random(lo, hi)
	}

	ClickRandomizer(x) {
		return Random(x-10, x+10)
	}

	moveMouseClick(x, y, key, doubleClick, loSleep:=200, hiSleep:=400) {
		SendMode "Event"
		if Random(0, 1) == 0 {
			CursorCurveMove(ClickRandomizer(x), ClickRandomizer(y), 20) ; Modify speed
		}
		else {
			MouseMove ClickRandomizer(x), ClickRandomizer(y), 8 ; Modify speed
		}
		SendMode "Input"

		if key == "right" {
			Click "Right"
			if doubleClick && Random(0, 5) <= 3
				Click "Right"
		}
		else if key == "left" {
			Click
			if doubleClick && Random(0, 5) <= 3
				Click
		}
		; If "none", do nothing

		Sleep sleepTimeGen(loSleep, hiSleep)
	}

	CursorCurveMove(x,y,Speed) {
		MouseGetPos(&x0, &y0)
		r := Random(-2., 2.)
		xd := x-x0, yd := y-y0
		z := (Floor(Sqrt(xd*xd+yd*yd))//Speed)+1
		xd := xd/z, yd := yd/z
		x2 := -yd*r/z, y2 := xd*r/z
		x3 := yd*r/2, y3 := -xd*r/2, z--
		Loop z
			MouseMove(x0+=xd+x3+=x2, y0+=yd+y3+=y2, 1)
		MouseMove(x, y, 1)
	}

	/* Match Finding */
	PlayAgain() {
		if PixelSearch(&Px, &Py, 497, 679, 581, 690, 0xA3C7C7, 1) {
			moveMouseClick(525, 671, "left", true, , )
		}
	}

	AcceptMatch() {
		if PixelSearch(&Px, &Py, 630, 550, 640, 560, 0xCDFAFA, 1) or 
			PixelSearch(&Px, &Py, 630, 550, 640, 560, 0xA3C7C7, 1) {
			Sleep 1500
			moveMouseClick(636, 554, "left", true, , )
			Sleep 10000
			AltTab()
			AltTab()
			return 0
		}
	}

	AcceptHonor() {
		if ImageSearch(&Px, &Py, 537, 638, 785, 713, "MiscImages\GG.png") {
			moveMouseClick(628, 423, "left", true, , )
		}
	}

	AcceptReport() {
		if ImageSearch(&Px, &Py, 0, 0, 1920, 1080, "MiscImages\report.png") or
			ImageSearch(&Px, &Py, 0, 0, 1920, 1080, "MiscImages\report2.png") {
			moveMouseClick(638, 676, "left", true, , )
		}
	}

	/* Store Checking (RightMost) */
	BuyChamp() {
		canBuy := 0
		LocationX := 0
		LocationY := 0
		champValue := 0 

		/* Skip buying, if excessive champions */
		; if GetNumberChampsBench() >= currentLevel {
		; 	return
		; }

		/* Identify highest price champ */
		Loop 4 {
			if ImageSearch(&ImgX, &ImgY, 460, 1026, 1512, 1079, champBench_dirPath . champBench_goldArray[A_Index] . ".png") && minChampPriceToBuy <= 1+A_Index {
				canBuy := 1
				LocationX := ImgX
				LocationY := ImgY
				champValue := 1+A_Index
			}
		}

		; How to identify the value of the champ? --> Set to 0, since it will be merged anyways
		Loop 10 {
			if ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star.png") or 
				ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star1.png") or
				ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star2.png") {
				canBuy := 1
				LocationX := ImgX
				LocationY := ImgY
				champValue := 0
			}
			Sleep 100
		}

		/* If no possible champs available to buy */
		if !canBuy {
			return
		}

		/* Attempt to sell a champion from the bench */
		if SellChampion()
			return

		moveMouseClick(LocationX, LocationY, "left", true, , )
		champsBoughtStage++

		BenchTracker[targetBenchSlot] := champValue ; Updates value on bench
	}

	SellChampion() {
		tempLowest := [1, BenchTracker[1]] ; Array (Bench) Location (default to bench spot #1), Value of Champ

		; Change target slot, to slot with lowest number
		Loop BenchTracker.Length {
			if BenchTracker[A_Index] < tempLowest[2] { ; If value in array is less than 'temporary Lowest, then replace'
				tempLowest[1] := A_Index
				tempLowest[2] := BenchTracker[A_Index]
			}
		}
		targetBenchSlot := tempLowest[1] ; targetBenchSlot --> Communicate with buying

		/* Checks to see if what we're selling, is worth LESS than what we're buying */
		if tempLowest[2] > champValue {
			return 1
		}
		
		; ReportBoardDebug()

		SendMode "Event"
		moveMouseClick(champBench_xCoordsArray[targetBenchSlot], 768, "none", true, , )
		Click "Down"
		Sleep 200
		moveMouseClick(905, 1000, "none", true, , )
		Click "Up"
		SendMode "Input"
		return 0
	}

	CheckAndBuy2Star() {
		canBuy := false
		Loop 10 {
			if ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star.png") or 
				ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star1.png") or
				ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack MiscImages\2Star2.png") {
				canBuy := 1
				LocationX := ImgX + 100
				LocationY := ImgY + 100
			}
			Sleep 100
		}
		if !canBuy
			return

		; Clear a slot
		if SellChampion()
			return

		moveMouseClick(LocationX, LocationY, "left", true, , )
		champsBoughtStage++
	}

	/* Updates the board at a position, with a new champion value */
	UpdateBoardValue(tileID, tileVal) {
		board_Positions[tileID][3] := tileVal
	}

	/* Gets the value at a position on the board */
	GetBoard(id) {
		return board_Positions[id][3]
	}

	GetNumberChampsBoard() {
		counter := 0
		Loop board_Positions.Length {
			if board_Positions[A_Index][3] != 0
				counter++
		}
		return counter
	}

	GetNumberChampsBench() {
		counter := 0
		Loop BenchTracker.Length {
			if BenchTracker[A_Index] != 0
				counter++
		}
		return counter
	}

	GetMinCostPosBoard() {
		tempLow := 999
		location := 0
		Loop board_Positions.Length {
			if board_Positions[A_Index][3] < tempLow {
				tempLow := board_Positions[A_Index][3]
				location := A_Index
			}
		}
		return location
	}

	GetHighCostBoard() {
		tempHigh := 0
		Loop board_Positions.Length {
			if board_Positions[A_Index][3] > tempHigh {
				tempHigh := board_Positions[A_Index][3]
			}
		}
		return tempHigh
	}

	/* Finds the most valued on bench, and swaps it with a board */
	/* Prioritizes stars, then value (cost) */
	/* Called regularly --> Keeps board updated with most expensive champs */
	UpdateMostValuedOnBoard() {
		/* Identify highest cost */
		costHighest := [0, 0] ; Value/Position
		Loop BenchTracker.Length {
			if BenchTracker[A_Index] > costHighest[1]
				costHighest := [BenchTracker[A_Index], A_Index]
		}

		if costHighest[1] == 0 { ; Bench is empty --> Fail
			return 1
		}

		if costHighest[1] < GetHighCostBoard() { ; Trying to swap lower value bench for higher value board. Stop.
			return 1
		}

		ReplaceBoard(costHighest[2], GetMinCostPosBoard())
		return 0
	}

	/* Swaps specified bench and board champions */
	ReplaceBoard(benchPos, boardTileID) {
		/* If board full, return */
		if GetNumberChampsBoard() >= currentLevel
			return 1

		SendMode "Event"
		moveMouseClick(champBench_xCoordsArray[benchPos], 768, "none", false, , )
		Click "Down"
		Sleep 200
		moveMouseClick(board_Positions[boardTileID][1], board_Positions[boardTileID][2], "none", false, , )
		Click "Up"
		SendMode "Input"

		/* Flip Bench Tracker and Board values */
		temp := BenchTracker[benchPos]
		BenchTracker[benchPos] := GetBoard(boardTileID)
		UpdateBoardValue(boardTileID, temp)

		return 0
	}

	/* Move randomly in the arena */
	MoveRandomInArena() {
		Loop Random(2,5) {
			moveMouseClick(Random(510, 1328), Random(200, 643), "right", true, , )
			sleepTimeGen(500, 3500)
		}
		return 0
	}

	LevelUp() {
		if ImageSearch(&FoundImageX, &FoundImageY, 271, 925, 464, 997, "Jungle.png") {
			moveMouseClick(357, 953, "left", true, , )
			return 0
		}
		return 1
	}

	AltTab() {
		Send "{Alt down}"
		Sleep 100
		Send "{Tab down}"
		Sleep 100
		Send "{Tab up}"
		Sleep 100
		Send "{Alt up}"
	}

	EquipItem() {
		SendMode "Event"

		itemTemp := Random(1, itemArray.Length)
		moveMouseClick(itemArray[itemTemp][1], itemArray[itemTemp][2], "none", true, ,)
		; moveMouseClick(279, 734, "none", true, ,)
		Click "Down"
		Sleep 200

		itemTemp := Random(1, currentLevel)
		moveMouseClick(board_Positions[itemTemp][1], board_Positions[itemTemp][2], "none", true, ,)
		Click "Up"
		SendMode "Input"
	}

	BuyXP() {
		if ImageSearch(&FoundImageX, &FoundImageY, 273, 924, 467, 998, "MiscImages\BuyXP.png") {
			moveMouseClick(357, 953, "left", true, , )
			return 0
		}
		return 1
	}

	RefreshChamps() {
		if ImageSearch(&FoundImageX, &FoundImageY, 251, 985, 482, 1079, "*10 MiscImages\Refresh.png") {
			moveMouseClick(368, 1031, "left", true, , )
			return 1
		}
		return 0
	}

	CheckCurrentStage() {
		nowStage := currentStage
		Loop stage_array.Length {
			if ImageSearch(&ImgX, &ImgY, 740, 7, 820, 36, stage_dirPath . stage_array[A_Index] . ".png") {
				currentStage := A_Index
			}
		}
		if nowStage != currentStage
			champsBoughtStage := 0
	}

	CheckCurrentLevel() { ; Tactician Level
		Loop tacticianLevel_array.Length {
			if ImageSearch(&ImgX, &ImgY, 256, 865, 365, 915, tacticianLevel_dirPath . tacticianLevel_array[A_Index] . ".png") {
				currentLevel := A_Index+1
			}
		}
	}

	CheckCurrentGold() {
		Loop currentGold_array.Length {
			if ImageSearch(&ImgX, &ImgY, 812, 858, 935, 919, currentGold_dirPath . currentGold_array[A_Index] . ".png") {
				currentGold := A_Index * 10
				if A_Index == 10 {
					currentGold := 100
				}
			}
		}
	}

	CheckCarousel() {
		if ImageSearch(&ImgX, &ImgY, 818, 0, 1108, 41, "MiscImages\Carousel.png") {
			if Random(0, 1) == 0 {
				Loop carousel_path1.Length {
					moveMouseClick(carousel_path1[A_Index][1], carousel_path1[A_Index][2], "right", true, 100, 400)
				}
			}
			else {
				Loop carousel_path2.Length {
					moveMouseClick(carousel_path2[A_Index][1], carousel_path2[A_Index][2], "right", true, 100, 400)
				}
			}
		}
		return
	}

	SelectAugment() {
		if ImageSearch(&FoundImageX, &FoundImageY, 0, 0, 1920, 1080, "MiscImages\Augment.png") {
			Sleep 1000
			if firstAugment {
				moveMouseClick(548, 518, "left", true, , )
				firstAugment := false
			}
			else if Random(0, 1) == 0 {
				moveMouseClick(961, 518, "left", true, , )
			}
			else {
				moveMouseClick(1478, 518, "left", true, , )
			}
		}
	}

	CallFunc(name) {
		if name == "MoveRandomInArena()" {
			MoveRandomInArena()
		}
		else if name == "BuyChamp()" {
			BuyChamp()
		}
		else if name == "RefreshChamps()" {
			RefreshChamps()
		}
		else if name == "BuyXP()" {
			BuyXP()
		}
		else if name == "UpdateMostValuedOnBoard()" {
			UpdateMostValuedOnBoard()
		}
		else if name == "EquipItem()" {
			EquipItem()
		}
	}

	; ReportBoardDebug() {
	; 	strng := "Current Level: " . currentLevel . ", Num of Champs on Board: " . GetNumberChampsBoard() . ", Champ Board Values: "
	; 	Loop board_Positions.Length {
	; 		strng := strng . board_Positions[A_Index][3] . ", "
	; 	}
	; 	strng := strng . " | Bench: "
	; 	Loop BenchTracker.Length {
	; 		strng := strng . BenchTracker[A_Index] . ", "
	; 	}
	; 	strng := strng . " | Gold: " . currentGold
	; 	MsgBox strng
	; }

	/* Exit Game */
	ExitGame() {
		if ImageSearch(&ImgX, &ImgY, 839, 529, 1088, 600, "MiscImages\ExitNow.png") {
			moveMouseClick(962, 569, "left", false, , )
			return 1
		}
		return 0
	}

; Begin Routine
	while(true) {
		if gameStatus == 0 {
			; Re-initialize Values
			firstAugment := true
			BenchTracker := [0, 0, 0, 0, 0, 0, 0, 0, 0] ; 9 Slots, defaulted to 0 stars
			targetBenchSlot := 1
			currentGold := 0
			currentLevel := 1
			currentStage := 0
			minChampPriceToBuy := 0
			functionArray := []
			board_Positions := [[965, 645, 1, 0], [904, 570, 0, 0], [964, 494, 0, 0], [1094, 645, 0, 0], [1024, 563, 0, 0], [1085, 494, 0, 0], [1216, 645, 0, 0], [1147, 567, 0, 0], [1198, 491, 0, 0]]

			; Check if 'Accept Match' button exist, if it does, click it 
			AcceptMatch()

			/* If detected, that in queue, skip */
			if ImageSearch(&ImgX, &ImgY, 466, 662, 600, 697, "MiscImages\InQueue.png") {
				continue
			}
			
			/* Matchmake/PlayAgain */
			; Check if 'Play Again' button exists, if it does, click it
			PlayAgain()
			

			if ImageSearch(&Px, &Py, 1559, 40, 1912, 339, "MiscImages\InLoading.png") { ; Check if in loading screen
				gameStatus := 1 ; If in loading screen, set state to loading screen
				continue
			}

			/* Escape key fragment/Honor screen */
			AcceptHonor()
			AcceptReport()
			moveMouseClick(600, 664, "left", false, , )	

		}
		else if gameStatus == 1 { ; In loading screen
			; PixelSearch returns TRUE if pixel is found
			if !ImageSearch(&Px, &Py, 1559, 40, 1912, 339, "MiscImages\InLoading.png") { ; Check if in loading screen
				gameStatus := 2 ; Puts game status into IN-GAME
			}
		}
		else { ; In Game, do in-game things
					
		/* Frequency Functions -- Happens every now and then */

			if functionArray.Length == 0 && functionsRandomized {
				; If no functions to run left, functionsRandomized --> False
				functionsRandomized := false
			}
			else if functionsRandomized {
				; Select a remaining function, and run it
				; MsgBox "calling function: " . functionArray[functionArray.Length]
				CallFunc(functionArray[functionArray.Length])
				functionArray.Pop()
			}
			else {
				; Randomize functions from the given array
				functionArray := ["MoveRandomInArena()", "UpdateMostValuedOnBoard()", "EquipItem()"]

				/* Modify the array (what to execute), based on current level */
				if (GetNumberChampsBench() + GetNumberChampsBoard()) < currentLevel {
					BuyChamp()
				}
				; Check if any 2 stars avaialble.
				CheckAndBuy2Star()

				if currentStage == 1 {
					if champsBoughtStage < 2 { ; Ensure at least 3 on the board
						BuyChamp()
					}
				}
				else if currentStage == 2 {
					if currentLevel < 5 {
						functionArray.Push("BuyXP()")
					}
					if currentGold > 20 {
						functionArray.Push("BuyChamp()")
						functionArray.Push("RefreshChamps()")
					}
				}
				else if currentStage == 3 {
					minChampPriceToBuy := 2
					if currentLevel < 6 {
						functionArray.Push("BuyXP()")
					}
					if currentGold > 50 {
						functionArray.Push("BuyChamp()")
						functionArray.Push("RefreshChamps()")
					}
				}
				else if currentStage == 4 {
					if currentLevel < 7 {
						functionArray.Push("BuyXP()")
					}
					if currentGold > 40 {
						functionArray.Push("BuyChamp()")
						functionArray.Push("RefreshChamps()")
					}
				}
				else if currentStage == 5 {
					minChampPriceToBuy := 3
					if currentLevel < 7 {
						functionArray.Push("BuyXP()")
					}
					if currentGold > 50 {
						functionArray.Push("BuyChamp()")
						functionArray.Push("RefreshChamps()")
					}
				}

				/*
					MoveRandom -> As frequent as possible
					EquipChamps -> As frequent as possible, to ensure champs on board are maxed.
						BuyXP -> Prioritize levelling, before buying champs. BUT save money for interest.
							StoreBuy -> Whenever champs on board aren't maxed + Whenever money is available (starting from stage 3?)
							RefreshChamps -> Accompanies StoreBuy, to pull the best champs: Only when sufficient money and not levelling

					Stage 1:	Buy 2x champs
					Stage 2:	Min. Lvl 4 -> Save money (min 20) -> Buy/Refresh
					Stage 3:	Min. Lvl 5 -> Save money (min 50/60) -> Buy/Refresh
					Stage 4:	
					Stage 5:	Min. Lvl 7

				*/
				

				/* Randomize Array Order */
				Loop functionArray.Length {
					rand := Random(1, functionArray.Length)
					Temp := functionArray[A_Index]
					functionArray[A_Index] := functionArray[rand]
					functionArray[rand] := Temp
				}
				functionsRandomized := true
			}

			/* Constant Checker Functions */
			CheckCurrentStage()
			CheckCurrentLevel()
			CheckCurrentGold()
			SelectAugment()
			CheckCarousel()

			/* Pick up orbs */
			if ImageSearch(&ImgX, &ImgY, 818, 0, 1108, 41, "MiscImages\Orb1.png") or 
				ImageSearch(&ImgX, &ImgY, 818, 0, 1108, 41, "MiscImages\Orb2.png") {
				moveMouseClick(ImgX, ImgY, "right", true, , )
			}

			/* Exit Game */
			if ExitGame() {
				gameStatus := 0
				Sleep 5000

				AltTab()

				if SingleRun {
					ExitApp
				}
			}
		}
	}
}

RAlt::Pause -1
Esc::ExitApp