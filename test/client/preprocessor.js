var transform = require('coffee-react-transform');

module.exports = {
  process: function(src, path) {
    if (path.match(/\.cjsx$/)) {
      return transform(src);
    }
    return src;
  }
};
