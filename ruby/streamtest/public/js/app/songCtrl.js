(function() {
    angular.module('songList').controller('songCtrl', songCtrl);

    // works with $scope but trying with this and controller as doesn't >:-[
    // - solution was to store a variable ref to 'this'
    // see http://stackoverflow.com/questions/30241759/angularjs-http-get-and-controller-as
    songCtrl.$inject = ['$http'];
    function songCtrl($http) {
        var vm = this;
        vm.folder = 'ripped';
        vm.slistcontent = '';
        vm.username = '';
        getList($http);

        function getList($http) {
            $http.get('/json/' + vm.folder) // TODO: VALIDATE!
            .then(function(response) {
                vm.songData = angular.fromJson(response.data);
            });
        }

        vm.saveList = function() {
            // why does listname work but not slistcontent?
            // because slistcontent wasn't populated using angular apparently :-/
            vm.slistcontent = document.getElementById('listcontent').value;
            vm.username = document.getElementById('username').value;
            var req = {
                method: 'POST',
                url: '/songlist',
                //url: 'http://httpbin.org/post',
                headers: {
                    'Content-Type': undefined
                },
                data: { listname: vm.listname,
                        listcontent: vm.slistcontent,
                        listowner: vm.username
                    }
            }
            if (isEmpty(vm.listname) || isEmpty(vm.username)) {
                alert("The list name and owner name cannot be empty.");
            } else if (isEmpty(vm.slistcontent) || vm.slistcontent == '[]') {
                alert("The list of songs cannot be empty.");
            } else {

                $http(req)
                .then( function(response) {
                    alert('Your playlist was saved.');
                }, function() {
                    alert('There was an error saving your playlist. Please try again later.');
                });
            }
        }

        vm.getSongs = function() {
            // just check for regular alphanumeric names, no fancy stuff
            var alphanu = /^[\w\/-]+$/;
            var m;
            if (m = alphanu.exec(vm.folder) === null) {
                alert("invalid folder: " + vm.folder);
            } else {
                getList($http);
            }
        }

        function isEmpty(str) {
            if (typeof str === undefined) {
                return true;
            }
            if (!str || /^\s*$/.test(str)) {
                return true;
            }
            return false;
        }
    }

})();
