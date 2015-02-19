(function(angular) {
    angular.module('schedulerApp').factory('Customer', ['$resource', '$http', function($resource, $http) {
        var Customer = $resource('/customers',
            {archived: "false", format: "json"},
            {
                getOne: { method: "GET", url: "/customers/:id", isArray: false },
                update: { method: "PUT", url: "/customers/:id" },
                archive: {
                    method: "POST",
                    params: {},
                    url: "/customers/:id/archive"
                }
            }
        );

        Customer.archive = function(id, success) {
            $http.post("/customers/" + id + "/archive").success(success);
        };

        Customer.prototype.archiveLabel = function() {
            return this.archived ? "Unarchive" : "Archive";
        };

        return Customer;
    }]);
})(window.angular);