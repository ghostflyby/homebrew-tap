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

  bottle do
    root_url "https://github.com/ghostflyby/homebrew-tap/releases/download/jdkfind-0.5.1"
    sha256 cellar: :any, arm64_tahoe:   "109fcb7adc573e909e3b84b0fe1c3ab357fd39507573143e33cffd148f8df940"
    sha256 cellar: :any, arm64_sequoia: "69a7ffa55c0da8bd7a8296417aea6a8ac6ce18fc15585f0e0a73a659be4c7f2e"
    sha256 cellar: :any, x86_64_linux:  "2f77733435c31d6c13c0a94bf7791f484656bdf278352af4aab3631b94080fd2"
  end

  depends_on "dotnet" => :build
  # NativeAOT links the crypto and compression shims into the binary at build
  # time, so the produced executable load-commands brew's openssl and brotli.
  depends_on "brotli"
  depends_on "openssl@4"

  # .NET dlopens ICU by soname at runtime and icu4c@78 is keg-only, so its lib
  # dir is not on the default loader path; the RUNPATH added in install makes
  # dlopen resolve it (glibc consults the calling executable's RUNPATH).
  on_linux do
    depends_on "patchelf" => :build
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

    bin.install buildpath/"publish/jdkfind"

    if OS.linux?
      system "patchelf", "--add-rpath", formula_opt_lib("icu4c@78"), bin/"jdkfind"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jdkfind --version")
  end
end
