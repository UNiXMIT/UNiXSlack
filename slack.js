const express = require('express');
const axios = require('axios');
const app = express();
require('dotenv').config();
const port = 3000;

app.use(express.json());
app.use(express.static(__dirname));

app.post('/', async (req, res) => {
    const body = req.body;
    
    const attachment = body.attachments[0];
    const title = attachment.title;
    const titleLink = attachment.title_link;
    const text = attachment.text;
    const fields = attachment.fields;
    const authorField = fields.find(field => field.title === "Author");
    const author = authorField ? authorField.value : null;

    const postData = {
        title: title,
        title_link: titleLink,
        text: text,
        author: author
    };

    console.log(postData);

    try {
        const response = await axios.post(process.env.SLACK_URL, postData);
        console.log("Response from Slack API:", response.data);
        res.status(200).send('Webhook received and data forwarded');
    } catch (error) {
        console.error("Error sending data to external API:", error);
        res.status(500).send('Error forwarding data');
    }
});

app.listen(port);
