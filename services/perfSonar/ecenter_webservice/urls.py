from django.conf.urls.defaults import *
from ecenter_webservice.handlers import *
from piston.resource import Resource

# Django-piston
metadata_handler = Resource(handler=MetadataHandler)
data_handler = Resource(handler=DataHandler)
path_data_handler = Resource(handler=PathDataHandler)
service_handler = Resource(handler=ServiceHandler)

urlpatterns = patterns('',
  url(r'^metadata/$', metadata_handler),
  url(r'^(?P<data_type>[\w-]+)_data/(?P<metaid>\d+)/$', data_handler),
  url(r'^data/$', path_data_handler),
  url(r'^service/(?P<service>\d+)/$', service_handler),
)
