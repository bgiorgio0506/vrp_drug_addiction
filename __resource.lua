
description "vRP drugs addiction"

dependency "vrp"

client_scripts{ 
  "lib/Proxy.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua"
}
