const pdf = require('html-pdf');
const fs = require('fs');

module.exports = 
function factura(cliente, pedido){
    const css = fs.readFileSync('./public/css/factura.css', 'utf-8');
    let filasTabla = "";

    const date = new Date();
    const dateTimeFormat = new Intl.DateTimeFormat('en', { year: 'numeric', month: 'numeric', day: '2-digit'});
    const [{ value: month },,{ value: day },,{ value: year }] = dateTimeFormat .formatToParts(date);

    for (i = 2; i < 16; i++){
        filasTabla +=  `<tr>
                            <td class="cantidad dato-num">${i}</td>
                            <td class="descripcion campos"></td>
                            <td class="cantidad campos"></td>
                            <td class="precio campos"></td>
                            <td class="total campos"></td>
                        </tr>`
    }
    const content = `<!doctype html>
                    <html>
                        <head>
                            <meta charset="utf-8">
                            <style>
                                ${css}
                            </style>
                        </head>
                        <body>
                            <table class="cabecera">
                                <td>
                                    <div class="logo">
                                        <img src="file:///Users/Carlos/Documents/Pruebas js/node-mysql-connection/public/img/logo-bueno_c.png">
                                    </div>
                                </td>
                                <td class="cabe-cont">
                                    <p class="espacio" style="margin-top: 30px;">Email:</p>
                                    <p class="espacio">Telefono:</p>
                                    <p class="espacio" style="margin-bottom: 30px;">Chihuahua, Chihuahua, México</p>
                                </td>
                            </table>
                            <section class="contenedor">
                                <table>
                                    <td>
                                        <img src="file:///Users/Carlos/Documents/Pruebas js/node-mysql-connection/public/img/fac.png">
                                    </td>
                                    <td>
                                        <p class="datos-cliente">Nombre: ${cliente.nombre + ' ' + cliente.apellido}</p>
                                        <p class="datos-cliente">Email: ${cliente.email}</p>
                                        <p class="datos-cliente">Telefono: ${cliente.telefono}</p>
                                    </td>
                                </table>
                                <h1 class="espacio titulo">Factura</h1>
                                <p class="espacio" style="margin-bottom: 30px;">N°${pedido.idFactura}</p>
                                <p style="text-align: right; font-size: 8pt;" class="espacio">Fecha: ${day}/${month}/${year }</p>

                                <table class="blueTable" style="height: 88px;" width=100%>
                                    <thead>
                                        <tr>
                                            <th class="numero">N°</th>
                                            <th class="descripcion">Descripcion</th>
                                            <th class="cantidad">Cantidad</th>
                                            <th class="precio">Precio</th>
                                            <th class="total">Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td class="numero dato-num">1</td>
                                            <td class="descripcion campos">${pedido.name}</td>
                                            <td class="cantidad campos">${pedido.cantidad}</td>
                                            <td class="precio campos">${pedido.precioProducto}</td>
                                            <td class="total campos">${pedido.cantidad * pedido.precioProducto}</td>
                                        </tr>
                                        `+ filasTabla +`
                                    </tbody>
                                </table>

                                <h1 style="text-align: right;" class="total-txt">Total</h1>
                                <p class="espacio total-dinero">$${pedido.cantidad * pedido.precioProducto} MXN</p>
                                <p class="detalles">Subtotal: </p>
                                <p class="detalles">IVA: </p>
                            </section>
                        </body>
                    </html>`;
                    
    const config = {
        // "height": "595.30 px", 
        // "width": "650.60 px" 
        "format": "A4" 
    };

    pdf.create(content, config).toFile(`./public/pdfs/Factura_N${pedido.idFactura}.pdf`, (err, res) => {
        if (err) {
            console.log(err);
        } else {
            console.log(res);
        }
    });
}
