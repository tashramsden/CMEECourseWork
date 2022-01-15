# Week 5

**Topics covered this week:** [Geographic Information Systems (GIS) and Spatial Methods using R](https://davidorme.github.io/Masters_GIS/intro.html)

Languages: R (version 4.1.2 "Bird Hippie")

Project strcuture: 3 R scripts exploring different aspects of GIS use; GIS data files not in data directory (large files).

Required R packages: `sp`, `rgdal`, `raster`, `sf`, `units`, `rgeos`, `gdistance`, `openxlsx`, `ggplot2`, `RColorBrewer`, `lwgeom`, `sp`, `dismo`, `ncf`, `spdep`, `fastmatrix`, `SpatialPack`, `spatialreg`, `nlme`, `spgwr`, `spmoran`.


## Code Files:

* [**prac1_GIS.R**](code/prac1_GIS.R)
  * Core GIS concepts: vector and raster; converting between data types; spatial joins; plotting.
  * Requires packages: sp, rgdal, raster, sf, units, rgeos, gdistance, openxlsx, ggplot2, RColorBrewer

* [**prac2_spp_distribution_modelling.R**](code/prac2_spp_distribution_modelling.R)
  * Species distribution modelling of tapirs; a BIOCLIM model and glm.
  * Required packages: lwgeom, sp, rgdal, raster, sf, dismo

* [**prac3_spatial_modelling.R**](code/prac3_spatial_modelling.R)
  * Spatial modelling of avian richness in R; testing an autoregressive model, generalised least squares and eigenvector filtering to compensate for spatial autocorrelation.
  * Required packages: ncf, sp, raster, sf, spdep, fastmatrix, SpatialPack, spatialreg, nlme, spgwr, spmoran


## Author

Tash Ramsden | tash.ramsden21@imperial.ac.uk
