module.exports = admin => {
    admin.get('/panel', (req, res) => {
        if (req.session.loggedin) {
            res.render('admin/panel', {
                cotizacion: false,
                cliente: false,
                pedido: false,
                factura: false,
                producto: false
            });
        } else {
            res.send('<h1>Ingrese para acceder</h1>');
        }
    });
}