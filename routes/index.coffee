pg = require("pg")


exports.select = (req, res, next) ->
    if (req.query.translate)
        [x,y] = req.query.translate.split(',')
        map = {
            #  cent : 'ST_Transform(ST_Centroid(way),4326)',
            json : "ST_AsGeoJSON(ST_Translate(ST_Transform(way,4326),#{x}-ST_X(ST_Transform(ST_Centroid(way),4326)), #{y}-ST_Y(ST_Transform(ST_Centroid(way),4326))))"
            name : "name"
            centroid: "ST_AsGeoJSON(ST_Transform(ST_Centroid(way), 4326))"
            area: "ST_Area(Geography(ST_Transform(way, 4326)))"
        }
    else
        map =
          json: 'ST_AsGeoJSON(ST_Transform(way,4326))'
          name: "name"
          centroid: "ST_AsGeoJSON(ST_Transform(ST_Centroid(way), 4326))"
          area: "ST_Area(Geography(ST_Transform(way, 4326)))"

    req.sql = { select: map}
    req.sql.where = []
    next()

exports.from = (req, res, next) ->
    req.sql.from = { plygon: "planet_osm_polygon" }
    next()

exports.whereBoundary = (req, res, next) ->
    req.sql.where.push "boundary = 'administrative'"
    next()

exports.whereName =  (req, res, next) ->
    if (req.params.name)
        req.sql.where.push "name = '#{req.params.name}'"
    next()


exports.index = (req, res) ->
  res.render 'index', { title: "A map of cities" }

exports.overlay = (req, res) ->
  res.render 'overlay', { title: "Overlay to city maps" }

exports.voronoi = (req, res) ->
  res.render 'voronoi', { title: "Voronoi for pubs" }

exports.pubs = (req, res, next) ->
  req.client.query "SELECT X(ST_Transform(way, 4326)) AS x, Y(ST_Transform(way, 4326)) AS y, name FROM planet_osm_point WHERE amenity = 'pub';", (error, results) ->
    if error then next error
    else
      res.send results

exports.points = (req, res, next) ->
  req.client.query "SELECT ST_AsGeoJSON(way) FROM  planet_osm_point", (error, results) ->
    if error
      next error
    else
      res.send results


buildQuery = (map) ->
    sql = ['SELECT']
    for alias,col of map.select
        sql.push(col)
        sql.push('as')
        sql.push(alias)
        sql.push(',')
    sql.pop()

    sql.push('FROM')
    for alias,table of map.from
        sql.push(table)

    sql.push('WHERE')
    for clause in map.where
        sql.push(clause)
        sql.push('AND')
    sql.pop()

    sql.join(" ")

exports.cities = (req, res, next) ->
        queryAndWrite buildQuery(req.sql), req , res, next

queryAndWrite = (query,req,res,next) ->
    console.log query
    req.client.query query, (error, results) ->
        if error
            next error
        else
            res.send featureCollectionFromRows results.rows

featureCollectionFromRows = (rows) ->
    list = []
    for row in rows
        geoJson = JSON.parse(row.json)
        list.push(
          type: "Feature"
          geometry: geoJson
          properties:
            name: row.name
            centroid: JSON.parse(row.centroid)
            area: row.area
        )

    collection =
      type: 'FeatureCollection',
      features: list

