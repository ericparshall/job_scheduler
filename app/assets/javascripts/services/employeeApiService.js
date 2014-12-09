(function(angular) {
  angular.module('schedulerApp').
  factory('employeeApiService', ["$http", "$log", function($http, $log) {
    var employeeApiService = {};
    employeeApiService.getEmployees = function(archived) {
      var resp = $http({
        method: 'GET', 
        url: '/employees.json?archived=' + archived
      });
      $log.log(resp);
      return resp;
    }

    return employeeApiService;
  }]);
})(window.angular);