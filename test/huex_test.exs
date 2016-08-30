defmodule HuexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "setting up a connection returns Bridge" do
    bridge = Huex.connect("http://localhost", "device-in-test", "testingusername")
    assert bridge.username == "testingusername"
    assert bridge.host == "http://localhost"
    assert bridge.devicetype == "device-in-test"
  end

  test "setting up a connection with optional params returns defaults" do
    bridge = Huex.connect("http://localhost")
    assert bridge.username == "test-user"
    assert bridge.host == "http://localhost"
    assert bridge.devicetype == "test-device"
  end

  test "an authorized client returns a bridge generated username" do
    use_cassette "authorize_client" do
      bridge = Huex.connect("192.168.1.1", "device-in-test", "testingusername")
      response = Huex.authorize(bridge, "foo")
      assert response.username == "99Y95FB1pY1JGiw25ceclUxuOpWA7D9etDP45SD0"
    end
  end

  test "authorizing a client without pressing link bridge with errors" do
    use_cassette "non_authorized_client" do
      bridge = Huex.connect("192.168.1.1", "device-in-test", "testingusername")
      response = Huex.authorize(bridge, "foo")
      assert response.status == :error
    end
  end

  test "info returns json client details" do
    use_cassette "info_bridge" do
      bridge = %Huex.Bridge{devicetype: "test-device", error: nil, host: "192.168.1.239",
 status: :ok, username: "clHm-mvm5-OB32rAt83pahBmtdZusBG3AmVr3TCy"}
      response = Huex.info(bridge)
      refute response.status == :error
    end
  end
end
