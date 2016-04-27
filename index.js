try {
  module.exports = require("./lib/telegram");
}
catch (err) {
  console.error(err);
  console.error("node-telegram-bot is now working with source code! Run `make build` before publish.");
  module.exports = require("./src/telegram");
}