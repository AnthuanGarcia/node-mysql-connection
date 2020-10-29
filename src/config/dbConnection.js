const mysql = require('mysql');

module.exports = () => {
    return mysql.createConnection({
        host: 'localhost',
        port: '3306',
        user: 'root',
        password: 'Pulgar_anomalo13579',
        database: 'integradora'
    });
}
