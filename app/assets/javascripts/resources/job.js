(function (angular) {
    angular.module('schedulerApp').factory('Job', ['$resource', '$http', function ($resource, $http) {
        var Job = $resource('/jobs/:id',
            {archived: "false", format: "json"},
            {
                getOne: {method: "GET", url: "/jobs/:id", isArray: false},
                update: {method: "PUT", url: "/jobs/:id"},
                archive: {
                    method: "POST",
                    params: {},
                    url: "/jobs/:id/archive"
                }
            }
        );
        Job.prototype.label = function () {
            var label = this.customer == null ? "" : this.customer.name + ": ";
            label += this.name;
            return label;
        };

        Job.archive = function (id, success) {
            $http.post("/jobs/" + id + "/archive").success(success);
        };

        Job.prototype.archiveLabel = function() {
            return this.archived ? "Unarchive" : "Archive";
        };

        return Job;
    }]);
})(window.angular);
