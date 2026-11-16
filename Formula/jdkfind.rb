class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "36d04ad8fa687e5f98f7b9de79880c96ebfcb4386e15d424b66ed5217439d382"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.9.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "aaaa4c2d276c743da4f9272c8714e32c3d7b48b09cd4d20d7cfe7c9b1f774a73"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "de09a4eda2e53afdf97d74804333108a40d0fddcb20909619086513e7b245387"
    sha256 cellar: :any,                 x86_64_linux:  "09be1db77589f639292cf85d8f95ea88956f703590ffca515754b207d3e49075"
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
