use Mix.Config

config :exvcr,
  vcr_cassette_library_dir: "fixture/vcr_cassettes",
  custom_cassette_library_dir: "fixture/custom_cassettes",
  filter_sensitive_data: [
    [pattern: "access_token", placeholder: "ACCESS_TOKEN"],
    [pattern: "refresh_token", placeholder: "REFRESH_TOKEN"],
    [pattern: "client_id", placeholder: "CLIENT_ID"],
    [pattern: "client_secret", placeholder: "CLIENT_SECRET"],
    [pattern: "username", placeholder: "USERNAME"],
    [pattern: "password", placeholder: "PASSWORD"]
  ],
  filter_url_params: true,
  filter_request_headers: ["X-UP-API-Key", "X-UP-API-Passphrase", "X-UP-API-Signature"],
  response_headers_blacklist: []
