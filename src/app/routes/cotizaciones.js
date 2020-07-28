const dbConnection = require('../../config/dbConnection');
const sendMail = require('./util/sendMail');

var success = 0;
module.exports = app => {

    const connection = dbConnection();

    app.get('/cotizaciones', (req, res) => {
        res.render('vistas/cotizaciones', {success: success});
        success = false;
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
            res.redirect('/cotizaciones');
            console.log(err);
          } else {
            sendMail(cliente, pedido);
            success = true;
            res.redirect('/cotizaciones');
          }
        });
      });
};