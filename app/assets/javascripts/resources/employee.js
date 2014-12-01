schedulerApp.factory('Employee', ['$resource', '$http', function($resource, $http) {
  var Employee = $resource('/employees/:id', 
    {archived: "false", format: "json"}, 
    {
      archive: {
        method: "POST", 
        params: {}, 
        url: "/employees/:id/archive"
      }
    }
  );
  
  Employee.archive = function(id, success) {
    $http.post("/employees/" + id + "/archive").success(success);
  };
  
  Employee.prototype.archiveLabel = function() {
    return this.archived ? "Unarchive" : "Archive";
  };
  
  return Employee;
}]);