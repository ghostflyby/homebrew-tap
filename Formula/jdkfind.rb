class Jdkfind < Formula
  desc "Locate installed JDKs across Windows, macOS and Linux"
  homepage "https://github.com/ghostflyby/JdkFind"
  url "https://github.com/ghostflyby/JdkFind/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "14b6f3e9b09ef7082c533030669af660db56e7bba0bc351f0ecd26ba8df52ddb"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "dotnet" => :build
  # NativeAOT links the crypto and compression shims into the binary at build
  # time, so the produced executable load-commands brew's openssl and brotli.
  depends_on "brotli"
  depends_on "openssl@4"

  # .NET dlopens ICU by soname at runtime and icu4c@78 is keg-only, so Linux
  # needs its lib dir on the loader path (same approach as the dotnet formula).
  on_linux do
    depends_on "icu4c@78"
  end

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"

    rid = "#{OS.mac? ? "osx" : "linux"}-#{Hardware::CPU.arm? ? "arm64" : "x64"}"

    system "dotnet", "publish", "JdkFind.Cli",
      "-c", "Release",
      "-r", rid,
      "-p:PublishAot=true",
      "-o", buildpath/"publish"

    if OS.linux?
      env = { LD_LIBRARY_PATH: "#{formula_opt_lib("icu4c@78")}:${LD_LIBRARY_PATH:-}" }
      (bin/"jdkfind").write_env_script buildpath/"publish/jdkfind", env
    else
      bin.install buildpath/"publish/jdkfind"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jdkfind --version")
  end
end
