
module.exports = admin => {

    let sqlNombre = 'SELECT nombre FROM cliente AS C, cotizacion AS COT WHERE C.idCliente = COT.idCliente;';

    connection.query(sqlNombre, (err, result) => {
        if (err) {
            console.log(err);
        } else {
            nombreCliente = result;
        }
    });

    connection.query('SELECT idCotizacion, DATE_FORMAT(fecha, "%d-%m-%Y") AS fecha,\
                     cantidad, equipo, codigo, capacidad, potencia, detalles\
                     FROM cotizacion', 
        (err, result) =>{
        admin.get('/panel/cotizacion', (req, res) => {
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    coti: result,
                    name: nombreCliente,
                    cotizacion: true,
                    cliente: false,
                    pedido: false,
                    factura: false,
                    producto: false
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });
};