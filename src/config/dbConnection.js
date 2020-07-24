const mysql = require('mysql');

module.exports = () => {
    return mysql.createConnection({
        host: 'localhost',
        port: '3307',
        user: 'root',
        password: 'root',
        database: 'integradora'
    });
}