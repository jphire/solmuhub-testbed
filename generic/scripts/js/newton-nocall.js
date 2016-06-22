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

	var iterations = [40000, 50000, 60000, 70000, 80000, 90000, 100000, 110000, 120000, 130000],
		times = []
	var len = iterations.length;

	for (var i = 0; i < len; i++) {
		time = newton(iterations[i]);
		times.push(time);
	}

	return times.join('\t');
}
