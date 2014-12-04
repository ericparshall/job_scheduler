schedulerApp.factory('Employee', ['$resource', '$http', function($resource, $http) {
  var Employee = $resource('/employees/:id', 
    {archived: "false", format: "json"}, 
    {
      update: { method: "PUT", url: "/employees/:id" },
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
  
  Employee.prototype.onRatingSelected = function(newRating) {
    this.$update({ id: this.id, "user[rating]" : newRating }, function(employee) {
      employee.rating = newRating;
    });
  };
  
  return Employee;
}]);