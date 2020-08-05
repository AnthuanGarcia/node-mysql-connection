module.exports = admin => {

    connection.query('SELECT idDetalle, idFactura, P.nombre AS nombre,\
                    detalle.cantidad, precio FROM detalle, productos AS P\
                    WHERE detalle.idProductos = P.idProductos;', (err, result) =>{
        admin.get('/panel/pedido', (req, res) => {
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
};