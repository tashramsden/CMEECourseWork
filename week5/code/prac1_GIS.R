## GIS data and plotting

rm(list=ls())

# https://github.com/davidorme/Masters_GIS

# required packages
# install.packages('raster') # Core raster GIS data package
# install.packages('sf') # Core vector GIS data package
# install.packages('sp') # Another core vector GIS package
# install.packages('rgeos') # Extends vector data functionality
# install.packages('rgdal') # Interface to the Geospatial Data Abstraction Library
# install.packages('lwgeom') # Extends vector data functionality

# all these packages wrappers to powerful GIS libraries: gdal (geospatial data
# handling), geos (vector data geometry), proj (coordinate system projections)

library(sp)
library(rgdal)
library(raster)
library(sf)
library(units)
library(rgeos)
library(gdistance)
library(openxlsx)
library(ggplot2)
library(RColorBrewer)


#### Vector data ---------

## a. Making vectors from coordinates ----

# pop density of british isles
pop_dens <- data.frame(n_km2 = c(260, 67, 151, 4500, 133), 
                       country = c('England','Scotland', 'Wales', 
                                   'London', 'Northern Ireland'))
print(pop_dens)
# want polygon features that look ish like map - want polygon for Scotland,
# England, Wales, NI and Eire

# Create coordinates for each country
# - this creates a matrix of pairs of coordinates forming the edge of the 
# polygon. 
# - note that they have to _close_: the first and last coordinate 
# must be the same.
scotland <- rbind(c(-5, 58.6), c(-3, 58.6), c(-4, 57.6), 
                  c(-1.5, 57.6), c(-2, 55.8), c(-3, 55), 
                  c(-5, 55), c(-6, 56), c(-5, 58.6))
england <- rbind(c(-2,55.8),c(0.5, 52.8), c(1.6, 52.8), 
                 c(0.7, 50.7), c(-5.7,50), c(-2.7, 51.5), 
                 c(-3, 53.4),c(-3, 55), c(-2,55.8))
wales <- rbind(c(-2.5, 51.3), c(-5.3,51.8), c(-4.5, 53.4),
               c(-2.8, 53.4),  c(-2.5, 51.3))
ireland <- rbind(c(-10,51.5), c(-10, 54.2), c(-7.5, 55.3),
                 c(-5.9, 55.3), c(-5.9, 52.2), c(-10,51.5))

# Convert these coordinates into feature geometries
# - these are simple coordinate sets with no projection information
scotland <- st_polygon(list(scotland))
england <- st_polygon(list(england))
wales <- st_polygon(list(wales))
ireland <- st_polygon(list(ireland))


# combine these into simple feature column (sfc):
# and can set up coord ref system (crs or projection)

# NOTE: sf automatically tries to scale the aspect ratio of plots of 
# geographic coord data based on their latitude - makes them look less squashed
# We are actively suppressing that here by setting aspect ratio of one (asp=1).

uk_eire <- st_sfc(wales, england, scotland, ireland, crs=4326)
plot(uk_eire, asp=1)


## b. Making vector points from a dataframe ----
# can easily turn df w coords in columns to point vector data source
# eg create points for capital cities:
uk_eire_capitals <- data.frame(long= c(-0.1, -3.2, -3.2, -6.0, -6.25),
                               lat=c(51.5, 51.5, 55.8, 54.6, 53.30),
                               name=c('London', 'Cardiff', 'Edinburgh',
                                      'Belfast', 'Dublin'))

# Indicate which fields in the data frame contain the coordinates
uk_eire_capitals <- st_as_sf(uk_eire_capitals, coords=c('long','lat'), crs=4326)
print(uk_eire_capitals)


# problems: 
# missing polygon for London
# boundary for Wales poorly digitized - want common border w England
# haven't separated NI for Eire
# handle these using:


# c. Vector geometry operations ----

# use buffer operation to create London (define as anywhere within 
# quarter degree of St Pauls Cathedral - stupid thing to do - more later...)
st_pauls <- st_point(x=c(-0.098056, 51.513611))
london <- st_buffer(st_pauls, 0.25)

# remove london from england polygon using difference operation
# so that can set diff pop densities for the 2 regions
england_no_london <- st_difference(england, london)
# has diff structure to england
# lengths allows to see num of components in polygon + how many points in each component

# for scotland:
lengths(scotland)  # single component w 18 points

# england_no_london:
lengths(england_no_london)  
# 2 components (or rings): 
# one ring of 18 points along external border
# one ring of 242 points for internal hole

# can use same operation to sort out wales
# want the bits of wales that are diff from england
wales <- st_difference(wales, england)


# now use intersection operation to separate NI from island of Ireland
# create rough polygon inc NI and sticks out into sea
# find intersection and diff of that with the Ireland polygon to get NI and Eire

# A rough polygon that includes Northern Ireland and surrounding sea.
# - note the alternative way of providing the coordinates
ni_area <- st_polygon(list(cbind(x=c(-8.1, -6, -5, -6, -8.1), 
                                 y=c(54.4, 56, 55, 54, 54.4))))

northern_ireland <- st_intersection(ireland, ni_area)
eire <- st_difference(ireland, ni_area)

# Combine the final geometries
uk_eire <- st_sfc(wales, england_no_london, scotland, london,
                  northern_ireland, eire, crs=4326)


## d. Features and geometries ----

# uk_eire now has 6 FEATURES:
# feature = set of 1/more vector GIS geometries that represent a spatial unit 
# uk_eire 6 features, each a single polygon, 
# england slightly more complex - has a hole
print(uk_eire)

# create single feature that contains all those geometries in one MULTIPOLYGON
# using union operation
# make the UK into a single feature
uk_country <- st_union(uk_eire[-6])
print(uk_country)

# plot them
par(mfrow=c(1, 2), mar=c(3,3,1,1))
plot(uk_eire, asp=1, col=rainbow(6))
plot(st_geometry(uk_eire_capitals), add=TRUE)
plot(uk_country, asp=1, col='lightblue')


# e. Vector data and attributes ----
# want to add data to the polygons - attributes/properties
# sf object: ~normal data frame w additional field containing Simple Feature data
uk_eire <- st_sf(name=c('Wales', 'England','Scotland', 'London', 
                        'Northern Ireland', 'Eire'),
                 geometry=uk_eire)

plot(uk_eire, asp=1)

# can add attributes by adding fields directly
uk_eire$capital <- c('Cardiff', 'London', 'Edinburgh', 
                     NA, 'Belfast','Dublin')
print(uk_eire)

# more useful (and less error prone) - use merge operation
# to match data in from the pop_dens df:
# use by.x and by.y, if col names identical in both dfs use by
# default is to drop rows w/o matching data - so Eire would be lost - no pop dens
# use all.x=TRUE to stop this
uk_eire <- merge(uk_eire, pop_dens, by.x='name', by.y='country', all.x=TRUE)
print(uk_eire)


