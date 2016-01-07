# software update modal controller

window.App.controller 'SoftwareUpdateCtrl', [
  '$scope'
  '$uibModal'
  '$uibModalInstance'
  'Device'
  '$window'
  '$state'
  ($scope, $uibModal, $uibModalInstance, Device, $window, $state) ->

    # $scope.update = {'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}
    $scope.content = 'checking_for_updates'
    updatePromise = null

    checkForUpdatePromise = Device.checkForUpdate()

    checkForUpdatePromise.then (resp) ->
      $scope.content = 'update_available'
      $scope.new_update = resp.data.upgrade

    checkForUpdatePromise.catch ->
      cloudCheckPromise = Device.checkCloudUpdate()
      cloudCheckPromise.then (resp) ->
        console.log resp
        cloudInfo = resp.data
        devideCheckPromise = Device.getVersion()
        devideCheckPromise.then (device) ->
          if cloudInfo.software_version isnt device.software.version
            $scope.content = 'update_available'
            $scope.new_update =
              is_offline: true
              image_url: cloudInfo.image_url
              brief_description: cloudInfo.brief_description
              full_description: cloudInfo.full_description
              release_date: cloudInfo.release_date
              version: cloudInfo.software_version

          else
            $scope.content = 'update_unavailable'

        devideCheckPromise.catch (err) ->
          $scope.content = 'unable_to_update'

      cloudCheckPromise.catch (resp) ->
        console.log resp
        $window.alert('Unable to check for updates!');
        $uibModalInstance.dismiss()

    $scope.doUpdate = ->
      $scope.content = 'update_in_progress'

      updatePromise = Device.updateSoftware()

      updatePromise.then ->
        $scope.data.updating = 'complete'

      updatePromise.catch ->
        $scope.data.updating = 'failed'

    $scope.downloadUpdate = ->
      $state.go 'upload-image'
      $window.open("ftp://#{$scope.new_update.image_url}", '_blank')
      $uibModalInstance.dismiss()

]