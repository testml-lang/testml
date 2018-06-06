var TestMLBridge;

require('testml/bridge');

require('rotn');

module.exports = TestMLBridge = class TestMLBridge extends TestML.Bridge {
  rot(input, n) {
    var rotn;
    rotn = new RotN(input);
    rotn.rot(n);
    return rotn.string;
  }

};
