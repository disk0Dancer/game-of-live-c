cmake_minimum_required(VERSION 4.0)
project(game-of-live C)

set(CMAKE_C_STANDARD 23)
find_package(SDL2 REQUIRED)

add_executable(sim_app/)
