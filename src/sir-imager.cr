require "kemal"
require "http/client"

macro serve(filename)
  render "src/views/#{{{filename}}}.ecr", "src/views/base/layout.ecr"
end

get "/" do |env|
  files = Dir.open(File.join [Kemal.config.public_folder, "uploads/"]).entries()
  dirs = [] of String
  
  files.each do |file|
    if File.directory?(File.join [Kemal.config.public_folder, "uploads/", File.basename(file)]) && file != "." && file != ".."
      dirs << File.join ["/uploads/", File.basename(file)]
    end
  end
  hello = "HELLO"
  serve "index"
end

post "/upload" do |env|
  file = env.params.files["image"].tempfile
  orig_name = env.params.files["image"].filename.as(String)
  dir = env.params.body["dir"].as(String)

  unless Dir.exists?(File.join [Kemal.config.public_folder, "uploads/", dir])
    Dir.mkdir(File.join [Kemal.config.public_folder, "uploads/", dir])
  end
  
  file_path = File.join [Kemal.config.public_folder, "uploads/", dir, "/", orig_name]
  File.open(file_path, "w") do |f|
    IO.copy(file, f)
  end
  "Upload OK"
end

get "/:dir/:width/:height/:file" do |env|
  file = env.params.url["file"].as(String)
  dir = env.params.url["dir"].as(String)
  width = env.params.url["width"].as(String)
  height = env.params.url["height"].as(String)
  file_path = ::File.join [Kemal.config.public_folder, "uploads/", dir, "/", file]
  HTTP::Client.get("http://resizer:8000/unsafe/#{width}x#{height}/http://sir-imager:3000/#{file_path}") do |response|
    File.write("test.jpg", response.body_io)
  end
end

get "/uploads/:path/" do |env|
  path = env.params.url["path"]
  if File.directory?(File.join [Kemal.config.public_folder, "uploads/", File.basename(path)]) != true
    send_file env, File.join [Kemal.config.public_folder, "uploads/", File.basename(path)]
  end

  directory_entries = Dir.open(File.join [Kemal.config.public_folder, "uploads/", path]).entries()
  files = [] of String
  
  directory_entries.each do |file|
    if File.directory?(File.join [Kemal.config.public_folder, "uploads/", path, File.basename(file)]) != true && file != "." && file != ".."
      files << File.join ["/uploads/", path, File.basename(file)]
    end
  end
  serve "directory"
end

Kemal.run
