//  
// This script is meant to test data processing capabilities of an IoT hub. 
//  

// Get image data from somewhere, or simulate every pixel.
//var img = data.img1; //Buffer object
//var measures = lib.func2.calculate(img);

//var width = measures.width
//  , height = measures.height;

var width = 512;
var height = 512;
var imgLength = width * height * 4;
var hubCount = 2;

var r = new ArrayBuffer(imgLength);
var data = new Uint32Array(r); //Typed integer array for faster processing
var buf8 = new Uint8ClampedArray(r); //Typed array for image data

var start_time = new Date().getTime();

for (var y = 0; y < height; ++y) {
    for (var x = 0; x < width; ++x) {
        var value = x * y & 0xff;
        data[y * width + x] =
            (255 << 24) |      // alpha
            (value << 16) |    // blue
            (value <<  8) |    // green
             value;            // red
    }
}

var end_time = new Date().getTime();
var time = end_time-start_time;
time;