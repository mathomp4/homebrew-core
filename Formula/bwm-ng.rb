class BwmNg < Formula
  desc "Console-based live network and disk I/O bandwidth monitor"
  homepage "https://www.gropp.org/?id=projects&sub=bwm-ng"
  url "https://github.com/vgropp/bwm-ng/archive/v0.6.3.tar.gz"
  sha256 "c1a552b6ff48ea3e4e10110a7c188861abc4750befc67c6caaba8eb3ecf67f46"
  license "GPL-2.0-or-later"
  head "https://github.com/vgropp/bwm-ng.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "81b97f5bfdcb51cef9927bb4459eefb6ef80083350accbfdd443e89809f29d1e" => :big_sur
    sha256 "ad15b588b98b9ff4a70c111c8d674e1f267cf5d66d9347598d6c83a39b0e0630" => :arm64_big_sur
    sha256 "99d28681821e0c8114f4d1ea8db15ff088beb61d755e657c4a43684292cf556d" => :catalina
    sha256 "4126db28facbbd0c0575d166a4c30968c4449b8094430022d3c8455ec7481809" => :mojave
    sha256 "4a8ffbfe0bc2c9bf93bd516cff8916e9ea1d9554d939f21c4f7e9bfbd02ab04f" => :high_sierra
    sha256 "0c663c3fedbcdc690b553ccb88b6f69b94a4a70dea67e3d152dbaaa741973ba8" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    ENV.append "CFLAGS", "-std=gnu89"

    system "./autogen.sh"
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match "<div class=\"bwm-ng-header\">", shell_output("#{bin}/bwm-ng -o html")
  end
end
