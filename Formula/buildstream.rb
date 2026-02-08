class Buildstream < Formula
  include Language::Python::Virtualenv

  desc "Powerful software integration tool"
  homepage "https://buildstream.build"
  url "https://files.pythonhosted.org/packages/7b/88/8b445d272ecb7367e5da4f0d8f41bae87517361098d4f712fb427e04af87/buildstream-2.6.0.tar.gz"
  sha256 "d6f835bab11dda88a3f213441768b1566e21a6c658913f0f0488fcf01a5c23bf"
  license "Apache-2.0"

  depends_on "buildbox"
  depends_on "gpatch"
  depends_on :linux
  depends_on "lzip"
  # Pinned to 3.11 because all binary wheel resources are cp311
  depends_on "python@3.11"

  # Cython for python11
  resource "Cython" do
    url "https://files.pythonhosted.org/packages/ac/25/58893afd4ef45f79e3d4db82742fa4ff874b936d67a83c92939053920ccd/cython-3.2.4-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
    sha256 "b362819d155fff1482575e804e43e3a8825332d32baa15245f4642022664a3f4"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/94/b8/f1f62a5e3c0ad2ff1d189590bfa4c46b4f3b6e49cef6f26c6ee4e575394d/setuptools-80.10.2-py3-none-any.whl"
    sha256 "95b30ddfb717250edb492926c92b5221f7ef3fbcc2b07579bcd4a27da21d0173"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/87/22/b76d483683216dde3d67cba61fb2444be8d5be289bf628c13fc0fd90e5f9/wheel-0.46.3-py3-none-any.whl"
    sha256 "4b399d56c9d9338230118d705d9737a2a468ccca63d5e813e2a4fc7815d8bc4d"
  end

  # Runtime dependencies
  resource "click" do
    url "https://files.pythonhosted.org/packages/3d/fa/656b739db8587d7b5dfa22e22ed02566950fbfbcdc20311993483657a5c0/click-8.3.1.tar.gz"
    sha256 "12ff4785d337a1bb490bb7e9c2b1ee5da3112e94a8622f26a6c77f5d2fc6842a"
  end

  resource "grpcio" do
    url "https://files.pythonhosted.org/packages/68/86/093c46e9546073cefa789bd76d44c5cb2abc824ca62af0c18be590ff13ba/grpcio-1.76.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
    sha256 "8843114c0cfce61b40ad48df65abcfc00d4dba82eae8718fab5352390848c5da"
  end

  resource "Jinja2" do
    url "https://files.pythonhosted.org/packages/df/bf/f7da0350254c0ed7c72f3e33cef02e048281fec7ecec5f032d4aac52226b/jinja2-3.1.6.tar.gz"
    sha256 "0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d"
  end

  resource "MarkupSafe" do
    url "https://files.pythonhosted.org/packages/7e/99/7690b6d4034fffd95959cbe0c02de8deb3098cc577c67bb6a24fe5d7caa7/markupsafe-3.0.3.tar.gz"
    sha256 "722695808f4b6457b320fdc131280796bdceb04ab50fe1795cd540799ebe1698"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/65/ee/299d360cdc32edc7d2cf530f3accf79c4fca01e96ffc950d8a52213bd8e4/packaging-26.0.tar.gz"
    sha256 "00243ae351a257117b6a241061796684b084ed1c516a08c48a3f7e147a9d80b4"
  end

  resource "pluginbase" do
    url "https://files.pythonhosted.org/packages/f3/07/753451e80d2b0bf3bceec1162e8d23638ac3cb18d1c38ad340c586e90b42/pluginbase-1.0.1.tar.gz"
    sha256 "ff6c33a98fce232e9c73841d787a643de574937069f0d18147028d70d7dee287"
  end

  resource "protobuf" do
    url "https://files.pythonhosted.org/packages/9b/53/a9443aa3ca9ba8724fdfa02dd1887c1bcd8e89556b715cfbacca6b63dbec/protobuf-6.33.5-cp39-abi3-manylinux2014_x86_64.whl"
    sha256 "cbf16ba3350fb7b889fca858fb215967792dc125b35c7976ca4818bee3521cf0"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/b5/70/5d8df3b09e25bce090399cf48e452d25c935ab72dad19406c77f4e828045/psutil-7.2.2-cp36-abi3-manylinux2010_x86_64.manylinux_2_12_x86_64.manylinux_2_28_x86_64.whl"
    sha256 "076a2d2f923fd4821644f5ba89f059523da90dc9014e85f8e45a5774ca5bc6f9"
  end

  resource "pyroaring" do
    url "https://files.pythonhosted.org/packages/ea/82/9f1a85ba33e3d89b9cdb8183fb2fd2f25720d10742dd8827508ccccc13ae/pyroaring-1.0.3-cp311-cp311-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
    sha256 "7d815f624e0285db3669f673d1725cb754b120ec70d0032d7c7166103a96c96d"
  end

  resource "ruamel-yaml" do
    url "https://files.pythonhosted.org/packages/c7/3b/ebda527b56beb90cb7652cb1c7e4f91f48649fbcd8d2eb2fb6e77cd3329b/ruamel_yaml-0.19.1.tar.gz"
    sha256 "53eb66cd27849eff968ebf8f0bf61f46cdac2da1d1f3576dd4ccee9b25c31993"
  end

  resource "ruamel-yaml-clib" do
    url "https://files.pythonhosted.org/packages/aa/ed/3fb20a1a96b8dc645d88c4072df481fe06e0289e4d528ebbdcc044ebc8b3/ruamel_yaml_clib-0.2.15-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
    sha256 "617d35dc765715fa86f8c3ccdae1e4229055832c452d4ec20856136acc75053f"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz"
    sha256 "0cea48d173cc12fa28ecabc3b837ea3cf6f38c6d1136f85cbaaf598984861466"
  end

  resource "ujson" do
    url "https://files.pythonhosted.org/packages/5d/7c/48706f7c1e917ecb97ddcfb7b1d756040b86ed38290e28579d63bd3fcc48/ujson-5.11.0-cp311-cp311-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
    sha256 "7e0ec1646db172beb8d3df4c32a9d78015e671d2000af548252769e33079d9a6"
  end

  # Manual deps for gnome/freedesktopsdk

  resource "dulwich" do
    url "https://files.pythonhosted.org/packages/d3/94/1b65ffc7e8794b0391112d365f54c9d7da49d6257ea59dcee01ac29dad8d/dulwich-0.24.10-cp311-cp311-manylinux_2_28_x86_64.whl"
    sha256 "858fae0c7121715282a993abb1919385a28e1a9c4f136f568748d283c2ba874f"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/56/1a/9ffe814d317c5224166b23e7c47f606d6e473712a2fad0f704ea9b99f246/urllib3-2.6.0-py3-none-any.whl"
    sha256 "c90f7a39f716c572c4e3e58509581ebd83f9b59cced005b7db7ad2d22b0db99f"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/1e/db/4254e3eabe8020b458f1a747140d32277ec7a271daf1d235b70dc0b4e6e3/requests-2.32.5-py3-none-any.whl"
    sha256 "2462f94637a34fd532264295e186976db0f5d453d1cdd31473c85a6a161affb6"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/0e/61/66938bbb5fc52dbdf84594873d5b51fb1f7c7794e9c0f5bd885f30bc507b/idna-3.11-py3-none-any.whl"
    sha256 "771a87f49d9defaf64091e6e6fe9c18d4833f140bd19464795bc32d966ca37ea"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/e6/ad/3cc14f097111b4de0040c83a525973216457bbeeb63739ef1ed275c1c021/certifi-2026.1.4-py3-none-any.whl"
    sha256 "9943707519e4add1115f44c2bc244f782c0249876bf51b6599fee1ffbedd685c"
  end

  resource "tomlkit" do
    url "https://files.pythonhosted.org/packages/b5/11/87d6d29fb5d237229d67973a6c9e06e048f01cf4994dee194ab0ea841814/tomlkit-0.14.0-py3-none-any.whl"
    sha256 "592064ed85b40fa213469f81ac584f67a4f2992509a7c3ea2d632208623a3680"
  end

  def install
    venv = virtualenv_create(libexec, "python3.11")

    # Setup Build Environment
    python_include = Formula["python@3.11"].opt_include/"python3.11"
    ENV.append_path "CPATH", python_include
    ENV.prepend_path "PATH", libexec/"bin"

    # Install Resources
    resources.each do |r|
      r.stage do
        if (wheel = Dir.glob("*.whl").first)
          venv.pip_install Pathname.pwd/wheel
        else
          venv.pip_install Pathname.pwd
        end
      end
    end

    # Cython and setuptools are already installed in the venv
    venv.pip_install buildpath, build_isolation: false

    bin.install_symlink libexec/"bin/bst"
  end

  test do
    system bin/"bst", "--version"
  end
end