## f. Spatial attributes ----

# centroids of features:
uk_eire_centroids <- st_centroid(uk_eire)
st_coordinates(uk_eire_centroids)
# get warning - this isn't great way to calculate true centroid for geo coord (more later...)

# length and area:
# behind the scenes sf converts units in degrees to meters (using calculations 
# on surface of a sphere - great circle distances)
uk_eire$area <- st_area(uk_eire)

# The length of a polygon is the perimeter length 
# - note that this includes the length of internal holes.
# uk_eire$length <- st_length(uk_eire)  # this is old version - but gives 0s 
uk_eire$length <- st_length(st_cast(uk_eire, 'MULTILINESTRING'))
# Look at the result
print(uk_eire)

# can change units - R will do the conversion!
uk_eire$area <- set_units(uk_eire$area, 'km^2')
uk_eire$length <- set_units(uk_eire$length, 'km')
print(uk_eire)
# And it won't let you make silly error like turning a length into weight
# uk_eire$area <- set_units(uk_eire$area, 'kg')
# Or you can simply convert the `units` version to simple numbers
uk_eire$length <- as.numeric(uk_eire$length)

# distance:
# sf gives closest dist between geometries (might be 0 if 2 features overlap/touch)
st_distance(uk_eire)
st_distance(uk_eire_centroids)
# Again, sf is noting that we have a geographic coordinate system and
# internally calculating distances in metres.


## g. Plotting sf objects ----

# when plotting sf, default is to plot all attributes
# can specify using square brackets

# map of pop density
plot(uk_eire["n_km2"], asp=1)

# with log scale (more useful!)
par(mfrow=c(1,2))
# You could simply log the data:
uk_eire$log_n_km2 <- log10(uk_eire$n_km2)
plot(uk_eire['log_n_km2'], asp=1)
# Or you can have logarithimic labelling using logz
plot(uk_eire['n_km2'], asp=1, logz=TRUE)


## h. Reprojecting vector data ----

# above - been ASSERTING that we have data w particular projection (4326)
# NOT reprojection - just saying we know our coords are in this proj

# 4326 just unique numeric code in EPSG database = WGS 84 (most GPS data in WGS 84)

# reprojection = moving data from one set of coords to another
# ~straightforward ish for vector:
# spatial info just coords in space, and projections just equations so apply equations to coords 

# reproj often used to convert from coords sys (w units in degrees) to 
# project coord sys (w linear units)
# REMEMBER: projected coord systems are trade-off between conserving dist, 
# shape, area, bearings - pick which is appropriate for your analysis/area

# reproject UK and Eire map onto good choice local proj coord sys: British National Grid
# can also use bad choice: UTM 50N proj (appropriate for Borneo!)
# British National Grid (EPSG:27700)
uk_eire_BNG <- st_transform(uk_eire, 27700)
# UTM50N (EPSG:32650)
uk_eire_UTM50N <- st_transform(uk_eire, 32650)
# The bounding boxes of the data shows the change in units
st_bbox(uk_eire)
st_bbox(uk_eire_BNG)

# Plot the results
par(mfrow=c(1, 3), mar=c(3,3,1,1))
plot(st_geometry(uk_eire), asp=1, axes=TRUE, main='WGS 84')
plot(st_geometry(uk_eire_BNG), axes=TRUE, main='OSGB 1936 / BNG')
plot(st_geometry(uk_eire_UTM50N), axes=TRUE, main='UTM 50N')

## h.1 Proj4 strings ----
# EPSG ID codes save us from proj4 strings
# these contain long, confusing sets of options and params to define projection
# sf package nice - others not so much (see proj4 strings on the EPSG website!)

## h.2 Degrees are not constant ----
# units for geog coord systems are ANGLES of lat and long
# not constant unit of distance:
# as lines of long converge towards poles, physical length of a degree decreases
# this why 0.25degree buffered point for London is nonsense and 
# why on BNG projection London is distorted

# at the lat of London, a degree longitude is ~69km and lat ~111km
# st_distance is noting that we have geog coords and returning great circle
# distance in meters

# Set up some points separated by 1 degree latitude and longitude from St. Pauls
st_pauls <- st_sfc(st_pauls, crs=4326)
one_deg_west_pt <- st_sfc(st_pauls - c(1, 0), crs=4326) # near Goring
one_deg_north_pt <-  st_sfc(st_pauls + c(0, 1), crs=4326) # near Peterborough
# Calculate the distance between St Pauls and each point
st_distance(st_pauls, one_deg_west_pt)
st_distance(st_pauls, one_deg_north_pt)

# and diff num when projected on BNG
st_distance(st_transform(st_pauls, 27700), 
            st_transform(one_deg_west_pt, 27700))


# London feature would be better if used constant 25km buffer around St. Pauls
# rather than poor attempt using degrees
# transform St Pauls to BNG and buffer using 25 km
london_bng <- st_buffer(st_transform(st_pauls, 27700), 25000)
# In one line, transform england to BNG and cut out London
england_not_london_bng <- st_difference(st_transform(st_sfc(england, crs=4326), 27700), london_bng)
# project the other features and combine everything together
others_bng <- st_transform(st_sfc(eire, northern_ireland, scotland, wales, crs=4326), 27700)
corrected <- c(others_bng, london_bng, england_not_london_bng)
# Plot that and marvel at the nice circular feature around London
par(mfrow=c(1,1), mar=c(3,3,1,1))
plot(corrected, main='25km radius London', axes=TRUE)


#### Rasters ----

## a. Creating a raster ----

# build raster dataset from scratch, set projection, bounds, resolution
# initially has no data values but will set them
# NOTE: raster package doesn't support EPSG codes as numbers but does as 
# formatted text string: +init=EPSG:4326

# Create an empty raster object covering UK and Eire
uk_raster_WGS84 <- raster(xmn=-11,  xmx=2,  ymn=49.5, ymx=59, 
                          res=0.5, crs="+init=EPSG:4326")
hasValues(uk_raster_WGS84)

# Add data to the raster: just the number 1 to number of cells
values(uk_raster_WGS84) <- seq(length(uk_raster_WGS84))
print(uk_raster_WGS84)

# create basic map of this w country borders on top
# add=TRUE adds vector data to the existing map
plot(uk_raster_WGS84)
plot(st_geometry(uk_eire), add=TRUE, border='black', lwd=2, col='#FFFFFF44')


## b. Changing raster resolution ----

# can make resolution coarser/finer - THINK about it though
# might need to change so that diff data have same resolution
# or maybe data is more detailed than needed/can be analysed

# Define a simple 4 x 4 square raster
m <- matrix(c(1, 1, 3, 3,
              1, 2, 4, 3,
              5, 5, 7, 8,
              6, 6, 7, 7), ncol=4, byrow=TRUE)
