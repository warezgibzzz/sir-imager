require "kemal"

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
  
  file_path = ::File.join [Kemal.config.public_folder, "uploads/", dir, "/", orig_name]
  File.open(file_path, "w") do |f|
    IO.copy(file, f)
  end
  "Upload OK"
end

get "/:dir/:width/:height/:file" do |env|
  file = env.params.url["file"].as(String)
  dir = env.params.url["dir"].as(String)
  width = env.params.url["width"].as(String).to_i
  height = env.params.url["height"].as(String).to_i
  file_path = ::File.join [Kemal.config.public_folder, "uploads/", dir, "/", file]
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
