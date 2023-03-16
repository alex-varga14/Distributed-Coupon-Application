import base64

def toBase64(string):
    b = string.encode("ascii")
    bb = base64.b64encode(b)
    return bb.decode("ascii")

def fromBase64(b64):
    bb = b64.encode("ascii")
    b = base64.b64decode(bb)
    return(b.decode("ascii"))