square <- raster(m)

## b.1 Aggregating rasters ----

# choose an aggregating factor (how many cells to group), eg 2 -> aggregates into blocks of 2x2 cells

# how to aggregate
# if data continuous, mean/max might be appropriate
# if categorical (eg land cover) mean makes NO SENSE (eg average of forest(2) 
# and moorland(3))

# Average values
square_agg_mean <- aggregate(square, fact=2, fun=mean)
as.matrix(square_agg_mean)

# Maximum values
square_agg_max <- aggregate(square, fact=2, fun=max)
as.matrix(square_agg_max)

# Modal values for categories
square_agg_modal <- aggregate(square, fact=2, fun=modal)
as.matrix(square_agg_modal)
# but if no mode, eg bottom left (two 5s and 2 6s) a value is assigned (but shouldn't exist)
# can specify first/last but there is no single mode


## b.2 Disaggregating rasters ----

# also requires a factor - but this is sqrt of num of cells to create from each cell

# and value - obvious answer is copy parent cell value into new cells (fine for
# continuous and cat)
# another option: INTERPOLATE between the values to provide gradient - does 
# NOT make sense for cat data

# Copy parents
square_disagg <- disaggregate(square, fact=2)
as.matrix(square_disagg)
# Interpolate
square_disagg_interp <- disaggregate(square, fact=2, method='bilinear')
as.matrix(square_disagg_interp)

# to visualise this - doesn't seem to like being zoomed!!!!
par(mfrow=c(1,3))
plot(square, main="Original")
plot(rasterToPolygons(square), add=TRUE, border='grey') 

plot(square_disagg, main="Dissag - copy parents")
plot(rasterToPolygons(square_disagg), add=TRUE, border='grey') 

plot(square_disagg_interp, main="Dissag - interpolate")
plot(rasterToPolygons(square_disagg_interp), add=TRUE, border='grey') 


## c. Resampling ----

# the previous 2 functions don't change the origin or alignments of cell borders
# just group/split values wihtin same grid framework
# IF need to match data w diff origins/alignments - use resample function

# but this is basically:

## d. Reprojecting a raster ----

# conceptually more difficult than reproj vector data
# raster cell values, want to insert these values into set of cells on diff 
# projection - could have diff borders etc

# e.g. see how 0.5 degree WGS 84 raster for UK and Eire compares to 100km 
# resolution raster on British National Grid

# cannot plot actual raster data (always need regular grid) but create 
# vector grids using st_make_grid to represent cells in the 2 rasters 

# make two simple `sfc` objects containing points in the
# lower left and top right of the two grids
uk_pts_WGS84 <- st_sfc(st_point(c(-11, 49.5)), st_point(c(2, 59)), crs=4326)
uk_pts_BNG <- st_sfc(st_point(c(-2e5, 0)), st_point(c(7e5, 1e6)), crs=27700)

#  Use st_make_grid to quickly create a polygon grid with the right cell size
uk_grid_WGS84 <- st_make_grid(uk_pts_WGS84, cellsize=0.5)
uk_grid_BNG <- st_make_grid(uk_pts_BNG, cellsize=1e5)

# Reproject BNG grid into WGS84
uk_grid_BNG_as_WGS84 <- st_transform(uk_grid_BNG, 4326)

# Plot the features
par(mfrow=c(1,1))
plot(uk_grid_WGS84, asp=1, border='grey', xlim=c(-13,4))
plot(st_geometry(uk_eire), add=TRUE, border='darkgreen', lwd=2)
plot(uk_grid_BNG_as_WGS84, border='red', add=TRUE)
# see how transferring cell values between these 2 raster grids gets complicated!


# use projectRaster function
# gives choice to interpolate representative value from source data (method='bilinear')
# or pick cell value from nearest neighbour to new cell centre (method='ngb')

# first create the target raster
uk_raster_BNG <- raster(xmn=-200000, xmx=700000, ymn=0, ymx=1000000,
                        res=100000, crs='+init=EPSG:27700')
uk_raster_BNG_interp <- projectRaster(uk_raster_WGS84, uk_raster_BNG,
                                      method='bilinear')
uk_raster_BNG_ngb <- projectRaster(uk_raster_WGS84, uk_raster_BNG,
                                   method='ngb')
# compare the values in the top row
round(values(uk_raster_BNG_interp)[1:9], 2)
values(uk_raster_BNG_ngb)[1:9]
# NOTE the NAs on left and right - in above plot can see how top left and right
# red cells do not overlie the original grey grid so are assigned NA

par(mfrow=c(1,2), mar=c(1,1,2,1))
plot(uk_raster_BNG_interp, main='Interpolated', axes=FALSE, legend=FALSE)
plot(uk_raster_BNG_ngb, main='Nearest Neighbour',axes=FALSE, legend=FALSE)
# can see more abrupt changes using nearest neighbour projection

# see stars package for more raster handling


#### Converting between vector and raster data types ----

# think before doing this - data often comes in format for a reason - but there
# are plenty of valid reasons for converting

## a. Vector to raster ----

# a bit like doing reprojectRaster
# provide target raster and the vector data to rasterize function

# important diffs in how diff geometry types get rasterized:
# (in each case a vector attribute is chosen to assign cell values in the raster)
# POINT: if a point falls within a cell, that value is assigned to the cell
# LINESTRING: if any part of the linestring falls within a cell, that value assigned to cell
# POLYGON: if centre of cell falls within a polygon, the value from polygon assigned to cell

# common for cell to have >1 possible value, eg if 2 points in a cell
# rasterize - can set fun argument to set rules to decide which "wins"

# raster package predates sf so wants vector data in older SPATIAL data type from sp
# easy to convert: as(sf_object, 'Spatial')

# rasterize uk_eire_BNG vector data onto 20km res grid
# use st_cast to change polygon data into lines and points

# Create the target raster 
uk_20km <- raster(xmn=-200000, xmx=650000, ymn=0, ymx=1000000, 
                  res=20000, crs='+init=EPSG:27700')

# Rasterizing polygons
uk_eire_BNG$name <- as.factor(uk_eire_BNG$name)
uk_eire_poly_20km  <- rasterize(as(uk_eire_BNG, 'Spatial'), uk_20km, field='name')
# Rasterizing lines
uk_eire_BNG_line <- st_cast(uk_eire_BNG, 'LINESTRING')
# get warnings here - beacuse country attributes might not apply to the lines

# INSTEAD:
# use st_agr function to tell sf that attributes ARE constant 

uk_eire_BNG$name <- as.factor(uk_eire_BNG$name)
st_agr(uk_eire_BNG) <- 'constant'

# Rasterizing lines
uk_eire_BNG_line <- st_cast(uk_eire_BNG, 'LINESTRING')
uk_eire_line_20km <- rasterize(as(uk_eire_BNG_line, 'Spatial'), uk_20km, field='name')

