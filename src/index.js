const app = require('./config/server');

require('./app/routes/contenido')(app);
require('./app/routes/servicios')(app);
require('./app/routes/productos')(app);
require('./app/routes/indexP')(app);
require('./app/routes/cotizaciones')(app);

app.listen(app.get('port'), () => {
    console.log("Servidor en el puerto ", app.get('port'));
});