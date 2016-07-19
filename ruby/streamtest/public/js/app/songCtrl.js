(function() {
    angular.module('songList').controller('songCtrl', songCtrl);

    // works with $scope but trying with this and controller as doesn't >:-[
    // - solution was to store a variable ref to 'this'
    // see http://stackoverflow.com/questions/30241759/angularjs-http-get-and-controller-as
    songCtrl.$inject = ['$http'];
    function songCtrl($http) {
        var vm = this;
        vm.folder = 'ripped';
        getList($http);

        function getList($http) {
            $http.get('/json/' + vm.folder) // TODO: VALIDATE!
            .then(function(response) {
                vm.songData = angular.fromJson(response.data);
            });
        }

        vm.getSongs = function() {
            // just check for regular alphanumeric names, no fancy stuff
            var alphanu = /^[\w\/]+$/;
            var m;
            if (m = alphanu.exec(vm.folder) === null) {
                alert("invalid folder: " + vm.folder);
            } else {
                getList($http);
            }
        }
    }

})();
