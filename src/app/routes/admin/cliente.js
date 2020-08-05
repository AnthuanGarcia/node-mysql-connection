var nombreCliente;

module.exports = admin => {

    connection.query('SELECT * FROM cliente;', (err, result) =>{
        admin.get('/panel/client', (req, res) => {
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    cli: result,
                    name: nombreCliente,
                    cliente: true,
                    cotizacion: false,
                    pedido: false,
                    factura: false,
                    producto: false
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });
}
