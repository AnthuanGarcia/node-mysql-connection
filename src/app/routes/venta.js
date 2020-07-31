// const dbConnection = require('../../config/dbConnection');

// module.exports = app => {
//     const conecction = dbConnection();

//     app.get('/venta', (req, res) => {
//         conecction.query('SELECT * FROM productos;', (err, result) => {
//             res.render('vistas/venta', {
//                 pro: result
//             });
//         });
//     });
// }