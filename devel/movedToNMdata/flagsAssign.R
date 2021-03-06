##' Assign exclusion flags to a dataset based on specified table
##'
##' The aim with this function is to take a (say PK) dataset and a pre-specified
##' table of flags, assign the flags automatically.
##'
##' @param data The dataset to assign flags to.
##' @param tab.flags A data.frame containing at least these named columns: FLAG,
##'     flag, condition. Condition is disregarded for FLAG==0.
##' @param return.all If TRUE, both the edited dataset and the table of flags
##'     are returned. If FALSE (default) only the edited dataset is returned.
##' @param LLOQ At the moment a list with FLAG, condition, and LLOQ (value). If
##'     it does not contain "flag", flag will be set to "Value below LLOQ". LLOQ
##'     can only handle one value of LLOQ. This is insuffiecient for PKPD
##'     datasets. Likely to change.
##' @param col.id The name of the subject ID column. Default is "ID".
##' @param col.dv The name of the data value column. Default is "DV".
##' @param debug Start by calling browser()?
##' @return The dataset with flags added. See parameter flags.return as well.
##' @import data.table

####### TODO #######


## Per default, should not overwrite already assigned FLAG. User may
## have hardcoded some flags already.

## check that all PKdata$FLAG have a value matching tab.flags$FLAG. Then merge
## on the flag values.

## Check that tab.flags contain a numeric called FLAG and a character/factor
## called flag.

## Check that FLAG, flag, and condition contain unique values

## Add an increasing variable to PKdata so we can arrange the observations
## exactly as they were to begin with.

## arrange back to original order

## This function must handle NA ID's and maybe FAS as well.

## If EVID is present, only treat EVID==0. Or maybe better group by EVID.

#### End TODO ########



##### removed argument: fas.ids=NULL

flagsAssign <- function(data,tab.flags,return.all=F,LLOQ=NULL,col.id="ID",col.dv="DV",debug=F){
    if(debug) browser()
    

##################### CHECKS START ######################

####### Check data ######
    if(!is.data.frame(data)){stop("data must be a data.frame")}
    ## make sure data is a data.table
    data <- as.data.table(data)
    datacols <- colnames(data)
    if(!col.id%in%datacols) stop("data must contain a column name matching the argument col.id.")
    ## Check NA ids. I think this requires that col.id has length 1
    stopifnot(length(col.id)==1)
    if(data[,any(is.na(..col.id))]||is.character(data[,is.character(..col.id)])&&data[,any(..col.id=="")]) stop("col.id contains missing (NA's or empty strings). You must fix this first.")

    if(!col.dv%in%datacols) stop(paste(col.dv,"does not exist. Please see argument col.dv."))

### data can contain a column named FLAG - but it is removed
    if("FLAG"%in%datacols) {
        message("Data contains FLAG already. This is overwritten")
        data[,"FLAG"] <- NULL
    }
    if("flag"%in%datacols) {
        message("Data contains flag already. This is overwritten")
        data[,"flag"] <- NULL
    }
    
##### End Check data #######


####### Check tab.flags ####
    ## Check that tab.flags contain a numeric called FLAG and a character/factor called flag.
    if(!is.data.frame(tab.flags)||!(all(c("FLAG","flag","condition")%in%colnames(tab.flags)))){
        stop("tab.flags must be a data.frame containing FLAG, flag, and condition.")
    }

    
###### Check that FLAG, flag, and condition contain unique values

#### FLAG cannot be negative
    ## if(any(tab.flags[,"FLAG"]<0)) stop("FLAG contains negative values. Not allowed.")

####### END Check tab.flags ####

    ## make sure tab.flags and data are data.tables
        tab.flags <- as.data.table(tab.flags)
    
    
####################### CHECKS END ######################

### add an increasing variable to data so we can arrange the observations
### exactly as they were to begin with.
#### save order for re-arranging in the end
    ## TODO: create this column name by making sure it does not exist
    col.row <- tmpcol(data)
    data[,(col.row):=1:.N ]
#### 


    
    
### FLAG==0 cannot be customized. If not in table, put in table. Return the
### table as well. Maybe a reduced table containing only used FLAGS
    if(!0%in%tab.flags[,"FLAG"]) {tab.flags <- rbind(
                                      data.frame(FLAG=0,flag="Keep in analysis",condition=NA_character_),
                                      tab.flags,
                                      fill=T)
    }
    tab.flags[FLAG==0,condition:=NA_character_]

    
    ## If a FLAG is not zero and does not have a condition, it is not used.
    tab.flags <- tab.flags[FLAG==0|(!is.na(condition)&condition!="")]
    tab.flags <- tab.flags[order(FLAG),]

    tab.flags[,condition.used := paste0("FLAG==0&(",tab.flags[,condition],")")]
    tab.flags[FLAG==0,condition.used:=NA_character_]

    
### assigning the flags
    data[,FLAG:=0]
    tab.flags.0 <- tab.flags[FLAG==0]
    tab.flags <- tab.flags[FLAG!=0]
    
    tab.flags[,Nmatched:=NA_real_]
    tab.flags[,Nobs:=NA_real_]
    tab.flags[,NID:=NA_real_]
    for(fn in 1:tab.flags[,.N]){
        message(paste("Coding FLAG =",tab.flags[fn,FLAG]))
        ## find all affected columns
        is.matched <- try(with(data,eval(parse(text=tab.flags[fn,condition.used]))),silent=T)
        if("try-error"%in%class(is.matched)){
            warning(attr(is.matched,"condition")$message)
            next
        }
        if(any(is.na(is.matched))) stop("Evaluation of criterion returned NA. Missing values in columns used for evaluation?")
        tab.flags[fn,Nmatched:=sum(is.matched)]
        ## data[with(data,eval(parse(Data="FLAG==0&TIME<=0|NTIM<=0"))),"FLAG"] <- tab.flags[fn,"FLAG"]
        data[is.matched,FLAG:=tab.flags[fn,FLAG]]
        tab.flags[fn,Nobs:=data[FLAG==0,.N]]
        tab.flags[fn,NID:=data[FLAG==0,uniqueN(col.id)]]
    }

    tab.flags.0[,Nmatched:=data[FLAG==0,.N]]
    
    tab.flags <- rbind(tab.flags,tab.flags.0,fill=T)

### check that all data$FLAG have a value matching tab.flags$FLAG. Then merge on the flag values.
    if(any(is.na(data[,FLAG]))) {
        cat("NA's found in FLAG after assigning FLAGS. This should not happen. Bug in flagsAssign?\n")
        print(subset(data,is.na(FLAG)))
        stop("NA's found in data$FLAG after assigning FLAGS. Bug in flagsAssign?")
    }

    ##    browser()
    
    dim0 <- dim(data)
    data <- mergeCheck(data,unique(tab.flags[,c("FLAG","flag")]),all.x=T,by="FLAG")
    stopifnot(all(dim(data)==(dim0+c(0,1))))
### arrange back to original order
    setorderv(data,col.row)
    data[,(col.row):=NULL]
    
    
    if(return.all){
        return(list(data,tab.flags))
    } else {
        return(data)
    }

}

