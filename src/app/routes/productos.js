const dbConnection = require('../../config/dbConnection');

module.exports = app => {
    const connection = dbConnection();
    
    app.get('/productos', (req, res) => {
    
    connection.query('SELECT * FROM productos', (err, result) => {
      res.render('vistas/productos', {
        products: result
      });
    });

  });
}