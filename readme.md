# node-homeassistant-proxy
A transparent proxy that limits access for HomeAssistant so you can put it on the net

Problem: I have some HomeAssistant API endpoints I want exposed to the internet (specifically IFTTT), but I want to prevent security issues with the front end or other API endpoints.

Solution: This project makes a transparent proxy that routes the endpoints I need, adds SSL encryption, and doesn't mess with my HomeAssistant config.

# Setup Instructions

- Create a .env file with the following contents (change as needed)
```
PROXY_PORT=3000     # The port you are exposing with port forwarding
HA_PORT=8123        # The actual HomeAssistant server port (default is 8123)
HA_HOST=localhost   # The host IP running HomeAssistant, this setup assumes you're running it on the same machine
```


- Run `npm i` to install all project dependencies.

- Run `npm start`. If there are no issues, the console should show "Proxy is running!"

TODO: Add instructions for creating service.
