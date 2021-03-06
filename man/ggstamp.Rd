% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ggstamp.R
\name{ggstamp}
\alias{ggstamp}
\title{Always stamp your plots with script name}
\usage{
ggstamp(plot, stamp = "no stamp", file, time = Sys.time())
}
\arguments{
\item{plot}{The plot to be stamped.}

\item{stamp}{the script name. Date and time will be added
automatically.}

\item{file}{An optional output filename to be included in the stamp.}

\item{time}{The timestamp to be included.}
}
\value{
the plot with a stamp
}
\description{
This function is used to stamp ggplot type plots with datetime and
script name. User must provide the script name.
}
\details{
The stamp is adding using the caption label. If a caption
    is already in the plot, the stamp will be added in a new
    line.

The caption is derived as
caption=paste(c(plot$label$caption,stamp,paste(date.txt,file)),collapse="\\n")

ggplot 2.2.1 or newer is required.
}
\examples{
library(ggplot2)
data(pksim1,package="pmxtricks")
p1 <- ggIndProfs(pksim1)[[1]]
stamp <- "note"
ggstamp(p1,stamp)
## Or use ggwrite which will call ggstamp automatically.
ggwrite(p1,stamp=stamp,canvas="wide")
}
\seealso{
Other Plotting: 
\code{\link{NMplotBSV}()},
\code{\link{NMplotGOF}()},
\code{\link{canvasSize}()},
\code{\link{extractLegend}()},
\code{\link{ggIndProfs}()},
\code{\link{ggWater}()},
\code{\link{ggwrite}()},
\code{\link{theme_pp_facet}()},
\code{\link{theme_pp}()}
}
\concept{Plotting}
