pg = require("pg")


polygonQuery = ->
    "SELECT ST_AsGeoJSON(way) AS json
     FROM  planet_osm_polygon
    "

citiesFilter = () ->
    "WHERE boundary = 'administrative'
    "

cityNameFilter =  (name) ->
    citiesFilter() +
    "AND name = '" + name + "'
    "

exports.index = (req, res) ->
  res.render 'index', { title: "Express" }

exports.points = (req, res, next) ->
  req.client.query "SELECT ST_AsGeoJSON(way) FROM  planet_osm_point", (error, results) ->
    if error
      next error
    else
      res.send results

exports.polygons = (req, res, next) ->
  req.client.query polygonQuery, (error, results) ->
    if error
      next error
    else
      res.send results

exports.cities = (req, res, next) ->
    if req.params.name
        queryAndWrite (polygonQuery() + cityNameFilter(req.params.name)),req , res, next
    else
        queryAndWrite (polygonQuery() + citiesFilter(req.params.name)),req , res, next

queryAndWrite = (query,req,res,next) ->
    req.client.query query, (error, results) ->
        if error
            next error
        else
            res.send featureCollectionFromRows query.rows

featureCollectionFromRows = (rows) ->
    list = []
    for row in rows
        geoJson = JSON.parse(row.json)
        list.push { type: 'Feature', geometry: geoJson }

    collection = {
        type: 'FeatureCollection',
        features: list
    }
