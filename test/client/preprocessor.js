var cjsx = require('coffee-react');

module.exports = {
  process: function(src, path) {
    if (path.match(/\.cjsx$/)) {
      return cjsx.compile(src, {'bare': true});
    }
    return src;
  }
};
