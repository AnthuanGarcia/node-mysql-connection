module.exports = admin => {

    const nombreCliente = '(SELECT C.nombre FROM cliente AS C, factura AS F WHERE C.idCliente = F.idCliente)'

    connection.query('SELECT idFactura, DATE_FORMAT(fecha, "%d %m %Y") AS fecha, \
                    C.nombre AS nombre, tipoPago FROM factura, cliente AS C\
                    WHERE factura.idCliente = C.idCliente;', (err, result) => {
        admin.get('/panel/factura', (req, res) => {
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    factu: result,
                    name: nombreCliente,
                    cliente: false,
                    cotizacion: false,
                    pedido: false,
                    factura: true,
                    producto: false
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });
};