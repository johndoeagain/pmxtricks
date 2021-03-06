##' Select only wanted columns - If any of them are missing, tell the user
##' which ones.
##'
##' This is just a wrapper to data[,vars]. But first it checks if vars are in
##' data. And if not it is reported in an error to the user. This saves you the
##' manual investigation every time data[,vars] gives you the annoyingly
##' non-informative error "undefined columns selected".
##' 
##' @param data data.frame or data.table to select columns from.
##' @param vars columns to select. A vector of characters.
##' @family DataWrangling
##' @export

selectVars <- function(data,vars){
    if(!all(vars%in%names(data))){
        stop(paste("\nThe following variables are missing in data:",vars[!vars%in%names(data)]))
    }
    if("data.table"%in%class(data)){
        out <- data[,vars,with=FALSE]
    } else {
        out <- data[,vars]
    }
    return(out)
}

