function wrapper () {
	function quickSort(limit) {

		var nums = [];
		for (var i = 0; i<limit; i++) {
			nums[i] = Math.random();
		}
		var start = new Date().getTime();
		nums.sort();
		var end = new Date().getTime();
		var time = end - start;
		return time;
	};

	var times = [
		quickSort(5000),
		quickSort(10000),
        quickSort(15000),
        quickSort(20000),
        quickSort(25000),
        quickSort(30000),
        quickSort(35000),
        quickSort(40000),
        quickSort(45000),
        quickSort(50000)
	];

	return times.join('\t');
};
