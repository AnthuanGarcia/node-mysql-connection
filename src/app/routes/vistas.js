const dbConnection = require('../../config/dbConnection');

module.exports = app => {

  const connection = dbConnection();

  app.get('/', (req, res) => {

    connection.query('SELECT * FROM productos', (err, result) => {
      res.render('vistas/index', {
        ver: result
      });
    });
  });

  app.post('/vistas', (req, res) => {
    const {idProductos, nombre, cantidad, precioPro, descripcion} = req.body;
    connection.query('INSERT INTO productos SET?', {
      idProductos,
      nombre,
      cantidad,
      precioPro,
      descripcion
    }, (err, result) => {
      res.redirect('/');
    });
  });
}