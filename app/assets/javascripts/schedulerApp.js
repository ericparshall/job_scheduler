var schedulerApp = angular.module('schedulerApp', ['ngResource', 'ngSanitize', 'ui.date', 'angucomplete', 'ui.bootstrap', 'ui.bootstrap.datetimepicker'], ["$compileProvider", function($compileProvider) {

  // configure new 'compile' directive by passing a directive
  // factory function. The factory function injects the '$compile'
  $compileProvider.directive('compile', ["$compile", function($compile) {
    // directive factory creates a link function
    return function(scope, element, attrs) {
      scope.$watch(
        function(scope) {
           // watch the 'compile' expression for changes
          return scope.$eval(attrs.compile);
        },
        function(value) {
          // when the 'compile' expression changes
          // assign it into the current DOM
          element.html(value);

          // compile the new DOM and link it to the current
          // scope.
          // NOTE: we only compile .childNodes so that
          // we don't get into infinite loop compiling ourselves
          $compile(element.contents())(scope);
        }
      );
    };
  }]);
}]).config(["$httpProvider", function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = angular.element(document.querySelector('meta[name=csrf-token]')).attr('content');
  }
]).config(["$locationProvider", function($locationProvider) {
  $locationProvider.html5Mode({
    enabled: true,
    requireBase: false
  });
}]);