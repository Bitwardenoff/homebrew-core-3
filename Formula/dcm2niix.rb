class Dcm2niix < Formula
  desc "DICOM to NIfTI converter"
  homepage "https://www.nitrc.org/plugins/mwiki/index.php/dcm2nii:MainPage"
  url "https://github.com/rordenlab/dcm2niix/archive/v1.0.20170609.tar.gz"
  sha256 "17756f28dc42965854b7389d166df6d70c126486887fd2037b99d4a082c037ab"
  head "https://github.com/rordenlab/dcm2niix.git"

  option "with-batch"

  depends_on "cmake" => :build

  resource "sample.dcm" do
    url "https://raw.githubusercontent.com/dangom/sample-dicom/master/MR000000.dcm"
    sha256 "4efd3edd2f5eeec2f655865c7aed9bc552308eb2bc681f5dd311b480f26f3567"
  end

  def install
    args = std_cmake_args
    args << "-DBATCH_VERSION=ON" if build.with? "batch"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    resource("sample.dcm").stage testpath
    system "#{bin}/dcm2niix", "-f", "%d_%e", "-z", "n", "-b", "y", testpath
    assert File.exist? "localizer_1.nii"
    assert File.exist? "localizer_1.json"
  end
end
