const nodemailer = require('nodemailer');

const remitente     = 'slayerkitty10@gmail.com';
const passw         = 'kilosmortales15';
const destinatario  = 'pinkyfloid0@gmail.com';

module.exports = 
function sendMail(cliente, pedido){
    let body;
    let subject;
    let attachments;

    if (!('idFactura' in pedido)){
      attachments = undefined;
      subject = `Solicitud de cotizacion de ${cliente.nombre + ' ' + cliente.apellido}`;
      body = `<body>
                <h1>Solicitud de cotizacion</h1>
                <div>
                    <h2>Informacion del solicitante</h2>
                    <p><strong>Nombre:</strong> ${cliente.nombre + ' ' + cliente.apellido}</p>
                    <p><strong>Datos de contacto:</strong></p>
                    <li>Correo eletronico: ${cliente.email}</li>
                    <li>Telefono: ${cliente.telefono}</li>
                </div>
                <div>
                    <h2>Informacion de la Cotizacion</h2>
                    <p><strong>Equipo: </strong>${pedido.equipo}</p>
                    <p><strong>Cantidad de equipos: </strong>${pedido.cantidad}</p>
                    <p><strong>Codigo: </strong>${pedido.codigo}</p>
                    <p><strong>Capacidad: </strong>${pedido.capacidad}</p>
                    <p><strong>Potencia: </strong>${pedido.potencia}</p>
                    <p><strong>Detalles: </strong>${pedido.detalles}</p>
                </div>
              </body>`
    } else {
      attachments = [{
        filename: `Factura_${pedido.idFactura}`,
        path: './public/pdfs/xd.pdf',
        contentType: 'application/pdf'
      }];
      subject = `Solicitud de pedido de ${cliente.nombre + ' ' + cliente.apellido}`;
      body = `<body>
                <h1>Pedido de ${pedido.name}</h1>
                <div>
                    <h2>Informacion del solicitante</h2>
                    <p><strong>Nombre:</strong> ${cliente.nombre + ' ' + cliente.apellido}</p>
                    <p><strong>Datos de contacto:</strong></p>
                    <li>Correo eletronico: ${cliente.email}</li>
                    <li>Telefono: ${cliente.telefono}</li>
                </div>
                <div>
                    <h2>Informacion del pedido</h2>
                    <p><strong>Producto pedido: </strong>${pedido.name}</p>
                    <p><strong>Cantidad: </strong>${pedido.cantidad}</p>
                </div>
              </body>`
    }

    const transporter = nodemailer.createTransport({
        service: 'gmail',
        secure: false,
        port: 25,
        auth: {
          user: remitente,
          pass: passw
        },
        tls:{
          rejectUnauthorized: false
        }
    });
    
    const mailOptions = {
        from: remitente,
        to: destinatario,
        subject: subject,
        html: body,
        attachments: attachments
    }
    
    transporter.sendMail(mailOptions, function(error, info){
        if (error){
          console.log(error);
        } else {
          console.log('Email enviado ' + info.response);
        }
    });
}