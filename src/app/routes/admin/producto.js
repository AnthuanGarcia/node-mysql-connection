module.exports = admin => {

    admin.get('/panel/producto', (req, res) => {
        connection.query('SELECT * FROM productos;', (err, result) =>{
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

    admin.post('/insertar/producto', (req, res) => {
        const {nombre, precioPro, descripcion} = req.body;

        connection.query(`CALL agregarProductos(null, '${nombre}', null, ${precioPro}, '${descripcion}')`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/producto');
            }
        });
    });

    admin.post('/eliminar/producto', (req, res) => {
        const {idProducto} = req.body;

        connection.query(`DELETE FROM productos WHERE idProductos = ${idProducto};`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/producto');
            }
        });
    });
};