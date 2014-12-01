schedulerApp.factory('Skill', ['$resource', '$http', function($resource, $http) {
  var Skill = $resource('/skills/:id', 
    {archived: "false", format: "json"}
  );
  
  Skill.archive = function(id, success) {
    $http.post("/skills/" + id + "/archive").success(success);
  };
  
  Skill.prototype.archiveLabel = function() {
    return this.archived ? "Unarchive" : "Archive";
  };
  
  return Skill;
}]);