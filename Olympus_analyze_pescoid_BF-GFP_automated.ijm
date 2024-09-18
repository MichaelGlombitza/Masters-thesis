// choose an input/output directory requires two folders
// this functions takes all images from the input directory > runs the Macro > and saves everything in the ouput folder
// the files in the output folder keep the same name
    input = getDirectory("Input directory");
    output = getDirectory("Output directory"); // AVI video files
    output2 = getDirectory("Output directory"); // JPEG start and end point images
processFolder(input); 
function processFolder(dir) {
    list = getFileList(dir);
    for (i=0; i<list.length; i++) {
                if(endsWith(list[i], ".tif")) { //add the file ending for your images"How many explants do you have in the timelapse/field of view?", 1"How many explants do you have in the timelapse/field of view?", 1
                processFile(dir, output, list[i]);
        } else if(endsWith(list[i], "/") && !matches(output, ".*" + substring(list[i], 0, lengthOf(list[i])-1) + ".*")) {
            //if the file encountered is a subfolder, go inside and run the whole process in the subfolder
                processFolder(""+dir+list[i]);
        } else {
                //if the file encountered is not an image nor a folder just print the name in the log window
                print(dir + list[i]);
        }
    }
}
// everything in this function will be applied to each image in the input folder
function processFile(inputFolder, output, file) {
    // open(inputFolder + file);
    
    s = "open=[" + inputFolder + file + "]";
    run("Bio-Formats Importer", s);
      
    filename = getTitle();
    
// start editing the images 
    run("Split Channels");
    run("Tile");
    
    // rename windows
        selectWindow("C1-"+ filename); // green
            rename("GFP");
        
        selectWindow("C2-"+ filename); // gray
            rename("BF");
        
    // choose the best z-stack (manually)
    // it will play the BF channel first, so you can choose the best z-stack(-s)
    // because pescoids (and eggs) are big and move, z-projection of all stacks would result in blurry image
    // select the best z-stack and use for all channels
        selectWindow("BF");
            
        run("Z Project...", "projection=[Average Intensity] all");
        close("BF");
        
        selectWindow("GFP");
        run("Z Project...", "projection=[Average Intensity] all");
        close("GFP");
    
    // adjust brightness and contrast
        run("Tile");
        
        selectWindow("AVG_GFP");
            setMinAndMax(180, 240);
            // run("Enhance Contrast", "saturated=0.35");
        
        selectWindow("AVG_BF");
            setSlice(20);
            run("Enhance Contrast", "saturated=0.35"); // auto-b&c is sufficient here
            // title = "Adjust B&C";
            // msg = "Inhance Minimum and reduce Maximum,\nthen click \"Apply\",\nthen apply it to all stacks,\nthen click \"OK\".";
            // waitForUser(title, msg);
        
    // merge the channels according to the color
        run("Merge Channels...", "c2=AVG_GFP c4=AVG_BF create keep");
        
    // insert labels
    // h = hours of imaging
    // hpf = hours post fertilization 
        
        // create dialog field to adjust starting times of imaging 
        Dialog.create("Label");
            Dialog.addNumber("Start Time for Imaging [h]:", 0);
            Dialog.addNumber("Time after fertilization [hpf]:", 6);
            Dialog.addNumber("Interval [between frames]:", 1);
            // Dialog.show();
            StartTime = Dialog.getNumber();
            PostFert = Dialog.getNumber();
            Interval = Dialog.getNumber();
        
        //run("Labels...", "color=black font=24 show");
        setForegroundColor(0, 0, 0);
        run("Label...", "format=0 starting=StartTime interval=Interval x=5 y=30 font=25 text=h range=1-10000 use");
        //run("Labels...", "color=black font=24 show");
        setForegroundColor(0, 0, 0);
        run("Label...", "format=0 starting=PostFert interval=Interval x=5 y=60 font=25 text=hpf range=1-10000 use");
    // insert scale bar
        run("Scale Bar...", "width=200 height=200 thickness=4 font=18 color=Black background=None location=[Lower Right] horizontal bold overlay");
// save as AVI (no need to flatten)
// adjust compression and frame if needed 
    selectWindow("Merged");
        saveAs("AVI", output + filename);
    
// take image from the START and END point of imaging (besides videos)
// adjust the start end end time point (= hours)
// needs to flatten the image first to come from multichannel to RGB that can be duplicated
    // run("Flatten");
    
    Dialog.create("Time Points");
        Dialog.addNumber("Start Point:", 1);
        Dialog.addNumber("End Point:", 11);
        // Dialog.show();
        TStart = Dialog.getNumber();
        TEnd = Dialog.getNumber();
    selectWindow("Merged");
        run("Duplicate...", "title=START duplicate frames=TStart");
    selectWindow("Merged");
        run("Duplicate...", "title=END duplicate frames=TEnd");
    close("Merged");
// save them in separate folder for JPEG    
    selectWindow("START");
        saveAs("Jpeg", output2 + filename + "_start");
        close("START");
    selectWindow("END");
        saveAs("Jpeg", output2 + filename + "_end");
        close("END");
run("Close All");
}