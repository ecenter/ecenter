# -*- coding: utf-8 -*-
"""
Last modified on Sunday, September 11, 2011

@author: mfrey
"""
# This code is an implementation of flow field forecasting (FFF) for a 
# univariate time series. The generic input for flow field forecasting 
# is a sequence of n times with the observations obtained for those 
# times. Additionally, the desired time for the forecast must be given. 
# The present code makes an arbitrary placeholder choice of desired
# forecast time and fabricates a sequence (there is a choice of two)
# of observations for n=1000 times. Reasonable numbers of observation
# times are between n=200 and n=2000. Less than n=200 time observations
# is likely to yield forecasts with uselessly high standard errors.
#
# The present code gives a verbose graphical output of the FFF results.
# This output can be tailored (or eliminated and replaced by a numerical
# forecast) in any particular application depending on final decisions
# about what to present to the user. 
#
# This code makes only one external call: to GPR3err in GPRmodule.
# GPR3err contains the code necessary for making a Gaussian process
# regression (GPR) prediction with an attendant standard error. In
# applications where no formal error analysis is required, GPR3err can
# be simplified to execute faster.
# 
# FFF is described in the paper "Introducing Flow Field Forecasting" by
# Michael Frey and Kyle Caudle, 10th International Conference on Machine
# Learning, Honolulu, Hawaii, Dec. 18-21, 2011.
#
import simplejson as json
import numpy as np
import scipy as sp
#
from scipy import *
from numpy import *
from scipy import linalg
from GPRmodule import GPR3err
#
def fff(times1, obs1, numfut=10):
#
#---------translate-true-times-to-generic-times----
    times = map(lambda x: int(x), times1)
    obs=map(lambda x: float(x),  obs1)
    print 'Times:', times, "\n Data:", obs
    n = len(times)                                   # number of observations
    mnn = times[0]                                   # time of 1st observation
    mxx = times[-1]                                  # time of last observation
    spc = (mxx-mnn)/(n-1.0)                          # spacing of true times
#
    if n<30: #--------regression-forecast----------
        t = (times-mnn)/spc                          # generic times start at 0
        fut = n+arange(0,numfut)                     # generic forecast times 
        z = (fut-average(t))/std(t)                  # standardized
        forecast = average(obs)*ones(numfut)         # regression forecasts
        sderr = std(obs)*sqrt(1.0+1.0/n+z*z/(n+1))
        futtim = mxx+spc*arange(1,numfut+1)          # true times for forecasts
        return{'sderr': list(sderr), 'times':  map(lambda i: int(i), futtim), 'forecast' : list(forecast)}
#
    else: #----------------FF-forecast-------------
        if n<1000:
            kn = 4+(n>40)+(n>50)+(n>60)+(n>75)+(n>90)
            kn = kn + (n>105)+(n>120)+(n>135)+(n>150)
            kn = kn + (n>165)+(n>180)+(n>200)+(n>220)
            kn = kn + (n>240)+(n>260)+(n>280)+(n>300)
            kn = kn + (n>325)+(n>350)+(n>375)+(n>400)
            kn = kn + (n>440)+(n>480)+(n>520)+(n>560)
            kn = kn + (n>600)+(n>640)+(n>680)+(n>720)
            kn = kn + (n>760)+(n>800)+(n>840)+(n>880)
            kn = kn + (n>920)+(n>960)                # number of knots (tuned)
        else:
            kn = n/25                                # number of knots (tuned)
#
        start = n/(2*kn)
        gt = start+arange(0,n)                       # generic times
        (k,DELT)=linspace(0,n-1,kn+1,retstep=True)   # DELT is knot spacing
        k = k[1:]                                    # knot times (locations)
        y = obs                                      # usual name
#    
#--------------penalized-spline-smooth-------------
        gt = matrix(gt).T
        o = matrix(ones((n,1)))
        us = lambda x: (sign(x)+1)/2                 # unit step function
        ramp = lambda x: multiply(x,us(x))           # ramp function
        X = append(o,gt,axis=1)                      # design matrix
        X = append(X,ramp(gt-k),axis=1)              # add basis functions
        R = matrix(linalg.cholesky(X.T*X))
        D = eye(kn+2)
        D[0,0] = 0
        D[1,1] = 0
        Rinv = R.I
        U,s,Vh = linalg.svd(Rinv.T*D*Rinv)
        U = matrix(U)
        A = X*Rinv*U
        y = matrix(y).T
        bb = A.T*y
#
#---------------find-optimal-lambda----------------
        def cv(lam):
            lam2 = lam**2
            H = A*diag(1/(1+lam2*s))*A.T             # hat matrix
            f = H*y
            res = y-f                                # residuals
            h = diag(H,0)                            # leverages
            return sum(np.array(res/(1-h))**2)       # returns cv
#
        from scipy.optimize import brent
        lamopt = brent(cv,tol=1e-5,maxiter=10)       # scalar function minimizer
        lam2 = lamopt**2
        b = Rinv*U*diag(1/(1+lam2*s))*bb             # parameter estimates
#
#------------------estimate-sigma-----------------
        fit = A*bb                                   # fits with lam=0
        rss = sum(np.array(y-fit)**2)                # residual sum-of-squares
        df = n-kn-2
        sig = sqrt(rss/df)                           # estimate of sigma
#
#----------------get-skeleton-data----------------
        accum = lambda n: matrix(tri(n))             # triangular matrix of ones
        delta = accum(kn+1)*b[1:]
        s = matrix(array(b[0])*ones((kn+1,1)))
        s[1:] = s[1:]+DELT*accum(kn)*delta[:kn]      # skeleton
# 
#--------------prepare-to-forecast----------------
        t = array([k[-1]+DELT])                      # first future time
        fn = s[-1]+DELT*delta[-1]                    # new predicted level
        f = array(fn)                                # 1st future level
        omg = []
        d3 = array(delta[-3:])                       # most recent 3 delta's
        s3 = append(array(s[-2:]),fn)                # most recent 3 levels
#
#--------------flow-field-forecast----------------
        M = numfut                                   # usual name
        for i in range(2,M+1):                       # remaining M-1 pred levels
            test = append(s3,d3)                     # test point for GPR
            [deltstar,omega] = GPR3err(s[1:],delta[:-1],delta[3:],test)
            fn = fn+DELT*deltstar                    # new predicted level
            omg = append(omg,omega)                  # for error bounds
            d3 = append(d3[-2:],deltstar)            # new most recent 3 delta's
            s3 = append(s3[-2:],fn)                  # new most recent 3 levels
            t = append(t,t[-1]+DELT)                 # updated future times
            f = append(f,fn)                         # updated future levels
        forecast = f                                 # output label
#
#------------calculate-standard-errors------------  
        sderr = array(sig)
        sderr = append(sderr,sqrt(sig**2+DELT**2*delta.var()*(arange(1,len(omg)+1)-omg.cumsum())))
        futtim = mnn+spc*t                           # translate to true times
        return{'sderr': list(sderr), 'times':  map(lambda i: int(i), futtim), 'forecast' : list(forecast) }

def main():
    """
    A test harness for this module.
    """
    test_file=  open('bwctl2.json')
    json_content = json.load(test_file)
    data = json_content["bwctl"]
    print json.dumps(data["198.129.254.30"]["198.124.252.117"]["data"])
    times = []
    bw = []
    for timestamp in data["198.129.254.30"]["198.124.252.117"]["data"]:
      times.append(timestamp)
      bw.append(data["198.129.254.30"]["198.124.252.117"]["data"][timestamp]["throughput"])
    print json.dumps(fff( times,  bw, 10))
if __name__ == '__main__':
    main()
