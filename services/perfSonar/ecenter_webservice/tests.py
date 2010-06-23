from ecenter_webservice import util

__test__ = {"doctest": """
The E-Center webservice application provides a RESTful webservice frontend
to network data.

We need to validate and convert IPv6 and IPv4 addresses back and forth between
binary and string representations of the data. These utility functions are
critical for interacting with the database, as the internal representation of
any IP address in the database is varbinary(16).

IPv4 addresses should validate properly:

>>> util.is_valid_ip_address('74.125.95.105')
True

So should IPv6 addresses, including mixed and shorthand notation:

>>> util.is_valid_ip_address('2001:0db8:85a3:08d3:1319:8a2e:0370:7334')
True
>>> util.is_valid_ip_address('e3d7::51f4:9bc8:192.168.100.32')
True

Just as important, we don't want false positives:

>>> util.is_valid_ip_address('74.125.95')
False
>>> util.is_valid_ip_address('74.125.95.256')
False

>>> util.is_valid_ip_address('2001:0db8:85a3:08d3:1319:8a2e:0370')
False
>>> util.is_valid_ip_address('2001:0db8:85a3:08d3:1319:8a2e:0370:7s73')
False

We hould be able to convert back and forth between the binary and IPv4
or IPv6 representation of an address.

>>> util.inet6_pton('131.225.70.2')
'\\x83\\xe1F\\x02'
>>> util.inet6_ntop('\\x83\\xe1F\\x02')
'131.225.70.2'
>>> util.inet6_pton('2001:fecd:ba23:cd1f:dcb1:1010:9234:4088')
' \\x01\\xfe\\xcd\\xba#\\xcd\\x1f\\xdc\\xb1\\x10\\x10\\x924@\\x88'
>>> util.inet6_ntop(' \\x01\\xfe\\xcd\\xba#\\xcd\\x1f\\xdc\\xb1\\x10\\x10\\x924@\\x88')
'2001:fecd:ba23:cd1f:dcb1:1010:9234:4088'

You can provide mixed notation for conversion TO binary:

>>> util.inet6_pton('e3d7::51f4:9bc8:192.168.100.32')
'\\xe3\\xd7\\x00\\x00\\x00\\x00\\x00\\x00Q\\xf4\\x9b\\xc8\\xc0\\xa8d '

But you should always get standard notation back:

>>> util.inet6_ntop('\\xe3\\xd7\\x00\\x00\\x00\\x00\\x00\\x00Q\\xf4\\x9b\\xc8\\xc0\\xa8d ')
'e3d7::51f4:9bc8:c0a8:6420'

"""}

