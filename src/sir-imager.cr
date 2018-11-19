require "kemal"

macro serve(filename)
  render "src/views/#{{{filename}}}.ecr", "src/views/base/layout.ecr"
end


get "/" do |env|
  serve "index"
end

Kemal.run
