import socket
"""
Utility functions for ecenter

These functions act as wrapper around the native Python inet_pton and inet_ntop
functions to provide a single interface for encoding IPv4 and IPv6 addresses.
"""

def is_valid_ip_address(n):
    ipv4 = ipv6 = False

    try:
        socket.inet_pton(socket.AF_INET6, n)
        ipv6 = True
    except (ValueError, TypeError, socket.error):
        pass

    try:
        socket.inet_pton(socket.AF_INET, n)
        ipv4 = True
    except (ValueError, TypeError, socket.error):
        pass

    return ipv6 or ipv4

def inet6_pton(p):
    try:
        return socket.inet_pton(socket.AF_INET6, p)
    except (ValueError, TypeError, socket.error):
        pass

    try:
        return socket.inet_pton(socket.AF_INET, p)
    except (ValueError, TypeError, socket.error):
        pass

    return None

def inet6_ntop(n):
    try:
        return socket.inet_ntop(socket.AF_INET6,  n)
    except (ValueError, TypeError, socket.error):
        pass

    try:
        return socket.inet_ntop(socket.AF_INET, n)
    except (ValueError, TypeError, socket.error):
        pass

    return None

# @TODO the following two functions may not be necessary, but will be kept
# around until I'm sure we don't need them!
def pairs(lst):
    """See: http://stackoverflow.com/questions/1257413/iterate-over-pairs-in-a-list-circular-fashion-in-python"""
    i = iter(lst)
    first = prev = i.next()
    for item in i:
        yield prev, item
        prev = item
    yield item, first

def product(*args, **kwds):
    """See: http://docs.python.org/library/itertools.html"""
    # product('ABCD', 'xy') --> Ax Ay Bx By Cx Cy Dx Dy
    # product(range(2), repeat=3) --> 000 001 010 011 100 101 110 111
    pools = map(tuple, args) * kwds.get('repeat', 1)
    result = [[]]
    for pool in pools:
        result = [x+[y] for x in result for y in pool]
    for prod in result:
        yield tuple(prod)

