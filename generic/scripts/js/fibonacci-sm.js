function wrapper() {

  var recursive = function(n) {
      if (n <= 2) {
          return 1;
      } else {
          return recursive(n - 1) + recursive(n - 2);
      }
  };
  
  var iterations = [23, 24, 25, 26, 27, 28, 29, 30, 31, 32];
  var start = null, 
      end = null,
      time = null,
      times = [];
  
  
  for (var i = 0; i < iterations.length; i++) {
      start = new Date().getTime();
      recursive(iterations[i]);
      end = new Date().getTime();
      time = end - start;
      times.push(time);
  }

  return times.join('\t');
}

wrapper();
