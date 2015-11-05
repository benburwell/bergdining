Hapi = require 'hapi'
request = require 'request'
xmlparser = require './src/xmlparser'

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
      menu = xmlparser.processXML(body)
      if req.query.location
        menu = (location for location in menu.locations when location.name is req.query.location)[0] or {}
      reply(menu).type('application/json').header('Access-Control-Allow-Origin', '*')

setInterval ->
  request 'http://bergdining.herokuapp.com/', (err, res, body) ->
    console.log 'ping'
, 1000*60*45
