class IgnitionMsgs8 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs8-8.7.0.tar.bz2"
  sha256 "b17a8e16fe56a84891bd0654a2ac09427e9a567b9cd2255bb2cfa830f8e1af45"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "ign-msgs8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "aac173533941affa54dc9538470572ce2858ff059d3eda3285c0d176212790ae"
    sha256 cellar: :any, big_sur:  "6a506d51c89f032b7f6c0d923c107d36d84d9bbce711ff6139686ef863ec3272"
    sha256 cellar: :any, catalina: "3c8ddaf2a56ebfb1ab322274bec231adbe745fd33fcb535bd4a42b4aa6e8b3f7"
  end

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-msgs8 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs8::ignition-msgs8)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs8"
    cflags = `pkg-config --cflags ignition-msgs8`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs8",
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
