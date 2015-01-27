(function(angular) {
  angular.module('schedulerApp').factory('PathUtils', function() {
    return {
      parseId : function(pattern, index) {
        var matches = pattern.exec(window.location.pathname);
        if (matches != null && matches.length > 1) {
          return matches[index];
        } else {
          return null;
        }
      }
    };
  });
})(window.angular);