// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library CircleTypes {
    struct Config {
        uint16 x;
        uint16 y;
        uint16 size;
        uint256 seed;
        bool useGradient;
        bool enableGlitch;
    }
}
