# node-homeassistant-proxy
A transparent proxy that limits access for HomeAssistant so you can put it on the net

Problem: I have some HomeAssistant API endpoints I want exposed to the internet (specifically IFTTT), but I want to prevent security issues with the front end or other API endpoints.

Solution: This project makes a transparent proxy that routes the endpoints I need, adds SSL encryption, and doesn't mess with my HomeAssistant config.

## Setup Instructions

### 1. Install Node.latest JS for your platform.
I did this on a Raspberry Pi, so I needed to get the ARM installer. If you're using something else, you can go [here](https://nodejs.org/en/download/) to find the latest LTS for your platform. 

Beware the Node version in your package manager (apt or yum), in my experience they are generally VERY out of date. 
```
wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb
```

### 2. Create a .env file with the following contents (change as needed)
```
# The port you are exposing with port forwarding
PROXY_PORT=3000
# The actual HomeAssistant server port (default is 8123)
HA_PORT=8123
# The host IP running HomeAssistant, this setup assumes you're running it on the same machine
HA_HOST=localhost
# Tells the proxy if it should forward all requests to the UI. Set to true if you want the world to see your HomeAssistant web interface (good luck with that)
FORWARD_UI=FALSE
# Tells the proxy if it should forward all requests to the /api endpoints. 
FORWARD_API=TRUE
```

- (Optional) Create `allowed` and `blocked` files.
These files should have URL paths for locations you want to block/allow access to. These should be one URL per line.
For example, if you want to access only the cover status in HomeAssistant, you could add
`/api/services/cover`
to the allowed file, and set the FORWARD_API variable in the .env file to FALSE.

### 3. Install all project dependencies.

Open a temrminal and run this to install all the project dependenies in package.json
```
cd node-homeassistant-proxy
npm i
```

### 4. Verify that everything is working correctly.

In the same terminal, run the following to make sure you can run the app correctly.

`npm start`

If there are no issues, the console should show "Proxy is running on port XXXX!" along with some debug information about which rules were loaded. You may also want to test your rules to make sure things work the way you want them to. You can quit with Ctrl+C. 

### 5. Setup node-homeassistant-proxy as a service

We're going to set this up with PM2, a process manager for Node.JS applications. First, we install it with npm, the -g flag specifies that it will be available system-wide:

`sudo npm install -g pm2 coffeescript`

Now, let's add our app to PM2's process list:

`pm2 start --interpreter coffee app.coffee --name "ha_proxy"`

If everything went smoothly, you should get something like this:

```
[PM2] Applying action restartProcessId on app [ha_proxy](ids: 0)
[PM2] [ha_proxy](0) ✓
[PM2] Process successfully started
┌──────────┬────┬──────┬──────┬────────┬─────────┬────────┬─────┬───────────┬──────┬──────────┐
│ App name │ id │ mode │ pid  │ status │ restart │ uptime │ cpu │ mem       │ user │ watching │
├──────────┼────┼──────┼──────┼────────┼─────────┼────────┼─────┼───────────┼──────┼──────────┤
│ ha_proxy │ 0  │ fork │ 6432 │ online │ 0       │ 0s     │ 37% │ 11.7 MB   │ pi   │ disabled │
└──────────┴────┴──────┴──────┴────────┴─────────┴────────┴─────┴───────────┴──────┴──────────┘
```

pm2 should keep this app running, but isn't currently setup to run at boot. To add pm2 to systemctl, execute the following:

`pm2 startup systemd`

That should yeild output simialar to this:

```
[PM2] Init System found: systemd
[PM2] To setup the Startup Script, copy/paste the following command:
sudo env PATH=$PATH:/usr/local/bin /usr/local/lib/node_modules/pm2/bin/pm2 startup systemd -u pi --hp /home/pi
```

Our last step is copying that last line and pasting it into the terminal to run it. Copy it from your terminal, not from above. This adds pm2 to the system PATH and adds the systemd entry for your current user. You can verify that this works by rebooting the machine and accessing your endpoints.

### 6. Set up port forwarding on your router.

I have no idea what router you have or how you should set this up. I set my forwarding to use the following:

```
Source Port: 8123
Destination Port: 3000
```

This forwards port 8123 from the Internet, to your device on port 3000. This proxy software then routes the requests you approve from 3000 to their final destination at 8123.


### References
[How to Set Up a Node.js Application for Production](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-node-js-application-for-production-on-ubuntu-16-04)

### TODO:
~~Add instructions for creating service.~~

Let allow and block files allow Regex

Add support for HTTPS
