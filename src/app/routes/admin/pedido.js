module.exports = admin => {
    
    admin.get('/panel/pedido', (req, res) => {
        connection.query('SELECT idDetalle, idFactura, P.nombre AS nombre,\
                    detalle.cantidad, precio FROM detalle, productos AS P\
                    WHERE detalle.idProductos = P.idProductos\
                    ORDER BY idDetalle ASC;', (err, result) =>{
            console.log(err);
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    deta: result,
                    name: nombreCliente,
                    cliente: false,
                    cotizacion: false,
                    pedido: true,
                    factura: false,
                    producto: false
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });

    admin.post('/insertar/pedido', (req, res) => {
        const {idFactura, idProductos, cantidad} = req.body;

        const precio = `(SELECT precioPro FROM productos WHERE idProductos = ${idProductos})`;

        connection.query(`CALL NewPedido(null, ${idFactura}, ${idProductos}, ${cantidad}, ${precio})`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/pedido');
            }
        });
    });

    admin.post('/eliminar/pedido', (req, res) => {
        const {idDetalle} = req.body;

        connection.query(`DELETE FROM detalle WHERE idDetalle = ${idDetalle};`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/pedido');
            }
        });
    });

};