require "kemal"

get "/" do |env|
  "Hello World!"
end

Kemal.run
