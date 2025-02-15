#' @title Retrieve Soil Series Extent Maps from SoilWeb
#' 
#' @description This function downloads a generalized representations of a soil series extent from SoilWeb, derived from the current SSURGO snapshot. Data can be returned as vector outlines (`sf` object) or gridded representation of area proportion falling within 800m cells (`SpatRaster` object). Gridded series extent data are only available in CONUS. Vector representations are returned with a GCS/WGS84 coordinate reference system and raster representations are returned with an Albers Equal Area / NAD83 coordinate reference system (`EPSG:5070`).
#' 
#' @param s a soil series name, case-insensitive
#' @param type series extent representation, `'vector'`: results in an `sf` object and `'raster'` results in a `SpatRaster` object
#' @param timeout time that we are willing to wait for a response, in seconds
#' @param as_Spatial Return sp (`SpatialPolygonsDataFrame`) / raster (`RasterLayer`) classes? Default: `FALSE`.
#' @return An R spatial object, class depending on `type` and `as_Spatial` arguments
#' @references \url{https://casoilresource.lawr.ucdavis.edu/see/}
#' @author D.E. Beaudette
#' @examplesIf requireNamespace("curl") && curl::has_internet() && requireNamespace("terra") && requireNamespace("sf")
#' @export
#' @examples
#' \donttest{
#'   
#'   # specify a soil series name
#'   s <- 'magnor'
#'   
#'   # return an sf object
#'   x <- seriesExtent(s, type = 'vector')
#'   
#'   # return a terra SpatRasters
#'   y <- seriesExtent(s, type = 'raster')
#'   
#'   library(terra)
#'   if (!is.null(x) && !is.null(y)) {
#'     x <- terra::vect(x)
#'     # note that CRS are different
#'     terra::crs(x)
#'     terra::crs(y)
#'   
#'     # transform vector representation to CRS of raster
#'     x <- terra::project(x, terra::crs(y))
#'   
#'     # graphical comparison
#'     par(mar = c(1, 1 , 1, 3))
#'     plot(y, axes = FALSE)
#'     plot(x, add = TRUE)
#'   }
#' }
seriesExtent <- function(s, type = c('vector', 'raster'), timeout = 60, 
                         as_Spatial = getOption('soilDB.return_Spatial', default = FALSE)) {
  
  # download timeout should be longer than default (13 seconds) 
  h <- .soilDB_curl_handle(timeout = timeout)
  
  # sanity check on type
  type <- match.arg(type)
  
  # encode series name: spaces -> underscores
  s <- gsub(pattern = ' ', replacement = '_', x = tolower(s), fixed = TRUE)
  
  # select type of output
  # ch: this is a shared curl handle with options set
  res <- switch(
    type,
    vector = {.vector_extent(s, ch = h, as_Spatial = as_Spatial)},
    raster = {.raster_extent(s, ch = h, as_Spatial = as_Spatial)}
  )
  
  return(res)
}

# 2022-08-15: converted from download.file() -> curl::curl_download() due to SSL errors
.vector_extent <- function(s, ch, as_Spatial) {
  
  if (!requireNamespace("sf")) 
    stop("package sf is required to return vector series extent grids", call. = FALSE)
  
  # base URL to cached data
  u <- URLencode(paste0('http://casoilresource.lawr.ucdavis.edu/series-extent-cache/json/', s, '.json'))
  
  # init temp files
  tf <- tempfile(fileext = '.json')
  
  # safely download GeoJSON file
  res <- tryCatch(
    curl::curl_download(url = u, destfile = tf, quiet = TRUE, handle = ch),
    error = function(e) {
      warning(e)
      return(e)
      }
  )

  # trap errors
  if (inherits(res, 'error')) {
    message('no data returned')
    return(NULL)
  }
    
  # load into sf object and clean-up
  # can use terra::vect() also
  x <- sf::st_read(tf, quiet = TRUE)
  unlink(tf)
  
  # reset row names in attribute data to series name
  rownames(x) <- as.character(x$series)
  
  if (as_Spatial) {
    x <- sf::as_Spatial(x)
  }
  
  # GCS WGS84
  return(x)
}

# 2022-08-15: converted from download.file() -> curl::curl_download() due to SSL errors
.raster_extent <- function(s, ch, as_Spatial) {
  
  if (!requireNamespace("terra")) 
    stop("package terra is required to return raster series extent grids", call. = FALSE)
  
  # base URL to cached data
  u <- URLencode(paste0('http://casoilresource.lawr.ucdavis.edu/series-extent-cache/grid/', s, '.tif'))
  
  # init temp files
  tf <- tempfile(fileext = '.tif')
  
  # safely download GeoTiff file
  # Mac / Linux: file automatically downloaded via binary transfer
  # Windows: must manually specify binary transfer
  res <- tryCatch(
    curl::curl_download(url = u, destfile = tf, quiet = TRUE, handle = ch),
    error = function(e) {
      warning(e)
      return(e)
    }
  )
  
  # trap errors
  if (inherits(res, 'error')) {
    message('no data returned')
    return(NULL)
  }
  
  # init SpatRaster
  x <- terra::rast(tf)
  
  # load all values into memory
  terra::values(x) <- terra::values(x)
  
  # remove tempfile 
  unlink(tf)
  
  # transfer layer name
  names(x) <- gsub(pattern = '_', replacement = ' ', x = s, fixed = TRUE)
  
  # make CRS explicit
  terra::crs(x) <- 'EPSG:5070'
  
  if (as_Spatial) {
    if (requireNamespace("raster", quietly = TRUE)) {
      x <- raster::raster(x) 
    } else {
      stop("Package `raster` is required to return raster data as a RasterLayer object with soilDB.return_Spatial=TRUE")
    }
  }
  
  return(x)
}

