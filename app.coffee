#!/usr/bin/env coffee

express = require "express"
routes = require "./routes"
pg = require "pg"

settings = require "./settings"

connectionString = ->
  "pg://#{settings.POSTGRES_USER}:#{settings.POSTGRES_PASSWORD}@#{settings.POSTGRES_HOST}:#{settings.POSTGRES_PORT}/#{settings.POSTGRES_DB}"

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()


getPgClient = (req, res, next) ->
  pg.connect connectionString(), (error, client) ->
    req.client = client
    next error


app.get "/", routes.index

app.get "/api/points", getPgClient, routes.points

app.get "/api/points/:id", getPgClient, routes.points

app.get "/api/cities", getPgClient, routes.cities
app.get "/api/cities/:name", getPgClient, routes.cities

app.get "/api/ways", routes.ways

app.get "/api/ways/:id", routes.ways

app.get "/api/polygons", getPgClient, routes.polygons

app.get "/api/polygons/:id", getPgClient, routes.polygons

app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
