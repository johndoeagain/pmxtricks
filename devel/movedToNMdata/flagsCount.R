##' Create an overview of number of retained and discarded datapoints.
##' @param data The dataset including both FLAG and flag columns.
##' @param tab.flags A data.frame containing at least these named
##'     columns: FLAG, flag, condition. Condition is disregarded for
##'     FLAG==0.
##' @param file A file to write the table of flag counts to. Will
##'     probably be removed and put in a separate function.
##' @param col.id The name of the subject ID column. Default is
##'     "ID".@param col.id The name of the subject ID column. Default
##'     is "ID".
##' @param by An optional column to group the counting by. This could
##'     be "STUDY", "DRUG", "EVID", or a combination of multiple
##'     columns.
##' @param debug Start by calling browser()?
##' @return A summary table with number of discarded and retained
##'     subjects and observations when applying each condition in the
##'     flag table. "discarded" means that the reduction of number of
##'     observations and subjects resulting from the flag, "retained"
##'     means the numbers that are left after application of the
##'     flag. The default is "both" which will report both.
##' @details Notice number of subjects in N.discarded mode can be
##'     misunderstood. If two is reported, it can mean that the
##'     remining one observation of these two subjects are discarded
##'     due to this flag. The majority of the samples can have been
##'     discarded by earlier flags.
##' @import data.table
##' @importFrom utils write.csv


flagsCount <- function(data,tab.flags,file,col.id="ID",by=NULL,debug=F){

    if(debug) browser()

    if(missing(file)) file <- NULL

    stopifnot(is.data.frame(data))
    if(!is.data.table(data)) {
        data <- as.data.table(data)
        data.was.data.frame <- TRUE
    }
    if(!is.data.table(tab.flags)) {
        tab.flags <- as.data.table(tab.flags)
        tab.flags.was.data.frame <- TRUE
    }

    
########## Check tab.init missing ########
    ## ##' @param tab.init If you have already counted something and then
    ## ##'     reduced data. To be documented.
    ## if(!missing(tab.init)){
    ##     if(!is.data.frame(tab.init)) stop("tab.init must be a data.frame")
    ##     names.tab.init <- colnames(tab.init)
    ##     ## It should be checked that classes match.
    ##     if(!all(c("Data","Nobs","NID")%in%names.tab.init)) stop("tab.init must contain columns Data, Nobs, NID.")
    ##     tab.report <- tab.init
    ## } else {
    ##     tab.report <- data.frame(Data="All data",Nobs=nrow(data),NID=data[,uniqueN(get(col.id))])
    ## }
    
######### END Check tab.init ########


    

    tab.flags.0 <- tab.flags[FLAG==0]
    tab.flags <- tab.flags[FLAG!=0]
    ## The smaller the number, the earlier the condition is
    ## applied. This must match what flagsAssign does.
    tab.flags <- tab.flags[order(FLAG)]
    ## tab.flags[,"Nobs"] <- NA_real_
    ## tab.flags[,"NID"] <- NA_real_

    ##    dt.passed <- data[,.(NFlagsPassed=findInterval(FLAG,tab.flags[order(FLAG),FLAG]))]
    data.tmp <- copy(data)

    allres.l <- lapply(1:tab.flags[,.N],function(I){
        resI <- data[FLAG>tab.flags[I,FLAG],.(
                                                N.left=uniqueN(ID),
                                                Nobs.left=.N)
                     ,by=by]
        resI[,FLAG:=tab.flags[I,FLAG]]
        resI
    })
    allres <- rbindlist(allres.l)

  
    allres <- rbind(allres,
                    data[,.(N.left=uniqueN(ID),
                            Nobs.left=.N,
                            FLAG=-Inf),by=by]
                    )

    allres <- allres[order(FLAG)]
    allres[,N.discarded:=c(NA,-diff(N.left)),by=by]
    allres[,Nobs.discarded:=c(NA,-diff(Nobs.left)),by=by]
    
    allres <- rbind(allres,data[FLAG==0,.(FLAG=0,N.left=uniqueN(ID),Nobs.left=.N,N.discarded=NA,Nobs.discarded=NA),by=by],
                    fill=T)
    
    tab.flags <- rbind(tab.flags,data.table(FLAG=-Inf,flag="All data"),fill=TRUE)
### this is how many N/obs are left after the flags/conditions are applied
    allres <- merge(allres,rbind(tab.flags.0,tab.flags)[,.(FLAG,flag)],all.x=T)
    setorderv(allres,c(by,"FLAG"))

    ## tab.flags <- rbind(tab.flags.0,tab.flags,fill=TRUE)
    ## tab.report <- rbind(tab.report,
    ##                     tab.flags[-1,.(Data=paste("After exclusion due to",tolower(flag)),Nobs,NID)]
    ##                     )

    ### select columns to report, depending on argument
    allres[,FLAG:=NULL]
    
    setcolorder(allres,c(by,"flag","N.left","Nobs.left","N.discarded","Nobs.discarded"))

    if(!is.null(file)){
        write.csv(allres,file=file,quote=F,row.names=F)
        cat(paste0("Table written to ",file,"\n"))
    }

    return(allres)

}
