
window.App.directive 'amplificationChart', [
  '$window'
  '$timeout'
  ($window, $timeout) ->
    return {
      restrict: 'EA'
      replace: true
      template: '<div></div>'
      scope:
        data: '='
        config: '='
        scroll: '='
        zoom: '='
        onZoom: '&'
        show: '='
      link: ($scope, elem, attrs) ->

        chart = null

        initChart = ->
          return if !$scope.data or !$scope.config or !$scope.show
          chart = new $window.ChaiBioCharts.AmplificationChart(elem[0], $scope.data, $scope.config)
          chart.onZoomAndPan($scope.onZoom())
          d = chart.getDimensions()
          $scope.onZoom()(chart.getTransform(), d.width, d.height, chart.getScaleExtent())

        $scope.$watchCollection ($scope) ->
          return {
            data: $scope.data,
            y_axis: $scope.config?.axes?.y
            x_axis: $scope.config?.axes?.x
            series: $scope.config?.series
          }
        , (val) ->
          if !chart
            initChart()
          else
            chart.updateData($scope.data)
            chart.updateConfig($scope.config)
            console.log "show: #{$scope.show}"
            if $scope.show
              chart.setYAxis()
              chart.setXAxis()
              chart.drawLines()

        $scope.$watch 'scroll', (scroll) ->
          return if !scroll or !chart or !$scope.show
          chart.scroll(scroll)

        $scope.$watch 'zoom', (zoom) ->
          return if !zoom or !chart or !$scope.show
          chart.zoomTo(zoom)

        $scope.$watch 'show', (show) ->
          console.log 'amplificationChart: initChart'
          if !chart
            initChart()
          else
            dims = chart.getDimensions()
            if dims.width <= 0 or dims.height <= 0 or !dims.width or !dims.height
              initChart()
              
            if $scope.show
              chart.setYAxis()
              chart.setXAxis()
              chart.drawLines()


    }
]