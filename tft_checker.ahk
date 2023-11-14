RCtrl::
{

	while true {
		if ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack C:\Users\Ryan\Desktop\TFTIcons\2Star.png") or 
			ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack C:\Users\Ryan\Desktop\TFTIcons\2Star1.png") or
			ImageSearch(&ImgX, &ImgY, 434, 885, 1500, 968, "*25 *TransBlack C:\Users\Ryan\Desktop\TFTIcons\2Star2.png") {
			MsgBox " FOUNDDD   "
		}
	}

}


Esc::ExitApp