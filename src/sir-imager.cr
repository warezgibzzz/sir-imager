require "kemal"
require "magickwand-crystal"

macro serve(filename)
  render "src/views/#{{{filename}}}.ecr", "src/views/base/layout.ecr"
end

def get_dimensions(x : Int, y : Int, x1 : Int, y1 : Int)
  ratio = (new_y/new_x) + (old_y - old_x*new_y/new_x)

  result = {"median_y" => median_y.to_i, "median_x" => median_x.to_i, "offset_x" => offset_x.to_i, "offset_y" => offset_y.to_i}
  
  puts result.inspect

  result
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


  env.response.content_type = "image/jpeg"
  LibMagick.magickWandGenesis
  wand = LibMagick.newMagickWand
  if LibMagick.magickReadImage( wand, file_path )
    w = LibMagick.magickGetImageWidth wand
    h = LibMagick.magickGetImageHeight wand
    coords = get_dimensions(w, h, width, height)

    # LibMagick.magickCropImage wand, w * coords["scale"], h * coords["scale"], LibMagick::FilterTypes::LanczosFilter, 1
    
    ## or simply scale with:
    LibMagick.magickSetImageCompressionQuality wand, 80
    LibMagick.magickWriteImage wand, File.basename(file_path)

    buffer = LibMagick.magickGetImageBlob wand, out length
    slice = Slice( UInt8 ).new( buffer, length )
    LibMagick.magickWandTerminus
    io = IO::Memory.new
    io.write slice
    io.to_s
  else
    "Not found"
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
