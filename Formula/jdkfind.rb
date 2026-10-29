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