# Rasterizing points 
# - This isn't quite as neat. You need to take two steps in the cast and need to convert 
#   the name factor to numeric.
uk_eire_BNG_point <- st_cast(st_cast(uk_eire_BNG, 'MULTIPOINT'), 'POINT')
uk_eire_BNG_point$name <- as.numeric(uk_eire_BNG_point$name)
uk_eire_point_20km <- rasterize(as(uk_eire_BNG_point, 'Spatial'), uk_20km, field='name')

# Plotting those different outcomes
# - Use the hcl.colors function to create a nice plotting palette
color_palette <- hcl.colors(6, palette='viridis', alpha=0.5)

# - Plot each raster
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(uk_eire_poly_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')

plot(uk_eire_line_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')

plot(uk_eire_point_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='grey')

# see fasterize package for faster POLYGON rasterization


## b. Raster to vector ----

# raster holds values in a regular grid
# can either view a value as representing a whole cell - so rep the cell as a polygon
# or a point in the center - use a point

# extra feature for creating polygons dissolve=TRUE but requires rgeos package
# library(rgeos)

# rasterToPolygons returns a polygon for each cell and returns a Spatial object
poly_from_rast <- rasterToPolygons(uk_eire_poly_20km)
poly_from_rast <- as(poly_from_rast, 'sf')

# but can be set to dissolve the boundaries between cells with identical values
poly_from_rast_dissolve <- rasterToPolygons(uk_eire_poly_20km, dissolve=TRUE)
poly_from_rast_dissolve <- as(poly_from_rast_dissolve, 'sf')

# rasterToPoints returns a matrix of coordinates and values.
points_from_rast <- rasterToPoints(uk_eire_poly_20km)
points_from_rast <- st_as_sf(data.frame(points_from_rast), coords=c('x','y'))

# Plot the outputs - using key.pos=NULL to suppress the key and
# reset=FALSE to avoid plot.sf altering the par() options
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(poly_from_rast['layer'], key.pos = NULL, reset = FALSE)
plot(poly_from_rast_dissolve, key.pos = NULL, reset = FALSE)
plot(points_from_rast, key.pos = NULL, reset = FALSE)

# uncommon to have raster data representing linear features (like uk_eire_line_20km)
# and it's not trivial to convert to LINESTRING Vector - so we won't!


#### Using data in files ----

# huge range of formats for spatial data
# but sf st_read good for vector and raster in raster good for raster!

## a. Saving vector data ----

# most common vector data file is shapefile
# developed by ESRI for ArcGIS 

# save uk_eire to shapefile using st_write function in sf
st_write(uk_eire, "../data/uk_eire_WGS84.shp")
st_write(uk_eire_BNG, "../data/uk_eire_BNG.shp")
# look in data dir - shapefile is not a single file! - at least: .prj, .shp, .shx, .dbf

# also personal geodatabases
# GeoJSON - stores coordinates and attributes in text file - human readable (ish)
# GeoPackage - stores vector data in single SQLite3 database file - multiple
# tables in the file but v portable
st_write(uk_eire, '../data/uk_eire_WGS84.geojson')
st_write(uk_eire, '../data/uk_eire_WGS84.gpkg')

# sf package chooses output format based on suffix (eg .shp gives ESRI shapefile)
# if want to use diff suffix, specify driver
# driver: software to read/write particular formats - see list of available formats w st_drivers()
# st_drivers()

st_write(uk_eire, '../data/uk_eire_WGS84.json', driver='GeoJSON')


## b. Saving raster data ----

# GeoTIFF most common for GIS raster data
# basically same as tiff image but contains embedded data describing origin,
# resolution, and coord ref system
# sometimes also see a .tfw file: this is a "world" file w info - should keep 
# w the tiff file

# use writeRaster from raster to save
# can use format to set the driver, see writeFormats() for options

# Save a GeoTiff
writeRaster(uk_raster_BNG_interp, '../data/uk_raster_BNG_interp.tif')
# Save an ASCII format file: human readable text. 
# Note that this format does not contain the projection details!
writeRaster(uk_raster_BNG_ngb, '../data/uk_raster_BNG_ngb.asc', format='ascii')


## c. Loading vector data ----

# eg 1:110m scale Natural Earth data on countries
# see https://www.naturalearthdata.com/ for open-source basic GIS data
# and has R package that provides access to data (rnaturalearth)

# also use some downloaded WHO data (r package for this too: WHO) 

# Load a vector shapefile
ne_110 <- st_read('../data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp')
# Also load some WHO data on 2016 life expectancy
# see: http://apps.who.int/gho/athena/api/GHO/WHOSIS_000001?filter=YEAR:2016;SEX:BTSX&format=csv
life_exp <- read.csv(file = "../data/WHOSIS_000001.csv")


# create some global maps of GDP, and life expectancy (averaged for both sexes)

# GDP
plot(ne_110['GDP_MD_EST'], asp=1, main="Global GDP", logz=TRUE, key.pos=4)

# life expectancy - have to merge the data first
# merge by COUNTRY in life_exp and ISO_A3_EH in ne_110
# all.x=TRUE means keep countries even if NA for life expectancy
ne_110 <- merge(ne_110, life_exp, by.x="ISO_A3_EH", by.y="COUNTRY", all.x=TRUE)
# create a sequence of break values to use for display
bks <- seq(50, 85, by=0.25)
# plot
plot(ne_110["Numeric"], asp=1, main="Global 2016 Life Expectancy (both sexes)",
     breaks=bks, pal=hcl.colors, key.pos=4)


## d. Loading XY data ----

# common source is table w coords (either lat and long for geo coords or 
# x and y for a projected coord system)

# load some data like this and convert to sf object (need to know the coord system)
# Read in Southern Ocean example data
so_data <- read.csv('../data/Southern_Ocean.csv', header=TRUE)
head(so_data)
# Convert the data frame to an sf object
so_data <- st_as_sf(so_data, coords=c('long', 'lat'), crs=4326)
head(so_data)


## e. Loading raster data ----

# local topgraphic data from ETOPO1 dataset
# original data at 1 arc minute (1/60 degrees), this file been resampled to 
# 15 arc minutes (0.25 degrees) to be more manageable (466.7Mb to 2.7Mb)

par(mfrow=c(1,1))

etopo_25 <- raster("../data/etopo_25.tif")
# look at content
print(etopo_25)
plot(etopo_25)

# plot nicely! - w nicer palette (and see colorRampPalette)
bks <- seq(-10000, 6000, by=250)
land_cols  <- terrain.colors(24)
sea_pal <- colorRampPalette(c('darkslateblue', 'steelblue', 'paleturquoise'))
sea_cols <- sea_pal(40)
plot(etopo_25, axes=FALSE, breaks=bks, col=c(sea_cols, land_cols), 
     axis.args=list(at=seq(-10000, 6000, by=2000), lab=seq(-10,6,by=2)))


## f. Raster stacks ----

# raster data often has multiple BANDS
# single file can have layers of info, eg colour imagery - red, green, blue
# satellite data can contains many layers w diff bands

# use getData from raster package to get some data!
# ?getData
# will download data and store locally, and load data if already downloaded (like here) - but prob just use raster!
# worldclim data for max temp, comes as stack of monthly values:

# Download bioclim data: global maximum temperature at 10 arc minute resolution
tmax <- getData('worldclim', path='../data', var='tmax', res=10)
# The data has 12 layers, one for each month
print(tmax)

# odd thing: temp range of values from -478 to 489
# v common for GIS data to be stored in a form that needs scaling 
# metadata should include any scale and offset values needed - need to check 
# that any vars used are correctly scaled

# reason for this: disk use
# -478 to 489 can be stored easily as integer data w 2 bytes per num (Int16)
# if stored as float - 4 bytes per num (Float32) or worse (Float64)
# so data is half the size and since the data only accurate to 1 decimal
# place, no loss of precision

# access diff layers using [[]] 
# aggregate functions (eg sum, mean, max, min)

# scale the data
tmax <- tmax / 10
# Extract  January and July data and the annual maximum by location.
tmax_jan <- tmax[[1]]
tmax_jul <- tmax[[7]]
tmax_max <- max(tmax)
# Plot those maps
par(mfrow=c(3,1), mar=c(2,2,1,1))
bks <- seq(-500, 500, length=101)
pal <- colorRampPalette(c('lightblue','grey', 'firebrick'))
cols <- pal(100)
ax.args <- list(at= seq(-500, 500, by=100))
plot(tmax_jan, col=cols, breaks=bks, axis.args=ax.args, main='January maximum temperature')
plot(tmax_jul, col=cols, breaks=bks, axis.args=ax.args, main='July maximum temperature')
plot(tmax_max, col=cols, breaks=bks, axis.args=ax.args, main='Annual maximum temperature')


#### Overlaying raster and vector data ----

# going to build more complex map of chlorophyll conc in southern ocean

## a. Cropping data ----

# maybe only specific area of interest, and makes mapping quicker

so_extent <- extent(-60, -20, -65, -45)
# the crop function for raster data
so_topo <- crop(etopo_25, so_extent)
# and the st_crop function to reduce some higher resolution coastline data
ne_10 <- st_read("../data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.shp")
st_agr(ne_10) <- "constant"
so_ne_10 <- st_crop(ne_10, so_extent)

par(mfrow=c(2,1))
# plot southern ocean chlorophyll
# for continuous raster data, can be clearer w contours
sea_pal <- colorRampPalette(c('grey30', 'grey50', 'grey70'))
plot(so_topo, col=sea_pal(100), asp=1, legend=FALSE)
contour(so_topo, levels=c(-2000, -4000, -6000), add=TRUE, col='grey80')
plot(st_geometry(so_ne_10), add=TRUE, col='grey90', border='grey40')
plot(so_data['chlorophyll'], add=TRUE, logz=TRUE, pch=20, cex=2, 
     pal=hcl.colors, border='white', reset=FALSE)
.image_scale(log10(so_data$chlorophyll), col=hcl.colors(18), 
             key.length=0.8, key.pos=4, logz=TRUE)


#### Spatial joins and raster data extraction ----

## a. Spatial joining ----

# before we have merged data by matching values in columns 
# but can also merge data SPATIALLY - spatial join

# eg map mosquito outbreaks in Africa
# random data to demonstrate st_sample
# find out whether any countries more severely impacted in terms of area of
# country and pop size

set.seed(1)
# extract Africa from the ne_110 data and keep the columns we want to use
africa <- subset(ne_110, CONTINENT=='Africa', select=c('ADMIN', 'POP_EST'))

# transform to the Robinson projection
africa <- st_transform(x=africa, crs="ESRI:54030")
# create a random sample of points
mosquito_points <- st_sample(africa, 1000)

# Create the plot
par(mfrow=c(1,1))
plot(st_geometry(africa), col='khaki')
plot(mosquito_points, col='firebrick', add=TRUE)

# to join these data together need to turn mosquito_points object
# from a geometry column (sfc) into full sf dataframe that can have attributes
# then can add the country name ("ADMIN") onto the points
mosquito_points <- st_sf(mosquito_points)
mosquito_points <- st_join(mosquito_points, africa['ADMIN'])

plot(st_geometry(africa), col='khaki')
plot(mosquito_points['ADMIN'], add=TRUE)

# now aggregate points within countries to get count of points in each country
# and convert multiple rows of POINTS into a single MULTIPOINT feature per country
mosquito_points_agg <- aggregate(mosquito_points, 
                                 by=list(country=mosquito_points$ADMIN),
                                 FUN=length)
names(mosquito_points_agg)[2] <-'n_outbreaks'
head(mosquito_points_agg)

africa <- st_join(africa, mosquito_points_agg)
africa$area <- as.numeric(st_area(africa))
head(africa)

par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1, 0))
plot(n_outbreaks ~ POP_EST, data=africa, log='xy', 
     ylab='Number of outbreaks', xlab='Population size')
