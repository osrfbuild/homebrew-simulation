class IgnitionFuelTools6 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools6-6.0.0~pre1.tar.bz2"
  version "6.0.0~pre1"
  sha256 "a26460bd554113ea7f85a760f2bd4d884e919fc59059a86446db9bded6d49b20"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-fuel-tools.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "d6c3299eb2cbefa2ccb710cf1e6b25fbb502fc9c210bc3c153e549cdc7d995d5"
    sha256 cellar: :any, mojave:   "1b46de66b82e352d18f2ffbaace2af3ab4e6d381275040486aaa14a2f423b85c"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-msgs7"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/fuel_tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel_tools6 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools6::ignition-fuel_tools6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools6"
    cflags = `pkg-config --cflags ignition-fuel_tools6`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools6",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
