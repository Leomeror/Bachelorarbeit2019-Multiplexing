macro "BachelorMacro" {

	Dialog.create("Images");
	Dialog.addMessage("Geben Sie die Anzahl Bilder ein, die Sie öffnen möchten. \nStellen Sie vorher sicher, dass keine anderen Bilder geöffnet sind. \n \nHöchstens 7 Bilder.");
	Dialog.addNumber("Anzahl:", 2);
	Dialog.show();
	n = Dialog.getNumber();
	if (n < 2) {
		exit("Es werden mindestens 2 Bilder benötigt.");
		
	}

	if (n > 7) {
		exit("Es können höchstens 7 Bilder aligniert werden. (Aufgrund von \"Merge Channels...\") \nWenn Sie mehr als 7 Bilder alignieren möchten speichern Sie das Bild der ersten 7 Bilder \nund führen das Macro erneut für die nächsten 7 Bilder aus.");
		
	}
	
	for (i = 1; i <= n; i++) {
		filepath=File.openDialog("Select a File");
		open(filepath);
	}

	list = getList("image.titles");

	stringer = "";
			
	for (j = 1; j <= n; j++) {
		//string für Merge Channels erstellen, Beispiel: "c1=1B c2=1C"
		//substring löscht die Endung .bmp oder .tif, .jpg etc.
		stringer = stringer + "c" + j + "=[" + substring(list[j-1], 0, lengthOf(list[j-1])-4) + "] ";
		//für Bilder mit Leerzeichen wird der Name mit [ ] umschlossen
	}
	t = lengthOf(stringer);
	stringer = substring(stringer, 0, t-1);
	//substring löscht das letzte Leerzeichen
	print(stringer);
	
	
	run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
	
	//run("8-bit");
	//run("Invert", "stack");
	
	setTool("rectangle");
	waitForUser("Wählen Sie ein Rechteck aus,\n anhand dessen \n aligniert werden soll und klicken Sie dann auf \"Ok.\"");
	//reference slice übertragen
	refSlice = getSliceNumber();
	//makeRectangle(1208, 438, 138, 198);
	Roi.getBounds(x,y,w,h);

	//beim Invertieren wird sonst nur das Rechteck invertiert, statt das ganze Bild, also:
	run("Select None");
	//dadurch wird nichts mehr ausgewählt, statt das Rechteck
	
	run("8-bit");
	run("Invert", "stack");

//Zeigt Nachricht: Warten Sie, während... an
	showText("Progress", "Warten Sie, während \n\"Align slices in stack...\" ausgeführt wird.");

	run("Align slices in stack...", "method=5 windowsizex=" +w+ " windowsizey=" +h+ " x0=" +x+ " y0=" +y+ " swindow=0 subpixel=false itpmethod=0 ref.slice=" +refSlice+ " show=true");
//Wählt das Fenster mit "Warten Sie, während ..." aus und schließt es
	selectWindow("Progress");
	run("Close");
	
	run("Stack to Images");
	run("Merge Channels...", stringer);
	//run("Merge Channels...", "c1=1B c2=1C");
	setTool("zoom");
	selectWindow("RGB");
	//close();
	makeRectangle(x,y,w,h);
	colors = newArray("Rot", "Grün", "Blau", "Grau", "Cyan", "Magenta", "Gelb");
	Array.show(list, colors);
	//, "C:/Users/Leon/Desktop/Bachelor-Bilder/04-06-2019/1A_1B_aligned.tif");
	
	for (k = 0; k < n && k < lengthOf(colors); k++) {
	List.set(list[k], colors[k]);
	//print("Bild: " + list[k] + " in Farbe: " + colors[k] + "\n");
	}
	metainfo = List.getList();
	print(metainfo);
	setMetadata("Info", metainfo);
	saveAs("Tiff");
}