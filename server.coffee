Hapi = require 'hapi'
request = require 'request'
x2j = require 'xml2json'

processLocation = (location) ->
  ret = {}
  ret.name = location.title
  ret.days = (processDay(day) for day in [].concat(location.menu.day)) if location.menu.day
  ret.stations = (processStation(station) for station in [].concat(location.menu.station)) if location.menu.station
  ret.items = (processItem(item) for item in [].concat(location.menu.item)) if location.menu.item
  ret


processPeriod = (period) ->
  ret = {}
  ret.name = period.title
  ret.stations = (processStation(station) for station in [].concat(period.station))
  ret

processDay = (day) ->
  ret = {}
  ret.date = day.datelong
  ret.periods = (processPeriod(period) for period in [].concat(day.period))
  ret

processStation = (station) ->
  ret = {}
  ret.name = station.title
  ret.items = (processItem(item) for item in [].concat(station.item))
  ret

processItem = (item) ->
  item.title

processXML = (xml) ->
  obj = JSON.parse x2j.toJson(xml)
  ret = {}
  ret.locations = (processLocation(location) for location in [].concat(obj.dining.locations.location))
  ret

server = new Hapi.Server()

server.connection
  port: process.env.PORT || 3000

server.start ->
  console.log 'Server running at', server.info.uri

server.route
  method: 'GET'
  path: '/menu.json'
  handler: (req, reply) ->
    request 'http://software.mogistic.com/muhlenberg/dining/muhlenberg_dining.xml', (err, res, body) ->
      menu = processXML(body)
      if req.query.location
        menu = (location for location in menu.locations when location.name is req.query.location)[0] or {}
      reply(menu).type('application/json').header('Access-Control-Allow-Origin', '*')

setInterval ->
  request 'http://bergdining.herokuapp.com/', (err, res, body) ->
    console.log 'ping'
, 1000*60*45
