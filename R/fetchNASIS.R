# convenient interface to local NASIS data
# from: pedons | components | lab | ???
# ... : arguments passed on to helper functions


#' Get a pedon or component data SoilProfileCollection from NASIS
#'
#' Fetch commonly used site/pedon/horizon data or component from NASIS,
#' returned as a SoilProfileCollection object.
#'
#' This function imports data from NASIS into R as a
#' \code{SoilProfileCollection} object. It "flattens" NASIS pedon and component
#' tables, including their child tables, into several more easily manageable
#' data frames. Primarily these functions access the local NASIS database using
#' an ODBC connection. However using the \code{fetchNASIS()} argument
#' \code{from = "pedon_report"}, data can be read from the NASIS Report
#' 'fetchNASIS', as either a txt file or url. The primary purpose of
#' \code{fetchNASIS(from = "pedon_report")} is to facilitate importing datasets
#' larger than 8000+ pedons/components.
#'
#' The value of \code{nullFragsAreZero} will have a significant impact on the
#' rock fragment fractions returned by fetchNASIS. Set \code{nullFragsAreZero =
#' FALSE} in those cases where there are many data-gaps and \code{NULL} rock
#' fragment values should be interpreted as \code{NULL}. Set
#' \code{nullFragsAreZero = TRUE} in those cases where \code{NULL} rock
#' fragment values should be interpreted as 0.
#'
#' This function attempts to do most of the boilerplate work when extracting
#' site/pedon/horizon or component data from a local NASIS database. Pedons
#' that are missing horizon data, or have errors in their horizonation are
#' excluded from the returned object, however, their IDs are printed on the
#' console. Pedons with combination horizons (e.g. B/C) are erroneously marked
#' as errors due to the way in which they are stored in NASIS as two
#' overlapping horizon records.
#'
#' Tutorials:
#'
#'  - [fetchNASIS Pedons Tutorial](http://ncss-tech.github.io/AQP/soilDB/fetchNASIS-mini-tutorial.html)
#'  - [fetchNASIS Components Tutorial](http://ncss-tech.github.io/AQP/soilDB/NASIS-component-data.html)
#'
#' @aliases fetchNASIS get_phorizon_from_NASIS_db
#' get_phfmp_from_NASIS_db get_RMF_from_NASIS_db
#' get_concentrations_from_NASIS_db
#' 
#' @param from determines what objects should fetched? ('pedons' | 'components' | 'pedon_report')
#' @param url string specifying the url for the NASIS pedon_report (default:
#' `NULL`)
#' @param SS fetch data from the currently loaded selected set in NASIS or from
#' the entire local database (default: `TRUE`)
#' @param rmHzErrors should pedons with horizon depth errors be removed from
#' the results? (default: `FALSE`)
#' @param nullFragsAreZero should fragment volumes of `NULL` be interpreted as `0`?
#' (default: `TRUE`), see details
#' @param soilColorState Used only for `from='pedons'`; which colors should be used to generate the convenience field `soil_color`? (`'moist'` or `'dry'`)
#' @param mixColors should mixed colors be calculated (Default: `TRUE`) where multiple colors are populated for the same moisture state in a horizon? `FALSE` takes the dominant color for each horizon moist/dry state.
#' @param lab should the `phlabresults` child table be fetched with
#' site/pedon/horizon data (default: `FALSE`)
#' @param fill include pedon or component records without horizon data in result? (default: `FALSE`)
#' @param dropAdditional Used only for `from='components'` with `duplicates=TRUE`. Prevent "duplication" of `mustatus=="additional"`  mapunits? Default: `TRUE`
#' @param dropNonRepresentative Used only for `from='components'` with `duplicates=TRUE`. Prevent "duplication" of non-representative data mapunits? Default: `TRUE`
#' @param duplicates Used only for `from='components'`. Duplicate components for all instances of use (i.e. one for each legend data mapunit is used on; optionally for additional mapunits, and/or non-representative data mapunits?). This will include columns from `get_component_correlation_data_from_NASIS_db()` that identify which legend(s) a component is used on.
#' @param stringsAsFactors deprecated
#' @param dsn Optional: path to local SQLite database containing NASIS table structure; default: `NULL`
#' @return A SoilProfileCollection object
#' @seealso `get_component_data_from_NASIS()`
#' @author D. E. Beaudette, J. M. Skovlin, S.M. Roecker, A.G. Brown
#' 
#' @export fetchNASIS
fetchNASIS <- function(from = 'pedons',
                       url = NULL,
                       SS = TRUE,
                       rmHzErrors = FALSE,
                       nullFragsAreZero = TRUE,
                       soilColorState = 'moist',
                       mixColors = TRUE,
                       lab = FALSE,
                       fill = FALSE,
                       dropAdditional = TRUE,
                       dropNonRepresentative = TRUE,
                       duplicates = FALSE,
                       stringsAsFactors = NULL,
                       dsn = NULL) {

  res <- NULL
  
  if (!missing(stringsAsFactors) && is.logical(stringsAsFactors)) {
    .Deprecated(msg = sprintf("stringsAsFactors argument is deprecated.\nSetting package option with `NASISDomainsAsFactor(%s)`", stringsAsFactors))
    NASISDomainsAsFactor(stringsAsFactors)
  }
  
  # TODO: do we need _View_1 tables in the sqlite table snapshot? Could be handy for
  #       specialized selected sets crafted by NASIS/CVIR stuff; currently you are allowed
  #       to specify the selected set for a SQLite database, and I suppose the convention
  #       should be for those tables to be there, even if empty

  # if (!is.null(dsn))
  #   SS <- FALSE

  # sanity check
  if (!from %in% c('pedons', 'components', 'pedon_report')) {
    stop('Must specify: pedons, components or pedon_report', call. = FALSE)
  }

  if (from == 'pedons') {
    # pass arguments through
    res <- .fetchNASIS_pedons(SS = SS,
                              fill = fill, 
                              rmHzErrors = rmHzErrors,
                              nullFragsAreZero = nullFragsAreZero,
                              soilColorState = soilColorState,
                              mixColors = mixColors,
                              lab = lab,
                              dsn = dsn)
  }

  if (from == 'components') {
    # pass arguments through
    res <- .fetchNASIS_components(SS = SS,
                                  rmHzErrors = rmHzErrors,
                                  nullFragsAreZero = nullFragsAreZero,
                                  fill = fill,
                                  dsn = dsn,
                                  dropAdditional = dropAdditional,
                                  dropNotRepresentative = dropNonRepresentative,
                                  duplicates = duplicates)
  }

  if (from == 'pedon_report') {
    # pass arguments through
    res <- .fetchNASIS_report(url              = url,
                              rmHzErrors       = rmHzErrors,
                              nullFragsAreZero = nullFragsAreZero,
                              soilColorState   = soilColorState,
                              )
  }

  return(res)

}
