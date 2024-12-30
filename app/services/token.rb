require "dotenv/load"
require "json"

class Token
  TOKENS_FILE = File.join(File.dirname(__FILE__), "..", "..", "tokens.json")
  DEFAULT_CONTENT = {"refresh" => ENV["REFRESH"], "xauth" => {}, "current_community" => nil}

  def self.list_tokens
    self.read_token_file["xauth"]
  end

  def self.save_token_file(tokens)
    File.write(TOKENS_FILE, JSON.pretty_generate(tokens))
  end

  def self.get_xauth(community_id)
    self.read_token_file["xauth"][community_id.to_s]
  end

  def self.set_xauth(community_id, value)
    tokens = self.read_token_file
    tokens["xauth"][community_id.to_s] = value
    self.save_token_file(tokens)
  end

  def self.refresh_token
    self.read_token_file["refresh"] || ENV["REFRESH"]
  end

  def self.set_refresh_token(value)
    tokens = self.read_token_file
    tokens["refresh"] = value
    self.save_token_file(tokens)
  end

  def self.set_current_community(value)
    tokens = self.read_token_file
    tokens["current_community"] = value.to_s
    self.save_token_file(tokens)
  end

  def self.get_current_community
    self.read_token_file["current_community"].to_i
  end

  private

  def self.read_token_file
    if !File.exist?(TOKENS_FILE)
      return DEFAULT_CONTENT
    end

    begin
      JSON.parse(File.read(TOKENS_FILE))
    rescue JSON::ParserError
      puts "Error parsing tokens.json: #{e.message}"
      DEFAULT_CONTENT
    end
  end
end
