import delimited "/Users/afifmazhar/Desktop/UT_Austin_Spring_2022/Time_Series/Research_Paper/Data/college_enrollment_clean.csv"

tsset v1

tsline white
tsline minority
tsline cpi
tsline ip
tsline unrate

gen ln_white = ln(white)
gen dln_white = d.ln_white
gen dln2_white = d.dln_white
rename dln2_white white_

gen ln_minority = ln(minority)
gen dln_minority = d.ln_minority
gen dln2_minority = d.dln_minority
rename dln2_minority minority_

gen d_cpi = d.cpi
gen d_ip = d.ip
gen d_unrate = d.unrate

var d_unrate d_cpi d_ip white_, lags(1/4) // unrate last
varsoc
var white_ d_cpi d_ip d_unrate, lags(1/4) // original submitted
varstable
var white_ d_ip d_cpi d_unrate, lags(1/4) // cpi and ip switched

matrix A = (1,0,0,0 \ .,1,0,0 \ .,.,1,0 \ .,.,.,1)
matrix B = (.,0,0,0 \ 0,.,0,0 \ 0,0,.,0 \ 0,0,0,.)
matrix C = (.,0,0,0 \ .,.,0,0 \ .,.,.,0 \ .,.,.,.)


svar d_unrate d_cpi d_ip white_, lags(1/7) aeq(A) beq(B)
svar white_ d_cpi d_ip d_unrate, lags(1/7) aeq(A) beq(B)
svar white_ d_ip d_cpi d_unrate, lags(1/7) aeq(A) beq(B)

irf create svar1, step(7) set(myGraph1, replace)
irf cgraph (svar1 white_ white_ sirf) (svar1 white_ d_cpi sirf) (svar1 white_ d_ip sirf) (svar1 white_ d_unrate sirf)


var d_unrate d_cpi d_ip minority_, lags(1/4) // unrate last
varsoc
var minority_ d_cpi d_ip d_unrate, lags(1/4) // original submitted
varstable
var minority_ d_ip d_cpi d_unrate, lags(1/4) // cpi and ip switched

svar d_unrate d_cpi d_ip minority_, lags(1/7) aeq(A) beq(B)
svar minority_ d_cpi d_ip d_unrate, lags(1/7) aeq(A) beq(B)
svar minority_ d_cpi d_ip d_unrate, lags(1/7) lreq(C)
svar minority_ d_ip d_cpi d_unrate, lags(1/7) aeq(A) beq(B)


irf create svar2, step(7) set(myGraph1, replace)
irf cgraph (svar2 minority_ minority_ sirf) (svar2 minority_ d_cpi sirf) (svar2 minority_ d_ip sirf) (svar2 minority_ d_unrate sirf)

irf cgraph (svar2 minority_ minority_ sirf) (svar2 minority_ d_cpi sirf) (svar2 minority_ d_ip sirf) (svar2 minority_ d_unrate sirf) (svar2 d_cpi minority_ sirf) (svar2 d_cpi d_cpi sirf) (svar2 d_cpi d_ip sirf)(svar2 d_cpi d_unrate sirf)(svar2 d_ip minority_ sirf)(svar2 d_ip d_cpi sirf)(svar2 d_ip d_ip sirf)(svar2 d_ip d_unrate)(svar2 d_unrate minority_ sirf)(svar2 d_unrate d_cpi sirf)(svar2 d_unrate d_ip sirf)(svar2 d_unrate d_unrate sirf)
