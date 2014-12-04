schedulerApp.controller('employeeDetailController', ['$scope', 'Employee', 'Skill', function($scope, Employee, Skill) {
  $scope.employee = {rating: 0};
  Employee.get({id: '5'}, function(e) {
    console.log(e);
    $scope.employee = e;
  });
}]);
