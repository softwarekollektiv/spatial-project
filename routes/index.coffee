pg = require("pg")
rel = require("rel")

exports.index = (req, res) ->
  res.render 'index', { title: "Express" }


points = new rel.Table "planet_osm_point"

polygons = new rel.Table "planet_osm_polygon"

exports.points = (req, res, next) ->
  pointQuery = points.project rel.star()
  if req.params.id?
    pointQuery.where (points.column "osm_id").eq parseInt req.params.id

  req.client.query pointQuery.toSql(), (error, results) ->
    if error
      next error
    else
      res.send results

exports.polygons = (req, res, next) ->
  polygonsQuery = polygons.project (polygons.column "way").asGeoJSON()
  if req.params.id?
    polygonsQuery.where (polygons.column "osm_id").eq(parseInt req.params.id)

  console.log polygonsQuery.toSql()
  req.client.query polygonsQuery.toSql(), (error, results) ->
    if error
      next error
    else
      res.send results

