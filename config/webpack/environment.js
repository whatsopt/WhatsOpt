const { environment } = require('@rails/webpacker')

// Add a loader https://github.com/rails/webpacker/blob/master/docs/webpack.md
// ifyLoader required to get a Plotly customized bundle with parcoords
// see https://github.com/plotly/react-plotly.js/issues/148
// see https://github.com/plotly/plotly.js/blob/master/BUILDING.md
const ifyLoader = {
  test: /\.js$/,
  use: 'ify-loader'
};

// Insert ify loader at the end of list
environment.loaders.append('ify', ifyLoader)

module.exports = environment
