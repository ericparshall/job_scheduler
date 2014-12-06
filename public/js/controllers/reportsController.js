schedulerApp.controller('reportsController', ['$scope', '$http', '$compile', '$filter', function($scope, $http, $compile, $filter) {
  $scope.report = {
    selectedReport: "Select Report...",
    paramsHtml: "",
    results: null
  };
  
  $scope.toggleSort = function(sortBy) {
    if ($scope.report.sortBy != sortBy) {
      $scope.report.sortBy = sortBy;
    } else {
      $scope.report.sortBy = "-" + sortBy;
    }
  };
  
  $scope.employeesScheduledUnscheduled = function() {
    $scope.report.dateOptions = { changeYear: true, changeMonth: true, yearRange: '2013:-0' };
    $scope.report.queryParams = { format: "json", fromDate: null, toDate: null };
    $scope.report.selectedReport = "Employees Scheduled/Unscheduled";
    $scope.report.results = null;
    $scope.report.sortBy = 'full_name';
    $scope.report.hasLink = true;
    $scope.report.fields = [
      "full_name",
      "email",
      "rating",
      "manager_name",
      "user_type_name",
      "scheduled"
    ];
    $http.get("/reports/employeesScheduledUnscheduledParams").success(function (data, status) {
      $scope.report.paramsHtml = data;
    });
    
    $scope.report.runReport = function() {
      $http({
        method: 'GET',
        url: '/reports/employees_scheduled_unschedule', 
        params: $scope.report.queryParams
      }).success(function (data, status) {
        $scope.report.results = data;
      });
    };
  };
  
  
  $scope.employeesScheduledForTheWeek = function() {
    $scope.report.weeks = [];
    $http.get("/reports/weeks_by_beginning.json").success(function (data, status) {
      $scope.report.weeks = data;
      $scope.report.queryParams.selectedWeek = $scope.report.weeks[55];
    });
    
    $scope.report.queryParams = { format: "json" };

    $scope.report.selectedReport = "Scheduled for the Week";
    $scope.report.results = null;
    $scope.report.sortBy = 'employee_name';
    $scope.report.hasLink = true;
    $scope.report.fields = [
      "employee_name",
      "job_name",
      "customer_name",
      "from_time",
      "to_time"
    ];
    $http.get("/reports/employeesScheduledForTheWeekParams").success(function (data, status) {
      $scope.report.paramsHtml = data;
    });
    
    $scope.report.runReport = function() {
      var index = $scope.report.queryParams.selectedWeek;
      $scope.report.queryParams.selectedWeek = $scope.report.weeks[index];
      $http({
        method: 'GET',
        url: '/reports/scheduled_for_the_week', 
        params: $scope.report.queryParams
      }).success(function (data, status) {
        $scope.report.results = data;
        
        for (var i = 0; i < $scope.report.results.records.length; i++) {
          var record = $scope.report.results.records[i];
          record.from_time = $filter('date')(record.from_time, "yyyy-MM-dd h:mm a", "UTC");
          record.to_time = $filter('date')(record.to_time, "yyyy-MM-dd h:mm a", "UTC");
        }
      });
      $scope.report.queryParams.selectedWeek = index;
    };
  };
}]);