(function(angular) {
  'use strict';
  angular.module('schedulerApp').controller('employeeDetailController', ['$scope', 'Employee', '$location', function($scope, Employee) {
    var pathSegments = window.location.pathname.split("/");
    var index = pathSegments.length;
    var employeeId;
    for (var i = index - 1; i > 0; i--) {
      if (pathSegments[i] != null && pathSegments[i] != "") {
        employeeId = pathSegments[i];
        break;
      }
    }
    $scope.employee = Employee.getOne({id: employeeId});
  }]);
})(window.angular);