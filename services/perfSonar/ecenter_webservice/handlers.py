from django.db.models import Q
from django import http
from django.utils.translation import ugettext as _
from piston.handler import BaseHandler
from piston.utils import rc, throttle
from ecenter_webservice import models
from ecenter_webservice import util
import time

ENABLED_SERVICES = ('bwctl', 'owamp', 'pinger', 'snmp',)

class EcenterHandler(BaseHandler):
    def debug_query(self, request, output = {}):
         if 'debug' in request.GET:
            from django.conf import settings
            if settings.DEBUG is True:
                from django.db import connection
                output['query'] = connection.queries

    def validate_ip(self, request, errors = []):
        if 'src_ip' not in request.GET or util.is_valid_ip_address(request.GET['src_ip']) is False:
            errors.append(_('You must specify a valid source IP address.'))
        if 'dst_ip' not in request.GET or util.is_valid_ip_address(request.GET['dst_ip']) is False:
            errors.append(_('You must specify a valid destination IP address.'))
        return errors

    def validate_date(self, request, errors = []):
        start = 0; end = 0
        if 'start' not in request.GET or 'end' not in request.GET:
            if 'start' not in request.GET:
                errors.append(_("You must specify a start time by using the 'start' querystring parameter."))
            if 'end' not in request.GET:
                errors.append(_("You must specify an end time by using the 'end' querystring parameter."))
        else:
            format = '%Y-%m-%d %H:%M:%S'
            format_error = 'The %s time was incorrectly formatted or invalid. It must be formatted as YYYY-DD-MM HH:mm:ss.'

            try:
                start = time.mktime(time.strptime(request.GET['start'], format))
            except ValueError:
                errors.append(_(format_error % 'start'))

            try:
                end = time.mktime(time.strptime(request.GET['end'], format))
            except ValueError:
                errors.append(_(format_error % 'end'))

            if start > 0 and end > 0 and start > end:
                errors.append(_('The start time may not be after the end time.'))

        return start, end, errors


class MetadataHandler(EcenterHandler):
    """
    Handle metadata requests.
    """
    allowed_methods = ('GET',)

    def read(self, request):
        output = {}

        # Check for errors
        errors = self.validate_ip(request)
        if len(errors) > 0:
            return http.HttpResponseBadRequest({'errors' : errors})

        # Get metadata and traceroute
        traceroute = models.Hop.objects.extra(join=["join (select td.*, m.src_ip, m.dst_ip from traceroute_data td join metadata m using(metaid) where m.src_ip = inet6_pton('%s') and m.dst_ip = inet6_pton('%s') order by td.updated desc limit 1) td1 using(trace_id)" % (request.GET['src_ip'], request.GET['dst_ip'])])

        metadata = models.Metadata.objects.filter(
            Q(src_ip=request.GET['src_ip']) & Q(dst_ip=request.GET['dst_ip'])
        ).filter(
            service__type__in=ENABLED_SERVICES
        )

        # Return 404 if no data exists
        if len(metadata) is 0 and len(traceroute) is 0:
            return http.HttpResponseNotFound({'errors': [_('No data was found for this query'),]})

        # @TODO: Properly escape input... might be necessary.
        output['out_hops'] = [{'ip': hop.hop_ip.ip_addr, 'num': hop.hop_num, 'delay': hop.hop_delay} for hop in traceroute]

        output['metadata'] = [{
            'metaid': item.metaid,
            'perfsonar_id': item.perfsonar_id,
            'service_type': item.service.type,
            'service_id': item.service.service,
            'capacity': item.capacity
        } for item in metadata]

        self.debug_query(request, output)
        return output


class DataHandler(EcenterHandler):
    allowed_methods = ('GET',)

    def read(self, request, metaid, data_type):
        output = {}

        if data_type not in ENABLED_SERVICES:
            return http.HttpResponseNotFound({'errors': [_("'%s' is not a valid data type.") % data_type,]})

        start, end, errors = self.validate_date(request)
        if len(errors) > 0:
            return http.HttpResponseBadRequest({'errors' : errors})

        metadata = models.Metadata.objects.get(metaid=metaid)
        data = getattr(metadata, "%sdata_set" % data_type)
        result = data.filter(timestamp__gte=start).filter(timestamp__lte=end)

        if (len(result) is 0):
            return http.HttpResponseNotFound({'errors': [_('No data was found for this query'),]})

        output['data'] = result.values()
        self.debug_query(request, output)
        return output


class PathDataHandler(EcenterHandler):
    allowed_methods = ('GET',)

    def read(self, request):
        output = {'data': {}}

        start, end, errors = self.validate_date(request)
        self.validate_ip(request, errors)

        if len(errors) > 0:
            return http.HttpResponseBadRequest({'errors' : errors})

        metadata = models.Metadata.objects.filter(
            Q(src_ip=request.GET['src_ip']) & Q(dst_ip=request.GET['dst_ip'])
        ).filter(
            service__type__in=ENABLED_SERVICES
        )

        for service in ENABLED_SERVICES:
            filtered_metadata = metadata.filter(service__type=service)
            if len(filtered_metadata) > 0:
                output['data'][service] = []
                for item in filtered_metadata:
                    data = getattr(item, "%sdata_set" % service)
                    result = data.filter(timestamp__gte=start).filter(timestamp__lte=end)
                    output['data'][service] += result.values()
                if len(output['data'][service]) is 0:
                    del output['data'][service]

        if (len(output['data']) is 0):
            return http.HttpResponseNotFound({'errors': [_('No data was found for this query'),]})

        self.debug_query(request, output)
        return output


class ServiceHandler(EcenterHandler):
    """
    Handle metadata requests.
    """
    allowed_methods = ('GET',)
    model = models.Service

    def read(self, request, service):
        output = {}
        output['service'] = models.Service.objects.get(service=service)
        self.debug_query(request, output)
        return output
