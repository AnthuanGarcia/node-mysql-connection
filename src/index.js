const app = require('./config/server');

require('./app/routes/contenido')(app);

app.listen(app.get('port'), () => {
    console.log("Servidor en el puerto ", app.get('port'));
});