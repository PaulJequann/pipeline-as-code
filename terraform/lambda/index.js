const Request = require("request");

exports.handler = (event, context, callback) => {
  forwardGitHubEvent(event, callback);
};

function forwardGitHubEvent(event, callback) {
  const requestOptions = {
    url: process.env.JENKINS_URL,
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-GitHub-Event": event.headers["X-GitHub-Event"],
    },
    json: JSON.parse(event.body),
  };

  Request.post(requestOptions, (error, response, body) => {
    handleResponse(error, response, body, callback);
  });
}

function handleResponse(error, response, body, callback) {
  if (error || response.statusCode !== 200) {
    console.error("Error:", error || body);
    callback(null, {
      statusCode: response ? response.statusCode : 500,
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({ error: "Failed to forward GitHub event" }),
      isBase64Encoded: false,
    });
    return;
  }

  callback(null, {
    statusCode: 200,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify("success"),
    isBase64Encoded: false,
  });
}
