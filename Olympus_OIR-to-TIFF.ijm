// creates window with message
	Dialog.create("Folder");
	Dialog.addMessage("Choose the Input and Output folder");
	Dialog.show();

// select the input and output path automatically

	input = getDirectory("Choose a Directory"); // OIR
	output = getDirectory("Choose a Directory"); // TIF


// define your function 

	function action(input, output, filename) {
	        
	        // opening ORI files needs specific BioFormats importer
	        // to avoid BioFormats window popping up after every image, define the parameter before in "s"
	        
	        list = getFileList(input);
	        s = "open=["+input+list[i]+"]";
			run("Viewer", s);
	        
	        // after the function is done, save in the format you want
	        // files will be saved in your output folder
	        // they will contain the same filename
	        
	        saveAs("Tiff", output + filename);
	        close();
	}


// this part will apply the function to every image in the folder

	setBatchMode(true); 
	list = getFileList(input);
	for (i = 0; i < list.length; i++){
	        action(input, output, list[i]);
	}
	setBatchMode(false);
