ALTER USER 'root'@'localhost' IDENTIFIED BY 'MySQL@1243';
uninstall plugin validate_password;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';