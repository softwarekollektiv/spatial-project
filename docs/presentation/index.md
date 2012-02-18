# Spatial project

---
# Requirements

* overlay of city maps
* based on osm data
* stored in PostGIS

---
# Procedure

* fetch osm data
* extract city maps
* convert data to PostGIS
* compute centroid and contour
* overlay maps

---
# Let's get coding done


---
# Part 1

* **fetch osm data**
* extract city maps
* convert data to PostGIS
* compute centroid and contour
* overlay maps

---
# Choice: OSM data formats

* OMS-XML
    * gzip
    * xml
* PBF
    * binary ( [googles protocoll buffer](https://code.google.com/p/protobuf/) )
    * streamable
* o5m
    * binary ( also protobuf)
    * but different structure

---
# Elementary Objects

* nodes
    * corrdinates
    * decriptive attributes
* ways
    * list of nodes
    * decriptive attributes
* ( polygons )
    * represented as closed ways
* relations
    * ordered set of nodes and points
    * decriptive attributes


## &rArr; spagetti model

---
# Part 2:

* fetch osm data
* **extract city maps**
* convert data to PostGIS
* compute centroid and contour
* overlay maps
---
# Extractotron

* toolchain to extract various cities
* takes bbox as input
* returns data ready for import
* already processed [city data](http://metro.teczno.com/) avaiable

![extract of berlin](image/berlin.extract.jpg)
![extract of paris](image/paris.extract.jpg)

---
# Part 3

* fetch osm data
* extract city maps
* **convert data to PostGIS**
* compute centroid and contour
* overlay maps

---
# Choice: Import tool

* osmosis
    * feature rich (different outputs + filters)
    * written in java
    * much more than a import tool
* osm2pgsql
    * output suitable for rendering
    * written in c

---
# Database schema

* rendering schema
* shema:
    * TODO: add shema here

---
# Part 4

* fetch osm data
* extract city maps
* convert data to PostGIS
* **compute centroid and contour**
* overlay maps


---
# Computation in PostGIS

## extraction of contour
* straight forward (select from table)
* transform to usefull projection
* output readable for display (GeoJson)


## Example: Extract contour of Berlin

    !sql
    SELECT ST_asGeoJson(ST_Transform(way,4326))
    FROM plante_osm_polygon
    WHERE boundary = 'administrative' and name = 'berlin'


---
# Computation in PostGIS (cont'd)

## computation of centroid
* similar
* requires extra function application

## Example: Compute centroid of Berlin

    !sql
    SELECT ST_asGeoJson(ST_Transform(ST_Centroid(way),4326))
    FROM plante_osm_polygon
    WHERE boundary = 'administrative' and name = 'berlin'

---
# Caution: geography vs geometry

* sometimes functions need PostGIS geography object

## Example: Compute area of Berlin
    !sql
    SELECT ST_Area(Geography(ST_Transform(way)))
    FROM plante_osm_polygon
    WHERE boundary = 'administrative' and name = 'berlin'


---
# Part 5

* fetch osm data
* extract city maps
* convert data to PostGIS
* compute centroid and contour
* **overlay maps**





---
# Software stack

* node.js
* express (http framework)
* (node-)postgres
* postgis

* leaflet (slippy map/rendering)

---

## Wtf is node.js

    !javascript
    eventEmitter.on('aTinyEvent', function(event) { });

---



## Application

---

## Example Queries

    paste some shit here

---

## GEOJson

* explain the geometry types and features/featureCollection

---
