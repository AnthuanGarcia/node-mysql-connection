const app = require('./config/server');

require('./app/routes/vistas')(app);

app.listen(app.get('port'), () => {
    console.log("Servidor en el puerto ", app.get('port'));
});