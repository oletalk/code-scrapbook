
(function() {
    angular.module('songList').filter('startFrom', function() {
		return function(input, start) {
			return input.slice(start);
		}
	});
})();
