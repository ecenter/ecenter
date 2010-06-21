from django.db import models
from ecenter_webservice.fields import IPV6AddressField

class Node(models.Model):
    ip_addr = IPV6AddressField(max_length=16, primary_key=True)
    nodename = models.CharField(max_length=765, blank=True)
    ip_noted = models.CharField(max_length=120)
    class Meta:
        db_table = u'node'

class Keyword(models.Model):
    keyword = models.TextField(max_length=765)
    pattern = models.CharField(max_length=765, blank=True)
    class Meta:
        db_table = u'keyword'

class Service(models.Model):
    service = models.BigIntegerField(primary_key=True)
    name = models.CharField(max_length=765)
    url = models.TextField(max_length=765)
    type = models.CharField(max_length=96)
    ip_addr = IPV6AddressField(max_length=16, primary_key=True)
    comments = models.CharField(max_length=765, blank=True)
    is_alive = models.IntegerField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    latitude = models.FloatField(null=True, blank=True)
    created = models.DateTimeField()
    updated = models.DateTimeField()
    class Meta:
        db_table = u'service'

class Eventtype(models.Model):
    ref_id = models.BigIntegerField(primary_key=True)
    eventtype = models.TextField(max_length=765, blank=True)
    service = models.ForeignKey(Service, db_column='service')
    class Meta:
        db_table = u'eventtype'

class KeywordsService(models.Model):
    ref_id = models.BigIntegerField(primary_key=True)
    keyword = models.ForeignKey(Keyword, db_column='keyword')
    service = models.ForeignKey(Service, db_column='service')
    class Meta:
        db_table = u'keywords_service'

class Metadata(models.Model):
    metaid = models.BigIntegerField(primary_key=True)
    perfsonar_id = models.TextField(max_length=765)
    src_ip = models.ForeignKey(Node, db_column='src_ip')
    rtr_ip = IPV6AddressField(max_length=16)
    dst_ip = IPV6AddressField(max_length=16)
    capacity = models.BigIntegerField(null=True, blank=True)
    service = models.ForeignKey(Service, db_column='service')
    subject = models.CharField(max_length=3069)
    parameters = models.CharField(max_length=3069, blank=True)
    class Meta:
        db_table = u'metadata'

class Data(models.Model):
    data = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    param = models.CharField(max_length=765)
    value = models.FloatField()
    class Meta:
        db_table = u'data'

class PingerData(models.Model):
    pinger_data = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    minrtt = models.FloatField(db_column='minRtt') # Field name made lowercase.
    meanrtt = models.FloatField(db_column='meanRtt') # Field name made lowercase.
    medianrtt = models.FloatField(db_column='medianRtt') # Field name made lowercase.
    maxrtt = models.FloatField(db_column='maxRtt') # Field name made lowercase.
    timestamp = models.BigIntegerField()
    minipd = models.FloatField(db_column='minIpd') # Field name made lowercase.
    meanipd = models.FloatField(db_column='meanIpd') # Field name made lowercase.
    maxipd = models.FloatField(db_column='maxIpd') # Field name made lowercase.
    duplicates = models.IntegerField()
    outoforder = models.IntegerField(db_column='outOfOrder') # Field name made lowercase.
    clp = models.FloatField()
    iqripd = models.FloatField(db_column='iqrIpd') # Field name made lowercase.
    losspercent = models.FloatField(db_column='lossPercent') # Field name made lowercase.
    class Meta:
        db_table = u'pinger_data'
        ordering = ('timestamp',)

class BwctlData(models.Model):
    bwctl_data = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    timestamp = models.BigIntegerField()
    throughput = models.FloatField(null=True, blank=True)
    jitter = models.FloatField(null=True, blank=True)
    lost = models.IntegerField(null=True, blank=True)
    sent = models.IntegerField(null=True, blank=True)
    class Meta:
        db_table = u'bwctl_data'
        ordering = ('timestamp',)

class OwampData(models.Model):
    owamp_data = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    timestamp = models.BigIntegerField()
    min = models.FloatField()
    max = models.FloatField()
    minttl = models.IntegerField()
    maxttl = models.IntegerField()
    sent = models.IntegerField()
    lost = models.IntegerField()
    dups = models.IntegerField()
    maxerr = models.FloatField()
    class Meta:
        db_table = u'owamp_data'
        ordering = ('timestamp',)

class SnmpData(models.Model):
    snmp_data = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    timestamp = models.BigIntegerField()
    utilization = models.FloatField()
    errors = models.IntegerField()
    drops = models.IntegerField()
    class Meta:
        db_table = u'snmp_data'
        ordering = ('timestamp',)

class TracerouteData(models.Model):
    trace_id = models.BigIntegerField(primary_key=True)
    metaid = models.ForeignKey(Metadata, db_column='metaid')
    number_hops = models.IntegerField()
    #delay = models.FloatField()
    #created = models.BigIntegerField()
    updated = models.BigIntegerField()
    class Meta:
        db_table = u'traceroute_data'
        get_latest_by = 'updated'
        ordering = ('updated',)

class Hop(models.Model):
    hop_id = models.BigIntegerField(primary_key=True)
    trace = models.ForeignKey(TracerouteData)
    hop_ip = models.ForeignKey(Node, db_column='hop_ip')
    hop_num = models.IntegerField()
    hop_delay = models.FloatField()

    def __str__(self):
        return self.hop_ip.ip_addr

    class Meta:
        db_table = u'hop'
        ordering = ('hop_num',)


