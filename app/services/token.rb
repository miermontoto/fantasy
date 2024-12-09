require "dotenv/load"
require "json"

class Token
  TOKENS_FILE = File.join(File.dirname(__FILE__), "..", "..", "tokens.json")

  def self.load_tokens
    if File.exist?(TOKENS_FILE)
      JSON.parse(File.read(TOKENS_FILE))
    else
      {"refresh" => ENV["REFRESH"], "xauth" => {}}
    end
  end

  def self.list_tokens
    tokens = load_tokens
    tokens["xauth"]
  end

  def self.save_tokens(tokens)
    File.write(TOKENS_FILE, JSON.pretty_generate(tokens))
  end

  def self.get_xauth(community_id)
    tokens = load_tokens
    tokens["xauth"][community_id.to_s]
  end

  def self.set_xauth(community_id, value)
    tokens = load_tokens
    tokens["xauth"][community_id.to_s] = value
    save_tokens(tokens)
  end

  def self.refresh_token
    tokens = load_tokens
    tokens["refresh"] || ENV["REFRESH"]
  end

  def self.set_refresh_token(value)
    tokens = load_tokens
    tokens["refresh"] = value
    save_tokens(tokens)
  end

  def self.set_current_community(value)
    # read tokens.json and modify the current_community key
    tokens = JSON.parse(File.read(TOKENS_FILE))
    tokens["current_community"] = value.to_s
    File.write(TOKENS_FILE, JSON.pretty_generate(tokens))
  end

  def self.get_current_community
    tokens = JSON.parse(File.read(TOKENS_FILE))
    tokens["current_community"].to_i
  end
end
