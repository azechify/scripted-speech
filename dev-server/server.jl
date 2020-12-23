using HTTP


mimetypes = Dict([
  (".js", "text/javascript; charset=utf-8"),
  (".mp3", "audio/mpeg")
])

struct SSML
  value:: AbstractString
end

function ssml(s) 
  if isnothing(s)
    nothing
  else
    SSML(s)
  end
end

Base.show(io::IO, s::SSML) = Base.print(io, s.value) 


function handler(req::HTTP.Request) 

  target = HTTP.URI(req.target)
  @show target

  filename = basename(target.path)
  filename = ifelse(isempty(filename), "index.html", filename)

  if isfile(filename)
    
    mimetype = get(mimetypes, splitext(filename)[2], nothing)
    if !isnothing(mimetype)
      headers = [("Content-Type", mimetype)]
    else 
      headers = []
    end

    return HTTP.Response(200, headers, body = read(filename))
  elseif filename == "speech"
    query = HTTP.queryparams(target.query)
    @show query
    input = get(query, "text", ssml(get(query, "ssml", nothing)))
    if isnothing(input)
      error("require parameter text or ssml")
    end

    return HTTP.Response(200, [("Content-Type", "audio/opus")], body = call(input))
  else
    return HTTP.Response(404)
  end

end


if (!@isdefined server)
  server = Base.Threads.@spawn HTTP.serve(handler , "0.0.0.0", 8080)
end

