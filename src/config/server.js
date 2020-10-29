const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const dbConnection = require('../config/dbConnection');
const cookieParser = require('cookie-parser');

const app = express();
const admin = express();

// Settings
app.set('port', process.env.PORT || 3000);
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '../app/views'));

admin.set('viewsAd', path.join(__dirname, '../app/views/admin'));

var connection = dbConnection();

global.connection = connection;

//Middleware
app.use(bodyParser.urlencoded({extended: false}));
app.use('/estilos', express.static('public'));
// app.use('/admon', admin);

admin.use(cookieParser);
admin.use(bodyParser.urlencoded({extended: true}));
admin.use(bodyParser.json());
admin.use('/estilos', express.static('public'));

module.exports = app, admin;
