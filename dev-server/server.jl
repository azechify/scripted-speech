using HTTP


mimetypes = Dict([
  (".js", "text/javascript; charset=utf-8"),
  (".mp3", "audio/mpeg")
])

abstract type MarkupString end
Base.show(io::IO, s::MarkupString) = Base.print(io, value(s))


struct SSML <: MarkupString
  ssml::AbstractString
end

value(s::SSML) = s.ssml


struct MARKDOWN <: MarkupString
  markdown::AbstractString
end

value(s::MARKDOWN) = s.markdown


function ssml(s) 
  if isnothing(s)
    nothing
  else
    SSML(s)
  end
end

function markdown(s)
  if isnothing(s)
    nothing
  else
    MARKDOWN(s)
  end
end


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
    input = query |> d -> begin
      haskey(d, "ssml") && return ssml(d["ssml"])
      haskey(d, "markdown") && return markdown(d["markdown"])
      haskey(d, "text") && return d["text"]
      error("require parameter text or ssml or markdown")
    end

    return HTTP.Response(200, [("Content-Type", "audio/opus")], body = call(input))
  else
    return HTTP.Response(404)
  end

end


if (!@isdefined server)
  server = Base.Threads.@spawn HTTP.serve(handler , "0.0.0.0", 8080)
end

