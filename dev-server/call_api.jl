using HTTP
using JSON
using Base64

url = "https://texttospeech.googleapis.com/v1/text:synthesize"
header = [
  "Content-Type" => "application/json"          
]


function call(s)

  @show "--------------------------"
  @show s
  @show "--------------------------"

  if isa(s, SSML)
    input = """
    'ssml': "$s"
    """
  elseif isa(s, MARKDOWN)
    input = """
    'ssml': "$s"
    """
  else
    input = """
    'text': "$s"
    """ 
  end 

  body = """
  {
    'input': { $input },
    'voice': {
      'languageCode': 'ja-JP',
      'name': 'ja-JP-Wavenet-B',
      'ssmlGender': 'FEMALE'
    },
    'audioConfig': {
      'audioEncoding': 'OGG_OPUS'
    }
  }
"""

  r = HTTP.post("$url?key=$(ENV["API_KEY"])", header, body)

  r.body |> 
    String |> 
    JSON.parse |> 
    x -> get(x, "audioContent", nothing) |>
    base64decode

end
