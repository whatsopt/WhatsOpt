const { environment } = require('@rails/webpacker');

// Add a loader https://github.com/rails/webpacker/blob/master/docs/webpack.md
// ifyLoader required to get a Plotly customized bundle with parcoords
// see https://github.com/plotly/react-plotly.js/issues/148
// see https://github.com/plotly/plotly.js/blob/master/BUILDING.md
const ifyLoader = {
  test: /\.js$/,
  use: 'ify-loader',
};

// Insert ify loader at the end of list
environment.loaders.append('ify', ifyLoader);

// Fix: ApiDoc Swagger UI page error : TypeError: _ is not a function
// Due to double transpilation of dompurify, a swagger-ui-react dependency
// To Avoid babel loader transpiling node-modules
// https://github.com/mapbox/mapbox-gl-js/issues/3422#issuecomment-577293154
// https://github.com/rails/webpacker/blob/54c3ca9245e9ee330f8ca63b447c202290f7b624/docs/v4-upgrade.md#excluding-node_modules-from-being-transpiled-by-babel-loader
environment.loaders.delete('nodeModules');

module.exports = environment;
