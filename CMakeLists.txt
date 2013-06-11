set(CMAKE_TOOLCHAIN_FILE cmake/cmake/ArduinoToolchain.cmake) # Arduino Toolchain
cmake_minimum_required(VERSION 2.8)

project(ArduinoExample C CXX)

print_board_list()
print_programmer_list()

set(ARDUINO_DEFAULT_BOARD leonardo) # Default Board ID, when not specified
set(ARDUINO_DEFAULT_PORT /dev/ttyACM0) # Default Port, when not specified

link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)

generate_arduino_firmware(FC
    SRCS FC.cpp
    HDRS FC.h
    SERIAL picocom @SERIAL_PORT@ #optional target for talking to arudino
    PROGRAMMER arduinoisp
   )


