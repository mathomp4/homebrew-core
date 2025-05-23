class Keploy < Formula
  desc "Testing Toolkit creates test-cases and data mocks from API calls, DB queries"
  homepage "https://keploy.io"
  url "https://github.com/keploy/keploy/archive/refs/tags/v2.5.4.tar.gz"
  sha256 "8cc3da3b8921c4194d4e8162300a377c43c829b7e10e38a987ad8529b02e0949"
  license "Apache-2.0"
  head "https://github.com/keploy/keploy.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5284f0bee63285c1ccfc92deae3d9df75fb9b4d8b75749c61b7186e6d718db79"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "5284f0bee63285c1ccfc92deae3d9df75fb9b4d8b75749c61b7186e6d718db79"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5284f0bee63285c1ccfc92deae3d9df75fb9b4d8b75749c61b7186e6d718db79"
    sha256 cellar: :any_skip_relocation, sonoma:        "22ee7bdf8ccfae4ddc2361c1a5fe5939e898d7543fcc98b334513bcbd6a76455"
    sha256 cellar: :any_skip_relocation, ventura:       "22ee7bdf8ccfae4ddc2361c1a5fe5939e898d7543fcc98b334513bcbd6a76455"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8ffc00603e0999fe4c227f54214f8d50316299dbb9d4705f5272ccbc00ccba43"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}")
  end

  test do
    system bin/"keploy", "config", "--generate", "--path", testpath
    assert_match "# Generated by Keploy", (testpath/"keploy.yml").read

    output = shell_output("#{bin}/keploy templatize --path #{testpath}")
    assert_match "No test sets found to templatize", output

    assert_match version.to_s, shell_output("#{bin}/keploy --version")
  end
end
