angular.module('schedulerApp').controller('employeeDetailController', ['$scope', '$resource', 'Employee', 'Skill', function($scope, $resource, Employee, Skill) {
  $scope.employee = {rating: 0};
  $resource(window.location.pathname).get({format: "json"}, function(e) {
    $scope.employee = e;
  });
}]);
