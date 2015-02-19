(function(angular) {
    angular.module("schedulerApp").controller('jobsController', ['$scope', 'Job', 'Customer', function($scope, Job, Customer) {
        $scope.queryParams = {
            archived: "false"
        };
        $scope.orderField = "name";
        $scope.defaultTabStyle = "active";
        $scope.archivedTabStyle = "";
        $scope.customers = Customer.query();

        $scope.onCustomerSelected = function(customer) {
            $scope.queryParams.customer_id = customer.id;
            $scope.refreshJobs();
        };
        
        $scope.resetFilter = function() {
            delete $scope.queryParams.customer_id;
            $scope.customer = null;
            $scope.refreshJobs();
        };

        $scope.refreshJobs = function() {
            $scope.jobs = Job.query($scope.queryParams);
        };
        $scope.refreshJobs();

        $scope.toggleSort = function(sortBy) {
            if ($scope.orderField != sortBy) {
                $scope.orderField = sortBy;
            } else {
                $scope.orderField = "-" + sortBy;
            }
        };

        $scope.archiveJob = function(job) {
            var index = jQuery.inArray(job, $scope.jobs);
            if (index > -1) {
                Job.archive(job.id, function(success) {
                    job.archived = !job.archived;
                    $scope.jobs.splice(index, 1);
                });
            }
        };

        $scope.archivedTabClick = function() {
            $scope.queryParams.archived = "true";
            $scope.defaultTabStyle = "";
            $scope.archivedTabStyle = "active";
            $scope.refreshJobs();
        };

        $scope.defaultTabClick = function() {
            $scope.queryParams.archived = "false";
            $scope.defaultTabStyle = "active";
            $scope.archivedTabStyle = "";
            $scope.refreshJobs();
        };
    }]);
})(window.angular);