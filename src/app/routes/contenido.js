const dbConnection = require('../../config/dbConnection');
const nodemailer = require('nodemailer');

module.exports = app => {
  //Const con la conexion con la BD
  const connection = dbConnection();

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    secure: false,
    port: 25,
    auth: {
      user: 'slayerkitty10@gmail.com',
      pass: 'kilosmortales15'
    },
    tls:{
      rejectUnauthorized: false
    }
  });

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
    const {cantidad, equipo, codigo, capacidad, potencia, detalles} = req.body;

    connection.query(`CALL agregarClientes(null, '${nombre}', '${apellido}', null, '${email}', ${telefono});`);
    connection.query(`CALL agregarCotizacion(null, (SELECT idCliente    \
                                                    FROM cliente        \
                                                    ORDER BY idCliente  \
                                                    DESC LIMIT 1),      \
                                                    NOW(), ${cantidad}, '${equipo}', '${codigo}', '${capacidad}', '${potencia}', '${detalles}');`);
    connection.query(`CALL agregarFactura(null, NOW(), (SELECT idCliente FROM cliente ORDER BY idCliente DESC LIMIT 1), 'efectivo');`, 
    (err, result) => {
      if (err){
        console.log(err);
      } else {

        const mailOptions = {
          from: 'slayerkitty10@gmail.com',
          to: 'pinkyfloid0@gmail.com',
          subject: `Solicitud de cotizacion de ${nombre + ' ' + apellido}`,
          html: `<h1>Solicitud de cotizacion</h1>
                <body>
                 <div>
                    <h2>Informacion solicitante</h2>
                    <p><strong>Nombre:</strong> ${nombre + ' ' + apellido}</p>
                    <p><strong>Datos de contacto:</strong></p>
                    <li>Correo eletronico: ${email}</li>
                    <li>Telefono: ${telefono}</li>
                 </div>
                 <div>
                    <h2>Informacion Cotizacion</h2>
                    <p><strong>Equipo: </strong>${equipo}</p>
                    <p><strong>Cantidad de equipos: </strong>${cantidad}</p>
                    <p><strong>Codigo: </strong>${codigo}</p>
                    <p><strong>Capacidad: </strong>${capacidad}</p>
                    <p><strong>Potencia: </strong>${potencia}</p>
                    <p><strong>Detalles: </strong>${detalles}</p>
                 </div>
                </body`
        }
    
        transporter.sendMail(mailOptions, function(error, info){
          if (error){
            console.log(error);
          } else {
            console.log('Email enviado ' + info.response);
          }
        });

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