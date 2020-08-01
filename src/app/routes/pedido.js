const dbConnection = require('../../config/dbConnection');
const sendMail = require('./util/sendMail');

var success = 0;
var idPro;
var nombrePro;

module.exports = app => {

    const connection = dbConnection();

    app.get('/pedido/id=:id/name=:name', (req, res) => {
      idPro = req.params.id;
      nombrePro = req.params.name;

      res.render('vistas/pedido',{success:success});
      success = false;
      });

    app.post(`/pedido`, (req, res) => {
      const cliente = {nombre, apellido, email, telefono} = req.body;
      const pedido = {cantidad} = req.body;
      pedido["idP"] = idPro;
      pedido["name"] = nombrePro;

      let ultFactura = '(SELECT idFactura FROM factura ORDER BY idFactura DESC LIMIT 1)';
      let precioProducto = `(SELECT precioPro FROM productos WHERE idProductos = ${pedido.idP})`; 

      connection.query(`CALL agregarClientes(null, '${cliente.nombre}', \
                                            '${cliente.apellido}', null,\
                                            '${cliente.email}', ${cliente.telefono})`);
      connection.query(`CALL agregarFactura(null, NOW(), (SELECT idCliente FROM cliente ORDER BY idCliente DESC LIMIT 1), 'efectivo');`);
      connection.query(`CALL NewPedido(null, ${ultFactura}, ${pedido.idP}, ${pedido.cantidad}, ${precioProducto})`, 
      (err, result) => {
        if (err){
          res.redirect('/index');
          console.log(err);
        } else {
          sendMail(cliente, pedido);
          success = true;
          res.redirect('/pedido/id=:id/name=:name');
        }
      });
    });
  
  }