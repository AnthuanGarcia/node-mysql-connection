const dbConnection = require('../../config/dbConnection');

module.exports = app => {
  //Const con la conexion con la BD
  const connection = dbConnection();

/* Renderizado de las distintas paginas*/
  app.get('/', (req, res) => {
    res.render('vistas/index');
  }); 

  app.get('/index', (req, res) => {
    res.render('vistas/index');
  });

  app.get('/cotizaciones', (req, res) => {
    res.render('vistas/cotizaciones');
  });

  app.get('/servicios', (req, res) => {
    res.render('vistas/servicios');
  }); 

  app.get('/productos', (req, res) => {
    
    connection.query('SELECT * FROM productos', (err, result) => {
      res.render('vistas/productos', {
        products: result
      });
    });

  });

  app.post('/cotizaciones', (req, res) => {
    const {nombre, apellido, email, telefono} = req.body;
    connection.query(`CALL agregarClientes(null, '${nombre}', '${apellido}', null, '${email}', ${telefono});`);
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