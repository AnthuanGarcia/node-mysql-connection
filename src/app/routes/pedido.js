
module.exports = app => {
    app.get('/pedido', (req, res) => {
      res.render('vistas/pedido');
    });
  
  }