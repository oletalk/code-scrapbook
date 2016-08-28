(function() {
    angular.module('songList').controller('songCtrl', songCtrl);

    // works with $scope but trying with this and controller as doesn't >:-[
    // - solution was to store a variable ref to 'this'
    // see http://stackoverflow.com/questions/30241759/angularjs-http-get-and-controller-as
    songCtrl.$inject = ['$http'];
    function songCtrl($http) {
        var vm = this;
        vm.folder = 'ripped';
        vm.username = '';
        vm.userPlaylists = [];
        getList($http);

        function getList($http) {
            $http.get('/json/' + vm.folder) // TODO: VALIDATE!
            .then(function(response) {
                vm.songData = angular.fromJson(response.data);
            });
        }

        vm.echo1 = function() {
            alert("sc.listnameFromSelect is " + JSON.stringify(vm.listnameFromSelect));
        }

        vm.saveList = function(username) {
            vm.username = username;
            var req = {
                method: 'POST',
                url: '/songlist',
                //url: 'http://httpbin.org/post',
                headers: {
                    'Content-Type': undefined
                },
                data: { listname: vm.listname,
                        listcontent: vm.droppedObjects1,
                        listowner: vm.username
                    }
            }
            if (isEmpty(vm.listname) || isEmpty(vm.username)) {
                alert("The list name and owner name cannot be empty.");
            } else if (listcontent.length == 0) {
                alert("The list of songs cannot be empty.");
            } else {
                alert("passing this to save function: " + JSON.stringify(req));
                $http(req)
                .then( function(response) {
                    if (response.data && typeof response.data.error !== undefined) {
                        alert('There was a problem saving your playlist: ' + response.data.error);
                    } else {
                        alert('Your playlist was saved.');
                    }
                }, function(error) {
                    alert('There was an error saving your playlist. Please try again later. ');
                });
            }
        }

        vm.removeSong = function(item) {
            var index = vm.droppedObjects1.indexOf(item);
            vm.droppedObjects1.splice(index, 1);
        }

        vm.getPlaylists = function(owner) {
            $http.get('/json_lists_for/' + owner)
            .then(function(response) {
                vm.userPlaylists = response.data;
            });
        }

        vm.loadList = function() {
            var lname = vm.listname;
            if (typeof vm.listnameFromSelect !== undefined && vm.listnameFromSelect.name !== '') {
                lname = vm.listnameFromSelect.name;
                vm.listname = lname;
            }
            $http.get('/playlist_json/' + lname) // TODO: VALIDATE!
            .then(function(response) {
                if (response.data.length > 0 ) {
                    var numsongs = response.data.length;
                    if (numsongs > 0) {
                        vm.droppedObjects1 = [];
                        for (var i = 0; i < response.data.length; i++) {
                            vm.droppedObjects1.push(response.data[i]);
                        }
                    }
                } else {
                    if (typeof response.data.error !== undefined) {
                        alert("An error occurred: " + response.data.error);
                    } else {
                        alert("Empty response");
                    }
                }
            });
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

        // drag 'n' drop stuff
        vm.droppedObjects1 = [];
        vm.onDropComplete1 = function(data,evt) {
            var index = vm.droppedObjects1.indexOf(data);
            if (index == -1) {
                vm.droppedObjects1.push(data);
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
