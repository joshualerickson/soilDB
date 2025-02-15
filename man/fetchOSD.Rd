% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fetchOSD.R
\name{fetchOSD}
\alias{fetchOSD}
\title{Get Official Series Descriptions and summaries from SoilWeb API}
\usage{
fetchOSD(soils, colorState = "moist", extended = FALSE)
}
\arguments{
\item{soils}{a character vector of named soil series; case-insensitive}

\item{colorState}{color state for horizon soil color visualization: "moist" or "dry"}

\item{extended}{if \code{TRUE} additional soil series summary data are returned, see details}
}
\value{
a \code{SoilProfileCollection} object containing basic soil morphology and taxonomic information.
}
\description{
This function fetches a variety of data associated with named soil series, extracted from the USDA-NRCS Official Series Description text files and detailed soil survey (SSURGO). These data are periodically updated and made available via SoilWeb.
}
\details{
{
\itemize{
\item{\href{https://ncss-tech.github.io/AQP/soilDB/soil-series-query-functions.html}{overview of all soil series query functions}}

\item{\href{https://ncss-tech.github.io/AQP/soilDB/competing-series.html}{competing soil series}}

\item{\href{https://ncss-tech.github.io/AQP/soilDB/siblings.html}{siblings}}
}

The standard set of "site" and "horizon" data are returned as a \code{SoilProfileCollection} object (\code{extended=FALSE}. The "extended" suite of summary data can be requested by setting \code{extended=TRUE}. The resulting object will be a \code{list} with the following elements:)

\describe{
\item{SPC}{\code{SoilProfileCollection} containing standards "site" and "horizon" data}
\item{competing}{competing soil series from the SC database snapshot}
\item{geog_assoc_soils}{geographically associated soils, extracted from named section in the OSD}
\item{geomcomp}{empirical probabilities for geomorphic component, derived from the current SSURGO snapshot}
\item{hillpos}{empirical probabilities for hillslope position, derived from the current SSURGO snapshot}
\item{mtnpos}{empirical probabilities for mountain slope position, derived from the current SSURGO snapshot}
\item{terrace}{empirical probabilities for river terrace position, derived from the current SSURGO snapshot}
\item{flats}{empirical probabilities for flat landscapes, derived from the current SSURGO snapshot}

\item{shape_across}{empirical probabilities for surface shape (across-slope) from the current SSURGO snapshot}
\item{shape_down}{empirical probabilities for surface shape (down-slope) from the current SSURGO snapshot}

\item{pmkind}{empirical probabilities for parent material kind, derived from the current SSURGO snapshot}
\item{pmorigin}{empirical probabilities for parent material origin, derived from the current SSURGO snapshot}
\item{mlra}{empirical MLRA membership values, derived from the current SSURGO snapshot}
\item{climate}{experimental climate summaries from PRISM stack (CONUS only)}

\item{NCCPI}{select quantiles of NCCPI and Irrigated NCCPI, derived from the current SSURGO snapshot}

\item{metadata}{metadata associated with SoilWeb cached summaries}
}

When using \code{extended = TRUE}, there are a couple of scenarios in which series morphology contained in \code{SPC} do not fully match records in the associated series summaries (e.g. \code{competing}).

\describe{

\item{1. A query for soil series that exist entirely outside of CONUS (e.g. PALAU).}{ - Climate summaries are empty \code{data.frames} because these summaries are currently generated from PRISM. We are working on a solution that uses DAYMET.}

\item{2. A query for data within CONUS, but OSD morphology missing due to parsing error (e.g. formatting, typos).}{ - Extended summaries are present but morphology missing from \code{SPC}. A warning is issued.}

}

These last two cases are problematic for analysis that makes use of morphology and extended data, such as outlined in this tutorial on \href{https://ncss-tech.github.io/AQP/soilDB/competing-series.html}{competing soil series}.

}
}
\examples{
\dontshow{if (requireNamespace("curl") && curl::has_internet() && requireNamespace("scales")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontshow{\}) # examplesIf}
\donttest{
  library(aqp)
  # soils of interest
  s.list <- c('musick', 'cecil', 'drummer', 'amador', 'pentz',
              'reiff', 'san joaquin', 'montpellier', 'grangeville', 'pollasky', 'ramona')

  # fetch and convert data into an SPC
  s.moist <- fetchOSD(s.list, colorState='moist')
  s.dry <- fetchOSD(s.list, colorState='dry')

  # plot profiles
  # moist soil colors
  par(mar=c(0,0,0,0), mfrow=c(2,1))
  plot(s.moist, name='hzname',
       cex.names=0.85, axis.line.offset=-4)
  plot(s.dry, name='hzname',
       cex.names=0.85, axis.line.offset=-4)

  # extended mode: return a list with SPC + summary tables
  x <- fetchOSD(s.list, extended = TRUE, colorState = 'dry')

  par(mar=c(0,0,1,1))
  plot(x$SPC)
  str(x, 1)

  # use makeChunks() for iteration over larger sequences of soil series
  s.list <- c('musick', 'cecil', 'drummer', 'amador', 'pentz',
              'reiff', 'san joaquin', 'montpellier', 'grangeville', 'pollasky', 'ramona')

  # make a vector of chunk IDs, with 2 series / chunk
  ck <- makeChunks(s.list, size = 2)

  # split original data by chunk IDs
  # iterate over resulting list
  # run fetchOSD() on pieces
  # result is a list of SoilProfileCollection objects
  x <- lapply(split(s.list, ck), fetchOSD)

  # flatten into a single SPC
  x <- combine(x)

  # there should be 11 profiles
  length(x)
}
}
\references{
USDA-NRCS OSD search tools: \url{https://www.nrcs.usda.gov/wps/portal/nrcs/detailfull/soils/home/?cid=nrcs142p2_053587}
}
\seealso{
\link{OSDquery}, \link{siblings}
}
\author{
D.E. Beaudette, A.G. Brown
}
\keyword{manip}
