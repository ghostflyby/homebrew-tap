class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "c174f327b9ab36916910e87687cd5b355974ad965c336b1d62e2e7462cb4373d"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.5.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7f0ccdeb0c7e692ae2320d80dd233b1131a2ab701c3734f858eeb54fae963d3d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f2e06e20efc873420f1a331bb3b09f792c68b5e26c7544ab2d12098806269876"
    sha256 cellar: :any,                 x86_64_linux:  "d425a5f1dd0a5469dbe8fb2bb75fe0daa16302f4268633556eff54129ba00213"
  end

  depends_on "dotnet" => :build

  # No runtime library dependencies: the AOT binary links system libraries
  # only. Upstream strips the unused NativeAOT zlib/brotli/openssl link args
  # and runs with invariant globalization, so nothing is dlopen'ed either.

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    rid = "#{OS.mac? ? "osx" : "linux"}-#{Hardware::CPU.arm? ? "arm64" : "x64"}"

    system "dotnet", "publish", "JdkFind.Cli",
      "-c", "Release",
      "-r", rid,
      "-p:PublishAot=true",
      "-o", buildpath/"publish"

    bin.install buildpath/"publish/jdkfind"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jdkfind --version")
  end
end
