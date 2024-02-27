/* global fetch */

// const fetch = require("node-fetch");

exports.handler = async (event) => {
  console.log(event);
  try {
    await forwardGitHubEvent(event);
    return {
      statusCode: 200,
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify("success"),
      isBase64Encoded: false,
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({ error: "Failed to forward GitHub event" }),
      isBase64Encoded: false,
    };
  }
};

async function forwardGitHubEvent(event) {
  const requestOptions = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-GitHub-Event": event.headers["X-GitHub-Event"],
    },
    body: event.body,
    // body: JSON.stringify(JSON.parse(event.body)),
  };

  const response = await fetch(process.env.JENKINS_URL, requestOptions);
  if (!response.ok) {
    throw new Error("Failed to forward GitHub event");
  }
}
