IP =  process.env.IP || '127.0.0.1'
PORT = process.env.PORT || 3000

module.exports =
  'jwt':
    'expires': '24h',
    'secret': 'devtm'
  'database': 'mongodb://localhost/thaismartins',
  'port': PORT,
  'host': IP,
  'uri': 'http://' + IP + ':' + PORT