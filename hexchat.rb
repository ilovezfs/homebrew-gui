class Hexchat < Formula
  desc "IRC client based on XChat"
  homepage "https://hexchat.github.io/"
  url "https://dl.hexchat.net/hexchat/hexchat-2.12.3.tar.xz"
  sha256 "6f2b22372c7a9ed8ffab817079638e8f4178f5f8ba63c89cb3baa01be614f2ba"

  bottle do
    sha256 "913a9f541e58edbfabecc3af78be1e138297d17cc2019c2a8cd3abc0cd07b5af" => :sierra
    sha256 "40e77ac17f46d79b691c4e32887990ff587c5cbbc7173db8b015ea7eb377875e" => :el_capitan
    sha256 "2f90b613b164bcf5b9a2af17d50cc9fc4ac5d1455eae8cd819d18a6a322a00d7" => :yosemite
  end

  head do
    url "https://github.com/hexchat/hexchat.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "autoconf-archive" => :build
  end

  option "without-perl", "Build without Perl support"
  option "without-plugins", "Build without plugin support"

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "gettext"
  depends_on "gtk+"
  depends_on "gtk-mac-integration"
  depends_on "openssl"
  depends_on :python => :optional
  depends_on :python3 => :optional
  depends_on "lua" => :optional

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-openssl=#{Formula["openssl"].opt_prefix}
    ]

    if build.with? "python3"
      ENV.delete("PYTHONPATH")
      # https://github.com/Homebrew/homebrew-gui/pull/9
      ENV["PYTHON_EXTRA_LIBS"] = " "
      args << "--enable-python=python3"
    elsif build.with? "python"
      args << "--enable-python=python2.7"
    else
      args << "--disable-python"
    end

    args << "--disable-perl" if build.without? "perl"
    args << "--disable-plugin" if build.without? "plugins"
    args << "--disable-lua" if build.without? "lua"

    # https://github.com/hexchat/hexchat/issues/1657
    args << "--disable-sysinfo" if MacOS.version <= :mavericks

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"

    rm_rf share/"applications"
    rm_rf share/"appdata"
  end

  test do
    system bin/"hexchat", "--help-gtk"
  end
end