plot(n_outbreaks ~ area, data=africa, log='xy',
     ylab='Number of outbreaks', xlab='Area (m2)')


# alien invasion!
# got landing sites and crew sizes of alien ships (in ../data/aliens.csv as WGS84 coords)
# need to know which countries will be overwhelmed
# countries will be ok if >1000 people per alien

# This is a hack! (2021-11-01) - to prevent an error
sf_use_s2(FALSE)
# Load the data and convert to a sf object
alien_xy <- read.csv('../data/aliens.csv')
alien_xy <- st_as_sf(alien_xy, coords=c('long','lat'), crs=4326)

# Add country information and find the total number of aliens per country
alien_xy <- st_join(alien_xy, ne_110['ADMIN'])
aliens_by_country <- aggregate(n_aliens ~ ADMIN, data=alien_xy, FUN=sum)

# Add the alien counts into the country data 
ne_110 <- merge(ne_110, aliens_by_country, all.x=TRUE)
ne_110$aliens_per_capita <- with(ne_110,  n_aliens / POP_EST)

# create the scale colours
bks <- seq(-8, 2, length=101)
pal <- colorRampPalette(c('darkblue','lightblue', 'salmon','darkred'))

plot(ne_110['aliens_per_capita'], logz=TRUE, breaks=bks, pal=pal, key.pos=4)


## b. Extracting data from rasters ----

# above we connected vector data based on location, might also need to 
# extract data from raster in certain locations
# eg to know altitude/surface temp of sampling sites / ave value within a polygon

# use chunk of the full resolution ETOPO1 elevation data to explore:
uk_eire_etopo <- raster("../data/etopo_uk.tif")

