VAAS_APPLICATION = "application"
VAAS_URL = "http://vaas.acapela-group.com/Services/Synthesizer"
VAAS_LOGIN = "login"
VAAS_PASSWORD = "password"

require 'net/http'
require 'uri'
require 'cgi'
require 'open-uri'

=begin
speak("I like cheese") will return a url that points to the MP3 of the file generated. Keep in mind that the thing you download can be really small, so you might end up with a StringIO if you try to open() the url.
speak("I like cheese", "bob") will change the speaker from the rather sensible default of rachel22k to bob.

downloadMP3(url) will coax the downloaded material to be a file. downloadMP3(url) also returns the file downloaded
=end

def speak(text, voice="rachel22k")
  
  hash = {"prot_vers" => "2", "cl_env" => "APACHE_2.2.9_PHP_5.5", "cl_vers" => "1-00", "cl_login" => VAAS_LOGIN,
          "cl_app" => VAAS_APPLICATION, "cl_pwd" => VAAS_PASSWORD, "req_voice" => voice, 
          "req_text" => text}
  url = URI.parse(VAAS_URL)
  
  res = Net::HTTP.post_form(url, hash)
  
  res.body.split("&").map{|pair| 
    if pair.split("=")[0] == "snd_url"
      return pair.split("=")[1]
    end}
end

def download_mp3(url)
  uri = URI.parse(url)
  Net::HTTP.start(uri.host){ |http|
    resp = http.get(uri.path)
    ret_file = File.new("short-#{(1000 * Time.now.utc.to_f).to_i}.mp3", "wb")
    ret_file.write(resp.body)
    ret_file.rewind
    ret_file
  }
end