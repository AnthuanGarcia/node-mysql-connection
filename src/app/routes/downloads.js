/* 
module.exports = app => {
    let ultFactura = '(SELECT idFactura FROM factura ORDER BY idFactura DESC LIMIT 1)';

    app.get('/descargar', (req, res) => {
        connection.query(ultFactura, (err, result) => {
            res.download('public/pdfs/Factura_N'+ result[0].idFactura + '.pdf', (err, res) => {
                if (err) {
                console.log(err);
                }
            });
        });
    })
}
 */