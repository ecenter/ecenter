from django.db.models import Q
from django import http
from django.utils.translation import ugettext as _
from piston.handler import BaseHandler
from piston.utils import rc, throttle
from ecenter_webservice import models
from ecenter_webservice import util
import time


class MetadataHandler(BaseHandler):
    """
    Handle metadata requests.
    """
    allowed_methods = ('GET',)

    def read(self, request):

        output = {}
        error_output = {'errors': []}

        if 'src_ip' not in request.GET or util.is_valid_ip_address(request.GET['src_ip']) is False:
            error_output['errors'].append(_('You must specify a valid source IP address.'))
        if 'dst_ip' not in request.GET or util.is_valid_ip_address(request.GET['dst_ip']) is False:
            error_output['errors'].append(_('You must specify a valid destination IP address.'))

        if len(error_output['errors']) > 0:
            return http.HttpResponseBadRequest(error_output)

        # Get metadata and traceroute
        traceroute = models.Hop.objects.extra(join=["join (select td.*, m.src_ip, m.dst_ip from traceroute_data td join metadata m using(metaid) where m.src_ip = inet6_pton('%s') and m.dst_ip = inet6_pton('%s') order by td.updated desc limit 1) td1 using(trace_id)" % (request.GET['src_ip'], request.GET['dst_ip'])])

        metadata = models.Metadata.objects.filter(
            Q(src_ip=request.GET['src_ip']) & Q(dst_ip=request.GET['dst_ip'])
        ).filter(
            Q(service__type='bwctl') | Q(service__type='owamp') |
            Q(service__type='pinger') | Q(service__type='snmp')
        )

        # Return 404 if no data exists
        if len(metadata) is 0 and len(traceroute) is 0:
            return http.HttpResponseNotFound({'errors': [_('No data was found for this query'),]})

        # @TODO: Properly escape input... might be necessary.
        output['out_hops'] = [{'ip': hop.hop_ip.ip_addr, 'num': hop.hop_num, 'delay': hop.hop_delay} for hop in traceroute]

        output['metadata'] = [{
            'metaid': item.metaid,
            'perfsonar_id': item.perfsonar_id,
            'type': item.service.type,
            'service_id': item.service.service,
            'capacity': item.capacity
        } for item in metadata]

        if 'debug' in request.GET:
            from ecenter.settings import DEBUG;
            if DEBUG is True:
                from django.db import connection
                output['query'] = connection.queries

        return output


class DataHandler(BaseHandler):

    allowed_methods = ('GET',)

    def read(self, request, metaid, data_type):
        output = {}
        error_output = {'errors': []}

        if 'start' not in request.GET or 'end' not in request.GET:
            missing_error = "You must specify a start time by using the '%s' querystring parameter."
            if 'start' not in request.GET:
                error_output['errors'].append(_(missing_error % 'start'))
            if 'end' not in request.GET:
                error_output['errors'].append(_(missing_error % 'end'))
            return http.HttpResponseBadRequest(error_output)

        else:
            format = '%Y-%m-%d %H:%M:%S'
            format_error = 'The %s time was incorrectly formatted or invalid. It must be formatted as YYYY-DD-MM HH:mm:ss.'

            try:
                start = time.mktime(time.strptime(request.GET['start'], format))
            except ValueError:
                error_output['errors'].append(_(format_error % 'start'))

            try:
                end = time.mktime(time.strptime(request.GET['end'], format))
            except ValueError:
                error_output['errors'].append(_(format_error % 'end'))

            if len(error_output['errors']) > 0:
                return http.HttpResponseBadRequest(error_output)

            if start > end:
                return http.HttpResponseBadRequest({'errors': [_('The start time may not be after the end time.'),]})

        metadata = models.Metadata.objects.get(metaid=metaid)

        try:
            data = getattr(metadata, "%sdata_set" % data_type)
            result = data.filter(timestamp__gte=start).filter(timestamp__lte=end)

            if (len(result) is 0):
                return http.HttpResponseNotFound({'errors': [_('No data was found for this query'),]})

            output['data'] = result.values()

            if 'debug' in request.GET:
                from ecenter.settings import DEBUG;
                if DEBUG is True:
                    from django.db import connection
                    output['query'] = connection.queries

            return output
        except AttributeError:
            return http.HttpResponseNotFound({'errors': [_("'%s' is not a valid data type.") % data_type,]})

