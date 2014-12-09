(function(angular) {
  angular.module('schedulerApp').directive('starRating', function() {
    return {
      restrict : 'A',
      template : "<ul class='rating'>" +
                     "  <li ng-repeat='star in stars' ng-class='star' ng-click='toggle($index)'>" +
                     "    <i class='fa fa-star'></i>" + //&#9733
                     "  </li>" +
                     "</ul>",
      scope : {
        ratable : '=',
        max : '=',
        onRatingSelected : '&'
      },
    
      link : function(scope, elem, attrs) {
        var updateStars = function() {
          scope.stars = [];
          for ( var i = 0; i < scope.max; i++) {
            scope.stars.push({
              filled : i < scope.ratable.rating
            });
          }
        };
      
        scope.toggle = function(index) {
          if (scope.ratable.rating != index + 1) {
            scope.ratable.onRatingSelected(index + 1);
          }
        };
      
        updateStars();
        scope.$watch('ratable.rating', function(oldVal, newVal) {
          if (oldVal != newVal) {
            updateStars();
          }
        });
      }
    };
  });
})(window.angular);