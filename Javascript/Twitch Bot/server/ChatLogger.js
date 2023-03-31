const rfs = require("rotating-file-stream");

const pad = num => (num > 9 ? "" : "0") + num;

class ChatLogger {
  constructor() {
    this.streams = {}
  }
  addStream(id) { 
    const generator = (time, index) => {
      if (!time) {
        const now = new Date()
        const year = now.getFullYear()
        const month = pad(now.getMonth() + 1);
        const day = pad(now.getDate());
        
        return `${id}/${year}/${month}/${day}.log`;
      } 

      const year = time.getFullYear()
      const month = pad(time.getMonth() + 1);
      const day = pad(time.getDate());

      return `${id}/${year}/${month}/${day}${index > 1 ? `_${index - 1}` : ''}.log`;
    }

    const stream = rfs.createStream(generator, {
      size: "1M",
      interval: "1d",
      path: "./logs/",
      //compress: "gzip"(will need to unzip when reading)
    });

    stream.on('close', () => {
      console.log('closed')
    })

    stream.on('finish', () => {
      console.log('finished chat logger stream')
    })

    stream.on('rotation', () => {
      console.log('rotation')
    })

    this.streams[id] = stream
  }
  write(id, data) {
    this.streams[id].write(data, 'utf8', () => {

    })
  }
  removeStream(id) {
    this.streams[id].end()
    delete this.streams[id]
  }
}

const chat_logger = new ChatLogger()

module.exports = chat_logger
