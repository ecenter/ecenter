from django.db import connection, models
from ecenter_webservice import util
from django.utils.datastructures import DictWrapper

class IPV6AddressField(models.Field):
    """
    It seems like a serious limitation/bug that I must do such explicit
    checking.
    """

    empty_strings_allowed = False

    __metaclass__ = models.SubfieldBase

    def db_type(self):
        data = DictWrapper(self.__dict__, connection.ops.quote_name, "qn_")
        return 'varbinary(%(max_length)s)' % data

    def get_internal_type(self):
        return "IPV6AddressField"

    def to_python(self, value):
        #import pdb; pdb.set_trace();
        convert = util.inet6_ntop(value)
        if convert is not None: return convert
        return value

    def get_prep_value(self, value):
        convert = util.inet6_pton(value)
        if convert is not None: return convert
        return value

    """
    def get_prep_lookup(self, lookup_type, value):
        convert = util.inet6_pton(value)
        if convert is not None: return convert
        return value
    """
