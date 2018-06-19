var indexOf = [].indexOf;

global.RotN = class RotN {
  constructor(string) {
    this.string = string;
  }

  rot(n) {
    var code, i, j, offset, orig, ref, rotn;
    rotn = '';
    for (i = j = 0, ref = this.string.length; (0 <= ref ? j < ref : j > ref); i = 0 <= ref ? ++j : --j) {
      orig = code = this.string.charCodeAt(i);
      if (indexOf.call((function() {
        var results = [];
        for (var k = 65; k <= 90; k++){ results.push(k); }
        return results;
      }).apply(this), code) >= 0 || indexOf.call((function() {
        var results = [];
        for (var k = 97; k <= 122; k++){ results.push(k); }
        return results;
      }).apply(this), code) >= 0) {
        offset = code >= 97 ? 97 : 65;
        code = (code - offset + n % 26) % 26 + offset;
      }
      //code = (code - offset + ((n % 26)+26)%26) % 26 + offset
      rotn += String.fromCharCode(code);
    }
    this.string = rotn;
    return this;
  }

};
