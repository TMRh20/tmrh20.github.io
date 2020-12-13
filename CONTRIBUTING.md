Documentation hosted in this repository is generated using [doxygen](https://www.doxygen.nl).

The only changes that should be made directly to this repository would be anything in the [index.html](https://github.com/TMRh20/tmrh20.github.io/blob/master/index.html) or the [RF24Installer/RPi](https://github.com/TMRh20/tmrh20.github.io/tree/master/RF24Installer/RPi) folder.

If you wish to contribute documentation changes, you must
1. be familiar with [doxygen](https://www.doxygen.nl/manual/index.html) (especially [doxygen's special commands](https://www.doxygen.nl/manual/commands.html)).
It also helps to know [Markdown syntax](https://guides.github.com/features/mastering-markdown/) because that is (mostly) the syntax that doxygen uses.
2. make your changes to the appropriate header file in the reository related to the library documentation you wish to change.

    | Library | Repository |
    |:-------:|:----------:|
    | RF24 | [nRF24/RF24](https://github.com/nRF24/RF24) |
    | RF24Network | [nRF24/RF24Network](https://github.com/nRF24/RF24Network) |
    | RF24Mesh | [nRF24/RF24Mesh](https://github.com/nRF24/RF24Mesh) |
    | RF24Ethernet | [nRF24/RF24Ethernet](https://github.com/nRF24/RF24Ethernet) |
    | AutoAnalogAudio | [TMRh20/AutoAnalogAudio](https://github.com/TMRh20/AutoAnalogAudio) |
    | TMRpcm | [TMRh20/TMRpcm](https://github.com/TMRh20/TMRpcm) |
    | RF24Audio | [nRF24/RF24Audio](https://github.com/nRF24/RF24Audio) |
3. submit a Pull Request in the repository for which you changed.
    - If your changes are related to AutoAnalogAudio or TMRpcm libraries, then a second Pull Request needs to be submitted to this repository.
    This second Pull Request should only contain the doxygen output of the new documentation.