# first: ETOPO data includes bathymetry and elevation
# use rasterize function on the high res ne_10 data to get land raster 
# matching uk_eire_etopo
# then use mask function to create elevation map
uk_eire_detail <- subset(ne_10, ADMIN %in% c('United Kingdom', "Ireland"))
uk_eire_detail_raster <- rasterize(as(uk_eire_detail, 'Spatial'), uk_eire_etopo)
uk_eire_elev <- mask(uk_eire_etopo, uk_eire_detail_raster)

par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1,0))
plot(uk_eire_etopo, axis.args=list(las=3))
plot(st_geometry(uk_eire_detail), add=TRUE, border='grey')

plot(uk_eire_elev, axis.args=list(las=3))
plot(st_geometry(uk_eire_detail), add=TRUE, border='grey')


## c. Raster cell statistics and locations ----

# cellStats function for summarising data in a raster
# can find locations of cells w certain characteristics using eg Which and which.max
# both return cell ID nums
# xyFromCell allows to turn those ID nums into coords

cellStats(uk_eire_elev, max)
cellStats(uk_eire_elev, quantile)
# Which is the highest cell
which.max(uk_eire_elev)
# Which cells are above 1100m
Which(uk_eire_elev > 1100, cells=TRUE)

# plot highest points and areas below sea level
par(mfrow=c(1,1))
max_cell <- which.max(uk_eire_elev)
max_xy <- xyFromCell(uk_eire_elev, max_cell)
max_sfc <- st_sfc(st_point(max_xy), crs=4326)
bsl_cell <- Which(uk_eire_elev < 0, cells=TRUE)
bsl_xy <- xyFromCell(uk_eire_elev, bsl_cell)
bsl_sfc <- st_sfc(st_multipoint(bsl_xy), crs=4326)

plot(uk_eire_elev, axis.args=list(las=3))
plot(max_sfc, add=TRUE, pch=24, bg='red')
plot(bsl_sfc, add=TRUE, pch=25, bg='lightblue', cex=0.6)

# is the max altitude the REAL max altitude in the UK?
# actual max altitude is Ben Nevis in Scotland - doesn't look like that's 
# where the red point is...
# lots of points below sea level


## d. The extract function ----

# extract makes lots of the above easier
# works in diff ways on diff geometry types:
# POINT: extracts values under the points
# LINESTRING: extracts values under the linestring
# POLYGON: extracts values within the polygon

# extracting points v easy
uk_eire_capitals$elev <- raster::extract(uk_eire_elev, uk_eire_capitals)
print(uk_eire_capitals)

# polygons also easy but some more detail about output
# by default extract returns set of ALL raster values within each polygon
# can use fun argument to specify that extract should do something w those values
print(uk_eire_elev)
print(uk_eire)
uk_eire$mean_height <- raster::extract(uk_eire_elev, uk_eire, fun=mean, na.rm=TRUE)
print(uk_eire)


# extracting values under linestrings more complicated
# returns values under the line, if want to tie these values to locations- a bit more work
# by default, function returns the sample of values under the line, in no 
# particular order - along=TRUE preserves order
# also want to know which cell gives each value, cellnumbers=TRUE

# get elevation transect for Pennine Way - 429km - data from a GPX file (common in GPS receivers)
# GPX contain multiple layers (diff GIS datasets within single source)
# st_layers function aloows see names of layers - can load data wanted
st_layers("../data/National_Trails_Pennine_Way.gpx")
# load the data, showing off the ability to use SQL queries to load 
# subsets of the data
pennine_way <- st_read("../data/National_Trails_Pennine_Way.gpx", 
                       layer="routes",
                       query="select * from routes where name='Pennine Way'")

# before anything else, our data (etopo_uk and pennine_way) are in WGS84
# doesn't make sense to calc distances and transects on a geo coord system
# reproject into the British National Grid, w 2km resolution:

# reproject vector data
pennine_way_BNG <- st_transform(pennine_way, crs=27700)
# create the target raster and project the elevation data into it
bng_2km <- raster(xmn=-200000, xmx=700000, ymn=0, ymx=1000000, 
                  res=2000, crs='+init=EPSG:27700')
uk_eire_elev_BNG <- projectRaster(uk_eire_elev, bng_2km)

# the route data v detailed - takes time to process - simplify for this 
# exercise before using
# use 100m tolerance for simplifying - goes from 31569 to 1512 points
# Simplify the data
pennine_way_BNG_simple <- st_simplify(pennine_way_BNG,  dTolerance=100)
# Zoom in to the whole route and plot the data
par(mfrow=c(1,2), mar=c(1,1,1,1))
plot(uk_eire_elev_BNG, xlim=c(3e5, 5e5), ylim=c(3.8e5, 6.3e5),
     axes=FALSE, legend=FALSE)
plot(st_geometry(pennine_way_BNG), add=TRUE, col='black')
plot(pennine_way_BNG_simple, add=TRUE, col='darkred')
# Add a zoom box and use that to create a new plot
zoom <- extent(3.77e5, 3.89e5, 4.7e5, 4.85e5)
plot(zoom, add=TRUE)
# Zoomed in plot
plot(uk_eire_elev_BNG, ext=zoom, axes=FALSE, legend=FALSE)
plot(st_geometry(pennine_way_BNG), add=TRUE, col='black')
plot(pennine_way_BNG_simple, add=TRUE, col='darkred')

# now extract elevations and cell IDs under the route
# can also use Pythagoras to find distance between cells along transect, 
# and therefore the cumulative distance
# Extract the data
pennine_way_trans <- raster::extract(uk_eire_elev_BNG, pennine_way_BNG_simple, 
                             along=TRUE, cellnumbers=TRUE)
# The output is a list: contains one set of values for each feature in input data
str(pennine_way_trans)
# Here, we only have one line, so we will extract it
pennine_way_trans <- pennine_way_trans[[1]]
pennine_way_trans <- data.frame(pennine_way_trans)
# Get the cell coordinates 
pennine_way_xy <- xyFromCell(uk_eire_elev_BNG, pennine_way_trans$cell)
pennine_way_trans <- cbind(pennine_way_trans, pennine_way_xy)
# Now we can use Pythagoras to find the distance along the transect
pennine_way_trans$dx <- c(0, diff(pennine_way_trans$x))
pennine_way_trans$dy <- c(0, diff(pennine_way_trans$y))
pennine_way_trans$distance_from_last <- with(pennine_way_trans, 
                                             sqrt(dx^2 + dy^2))
pennine_way_trans$distance <- cumsum(pennine_way_trans$distance_from_last)

par(mfrow=c(1,1), mar=c(3,3,1,1))
plot(etopo_uk ~ distance, data=pennine_way_trans, type='l', 
      ylab='Elevation (m)', xlab='Distance (m)')


