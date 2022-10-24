class Bsdmake < Formula
  desc "BSD version of the Make build tool"
  homepage "https://opensource.apple.com/"
  url "https://opensource.apple.com/tarballs/bsdmake/bsdmake-24.tar.gz"
  sha256 "82a948b80c2abfc61c4aa5c1da775986418a8e8eb3dd896288cfadf2e19c4985"
  license all_of: ["BSD-2-Clause", "BSD-3-Clause", "BSD-4-Clause-UC"]

  livecheck do
    url "https://opensource.apple.com/tarballs/bsdmake/"
    regex(/href=.*?bsdmake[._-]v?(\d+(?:\.\d+)*)\.t/i)
  end

  bottle do
    rebuild 2
    sha256 arm64_monterey: "d01faf8a67751cf8248d36ef46fa23f8f6031c04fd723eb1cbf40ee881d6bc09"
    sha256 arm64_big_sur:  "cfca87086e9932c2a1beb031d5fd34018a5afbe84a051918b41b33e4e86c82ea"
    sha256 monterey:       "303f1fce21a307e0ecb01214f64ba7c3f26c21aeafb44d803120d26500dd387a"
    sha256 big_sur:        "6b1aef88ae6c6b11cee8062b64f5fe2e1c337e3029833eaded84b6e740ae0391"
    sha256 catalina:       "5075d566898ea241d7251734f82f6846c288a49d939f8842fa566ea706e2417f"
  end

  # MacPorts patches to make bsdmake play nice with our prefix system
  # Also a MacPorts patch to circumvent setrlimit error
  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/1fcaddfc/bsdmake/patch-Makefile.diff"
    sha256 "1e247cb7d8769d50e675e3f66b6f19a1bc7663a7c0800fc29a2489f3f6397242"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/1fcaddfc/bsdmake/patch-mk.diff"
    sha256 "b7146bfe7a28fc422e740e28e56e5bf0166a29ddf47a54632ad106bca2d72559"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/1fcaddfc/bsdmake/patch-pathnames.diff"
    sha256 "b24d73e5fe48ac2ecdfbe381e9173f97523eed5b82a78c69dcdf6ce936706ec6"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/1fcaddfc/bsdmake/patch-setrlimit.diff"
    sha256 "cab53527564d775d9bd9a6e4969f116fdd85bcf0ad3f3e57ec2dcc648f7ed448"
  end

  def install
    # Replace @PREFIX@ inserted by MacPorts patches
    inreplace %w[mk/bsd.README
                 mk/bsd.cpu.mk
                 mk/bsd.doc.mk
                 mk/bsd.obj.mk
                 mk/bsd.own.mk
                 mk/bsd.port.mk
                 mk/bsd.port.subdir.mk
                 mk/sys.mk
                 pathnames.h],
                 "@PREFIX@", prefix

    inreplace "mk/bsd.own.mk" do |s|
      s.gsub! "@INSTALL_USER@", `id -un`.chomp
      s.gsub! "@INSTALL_GROUP@", `id -gn`.chomp
    end

    # See GNUMakefile
    ENV.append "CFLAGS", "-D__FBSDID=__RCSID"
    ENV.append "CFLAGS", "-mdynamic-no-pic"

    system "make", "-f", "Makefile.dist"
    bin.install "pmake" => "bsdmake"
    man1.install "make.1" => "bsdmake.1"
    (share/"mk/bsdmake").install Dir["mk/*"]
  end

  test do
    (testpath/"Makefile").write <<~EOS
      foo:
      \ttouch $@
    EOS

    system "#{bin}/bsdmake"
    assert_predicate testpath/"foo", :exist?
  end
end
