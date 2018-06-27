// Generated by CoffeeScript 2.3.1
(function() {
  require('../../pegex/receiver');

  require('../../pegex/tree');

  Pegex.Tree.Wrap = class Wrap extends Pegex.Receiver {
    gotrule(got) {
      if (got === void 0) {
        return;
      }
      return {
        [`${this.parser.rule}`]: got
      };
    }

    final(got) {
      if (got !== void 0) {
        return got;
      }
      return {
        [`${this.parser.rule}`]: []
      };
    }

  };

}).call(this);