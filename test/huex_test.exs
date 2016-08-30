defmodule HuexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("test/fixtures/vcr_cassettes")
    HTTPoison.start
  end

  test "setting up a connection returns Bridge" do
    bridge = Huex.connect("http://localhost")
    assert bridge.host == "http://localhost"
    assert bridge.username == nil
    assert bridge.status == :ok
  end

  test "setting up a connection with optional params returns defaults" do
    bridge = Huex.connect("http://localhost", "randomusername")
    assert bridge.host == "http://localhost"
    assert bridge.username == "randomusername"
    assert bridge.status == :ok
  end

  test "an authorized client given as string returns a bridge generated username" do
    use_cassette "authorize_client" do
      bridge =
        Huex.connect("192.168.1.1")
        |> Huex.authorize("foo#bar")
      assert bridge.username == "99Y95FB1pY1JGiw25ceclUxuOpWA7D9etDP45SD0"
    end
  end

  test "an authorized client given as tuple returns a bridge generated username" do
    use_cassette "authorize_client" do
      bridge =
        Huex.connect("192.168.1.1")
        |> Huex.authorize({"foo", "bar"})
      assert bridge.username == "99Y95FB1pY1JGiw25ceclUxuOpWA7D9etDP45SD0"
    end
  end

  test "authorizing a client without pressing link bridge with errors" do
    use_cassette "non_authorized_client" do
      bridge =
        Huex.connect("192.168.1.1")
        |> Huex.authorize("foo")
      assert bridge.status == :error
      assert bridge.error["description"] == "link button not pressed"
    end
  end

  test "info returns json client details" do
    use_cassette "info_bridge" do
      info =
        Huex.connect("192.168.1.239", "clHm-mvm5-OB32rAt83pahBmtdZusBG3AmVr3TCy")
        |> Huex.info

      assert Map.has_key?(info, "config")
      assert Map.has_key?(info, "lights")
    end
  end
end
