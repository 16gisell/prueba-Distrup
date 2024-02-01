module.exports = {
    stats: 'minimal',
    entry: {
      application: './app/javascript/packs/application.js', // Ruta archivo JS principal
    },
    output: {
      filename: mode === 'production' ? '[name]-[contenthash].js' : '[name]-[hash].js',
      path: __dirname + '/public/packs', // Ruta de salida para los archivos compilados
    },
    node:{
        __dirname: false,
        __filename: false,
        global:true
    }
  }