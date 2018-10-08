
# Shut the imports up!
devnull <- file('/dev/null','w')

sink(file = devnull,type = 'message')

require(stringr)
require(glue)

require(tools)

require(jsonlite)
require(redux)

require(tokenizers)

require(AgnusGlareTool)
require(ComfyInTurns)
require(DBgratia)

# Utility stuff ####################

scriptpath <- ComfyInTurns::myPath()

config <- readLines('stdin')%>%
	fromJSON()

chunksize <- config$chunksize
key <- config$redis$listkey

sink(type = 'message')

# Read my functions ################

dirname(scriptpath)%>%
	paste('lib/as.sentence.df.R',sep = '/')%>%
	source()

# Redis stuff ######################

sink(devnull)
redis_config(host = config$redis$hostname,
	     port = config$redis$port,
	     db = config$redis$db)
sink()

redis <- hiredis()

# Process data #####################

agtWrapper <- function(df){
	df <- AgnusGlareTool::as.sentence.df(df)
	df$body <- df$sentence
	df$sentence <- NULL

	df

	}

DBgratia::redisChunkApply(redis,
			  key,
			  FUN = agtWrapper, 
			  chunksize = chunksize,
			  verbose = TRUE)

