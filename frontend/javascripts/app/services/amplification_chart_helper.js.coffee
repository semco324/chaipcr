###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp.service 'AmplificationChartHelper', [
  'SecondsDisplay'
  '$filter'
  'Experiment'
  (SecondsDisplay, $filter, Experiment) ->

   # FLOOR_VALUE = 500

    @chartConfig = ->
      axes:
        x:
          min: 1
          key: 'cycle_num'
          ticks: 8
          tickFormat: (x) ->
            return parseInt(x)
        y:
          ticks: 10

      margin:
        top: 10
        left: 80
        right: 5
      grid:
        x: false
        y: false

      series: []

      tooltipHook: (items) ->
        return false

    # end chartConfig


    @neutralizeData = (amplification_data, is_dual_channel=false) ->
      amplification_data = angular.copy amplification_data
      channel_datasets = {}
      channels_count = if is_dual_channel then 2 else 1
      neutralized_baseline_data = []
      neutralized_background_data = []

      # get max cycle
      max_cycle = 0
      for datum in amplification_data by 1
        max_cycle = if datum[2] > max_cycle then datum[2] else max_cycle

      for channel_i in [1..channels_count] by 1
        dataset_name = "channel_#{channel_i}"
        channel_datasets[dataset_name] = []
        channel_data = _.filter amplification_data, (datum) ->
          datum[0] is channel_i
        for cycle_i in [1..max_cycle] by 1
          data_by_cycle = _.filter channel_data, (datum) ->
            datum[2] is cycle_i
          data_by_cycle = _.sortBy data_by_cycle, (d) ->
            d[1]
          channel_datasets[dataset_name].push data_by_cycle

        channel_datasets[dataset_name] = _.map channel_datasets[dataset_name], (datum) ->
          pt = cycle_num: datum[0][2]
          for y_item, i in datum by 1
            pt["well_#{i}_background"] = y_item[3]
            pt["well_#{i}_baseline"] =  y_item[4]
            pt["well_#{i}_background_log"] = if y_item[3] > 0 then y_item[3] else 0.01
            pt["well_#{i}_baseline_log"] =  if y_item[4] > 0 then y_item[4] else 0.01

          return pt

      return channel_datasets

    @paddData = (cycle_num = 1) ->
      paddData = cycle_num: cycle_num
      for i in [0..15] by 1
        paddData["well_#{i}_baseline"] = 0
        paddData["well_#{i}_background"] = 0

      channel_1: [paddData]
      channel_2: [paddData]

    @getMaxExperimentCycle = Experiment.getMaxExperimentCycle

    @getMaxCalibrations = (amplification_data) ->
      calibs_baseline = []
      calibs_baseline = _.map amplification_data, (datum) ->
        datum[4]
      calibs_background = _.map amplification_data, (datum) ->
        datum[3]

      return {
        baseline: (Math.max.apply Math, calibs_baseline)
        background: (Math.max.apply Math, calibs_background)
      }

    @toScientificNotation = (val, i) ->
      base = 0
      pow = 0
      val_string = val.toString()
      num = null
      if val*1 < 1
        val_spliced = val_string.split('.')
        num = val_spliced[1]
        num_length = num.length

        for i in [0...num_length] by 1
          n = num.charAt(i) * 1
          if n > 0
            base = n
            pow = -1 * (i + 1)
            break
        return base + 'x10^' + pow
      else
        num_length = val_string.length
        for i in [0...num_length] by 1
          n = val_string.charAt(i) * 1
          if n > 0
            base = n
            pow = num_length - (i + 1)
            break
        return base + 'x10^' + pow
      return


    @getLogViewYticks = (num) ->
      num_length = num.toString().length
      roundup = '1'
      for i in [0...num_length] by 1
        roundup = "#{roundup}0"

      roundup = roundup*1

      calibs = []
      calib = 0.01

      while calib <= roundup
        calibs.push calib
        calib = calib*10

      return calibs

    # @getMaxCycleFromAmplification = (amplification_data) ->
    #   cycles = []
    #   for datum in [0...amplification_data.length] by 1
    #     cycles.push parseInt(datum[2])

    #   return Math.max.apply Math, cycles

    @Xticks = (min, max)->
      num_ticks = 10
      ticks = []
      if max - min < num_ticks
        for i in [min..max] by 1
          ticks.push i
      else
        chunkSize = Math.floor((max-min)/num_ticks)
        for i in [min..max] by chunkSize
          ticks.push i
        ticks.push max if max % num_ticks isnt 0

      return ticks

    # @Yticks = (max) ->
    #   ticks = []
    #   num_ticks = 10
    #   denom = max/num_ticks
    #   for i in [0..10]
    #     ticks.push i*denom
    #   return ticks

    @COLORS = [
        '#04A0D9'
        '#1578BE'
        '#2455A8'
        '#3B2F90'
        '#73258C'
        '#B01C8B'
        '#FA1284'
        '#FF004E'
        '#EA244E'
        '#FA3C00'
        '#EF632A'
        '#F5AF13'
        '#FBDE26'
        '#B6D333'
        '#67BC42'
        '#13A350'
      ]

    @moveData = (data, zoom, scroll, max_cycle) ->
      data = angular.copy data
      scroll = if scroll < 0 then 0 else scroll
      scroll = if scroll > 1 then 1 else scroll
      scroll = if scroll is 'FULL' then 0 else scroll

      if zoom is max_cycle
        cycle_start = 1
        cycle_end = angular.copy max_cycle

      else
        cycle_start = Math.floor(scroll * (max_cycle - zoom) ) + 1
        cycle_end = cycle_start + zoom - 1

      min_cycle: cycle_start
      max_cycle: cycle_end
      amplification_data: data

    return
]