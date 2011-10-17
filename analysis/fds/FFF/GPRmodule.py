# -*- coding: utf-8 -*-
"""
Created on Tue Jun 14 2011

@author: mfrey
"""
# GPR does a Gaussian process regression for 1 predictor.
# This module accepts the following inputs:
#
#      x = column matrix of predictor values
#      y = column matrix of corresponding responses
#      t = column matrix of test points (where predictions are made)
#      ell = characteristic length
#
# This module outputs the column matrix f of GPR predictions
# corresponding to the test points. The GPR implemented here
# uses the squared exponential covariance model.
#
import numpy as np
from scipy import *
from numpy import *
def GPR(x,y,t,ell):
    K = exp(-array(x-x.T)**2/(2.0*ell**2))
    K = K+(1e-8)*np.eye(len(x))                        # ensure pos. def.
    R = matrix(linalg.cholesky(K))
    kstar = matrix(exp(-array(x-t.T)**2/(2.0*ell**2)))
    v = matrix(linalg.solve(R,kstar))
    w = matrix(linalg.solve(R,y))
    f = v.T*w  
    return f
    
# GPR3 does a Gaussian process regression for 2 predictors
# and their first and second delays. This module accepts the
# following inputs:
#
#      x = column matrix of 1st predictor values
#      d = column matrix of 1st predictor values
#      y = column matrix of corresponding responses
#      t = [tx2,tx1,tx0,td2,td1,td0] six test point components
#
# This module outputs the column matrix f of GPR predictions
# corresponding to the test points. The GPR implemented here
# uses the squared exponential covariance model.
#
# Note: the length of y should be 2 less than the lengths
# of x and d.
#    
# Note: ell = characteristic length (in standard units) of covariance
#
def GPR3(x,d,y,t):
    ell = 0.5
    x0 = x[2:]
    x1 = x[1:-1]
    x2 = x[:-2]
    d0 = d[2:]
    d1 = d[1:-1]
    d2 = d[:-2]
    tx2,tx1,tx0,td2,td1,td0 = t
    sqx = array(x0-x0.T)**2 + array(x1-x1.T)**2 + array(x2-x2.T)**2
    sqd = array(d0-d0.T)**2 + array(d1-d1.T)**2 + array(d2-d2.T)**2
    K = exp(-sqx/(2.0*x.var()*ell**2)-sqd/(2.0*d.var()*ell**2))
    K = K+(1e-10)*np.eye(len(x)-2)                        # ensure pos. def.
    R = matrix(linalg.cholesky(K))
    sqx = array(x0-tx0)**2 + array(x1-tx1)**2 + array(x2-tx2)**2
    sqd = array(d0-td0)**2 + array(d1-td1)**2 + array(d2-td2)**2
    kstar = exp(-sqx/(2.0*x.var()*ell**2)-sqd/(2.0*d.var()*ell**2))
    v = matrix(linalg.solve(R,kstar))
    w = matrix(linalg.solve(R,y))
    f = v.T*w  
    return f
#
def GPR3err(x,d,y,t):
    ell = 0.5
    x0 = x[2:]
    x1 = x[1:-1]
    x2 = x[:-2]
    d0 = d[2:]
    d1 = d[1:-1]
    d2 = d[:-2]
    tx2,tx1,tx0,td2,td1,td0 = t
    sqx = array(x0-x0.T)**2 + array(x1-x1.T)**2 + array(x2-x2.T)**2
    sqd = array(d0-d0.T)**2 + array(d1-d1.T)**2 + array(d2-d2.T)**2
    K = exp(-sqx/(2.0*x.var()*ell**2)-sqd/(2.0*d.var()*ell**2))
    K = K+(1e-10)*np.eye(len(x)-2)                        # ensure pos. def.
    R = matrix(linalg.cholesky(K))
    sqx = array(x0-tx0)**2 + array(x1-tx1)**2 + array(x2-tx2)**2
    sqd = array(d0-td0)**2 + array(d1-td1)**2 + array(d2-td2)**2
    kstar = exp(-sqx/(2.0*x.var()*ell**2)-sqd/(2.0*d.var()*ell**2))
    v = matrix(linalg.solve(R,kstar))
    w = matrix(linalg.solve(R,y))
    f = v.T*w
    omega = v.T*v
    return [f,omega]
