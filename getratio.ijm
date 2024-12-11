#@ File (label = "Fluorescence image", style = "file") input1
#@ File (label = "Green mask image", style = "file") input2
#@ File (label = "Red mask image", style = "file") input3


run("Bio-Formats", "open=[" + input1 +"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
open(input2);
open(input3);
wait(100);

// These are the proximate coordinates (upper-left corner) and dimension of a cropping box
// to be used because of the uneven intensity distribution in the red channel.
// Feel free to change them based on your own judgement:
x=128;
y=388;
width=1400;
height=1400;


// Crop all windows to exclude dim regions for Red channel
for (id=1; id<=3; id++) {
	selectImage(id);
	makeRectangle(x, y, width, height);
	run("Crop");
}

selectImage(1); // the fluorescene image
run("Subtract...", "value=100 stack"); // need to subtract camera background, for ratio to be more precise
run("Split Channels");  // windows 3 & 4 are green and red channels now
wait(100);

run("Set Measurements...", "centroid integrated display redirect=None decimal=3");


// for green channel mask:
selectImage(1)
// "Default bright" option is used for the Gal3(green) channel mask because the background has label 1
// while the objects have label 0
setAutoThreshold("Default bright no-reset");
run("Threshold...");
wait(100);
run("Convert to Mask");
run("Close");
run("Create Selection");
selectImage(3);
run("Restore Selection");
run("Measure");

run("Select None");

// for red channel mask:
selectImage(2)
// In the red channel, object/background labels are 0 and 1, opposite to the green channel.
setAutoThreshold("Default dark no-reset");
run("Threshold...");
wait(100);
run("Convert to Mask");
run("Close");
run("Create Selection");
selectImage(4);
run("Restore Selection");
run("Measure");

g=getResult("RawIntDen", 0);
r=getResult("RawIntDen", 1);

ratio=g/r;
print(ratio);

//setBatchMode(false);
close("*");
close("Results")
