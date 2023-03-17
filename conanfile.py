from conan import ConanFile

class ConsumerConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = [
        "CMakeDeps", 
        "CMakeToolchain"
    ]
    requires = [
        "fmt/8.1.1@",
        "cli11/2.2.0@",
        "eigen/3.3.9@"
    ]
    default_options = {
    }