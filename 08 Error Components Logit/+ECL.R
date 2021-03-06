# -----------------------------------
# Code for a Error Components Logit
# 
# Jeff Dumont & Jeff Keller
#
# -----------------------------------

library(RSGHB)

# ------------------
# DATA PREPARATION
# ------------------
# assumes that respondents are identified with a ID column
# also assumes that the data is sorted by respondent then experiment
choicedata <- read.table("ecl_simulated.csv", sep = ",", header = TRUE)

# Specify any variables here that you'd like to use in the
# utility equations in the likelihood function below
# These can be any variables within the data or transformations of
# those variables
x1 <- choicedata$x1
x2 <- choicedata$x2
x3 <- choicedata$x3
y1 <- choicedata$y1
y2 <- choicedata$y2
y3 <- choicedata$y3

# The choice vectors
# Dummying coding the choice vector allows for easier coding of the 
# the likelihood calculations. So we will have one column for each 
# alternative in the design
choice1 <- (choicedata$choice == 1)
choice2 <- (choicedata$choice == 2)
choice3 <- (choicedata$choice == 3)

# ----------------------------------------
# ESTIMATION CONTROL
# Setting control list for estimation
# ?doHB for more estimation options
# ----------------------------------------

modelname <- "Error Components"	# used for output

# Names for the random variables
gVarNamesNormal <- c("Bx", "By", "EC")


# For each variable, specify the distribution for its coefficient
# The options are:
# 1. normal
# 2. log-nomal
# 3. negative log-normal
# 4. normal with all values below zero massed at zero
# 5. Johnson SB with a specified min and max
# gDIST must have an entry for each value in gVarNamesNormal

gDIST <- c(1, 1, 1)

# STARTING VALUES
FC <- c()           # for the fixed coefficients
svN <- c(0, 0, 0)   # for the random coefficients
                    # The selection of the mean here is important when working with non-normal distributions

# Here you can specify random parameters to have fixed means
# Note that a NA represents unconstrained estimation of the mean value
fixedA <- c(NA, NA, 0)

# ITERATION SETTINGS
gNCREP    <- 5000  	# Number of iterations to use prior to convergence
gNEREP    <- 5000 	# Number of iterations to keep for averaging after convergence has been reached
gNSKIP    <- 1			# Number of iterations to do in between retaining draws for averaging
gINFOSKIP <- 100    # How frequently to print info about the iteration process

# CONTROL LIST TO PASS TO doHB
control <- list(
     modelname = modelname,
     gVarNamesNormal = gVarNamesNormal,
     gDIST = gDIST,
     svN = svN,
     gNCREP = gNCREP,
     gNEREP = gNEREP,
     gNSKIP = gNSKIP,
     gINFOSKIP = gINFOSKIP,
     fixedA = fixedA,
     gSeed = 1987
)


# ----------------------------------------------------------------------------------------
# likelihood
# USE:     Calculates the likelihood of choice | B
#          Returns likelihood values for each observation
# NOTES:   This is where the bulk of the computation resides so coding this efficiently
#          is essential to reducing run time.
# ----------------------------------------------------------------------------------------
likelihood <- function(fc, b) {

  cc <- 1
  Bx  <- b[, cc]; cc <- cc + 1
  By  <- b[, cc]; cc <- cc + 1
  EC  <- b[, cc]; cc <- cc + 1
  
  v1 <- Bx * x1 + By * y1 + EC
  v2 <- Bx * x2 + By * y2 + EC
  v3 <- Bx * x3 + By * y3
 
  p <- (exp(v1)*choice1 + exp(v2)*choice2 + exp(v3)*choice3) / (exp(v1) + exp(v2) + exp(v3))
	
  return(p)
}

# Estimate the model
model <- doHB(likelihood, choicedata, control)

# Plot model statistics
plot(model)
plot(model, type = "A")

# Save model object
save(model, file = paste0(model$modelname, ".RData"))

# Save in CSV format (Sawtooth-esque)
writeModel(model)