#### Mini projects ----


## a. Precipitation transect for New Guinea ----

# given these coords of a transect through New Guinea:
transect_long <- c(132.3, 135.2, 146.4, 149.3)
transect_lat <- c(-1, -3.9, -7.7, -9.8)

# TASK: create a total annual precipitation transect for New Guinea

# Use the 0.5 arc minute worldclim data from getData - you will need to 
# specify a location to get the tile including New Guinea.

# Use UTM 54S (https://epsg.io/32754) and use a 1 km resolution to 
# reproject raster data. You will need to find an extent in UTM 54S to 
# cover the study area and choose extent coordinates to create neat 1km cell
# boundaries

# Create a transect with the above (WGS84 Long + Lat) coordinates
   
# You will need to reproject the transect into UTM 54S and then use the 
# function st_segmentize to create regular 1000m sampling points along the 
# transect.

# 1. get precipitation data
ng_precip <- getData("worldclim", var="prec", res=0.5, lon=140, lat=-10,
                     path="../data")
# reduce the extent of new guinea (crop now rather than later - avoid unnecessary processing!)
ng_extent <- extent(130, 150, -10, 0)
ng_precip <- crop(ng_precip, ng_extent)
# calculate annual precip
ng_annual_precip <- sum(ng_precip)

# 2. reproject to UTM 54S
# use reprojecting the extent of the raster to get sensible values for UTM 54S extent
# pick extent values that create neat 1000m grid w sensible cell edges
ng_extent_poly <- st_as_sfc(st_bbox(ng_extent, crs=4326))
st_transform(ng_extent_poly, crs=32754)
ng_extent_utm <- extent(-732000, 1506000, 8874000, 10000000)  # these values from result of above

# 3. create raster and reproject data
ng_template_utm <- raster(ng_extent_utm, res=1000, crs="+init=EPSG:32754")
ng_annual_prec_utm <- projectRaster(ng_annual_precip, ng_template_utm)

# 4. create and reproject the transect and then segmentize to 1000m
transect <-  st_linestring(cbind(x=transect_long, y=transect_lat))
transect <- st_sfc(transect, crs=4326)
transect_utm <- st_transform(transect, crs=32754)
transect_utm <- st_segmentize(transect_utm, dfMaxLength=1000)

transect_data <- raster::extract(ng_annual_prec_utm, as(transect_utm, 'Spatial'),
                                 along=TRUE, cellnumbers=TRUE)

# 5. get first item from transect
transect_data <- transect_data[[1]]
transect_data <- data.frame(transect_data)

# 6. get cell coords
transect_data_xy <- xyFromCell(ng_annual_prec_utm, transect_data$cell)
transect_data <- cbind(transect_data, transect_data_xy)

# 7. use pythagoras to find distance along transect
transect_data$dx <- c(0, diff(transect_data$x))
transect_data$dy <- c(0, diff(transect_data$y))
transect_data$distance_from_last <- with(transect_data, sqrt(dx^2 + dy^2))
transect_data$distance <- cumsum(transect_data$distance_from_last)

# 8. get natural earth high res coastline
ne_10_ng <- st_crop(ne_10, ng_extent_poly)
ne_10_ng_utm <- st_transform(ne_10_ng, crs=32754)

# plot!
par(mfrow=c(2,1), mar=c(3,3,1,1), mgp=c(2,1,0))
plot(ng_annual_prec_utm)
plot(ne_10_ng_utm, add=TRUE, col=NA, border="grey50")
plot(transect_utm, add=TRUE)

par(mar=c(3,3,1,1))
plot(layer ~ distance, data=transect_data, type="l",
     ylab="Annual precipitation (mm)", xlab="Distance (m)")



## b. Fishing pressure in Fiji ----

# researchers have identified 7 commonly used fishing sites around 
# island of Kadavu in Fiji
# + surveys of coastal villages known to use these sites
# TASK: trying to identify how many households likely to use each site
# simplifying assumption that each village will always use closest site

# can't use st_distances because dists need to reflect travel distances 
# though sea not straight line dists
# going to use COST DISTANCE ANALYSIS
# cost dist models use raster to define cost surface: moving from a cell to 
# neighbouring cell has a cost derived from values in the raster
# can then ask what is cost of moving from A to B where movement allowed to 
# avoid areas that are expensive to traverse

# using data from excel file
# install.packages('gdistance') # Cost distance analysis
# install.packages('openxlsx') # Load data from Excel directly

# library(gdistance)
# library(openxlsx)


# 1. Loading the data

# use getData to get GADM Level 2 vector data for Fiji (country="FJI") then
# extract Kadavu
# GDAM is global administrative boundaries
# use readWorbook to load data from the Villages and Field sites worksheets
# from FishingPressure.xlsx and convert those tables into sf objects w point data
# all these in WGS84 so convert to projection sys appropriate for Fiji
# (UTM 60S: EPSG:32760)

# Download the GADM data for Fiji, convert to sf and then extract Kadavu
fiji <- getData('GADM', country='FJI', level=2, path='../data')
fiji <- st_as_sf(fiji)
kadavu <- subset(fiji, NAME_2 == 'Kadavu')

# Load the villages and sites and convert to sf
villages <- readWorkbook('../data/FishingPressure.xlsx', 'Villages')
villages <- st_as_sf(villages, coords=c('long','lat'), crs=4326)
sites <- readWorkbook('../data/FishingPressure.xlsx', 'Field sites', startRow=3)
sites <- st_as_sf(sites, coords=c('Long','Lat'), crs=4326)

# Reproject the data UTM60S
kadavu <- st_transform(kadavu, 32760)
villages <- st_transform(villages, 32760)
sites <- st_transform(sites, 32760)

# Map to check everything looks right
par(mfrow=c(1,1))
plot(st_geometry(sites), axes=TRUE, col='blue')
plot(st_geometry(villages), add=TRUE, col='red')
plot(st_geometry(kadavu), add=TRUE)


# 2. Create the cost surface

# cost surface should assign uniform cost to moving through sea and an
# infinte cost (NA) to moving over land
# resolution really matters - v fine res will give v precise distances but 
# take a long time, coarse res will run quickly but be v crude
# need to:
# pick extents to cover the islands and sites
# pick a resolution
# use st_rasterize to convert the vector coastline into raster and create 
# the surface

# remember from above diff between rasterizing polygon vs linestring
# cells w coastline contain sea so should be available for movement

# Create a template raster covering the whole study area, at a given resolution
res <- 100  # higher num eg 1000 will have MUCH coarser map, vs eg 50 takes a long time to process (for not that much extra detail)
r <- raster(xmn=590000, xmx=670000, ymn=7870000, ymx=7940000, 
            crs='+init=EPSG:32760', res=res)

