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

const UID_PREFIX = 'uid:';

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

app.get('/users/list', (req, res) => {
  try {
    client.keys(`${UID_PREFIX}*`, (err, keys) => {
      if (err) {
        console.error(err);
        throw err;
      }

      const ids = keys.map(key => { return key.replace(new RegExp(`^(${UID_PREFIX})`), '') })
      res.status(200).send({idsList: ids});
    })
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
})

app.get('/user/:id', (req, res) => {
  
  try {
    let redisId = null;
    const id = req.params.id;
    const uid = `${UID_PREFIX}${id}`

    client.get(uid, (err, data) => {
      if (err) {
        console.error(err);
        throw err;
      }

      redisId = data;
      let redisIdJSON = null;
      const regex = new RegExp(`^(${UID_PREFIX})`)

      if (redisId === null) {

        redisIdJSON = {uid, count: 1};
        redisId = JSON.stringify(redisIdJSON);
        client.set(uid, redisId);
        res.status(200).send({id: `${redisIdJSON.uid.replace(regex,'')}`, count: redisIdJSON.count});

      } else {

        redisIdJSON = JSON.parse(redisId);
        redisIdJSON.count++;
        client.set(uid, JSON.stringify(redisIdJSON));
        res.status(200).send({id: `${redisIdJSON.uid.replace(regex,'')}`, count: redisIdJSON.count});

      }
    });
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
});

app.get('/user/delete/:id', (req, res) => {
  try {

    let redisId = null;
    const id = req.params.id;
    const uid = `${UID_PREFIX}${id}`

    client.get(uid, (err, data) => {
      if (err) {
        console.error(err);
        throw err;
      }
      redisId = data;
      let redisIdJSON = null;
      const regex = new RegExp(`^(${UID_PREFIX})`)

      if (redisId === null) {
        res.status(404).send({message: 'ID Not Found'})

      } else {

        redisIdJSON = JSON.parse(redisId);
        redisIdJSON.count = redisIdJSON.count <= 0 ? 0 : redisIdJSON.count - 1;
        client.set(uid, JSON.stringify(redisIdJSON));

        if (redisIdJSON.count <= 0) {
          client.del(redisIdJSON.uid);
          res.status(200).send({message: `ID ${redisIdJSON.uid.replace(regex,'')} has been successfully deleted.`})
          return;
        }
        res.status(200).send({id: `${redisIdJSON.uid.replace(regex,'')}`, count: redisIdJSON.count});
      }

      
    })
  } catch (err) {
    res.status(500).send({ error: err.message });
  }
})

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started at port: ${PORT}`);
});

