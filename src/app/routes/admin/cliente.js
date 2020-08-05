var nombreCliente;

module.exports = admin => {

    admin.get('/panel/client', (req, res) => {
        connection.query('SELECT * FROM cliente;', (err, result) =>{
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

    admin.post('/insertar/cliente', (req, res) => {
        const {nombre, apellido, email, telefono} = req.body;

        connection.query(`CALL agregarClientes(null, '${nombre}', '${apellido}', null, '${email}', ${telefono})`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/client');
            }
        });
    });

    admin.post('/eliminar/cliente', (req, res) => {
        const {idCliente} = req.body;

        connection.query(`DELETE FROM cliente WHERE idCliente = ${idCliente}`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/client');
            }
        });
    });
}
