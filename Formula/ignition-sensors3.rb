class IgnitionSensors3 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors3-3.5.0.tar.bz2"
  sha256 "904297a8deea7f3bff79a4a1fa24aee9c208a72013e29147c3087ca07fc41788"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "ign-sensors3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "add01702814aac7161181a48fa6e141ba3cb9cc8189362fc6572d09b7d44fe66"
    sha256 big_sur:  "283d4781ca9ee33ec40390f6226f6f46a8f8af32516ccebd534fd7f9ea37f15b"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-rendering3"
  depends_on "ignition-transport8"
  depends_on "sdformat9"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/sensors/Noise.hh>

      int main()
      {
        ignition::sensors::Noise noise(ignition::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-sensors3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors3::ignition-sensors3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors3"
    cflags   = `pkg-config --cflags ignition-sensors3`.split
    ldflags  = `pkg-config --libs ignition-sensors3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
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
