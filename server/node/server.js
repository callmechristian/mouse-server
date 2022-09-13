var data = require('./process_data');

const WebSocket = require('ws');
const spawn = require("child_process").spawn;

const wss = new WebSocket.Server({ port: 7071 });
const clients = new Map();

wss.on('connection', (ws) => {
    const id = uuidv4();
    const color = Math.floor(Math.random() * 360);
    const metadata = { id, color };

    clients.set(ws, metadata);

    ws.on('message', (messageAsString) => {
      const message = JSON.parse(messageAsString);
      const metadata = clients.get(ws);

      // debug message
      if(message.msg != undefined) {
        // console.log(message);
      }

      // process the data
      var vx, vy, vz = data.processAccellerationToVelocity(message.x, message.y, message.z, 0, 0, 0, 60);
      var distx, disty, distz = data.estimateNewMouseDisplacement(0, 0, 0, vx, vy, vz);
      //run py script with new x y z
      

      console.log("Computed x: " + distx + " Computed y: " + disty);
      // move mouse
      //const pythonProcess = spawn('python',["../python/movemouse.py", distx, disty])

      message.sender = metadata.id;
      message.color = metadata.color;

      [...clients.keys()].forEach((client) => {
        client.send(JSON.stringify(message));
      });
    });  
});

wss.on("close", () => {
  clients.delete(ws);
});

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

console.log("wss up");