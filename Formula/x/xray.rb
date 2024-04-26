class Xray < Formula
  desc "Platform for building proxies to bypass network restrictions"
  homepage "https://xtls.github.io/"
  url "https://github.com/XTLS/Xray-core/archive/refs/tags/v1.8.11.tar.gz"
  sha256 "d99ee6008c508abbad6bbb242d058b22efb50fb35867d15447a2b4602ab4b283"
  license all_of: ["MPL-2.0", "CC-BY-SA-4.0"]
  head "https://github.com/XTLS/Xray-core.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "7900a516a7dfc34dad8a0aabe6f8f05518d77a6bc59f1ef317dd1c4f9db2d3b9"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "305272c1bafd3838e0f667ea9fc18b2d12dd0a73d6378c36a5e6f8c05b202151"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "73ea2aeb9fcbfb40d9883fb982dafe7ba33b518d9e52647a12f9cac669242134"
    sha256 cellar: :any_skip_relocation, sonoma:         "b41f956c8cbd9470c2d61e70141095772c7f01f0648e9f071a9086c0a23aa000"
    sha256 cellar: :any_skip_relocation, ventura:        "2dc93ea7e2f82ebf1170c6387957c8101e84fe6927e0596ac14a5fdcd6f833a2"
    sha256 cellar: :any_skip_relocation, monterey:       "a7d60ee7ef7af372cdb1a0c5972f03e8897371780bbdf5f9e3f90b11117e9e0b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dd69011b106ed7603fa250852870ec442121ca0d5b4d40ad1a05b6d2fa175e1b"
  end

  depends_on "go" => :build

  resource "geoip" do
    url "https://github.com/v2fly/geoip/releases/download/202404250042/geoip.dat"
    sha256 "8ad42be541dfa7c2e548ba94b6dcb3fe431a105ba14d3907299316a036723760"
  end

  resource "geosite" do
    url "https://github.com/v2fly/domain-list-community/releases/download/20240426060244/dlc.dat"
    sha256 "7aa19bb7fa5f99d62d3db87b632334caa356fb9b901f85f7168c064370973646"
  end

  resource "example_config" do
    # borrow v2ray example config
    url "https://raw.githubusercontent.com/v2fly/v2ray-core/v5.15.3/release/config/config.json"
    sha256 "1bbadc5e1dfaa49935005e8b478b3ca49c519b66d3a3aee0b099730d05589978"
  end

  def install
    ldflags = "-s -w -buildid="
    execpath = libexec/name
    system "go", "build", *std_go_args(output: execpath, ldflags:), "./main"
    (bin/"xray").write_env_script execpath,
      XRAY_LOCATION_ASSET: "${XRAY_LOCATION_ASSET:-#{pkgshare}}"

    pkgshare.install resource("geoip")
    resource("geosite").stage do
      pkgshare.install "dlc.dat" => "geosite.dat"
    end
    pkgetc.install resource("example_config")
  end

  def caveats
    <<~EOS
      An example config is installed to #{etc}/xray/config.json
    EOS
  end

  service do
    run [opt_bin/"xray", "run", "--config", "#{etc}/xray/config.json"]
    run_type :immediate
    keep_alive true
  end

  test do
    (testpath/"config.json").write <<~EOS
      {
        "log": {
          "access": "#{testpath}/log"
        },
        "outbounds": [
          {
            "protocol": "freedom",
            "tag": "direct"
          }
        ],
        "routing": {
          "rules": [
            {
              "ip": [
                "geoip:private"
              ],
              "outboundTag": "direct",
              "type": "field"
            },
            {
              "domains": [
                "geosite:private"
              ],
              "outboundTag": "direct",
              "type": "field"
            }
          ]
        }
      }
    EOS
    output = shell_output "#{bin}/xray -c #{testpath}/config.json -test"

    assert_match "Configuration OK", output
    assert_predicate testpath/"log", :exist?
  end
end
