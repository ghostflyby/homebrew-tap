class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "6e541a6cc6c31c6aa669ed035d1f3c34de7b4c5f77e5edbcf910591796772e06"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.6.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5ab3c6c8888add22b6f4da23679bde2f1f19b2b2c7c602156532ea91941418c8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "107c2cadd6dacbfda135f8cb9a12dc272de1e2275460602770dc2bf5aac23be8"
    sha256 cellar: :any,                 x86_64_linux:  "3d0fbcc44c9fe26dacd007a534e9a57d95f959c9602b559c08213fec8ad0d1ba"
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
