module.exports = {
  apps: [{
    name: 'portfoliopulse-frontend',
    script: 'server.js',
    cwd: '/opt/portfoliopulse-frontend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      HOSTNAME: '0.0.0.0'
    },
    error_file: '/var/log/portfoliopulse-frontend-error.log',
    out_file: '/var/log/portfoliopulse-frontend-out.log',
    log_file: '/var/log/portfoliopulse-frontend.log'
  }]
}
