module.exports = app =>{

  app.get('/servicios', (req, res) => {
    res.render('vistas/servicios');
  });

};