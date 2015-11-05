moment = require 'moment'
x2j = require 'xml2json'

processLocation = (location) ->
  ret =
    name: location.title
    days: (processDay(day) for day in [].concat(location.menu.day)) if location.menu.day
    stations: (processStation(station) for station in [].concat(location.menu.station)) if location.menu.station
    items: (processItem(item) for item in [].concat(location.menu.item)) if location.menu.item
  ret

processPeriod = (period) ->
  ret =
    name: period.title
    stations: (processStation(station) for station in [].concat(period.station))
  ret

processDay = (day) ->
  # convert the date string to a Moment with the correct format string
  # Dates from the XML look like: Monday - January 1, 2000
  date = moment day.datelong, 'dddd - MMMM D, YYYY'
  ret =
    weekday_short: date.format 'ddd'
    weekday_long: date.format 'dddd'
    date_long: date.format 'dddd MMMM Do'
    day_of_year: date.format 'DDD'
    iso_date: date.toISOString()
    periods: (processPeriod(period) for period in [].concat(day.period))
  ret

processStation = (station) ->
  ret =
    name: station.title
    items: (processItem(item) for item in [].concat(station.item))
  ret

processItem = (item) ->
  item.title

processXML = (xml) ->
  obj = JSON.parse x2j.toJson(xml)
  ret =
    locations: (processLocation(location) for location in [].concat(obj.dining.locations.location))
  ret

module.exports.processLocation = processLocation
module.exports.processPeriod = processPeriod
module.exports.processDay = processDay
module.exports.processStation = processStation
module.exports.processItem = processItem
module.exports.processXML = processXML
