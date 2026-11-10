class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "368d731f0e17df98c74ab791f3dcf71bebd5b47eae24fb1cdd7c9b2cc69f56da"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "18f278e34235b8fb09989c730d40fdaecea1ffe0f980ceb8bebf552bc5b76369"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "80aac82442b62dd02d8b0b493104746829e24a8da57d521904e9428f271da553"
    sha256 cellar: :any,                 x86_64_linux:  "8a3e602e0d8fd94cfb2930b278ab4afd9fdf693c84118de476f9ad95f1da481f"
  end

  depends_on "dotnet" => :build

  # No runtime library dependencies: the AOT binary links system libraries
  # only. Upstream strips the unused NativeAOT zlib/brotli/openssl link args
  # and runs with invariant globalization, so nothing is dlopen'ed either.

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    rid = "#{OS.mac? ? "osx" : "linux"}-#{Hardware::CPU.arm? ? "arm64" : "x64"}"

    # Upstream dropped the hardcoded <Version> from the csproj in v0.7.0 and
    # injects the tag version in its own release workflow, so pass it here.
    system "dotnet", "publish", "JdkFind.Cli",
      "-c", "Release",
      "-r", rid,
      "-p:Version=#{version}",
      "-p:PublishAot=true",
      "-o", buildpath/"publish"

    bin.install buildpath/"publish/jdkfind"

    # The completion scripts address jdkfind by command name, so they carry
    # no Cellar path and stay usable from a bottle as-is.
    generate_completions_from_executable(bin/"jdkfind", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jdkfind --version")

    assert_match "bash\nzsh\nfish\npowershell", shell_output("#{bin}/jdkfind completions")
    assert_match "complete -F _jdkfind jdkfind", shell_output("#{bin}/jdkfind completions bash")
  end
end
