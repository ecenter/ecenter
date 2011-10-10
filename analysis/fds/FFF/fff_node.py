# -*- coding: utf-8 -*-
"""
Last modified on 10/07/2011

@author: maxim
"""

import gearman
import FFF
import simplejson as json

def forecast(gearman_worker, gearman_job):
  data_json = json.loads(gearman_job.data)
  print  data_json['times'], data_json['data']
  return json.dump(fff(data_json['times'], (lambda x: x.__dict__, data_json['data']), int(data_json['future_points'])))


gm_worker = gearman.GearmanWorker(['xenmon.fnal.gov:10121'])
gm_worker.register_task('forecast', forecast)
gm_worker.work()


