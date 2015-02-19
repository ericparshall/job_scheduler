(function(angular) {
  angular.module("schedulerApp").controller('employeesController', ['$scope', 'Employee', 'Skill', function($scope, Employee, Skill) {
    $scope.queryParams = {
      archived: "false",
      skill_list: ""
    };
    $scope.orderField = "full_name";
    $scope.selectedSkills = [];
    $scope.defaultTabStyle = "active";
    $scope.archivedTabStyle = "";
    $scope.skills = Skill.query();
  
    $scope.refreshEmployees = function() {
      $scope.employees = Employee.query($scope.queryParams);
    };
    $scope.refreshEmployees();
  
    $scope.toggleSort = function(sortBy) {
      if ($scope.orderField != sortBy) {
        $scope.orderField = sortBy;
      } else {
        $scope.orderField = "-" + sortBy;
      }
    };
  
    $scope.archiveEmployee = function(employee) {
      var index = jQuery.inArray(employee, $scope.employees);
        if (index > -1) {
            Employee.archive(employee.id, function(success) {
                employee.archived = !employee.archived;
                $scope.employees.splice(index, 1);
            });
        }
    };

    $scope.archivedTabClick = function() {
      $scope.queryParams.archived = "true";
      $scope.defaultTabStyle = "";
      $scope.archivedTabStyle = "active";
      $scope.refreshEmployees();
    };

    $scope.defaultTabClick = function() {
      $scope.queryParams.archived = "false";
      $scope.defaultTabStyle = "active";
      $scope.archivedTabStyle = "";
      $scope.refreshEmployees();
    };
  
    $scope.updateQuerySkillList = function() {
      var skillList = new Array;
      for (i = 0; i < $scope.selectedSkills.length; i++) {
        skillList.push($scope.selectedSkills[i].id);
      }
      $scope.queryParams.skill_list = skillList.join(",")
    };
  
    $scope.addSkillFilter = function(option) {
      $scope.selectedSkills.push(
        $scope.skills.splice(option.dataset.index, 1)[0]
      );
      $scope.updateQuerySkillList();
      $scope.refreshEmployees();
    };
  
    $scope.removeSkillFilter = function(index) {
      $scope.skills.push(
        $scope.selectedSkills.splice(index, 1)[0]
      );
      $scope.updateQuerySkillList();
      $scope.refreshEmployees();
    };
  
    $( "#skill_id" ).combobox({
      list: $( "#skill_id" ),
      parent_div: $("#skill_id_input_group"),
      input: $("#skill_id_input"),
      custom_on_select: $scope.addSkillFilter
    });
  }]);
})(window.angular);