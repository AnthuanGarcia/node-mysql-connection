const dbConnection = require('../../config/dbConnection');

module.exports = app => {
    const connection = dbConnection();

    app.get('/productos', (req, res) => {
      connection.query(`SELECT * FROM productos;`, (err, result, fields) => {
        res.render('vistas/productos', {
        products: result
      });
    });
  });

  app.get('/venta/id=:id', (req, res) => {
    const idP = req.params.id;
    connection.query(`SELECT * FROM productos WHERE idProductos = ${idP};`, (err, result) => {
      res.render('vistas/venta', {
        pro: result
      });
    });
  });
}