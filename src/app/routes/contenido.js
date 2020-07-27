const dbConnection = require('../../config/dbConnection');
const sendMail = require('./sendMail');

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
    const cliente = {nombre, apellido, email, telefono} = req.body;
    const pedido = {cantidad, equipo, codigo, capacidad, potencia, detalles} = req.body;

    connection.query(`CALL agregarClientes(null, '${cliente.nombre}', '${cliente.apellido}', null, '${cliente.email}', ${cliente.telefono});`);
    connection.query(`CALL agregarCotizacion(null, (SELECT idCliente    \
                                                    FROM cliente        \
                                                    ORDER BY idCliente  \
                                                    DESC LIMIT 1),      \
                                                    NOW(), ${pedido.cantidad}, \
                                                    '${pedido.equipo}', '${pedido.codigo}',\
                                                    '${pedido.capacidad}', '${pedido.potencia}',\
                                                    '${pedido.detalles}');`);
    connection.query(`CALL agregarFactura(null, NOW(), (SELECT idCliente FROM cliente ORDER BY idCliente DESC LIMIT 1), 'efectivo');`, 
    (err, result) => {
      if (err){
        console.log(err);
      } else {
        sendMail(cliente, pedido);
        res.redirect('/cotizaciones');
      }
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