lx = 0
ly = 0
ux = 199.88
uy = 300.96

f = open("pinList", "r")
cont = f.read()
f.close()

metal5Name = "metal5"
metal6Name = "metal6"

def GetPointInfo( location, lx, ly, ux, uy ):
  width = ux - lx
  height = uy - ly

  # (lx, ly) ~ (lx, uy)
  if 0 <= location and location < height:
    return [lx ,  ly + location, metal5Name]
  # (lx, uy) ~ (ux, uy)
  elif height <= location and location < height + width:
    return [lx + location - height, uy, metal6Name]
  # (ux, uy) ~ (ux, ly)
  elif height + width <= location and location < 2*height + width:
    return [ux, uy -(location - (height + width)), metal5Name]
  # (ux, ly) ~ (lx, ly)
  elif 2*height + width <= location and 2*height + 2*width:
    return [ux - (location - (2*height + width)), ly, metal6Name]


pinList = []
for curPin in cont.split("\n"):
  if curPin == "":
    continue
  pinList.append( curPin )

print( pinList )
totalLength = 2*(ux - lx) + 2*(uy - ly)
spacing = totalLength / len(pinList)

eventLoc = 0

writeCont = ""
for curPin in pinList: 
  xyPoint = GetPointInfo(eventLoc, lx, ly, ux, uy)
  writeCont += curPin + " "
  writeCont += "%.5f " % (xyPoint[0])
  writeCont += "%.5f " % (xyPoint[1])
  writeCont += "%s\n" % (xyPoint[2])
  eventLoc += spacing
print( writeCont )
