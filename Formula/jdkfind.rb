class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.10.0.tar.gz"
  sha256 "f00875c08f437d0a6dc2b6d9170738de5ed7a2921b05153bd2a2bb5d9c447cf0"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.10.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e191253df04f0b4282c6c86d3999539a9778b221d249bd6ec87785a59463a4cf"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "cb518b1ea57a5becb2fe2311fcbe4e8e8da35f5e1c6f10b38592ff5423ef0a05"
    sha256 cellar: :any,                 x86_64_linux:  "1a7c7f5bb991424cd518c691eb4238b77c89ee5df52fec8bcee8f560d3362042"
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
