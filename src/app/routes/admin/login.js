const session = require('express-session');

module.exports = admin => {

    admin.use(
        session({
            secret: 'secret',
            resave: true,
            saveUninitialized: true,
        })
    );

    admin.get('/0', (req, res) => {
        res.render('admin/login')
    });

    admin.post('/auth', (req, res) => {
        const usuario = req.body.username;
        const passw = req.body.password;

        if (usuario && passw){
            connection.query(`SELECT * FROM usuario WHERE usuario = '${usuario}' AND contra = '${passw}'`, 
            (err, result) => {
                if (err){
                    console.log(err);
                }
                if (result.length > 0) {
                    req.session.loggedin = true;
                    req.session.username = usuario;
                    res.redirect('/panel')
                } else {
                    res.send('<h1>Usuario o contraseña incorrecto :(</h1>');
                }
                res.end();
            });
        } else {
            res.send('Introduce el nombre y contraseña');
            res.end();
        }
    });

    admin.get('/logout', (req, res) => {
        req.session.destroy();
        res.send("<h1>Salida exitosa</h1>\
                <a href='index'>Volver a la pagina principal</a>");
    })
}