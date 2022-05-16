const express = require('express')
const redis = require('ioredis')

const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_HOST = process.env.REDIS_HOST || 'localhost';
const REDIS_DB = process.env.REDIS_DB || 0;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD;
const client = redis.createClient({
  host: REDIS_HOST,
  port: REDIS_PORT,
  db: REDIS_DB,
  password: REDIS_PASSWORD
});

const app = express();

app.get('/ping', (req, res) => {
  try {
    res.status(200).send({version: '1.0'});
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
})

app.get('/', (req, res) => {
  try {
    res.status(200).send({message: 'Welcome!'});
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
})

app.get('/user/:id', (req, res) => {
  
  try {
    const key = 'id'
    let redisId = null;
    const id = req.params.id;

    client.get(id, (err, data) => {
      if (err) {
        console.error(err);
        throw err;
      }

      redisId = data;
      let redisIdJSON = null;
      if (redisId === null) {
        redisIdJSON = {id, count: 1};
        redisId = JSON.stringify(redisIdJSON);
        client.set(id, redisId);
        res.status(200).send({id: redisIdJSON.id, count: redisIdJSON.count});
      } else {
        redisIdJSON = JSON.parse(redisId);
        redisIdJSON.count++;
        client.set(id, JSON.stringify(redisIdJSON));
        res.status(200).send({id: redisIdJSON.id, count: redisIdJSON.count});
      }
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started at port: ${PORT}`);
});

