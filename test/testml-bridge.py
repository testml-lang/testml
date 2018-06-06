from testml.bridge import TestMLBridge as Base

import rotn;

class TestMLBridge(Base):
  def rot(self, input_, n):
    myrotn = rotn.RotN(input_)
    myrotn.rot(n)
    return myrotn.string;

