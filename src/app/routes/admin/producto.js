module.exports = admin => {

    connection.query('SELECT * FROM productos;', (err, result) =>{
        admin.get('/panel/producto', (req, res) => {
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    prod: result,
                    name: nombreCliente,
                    cliente: false,
                    cotizacion: false,
                    pedido: false,
                    factura: false,
                    producto: true
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });
};