module.exports = admin => {

    const nombreCliente = '(SELECT C.nombre FROM cliente AS C, factura AS F WHERE C.idCliente = F.idCliente)'

    admin.get('/panel/factura', (req, res) => {
        connection.query('SELECT idFactura, DATE_FORMAT(fecha, "%d %m %Y") AS fecha, \
                    C.nombre AS nombre, tipoPago FROM factura, cliente AS C\
                    WHERE factura.idCliente = C.idCliente\
                    ORDER BY idFactura ASC;', (err, result) => {
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

    admin.post('/insertar/factura', (req, res) => {
        const {fecha, idCliente, tipoPago} = req.body;

        connection.query(`CALL agregarFactura(null, '${fecha}', ${idCliente}, '${tipoPago}');`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/factura');
            }
        });
    });

    admin.post('/eliminar/factura', (req, res) => {
        const {idFactura} = req.body;

        connection.query(`DELETE FROM detalle WHERE idFactura = ${idFactura};`, (err, result) => {if(err){console.log(err);}});

        connection.query(`DELETE FROM factura WHERE idFactura = ${idFactura};`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/factura');
            }
        });
    });

};