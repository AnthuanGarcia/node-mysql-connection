
module.exports = admin => {

    let sqlNombre = 'SELECT nombre FROM cliente AS C, cotizacion AS COT WHERE C.idCliente = COT.idCliente;';

    connection.query(sqlNombre, (err, result) => {
        if (err) {
            console.log(err);
        } else {
            nombreCliente = result;
        }
    });
    
    connection.query('SELECT idCotizacion, DATE_FORMAT(fecha, "%d-%m-%Y") AS fecha,cantidad, equipo, codigo, capacidad, potencia, detalles FROM cotizacion', 
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

    admin.post('/insertar/cotizacion', (req, res) => {
        const {idCliente, cantidad, equipo, codigo, capacidad, potencia, detalles} = req.body;

        connection.query(`CALL agregarCotizacion(null, ${idCliente}, NOW(), ${cantidad}, '${equipo}',\
                                                '${codigo}', '${capacidad}', '${potencia}', '${detalles}')`,
        (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/cotizacion');
            }
        });
    });

    admin.post('/eliminar/cotizacion', (req, res) => {
        const {idCotizacion} = req.body;

        connection.query(`DELETE FROM cotizacion WHERE idCotizacion = ${idCotizacion}`, (err, result) => {
            if (err) {
                console.log(err);
            } else {
                res.redirect('/panel/cotizacion');
            }
        });
    });
};