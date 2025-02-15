% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fetchSoilGrids.R
\name{fetchSoilGrids}
\alias{fetchSoilGrids}
\title{Get SoilGrids 250m properties information from point locations}
\usage{
fetchSoilGrids(
  x,
  loc.names = c("id", "lat", "lon"),
  verbose = FALSE,
  progress = FALSE
)
}
\arguments{
\item{x}{A \code{data.frame} containing 3 columns referring to site ID, latitude and longitude.}

\item{loc.names}{Optional: Column names referring to site ID, latitude and longitude. Default: \code{c("id","lat","lon")}}

\item{verbose}{Print messages? Default: \code{FALSE}}

\item{progress}{logical, give progress when iterating over multiple requests; Default: \code{FALSE}}
}
\value{
A SoilProfileCollection
}
\description{
This function obtains SoilGrids properties information (250m raster resolution) given a \code{data.frame} containing site IDs, latitudes and longitudes. SoilGrids API and maps return values as whole (integer) numbers to minimize the storage space used. These values are converted by to produce conventional units by `fetchSoilGrids()``
}
\details{
\subsection{Properties}{\tabular{lllrl}{
   Name \tab Description \tab Mapped units \tab Conversion factor \tab Conventional units \cr
   bdod \tab Bulk density of the fine earth fraction \tab cg/cm^3 \tab 100 \tab kg/dm^3 \cr
   cec \tab Cation Exchange Capacity of the soil \tab mmol(c)/kg \tab 10 \tab cmol(c)/kg \cr
   cfvo \tab Volumetric fraction of coarse fragments (> 2 mm) \tab cm^3/dm^3 (vol per mil) \tab 10 \tab cm^3/100cm^3 (vol\%) \cr
   clay \tab Proportion of clay particles (< 0.002 mm) in the fine earth fraction \tab g/kg \tab 10 \tab g/100g (\%) \cr
   nitrogen \tab Total nitrogen (N) \tab cg/kg \tab 100 \tab g/kg \cr
   phh2o \tab Soil pH \tab pH*10 \tab 10 \tab pH \cr
   sand \tab Proportion of sand particles (> 0.05 mm) in the fine earth fraction \tab g/kg \tab 10 \tab g/100g (\%) \cr
   silt \tab Proportion of silt particles (= 0.002 mm and = 0.05 mm) in the fine earth fraction \tab g/kg \tab 10 \tab g/100g (\%) \cr
   soc \tab Soil organic carbon content in the fine earth fraction \tab dg/kg \tab 10 \tab g/kg \cr
   ocd \tab Organic carbon density \tab hg/m^3 \tab 10 \tab kg/m^3 \cr
   ocs \tab Organic carbon stocks \tab t/ha \tab 10 \tab kg/m^2 \cr
}


SoilGrids predictions are made for the six standard depth intervals specified in the GlobalSoilMap IUSS working group and its specifications. The depth intervals returned are: \code{"0-5cm", "5-15cm", "15-30cm", "30-60cm", "60-100cm", "100-200cm"} and the properties returned are \code{"bdod", "cec", "cfvo", "clay", "nitrogen", "phh2o", "sand", "silt", "soc"} -- each with 5th, 50th, 95th, mean and uncertainty values. The uncertainty values are the ratio between the inter-quantile range (90\% prediction interval width) and the median : \code{(Q0.95-Q0.05)/Q0.50.} Point data requests are made through \code{properties/query} endpoint of the \href{https://www.isric.org/explore/soilgrids/faq-soilgrids}{SoilGrids v2.0 REST API}. Please check ISRIC's data policy, disclaimer and citation: \url{https://www.isric.org/about/data-policy}.

Find out more information about the SoilGrids and GlobalSoilMap products here:
\itemize{
\item \url{https://www.isric.org/explore/soilgrids/faq-soilgrids}
\item \url{https://www.isric.org/sites/default/files/GlobalSoilMap_specifications_december_2015_2.pdf}
}
}
}
\examples{
\dontshow{if (requireNamespace("curl") && curl::has_internet()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontshow{\}) # examplesIf}
\dontrun{

  your.points <- data.frame(id  = c("A", "B"), 
                           lat = c(37.9, 38.1), 
                           lon = c(-120.3, -121.5), 
                           stringsAsFactors = FALSE)
  x <- try(fetchSoilGrids(your.points))
 
  library(aqp)
  if (!inherits(x, 'try-error'))
   plotSPC(x, name = NA, color = "socQ50")
}
}
\references{
Poggio, L., de Sousa, L. M., Batjes, N. H., Heuvelink, G. B. M., Kempen, B., Ribeiro, E., and Rossiter, D.: SoilGrids 2.0: producing soil information for the globe with quantified spatial uncertainty, SOIL, 7, 217-240, 2021. \doi{https://doi.org/10.5194/soil-7-217-2021}
}
\author{
Andrew G. Brown
}
