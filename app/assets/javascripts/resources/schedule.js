(function(angular) {
  angular.module('schedulerApp').factory('Schedule', ['$resource', '$http', '$location', function($resource, $http, $location) {
    var Schedule = $resource('/schedules/:id',
      {archived: "false", format: "json"},
      {
        getOne: { 
          method: "GET", 
          url: "/schedules/:id", 
          isArray: false, 
          transformResponse: function(data, headers) {
            var schedule = JSON.parse(data);
            schedule.time_ranges = [ new ScheduleTimeRange(moment.utc(schedule.from_time), moment.utc(schedule.to_time), null) ];
            return schedule;
          } 
        },
        getNew: { 
          method: "GET", 
          url: "/schedules/new", 
          isArray: false, 
          transformResponse: function(data, headers) {
            var schedule = JSON.parse(data);
            schedule.future_schedule_id = $location.search().future_schedule_id;
            time_range = schedule.time_ranges[0];
            schedule.time_ranges = [ new ScheduleTimeRange(moment.utc(time_range.from_time), moment.utc(time_range.to_time), moment.utc(time_range.through_date)) ];
            return schedule;
          } 
        },
        update: { method: "PUT", url: "/schedules/:id" }
      }
    );
    
    Schedule.prototype.expanded = false;
    Schedule.prototype.errors = [];
    Schedule.prototype.warnings = [];
    
    Schedule.prototype.persisted = function() {
      return ("id" in this) && !(this.id == null || this.id == "");
    };
    
    Schedule.prototype.isPendingSchedule = function() {
      return ("future_schedule_id" in this) && this.future_schedule_id != "";
    };
    
    Schedule.prototype.canExpand = function() {
      var canExpand = false;
      
      if (this.time_ranges) {
        var time_range = this.time_ranges[0];
        if (time_range && time_range.from_time && time_range.to_time && time_range.through_date) {
          if (time_range.from_time.isBefore(time_range.to_time) && time_range.from_time.isBefore(time_range.through_date)) {
            canExpand = true;
          }
        }
      }
      
      return canExpand;
    };
    
    
    
    Schedule.prototype.expandTimeRanges = function() {
      if (this.canExpand()) {
        var time_range = this.time_ranges[0];
        var new_start_time = time_range.from_time;
        var new_end_time = time_range.to_time;
        var daysToAdd = 1;
        var throughDate = time_range.through_date.clone().endOf('day');
        
        while (new_start_time.clone().add(daysToAdd, 'day').isBefore(throughDate)) {
          var scheduleTimeRange = new ScheduleTimeRange(new_start_time.clone().add(daysToAdd, 'day'), new_end_time.clone().add(daysToAdd, 'day'), null);
          this.time_ranges.push(scheduleTimeRange);
          daysToAdd += 1;
        } 
      }
      this.expanded = true;
    };
    
    Schedule.prototype.canValidateNewSchedule = function(usersSelected) {
      var canValidate = false;
      if (usersSelected.length > 0) {
        if (this.time_ranges.length == 1) {
          time_range = this.time_ranges[0];
          canValidate = time_range.getTotalHours() > 0 && time_range.through_date && time_range.through_date.clone().endOf("day").isAfter(time_range.from_time);
        } else if (this.time_ranges.length > 1) {
          var invalidRangeFound = false;
          for (i = 0; i < this.time_ranges.length; i++) {
            time_range = this.time_ranges[i];
            if ( !(time_range.from_time && time_range.to_time && time_range.from_time.isBefore(time_range.to_time)) ) {
              invalidRangeFound = true;
              break;
            }
          }
          canValidate = !invalidRangeFound;
        }
      }
      
      return canValidate;
    };
    
    Schedule.prototype.validateNewSchedule = function(schedule, usersSelected) {
      schedule.errors = [];
      schedule.warnings = [];
      
      if (this.canValidateNewSchedule(usersSelected)) {
        $http.post("/schedules/schedule_conflicts.json", {
          schedule: JSON.stringify(schedule), 
          users_selected: JSON.stringify(usersSelected)
        }).success(function(response, status) {
          schedule.errors = response.errors;
          schedule.warnings = response.warnings;
        });
      }
    };
    
    Schedule.prototype.createSchedule = function($scope) {
      if (!$scope.schedule.persisted()) {
        $http.post("/schedules/create_schedule.json", {
          schedule: JSON.stringify($scope.schedule),
          users_selected: JSON.stringify($scope.usersSelected)
        }).success(function(response, status, headers) {
          if (status == 200) {
            if ($scope.returnPath) {
              window.location.href = $scope.returnPath;
            } else {
              window.location.pathname = "/schedules";
            }
          } else {
            $scope.disableSubmitButtons = false;
          }
        }).error(function(response, status, headers) {
          if ("errors" in response) {
            $scope.schedule.errors = response.errors;
          }
          
          $scope.disableSubmitButtons = false;
        });
      }
    };
    
    Schedule.prototype.updateSchedule = function($scope) {
      if ($scope.schedule.persisted()) {
        $http.post("/schedules/update_schedule.json", {
          schedule: JSON.stringify($scope.schedule),
          users_selected: JSON.stringify($scope.usersSelected)
        }).success(function(response, status, headers) {
          if (status == 200) {
            if ($scope.returnPath) {
              window.location.href = $scope.returnPath;
            } else {
              window.location.pathname = "/schedules";
            }
          } else {
            $scope.disableSubmitButtons = false;
          }
        }).error(function(response, status, headers) {
          if ("errors" in response) {
            $scope.schedule.errors = response.errors;
          }
          
          $scope.disableSubmitButtons = false;
        });
      }
    };
    
    Schedule.prototype.createPendingSchedule = function($scope) {
      if (!$scope.schedule.persisted()) {
        $http.post("/schedules/create_pending_schedule.json", {
          schedule: JSON.stringify($scope.schedule)
        }).success(function(response, status, headers) {
          if (status == 200) {
            if ($scope.returnPath) {
              window.location.href = $scope.returnPath;
            } else {
              window.location.pathname = "/schedules";
            }
          } else {
            $scope.disableSubmitButtons = false;
          }
        }).error(function(response, status, headers) {
          if ("errors" in response) {
            $scope.schedule.errors = response.errors;
          }
          $scope.disableSubmitButtons = false;
        });
      }
    };
    
    Schedule.prototype.updatePendingSchedule = function($scope) {
      $http.post("/schedules/update_pending_schedule.json", {
        schedule: JSON.stringify($scope.schedule)
      }).success(function(response, status, headers) {
        if (status == 200) {
          if ($scope.returnPath) {
            window.location.href = $scope.returnPath;
          } else {
            window.location.pathname = "/schedules";
          }
        } else {
          $scope.disableSubmitButtons = false;
        }
      }).error(function(response, status, headers) {
          if ("errors" in response) {
            $scope.schedule.errors = response.errors;
          }
          $scope.disableSubmitButtons = false;
      });
    };
    
    Schedule.prototype.deletePendingSchedule = function($scope) {
      $http.post("/schedules/delete_pending_schedule.json", {
        schedule: JSON.stringify($scope.schedule)
      }).success(function(response, status, headers) {
        if (status == 200) {
          if ($scope.returnPath) {
            window.location.href = $scope.returnPath;
          } else {
            window.location.pathname = "/schedules";
          }
        } else {
          $scope.disableSubmitButtons = false;
        }
      });
    };
    
    return Schedule;
  }]);
})(window.angular);