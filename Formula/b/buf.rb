class Buf < Formula
  desc "New way of working with Protocol Buffers"
  homepage "https://github.com/bufbuild/buf"
  url "https://github.com/bufbuild/buf/archive/refs/tags/v1.53.0.tar.gz"
  sha256 "8051e6ec73d6dbf5b862fd3319128a617f18fb06f86aac89c58c02f514abc1ca"
  license "Apache-2.0"
  head "https://github.com/bufbuild/buf.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "30a049a5758e5e136da870f51d50e815f819ecb1a99257aae786cab3b886b067"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "30a049a5758e5e136da870f51d50e815f819ecb1a99257aae786cab3b886b067"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "30a049a5758e5e136da870f51d50e815f819ecb1a99257aae786cab3b886b067"
    sha256 cellar: :any_skip_relocation, sonoma:        "8133d31d21be6d6a17e3dbafa6acf43262d5ca0a2db47b0503c6cd2d9ec2b944"
    sha256 cellar: :any_skip_relocation, ventura:       "8133d31d21be6d6a17e3dbafa6acf43262d5ca0a2db47b0503c6cd2d9ec2b944"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f927076f044cee7d4a8ed8eee66feb04418686017d5c3e6daa8562f997783d4a"
  end

  depends_on "go" => :build

  def install
    %w[buf protoc-gen-buf-breaking protoc-gen-buf-lint].each do |name|
      system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/name), "./cmd/#{name}"
    end

    generate_completions_from_executable(bin/"buf", "completion")
    man1.mkpath
    system bin/"buf", "manpages", man1
  end

  test do
    (testpath/"invalidFileName.proto").write <<~PROTO
      syntax = "proto3";
      package examplepb;
    PROTO

    (testpath/"buf.yaml").write <<~YAML
      version: v1
      name: buf.build/bufbuild/buf
      lint:
        use:
          - STANDARD
          - UNARY_RPC
      breaking:
        use:
          - FILE
        ignore_unstable_packages: true
    YAML

    expected = <<~EOS
      invalidFileName.proto:1:1:Filename "invalidFileName.proto" should be \
      lower_snake_case.proto, such as "invalid_file_name.proto".
      invalidFileName.proto:2:1:Files with package "examplepb" must be within \
      a directory "examplepb" relative to root but were in directory ".".
      invalidFileName.proto:2:1:Package name "examplepb" should be suffixed \
      with a correctly formed version, such as "examplepb.v1".
    EOS
    assert_equal expected, shell_output("#{bin}/buf lint invalidFileName.proto 2>&1", 100)

    assert_match version.to_s, shell_output("#{bin}/buf --version")
  end
end
