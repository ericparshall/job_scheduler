angular.module('schedulerApp.services', []).
factory('employeeApiService', function($http, $log) {
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
});