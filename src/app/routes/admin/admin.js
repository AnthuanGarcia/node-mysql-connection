const app = require("../../../config/server");

var nombreCliente;

module.exports = admin => {

    let sqlNombre = 'SELECT nombre FROM cliente AS C, cotizacion AS COT WHERE C.idCliente = COT.idCliente;';

    connection.query(sqlNombre, (err, result) => {
        if (err) {
            console.log(err);
        } else {
            nombreCliente = result;
        }
    });

    connection.query('SELECT * FROM cotizacion;', (err, result) =>{
        
        admin.get('/panel', (req, res) => {
            if (req.session.loggedin) {
                res.render('admin/panel', {
                    coti: result,
                    name: nombreCliente
                });
            } else {
                res.send('<h1>Ingrese para acceder</h1>');
            }
        });
    });
};