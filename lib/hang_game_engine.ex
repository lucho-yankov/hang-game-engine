defmodule HangGameEngine do

  def guessed?(secret, tries) do
    spaceless_secret = HashSet.new(secret) |> Set.delete(32)
    Set.subset?(spaceless_secret, HashSet.new(tries))
  end

  def partial_guess(secret, tries) do
    tries_set = HashSet.new(tries)
    lc s inlist secret do 
      if HashSet.member?(tries_set, s) or s == 32 do
        s
      else 
        '_'
      end
    end |> list_to_bitstring
  end

  def incorrect_attempts(secret, tries) do
    spaceless_secret = HashSet.new(secret) |> Set.delete(32)
    tries_set = HashSet.new(tries)
    Set.difference(tries_set, spaceless_secret) |> Set.size
  end

  def random_element(options) do
    n = :crypto.rand_uniform(0, length options)
    Enum.at(options, n)
  end

  def ordered_uniqueue_list(l) do
    Enum.reverse(l) |> ordered_uniqueue_list([], HashSet.new)
  end

  def ordered_uniqueue_list([h | t], r, s) do
    if not Set.member?(s, h) do
      s = Set.put(s, h)
      r = [h | r]
    end
    ordered_uniqueue_list(t, r, s)
  end

  def ordered_uniqueue_list([], r, _s) do
    r
  end
  
  def search_giphy(search) do
    url = "http://api.giphy.com/v1/gifs/translate?api_key=dc6zaTOxFJmzC&limit=1&s="
    search_url = url <> String.replace(search, " ", "%20") # todo: better uri encode :/
    result = :hackney.request(:get, search_url)
    client = case result do
      {:ok, 400, _, _} -> nil
      {:ok, 200, _, client} -> client
    end

    if nil?(client) do
      nil
    else
      {:ok, body, client} = :hackney.body(client)
      {:ok, giphy_result} = JSON.decode(body)
      giphy_result["data"]["images"]["fixed_height"]["url"]
    end
  end
end

