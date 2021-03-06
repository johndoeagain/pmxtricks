##' Calculate coefficient of variation of data
##'
##' @param x The data @param log If TRUE, the geometric coefficient of variation
##'     is calculated. This is sqrt(exp(var(log(x))-1).
##' @param log If true, a geometric CV is derived.
##' @details This function is intended to be used on data. For a log-normal
##'     THETA[1]*EXP(OMEGA[1]) Nonmem parameter, do CV=sqrt(exp(OMEGA[1,1])-1).
##' @importFrom stats var sd
##' @family Calc
##' @export


CV <- function(x,log=F) {
    if(log){
        cv <- sqrt(exp(var(log(x)))-1)
    } else {
        cv <- sd(x)/mean(x)
    }
    cv
}
