defmodule Twitter.SignInChannel do
    use Twitter.Web, :channel
    alias Twitter.Subscription
    alias Twitter.Tweet
    alias Twitter.UserService
    alias Twitter.User


    def join("sign_in:" <> account, _params, socket) do
        IO.puts("+++++++++++++")
        IO.puts(account)
        IO.puts("+++++++++++++")

        {:ok, map} = Ecto.Adapters.SQL.query(Twitter.Repo, "SELECT publickeys
        FROM user_table
        WHERE account = $1", [account])

        [[publicKey]] = map.rows
        IO.puts(publicKey)

        {a, b, c} = :erlang.timestamp()
        current_time = to_string(a) <> to_string(b) <> to_string(c)

        IO.puts(current_time)
        encrypted = RSA.encrypt(current_time, {:public, RSA.decode_key(publicKey)})
        IO.inspect(encrypted)
        {:ok, Base.encode64(encrypted), assign(socket, :account, {account, current_time, publicKey})}
    end

    def handle_in("challenge:" <> message, _params, socket) do
        {_, answer, _} = socket.assigns.account
        case message == answer do
            true -> {:reply, {:ok, %{message: "authenticate successful"}}, socket}
            false -> {:reply, {:error, %{message: "authenticate unsuccessful"}}, socket}
        end
    end

    def handle_in("subscribe:" <> subscribee, _params, socket) do
        {account, _, _} = socket.assigns.account
        UserService.subscribe(account, subscribee)

        {:reply, {:ok, %{subscribee: subscribee}}, socket}
    end

    def handle_in("unsubscribe:" <> subscribee, _params, socket) do

        {account, _, _} = socket.assigns.account
        UserService.unsubscribe(account, subscribee)

        {:reply, {:ok, %{subscribee: subscribee}}, socket}

    end

    def handle_in("subscribee_tweet:", _params, socket) do
        {account, _, _} = socket.assigns.account
        tweet = UserService.subscribee_tweet(account)

        {:reply, {:ok, %{tweet: tweet}}, socket}
    end

    def handle_in("pound_tweet:", _params, socket) do
        {account, _, _} = socket.assigns.account
        tweet = UserService.pound_tweet(account)

        {:reply, {:ok, %{tweet: tweet}}, socket}
    end

    def handle_in("at_tweet:", _params, socket) do
        {account, _, _} = socket.assigns.account
        tweet = UserService.at_tweet(account)

        {:reply, {:ok, %{tweet: tweet}}, socket}
    end


    def handle_in("new_tweet:", params, socket) do
        {account, _, publicKey} = socket.assigns.account

        secret = RS256.generate_secret_key(account)
        params = RS256.decode(params, secret)

        IO.inspect(params)
        tweet = UserService.new_tweet(account, params.content, params.suffix)

        {:reply, {:ok, %{tweet: tweet}}, socket}
    end

    def handle_in("retweet:" <> tweet_id, params, socket) do
        {account, _, _} = socket.assigns.account
        tweet = UserService.retweet(account, tweet_id, params)

        {:reply, {:ok, %{tweet: tweet}}, socket}
    end

end