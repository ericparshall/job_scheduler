angular.module("schedulerApp").controller("EmployeeSearchCtrl", ["$scope", "$modalInstance", "Skill", "schedule", function($scope, $modalInstance, Skill, schedule) {
    $scope.schedule = schedule;
    $scope.orderField = "full_name";
    $scope.selectedUsers = [];
    $scope.availableUsers = [];
    $scope.addUser = function(user, user_skill) {
        if (user_skill != null) {
            user.user_label = user.full_name + " (" + user_skill + ")";
        } else {
            user.user_label = user.full_name;
        }

        if ($.inArray(user, $scope.selectedUsers) < 0) {
            $scope.selectedUsers.push(user);
        }
    }
    $scope.removeUser = function(index) {
        $scope.selectedUsers.splice(index, 1);
    };

    $scope.skills = Skill.query();
    $scope.selectedSkill = null;
    $scope.selectedSkills = [];

    $scope.addSkillFilter = function() {
        if ($scope.selectedSkill != null && $.inArray($scope.selectedSkill, $scope.selectedSkills) < 0) {
            $scope.selectedSkills.push($scope.selectedSkill);
        }
    };
    $scope.removeSkillFilter = function(index) {
        $scope.selectedSkills.splice(index, 1)[0]
    };

    schedule.getAvailableUsers($scope);

    $scope.toggleSort = function(sortBy) {
        if ($scope.orderField != sortBy) {
            $scope.orderField = sortBy;
        } else {
            $scope.orderField = "-" + sortBy;
        }
    };

    $scope.filterUsers = function(user) {
        if ($scope.selectedSkills.length > 0) {
            if ('skills_list' in user) {
                for (var i = 0; i < $scope.selectedSkills.length; i++) {
                    var skill = $scope.selectedSkills[i];
                    for (var j = 0; j < user.skills_list.length; j++) {
                        if (skill.name == user.skills_list[j]) {
                            return true;
                        }
                    }
                }
            }

            return false;
        } else {
            return true;
        }
    };

    $scope.ok = function () {
        $modalInstance.close($scope.selectedUsers);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
}]);


angular.module("schedulerApp").controller('scheduleEditController', ['$scope', '$location', 'Employee', 'Job', 'Schedule', 'PathUtils', '$modal', '$log', function($scope, $location, Employee, Job, Schedule, PathUtils, $modal, $log) {

    $scope.openEmployeeSearch = function () {

        var modalInstance = $modal.open({
            templateUrl: 'advEmployeeSearch.html',
            controller: 'EmployeeSearchCtrl',
            size: 'lg',
            resolve: {
                schedule: function() {
                    return $scope.schedule;
                }
            }
        });

        modalInstance.result.then(function (selectedUsers) {
            for (var i = 0; i < selectedUsers.length; i++) {
                var selectedUser = selectedUsers[i];
                for (var j = 0; j < $scope.users.length; j++) {
                    var user = $scope.users[j];
                    if (user.id == selectedUser.id) {
                        if ($.inArray(user, $scope.usersSelected) < 0) {
                            $scope.usersSelected.push(user);
                        }
                    }
                }
            }
        }, function () {
            $log.info('Modal dismissed at: ' + new Date());
        });
    };

  $scope.scheduleId = PathUtils.parseId(/\/schedules\/(\d+)\/edit.*/, 1);
  if ($location.search().return_path != null) {
    $scope.returnPath = decodeURIComponent($location.search().return_path);
  }
  
  $scope.usersSelected = [];
  $scope.disableSubmitButtons = false;
  
  $scope.onUserSelected = function(user) {
    if ($.inArray(user, $scope.usersSelected) < 0) {
      $scope.usersSelected.push(user);
    }
  };
  $scope.removeSelectedUser = function(user) {
    var index = $.inArray(user, $scope.usersSelected);
    if (index > -1) {
      $scope.usersSelected.splice(index, 1)
    }
  };
  $scope.saveSchedule = function() {
    $scope.disableSubmitButtons = true;
    if ($scope.schedule.persisted() != true) {
      $scope.schedule.createSchedule($scope);
    } else {
      $scope.schedule.updateSchedule($scope);
    }
  };
  $scope.createPendingSchedule = function() {
    if ($scope.schedule.persisted() != true) {
      $scope.disableSubmitButtons = true;
      $scope.schedule.createPendingSchedule($scope);
    }
  };
  $scope.updatePendingSchedule = function() {
    if ($scope.schedule.isPendingSchedule()) {
      $scope.disableSubmitButtons = true;
      $scope.schedule.updatePendingSchedule($scope);
    }
  };
  $scope.deletePendingSchedule = function() {
    if ($scope.schedule.isPendingSchedule()) {
      $scope.disableSubmitButtons = true;
      $scope.schedule.deletePendingSchedule($scope);
    }
  };
  
  if ($scope.scheduleId) {
    $scope.schedule = Schedule.getOne({id: $scope.scheduleId});
  } else if ($location.search().future_schedule_id != null) {
    $scope.schedule = Schedule.getNew($location.search());
  } else {
    var throughDate = null;

    if ($location.search().for_date) {
      throughDate = moment.utc(parseInt($location.search().for_date));
    }
    $scope.schedule = new Schedule();
    $scope.schedule.$resolved = true;
    $scope.schedule.job = {name: ""};
    $scope.schedule.user = {full_name: ""};
    $scope.schedule.time_ranges = [ new ScheduleTimeRange(null, null, throughDate) ]
    
    if ($location.search().employee_id) {
      $scope.schedule.user.id = parseInt($location.search().employee_id);
    }
    if ($location.search().future_schedule_id) {
      $scope.schedule.future_schedule_id = parseInt($location.search().future_schedule_id);
    }
  }
  
  $scope.jobs = Job.query(function(jobs) {
    if (("job" in $scope.schedule) && ("id" in $scope.schedule.job) && $scope.schedule.job.id != "") {
      for (i = 0; i < jobs.length; i++) {
        var job = jobs[i];
        if (job.id == $scope.schedule.job.id) {
          $scope.schedule.job = job;
          break;
        }
      }
    }
  });
  
  $scope.users = Employee.query(function(users) {
    if (("user" in $scope.schedule) && ("id" in $scope.schedule.user) && $scope.schedule.user.id != "") {
      for (i = 0; i < users.length; i++) {
        var user = users[i];
        if (user.id == $scope.schedule.user.id) {
          $scope.schedule.user = user;
          if (!$scope.schedule.persisted) {
            $scope.usersSelected.push(user);
          }
          break;
        } 
      }
    }
  });

  $scope.$watch("usersSelected", function(newValue) {
    $scope.schedule.validateNewSchedule($scope.schedule, $scope.usersSelected)
  }, true);
}]);