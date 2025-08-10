CREATE DATABASE IF NOT EXISTS portfolio_pulse_dev;
CREATE USER IF NOT EXISTS 'portfoliopulse'@'localhost' IDENTIFIED BY 'testpass123';
GRANT ALL PRIVILEGES ON portfolio_pulse_dev.* TO 'portfoliopulse'@'localhost';
FLUSH PRIVILEGES;
