function wrapper() {
	
	function sqrt(x) {
		
		var count = 8;

		function iterate(estimate) {
			count = count - 1;
			if (count < 1) {
				return estimate;
			} else {
				return iterate((estimate + x/estimate) / 2);
			}
		}

		return iterate(x);
	}

	function newton(limit) {
		
		var start = null,
			end = null,
			time = null,
			rand = Math.random()

		start = new Date().getTime();
		for (var i = 0; i < limit; i++) {
			sqrt(rand);
		}
		end = new Date().getTime();
		time = end - start;
		return time;
	}

	var iterations = [500000, 1000000, 1500000, 2000000, 2500000, 3000000, 3500000, 4000000, 4500000, 5000000],
		times = []
	var len = iterations.length;

	for (var i = 0; i < len; i++) {
		time = newton(iterations[i]);
		times.push(time);
	}

	return times.join('\t');
}

wrapper();
