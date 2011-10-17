#!/bin/env python
import gearman
import optparse
from FFF import fff
import simplejson as json

def forecast(gearman_worker, gearman_job):
  data_json = json.loads(gearman_job.data)
  results = fff(data_json['times'], data_json['data'], int(data_json['future_points']))
  print  "Results: ", results
  return json.dumps(results)

parser = optparse.OptionParser()
parser.add_option('--g_host', dest='g_host', default='xenmon.fnal.gov', help='Gearman server hostname')
parser.add_option('--host', dest='host', default='ecenterprod1.fnal.gov', help='DRS server hostname')
parser.add_option('--port', dest='port', default='10121', help='Gearman server port' )
parser.add_option('--db', dest='db', default='ecenterprod1.fnal.gov', help='where db is located' )
parser.add_option('--debug', dest='debug',   help='debug info' )
args,remainder = parser.parse_args()
if args.debug > 0:
  parser.print_help() 
print "Server:", args.g_host, ':', args.port
gm_worker = gearman.GearmanWorker([args.g_host + ':' + args.port])
gm_worker.register_task('forecast', forecast)
gm_worker.work()