# Rasterize the island as a POLYGON to get cells that cannot be traversed
kadavu_poly <- rasterize(as(kadavu, 'Spatial'), r, 
                         field=1, background=0)
# Rasterize the island as a MULTILINESTRING to get the coastal 
# cells that CAN be traversed
kadavu_lines <- rasterize(as(st_cast(kadavu, 'MULTILINESTRING'), 'Spatial'), r, 
                          field=1, background=0)

# Combine those to give cells that are in the sea (kadavu_poly=0)
# or in the coast (kadavu_lines=1)
sea_r <- (! kadavu_poly) | kadavu_lines

# Set the costs
sea_r[sea_r == 0] <- NA
sea_r[! is.na(sea_r)] <- 1
plot(sea_r)


# 3. Finding launch points

# the villages are not all on the coast!
# if village too far inland, might be on cell w infinite travel cost
# so need to find closest point on the coast to each village 
# using st_nearest_points
# all points in a polygon are part of that polygon- so have to convert the 
# island polygon to a MULTILINESTRING showing the coast to find point on coast

# output of st_nearest_points is a line that joins each village to nearest 
# point on coast
# the second point on each of these lines is the nearest launch point - so
# use st_line_sample w sample=1 to extract them

# Find the nearest points on the coast to each village
village_coast <- st_nearest_points(villages, st_cast(kadavu, 'MULTILINESTRING'))
# Extract the end point on the coast and convert from MULTIPOINT to POINT
launch_points <- st_line_sample(village_coast, sample=1)
launch_points <- st_cast(launch_points, 'POINT')

# Zoom in to a bay on Kadavu
plot(st_geometry(kadavu), xlim=c(616000, 618000), ylim=c(7889000, 7891000),
     col='khaki')
# Plot the villages, lines to the nearest coast and the launch points.
plot(st_geometry(villages), add=TRUE, col='firebrick')
plot(village_coast, add=TRUE, col='grey')
plot(launch_points, add=TRUE, col='darkgreen')

# add the launch points to villages object
# IS possible to have >1 geometry associated w a row of data- have to set
# which one being used
villages$launch_points <- launch_points
st_geometry(villages) <- 'launch_points'


# 4. Find distances

# hard bit!
# costDistance function a bit complicated
# first, use transition to create a transition graph, this sets:
# 1. which cells are connected to each other
# common options: direction=4 (rook's move), =8 (queen's move), =16 (knight's move):
r <- raster(matrix(0, ncol=5, nrow=5))
r[13] <- 2
# rook, queen and knight cells from the centre cell (13)
# - the output is a matrix with the second column showing the neighbours
# ?adjacent
rook <- adjacent(r, 13, direction=4)[,2]
queen <- adjacent(r, 13, direction=8)[,2]
knight <- adjacent(r, 13, direction=16)[,2]
# plot those
par(mfrow=c(1,3), mar=c(1,1,1,1))
r[rook] <- 1
plot(r)
r[queen] <- 1
plot(r)
r[knight] <- 1
plot(r)
# 2. what the cost of moving between connected cells is by applying function
# to the values in the 2 connected cells

# transition creates the network and assigns the basic transition values 
# between cells
# in GIS need to also scale the costs by the physical distances between cells
# using geoCorrection
# then use costDistance to find distances between sites and launch points 
# through the transition network

tr <- transition(sea_r, transitionFunction=mean, directions=8)
tr <- geoCorrection(tr)

# Now we can calculate the cost distance for each launch point to each site
costs <- costDistance(tr, as(villages, 'Spatial'), as(sites, 'Spatial'))


# 5. Assign villages to sites

# the result of costDistance is a matrix showing the calculated distance 
# through the sea from each launch point to each site
# now just need to find nearest site to each village,
# count households per site,
# merge that info into the sites

# Find the index and name of the lowest distance in each row
villages$nearest_site_index <- apply(costs, 1, which.min)
villages$nearest_site_name  <- sites$Name[villages$nearest_site_index]

# Find the total number of buildings  per site and merge that data
# into the sites object
site_load <- aggregate(building_count ~ nearest_site_name, data=villages, 
                       FUN=sum)
sites <- merge(sites, site_load, by.x='Name', by.y='nearest_site_name', 
               all.x=TRUE)

par(mfrow=c(1,1), mar=c(2,2,7,4))
# Now build up a complex plot
plot(st_geometry(kadavu))
# add the villages, colouring by nearest site and showing the village 
# size using the symbol size (cex)
plot(villages['nearest_site_name'], add=TRUE,  
     cex=log10(villages$building_count))
# Add the sites and label with site name and building count
plot(st_geometry(sites), add=TRUE, col='red')
labels <- with(sites, sprintf('%s: %s', Name, building_count))
text(st_coordinates(sites), label=labels, cex=0.7, pos=c(3,3,3,3,3,3,1))

# Add the path for each village to its nearest site
for(idx in seq(nrow(villages))){
   this_village <- as(villages[idx, ], 'Spatial')
   this_village_site <- as(sites[this_village$nearest_site_index, ], 'Spatial')
   journey <- shortestPath(tr, this_village, this_village_site, output='SpatialLines')
   plot(st_as_sfc(journey), add=TRUE, col='grey')
}


## Using ggplot to make maps ----

# tmap package - works in similar way to ggplot -but more focussed on map plotting

# library(ggplot2)
ggplot(ne_110) +
   geom_sf() +
   theme_bw()

sf_use_s2(FALSE)  # hack to prevent error
europe <- st_crop(ne_110, extent(-10,40,35,75))
# there are several ggplot extensions for sf that make plotting maps nicer:
ggplot(europe) +
   geom_sf(aes(fill=log(GDP_MD_EST))) +
   scale_fill_viridis_c() +
   theme_bw() + 
   geom_sf_text(aes(label = ADMIN), pointsize=9, colour = "grey20")


# european life expectancy
# note: map now in a projected coord system (ETRS89/LAEA Europe - EPSG:3035)

europe_laea <- st_transform(europe, 3035)
ggplot(europe_laea) +
   geom_sf(aes(fill=Numeric)) +
   scale_fill_viridis_b() +
   theme_bw()


## Colour palettes ----

# don't use rainbow - not v informative/colour blindness friendly!

# hcl.colors function (see above!) 
hcl.pals()

# viridis package
# in ggplot use scale_color_viridis() or scale_fill_viridis()
# has palettes: viridis, magma, plasma, inferno - use option argument to specify

# brewer
# library(RColorBrewer)
par(mfrow=c(1,1),mar=c(3,3,3,3))
display.brewer.all()
# top spectral = good for coninuous
# second - qualitative paletts for categorical data
# final - equal emphasis on mid-range values as ends - should be used for 
# representing changes in a value, eg temp - where white middle colour shows no change 
display.brewer.all(colorblindFriendly = TRUE)

# can use scale_color_brewer() or scale_fill_brewer() in ggplot
