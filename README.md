# Upvest Elixir

[![Build Status](https://travis-ci.org/rpip/upvest-elixir.svg?branch=master)](https://travis-ci.org/rpip/upvest-elixir)
[![Inline docs](http://inch-ci.org/github/rpip/upvest.svg)](http://inch-ci.org/github/rpip/upvest-elixir)

Elixir library for the Upvest API.

In order to retrieve your API credentials for using this Go client, you'll need to [sign up with Upvest](https://login.upvest.co/sign-up).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `upvest` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:upvest, "~> 0.1.0"}
  ]
end
```

Alternatively, you can install the library by a particular commit reference:

``` elixir
def deps do
  [
    {:upvest, git: "https://github.com/rpip/upvest-elixir", ref: "commit ref here"}
  ]
end
```

## Usage

Where possible, the services available on the client groups the API into logical chunks and correspond to the structure of the [Upvest API documentation](https://doc.upvest.co).

All tenancy related operations must be authenticated using the API Keys Authentication, whereas all actions on a user's behalf need to be authenticated via OAuth. The API calls are built along with those two authentication objects.

All API calls return either `{:ok, response}` or `{:error, error}`, and where possible succesful response are transformed into Elixir structs mapped to the corresponding Upvest API resource.

### Tenancy API - API Keys Authentication

The Upvest API uses the notion of _tenants_, which represent customers that build their platform upon the Upvest API. The end-users of the tenant (i.e. your customers), are referred to as _clients_. A tenant is able to manage their users directly and is also able to initiate actions on the user's behalf (create wallets, send transactions).

```elixir
alias Upvest.Client
alias Upvest.Authentication.KeyAuth
alias Upvest.Tenancy.User

keyauth = %KeyAuth{api_key: your_api_key, api_secret: your_api_secret, api_passphrase: your_api_passphrase}
client = Client.new(keyauth)

# create a user
with {:ok, user} <- User.create(client, username, password) do
    # do something with new user created
  else
    {:error, error} ->
    # handle the error
  end
end

# list users
{:ok, users} = User.list(client)

# retrieve 200 users
{:ok, users} = User.list_n(client, 200)

# change password
{:ok, user} = User.change_password(client, username, current_password, new_password)
```

### Clientele API - OAuth Authentication
The authentication via OAuth allows you to perform operations on behalf of your user.
For more information on the OAuth concept, please refer to our [documentation](https://doc.upvest.co/docs/oauth2-authentication).
Again, please retrieve your client credentials from the [Upvest account management](https://login.upvest.co/).

Next, create a `Client` with your Upvest OAuth authentication data in order to authenticate your API calls on behalf of a user:

```elixir
alias Upvest.Client
alias Upvest.Authentication.OAuth
alias Upvest.Clientele.Wallet

oauth = %OAuth{client_id: your_client_id, client_secret: your_client_secret, username: your_users_username, password: your_users_password}
# If you already have a client created with a key auth, you can create a new oauth client from that by changing the auth param
client = %{client | auth: oauth}

# alternatively, client = Client.new(oauth)

with {:ok, wallet} <- Wallet.create(client, user_password, asset_id) do
  {:ok, wallet} ->
    # handle new wallet created
  {:error, error} ->
    # handle error
end
```

## Building docs

```
$ MIX_ENV=docs mix docs
```

## Running tests

Clone the repo and fetch its dependencies:

```
$ git clone https://gitlab.com/rpip/upvest-elixir
$ cd upvest-elixir
$ mix do deps.get, compile
$ mix test
```
## Development

1. Code must be nicely formatted: `mix format`
2. All types, structs and funcs should be documented.
3. Ensure that `mix test` succeeds.
4. Set up config settings via environment variables, ideally in a .env file you can source:

    ```shell
    # Set your tenancy API key information here.
    export API_KEY=xxxx
    export API_SECRET=xxxx
    export API_PASSPHRASE=xxxx

    # Set your OAuth2 client information here.
    export OAUTH2_CLIENT_ID=xxxx
    export OAUTH2_CLIENT_SECRET=xxxx
    ```

## Test

Run all tests:

    mix test

Run a single test:

    mix test test/wallet_test.exs

## More

For a comprehensive reference, check out the [Upvest documentation](https://doc.upvest.co).

For details on all the functionality in this library, see the [HexDocs documentation](https://hexdocs.pm/upvest-elixir/).
