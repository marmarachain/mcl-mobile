[![downloads](https://img.shields.io/github/downloads/marmarachain/mcl-mobile/total?color=brightgreen&style=plastic)]()
![last commit](https://img.shields.io/github/last-commit/marmarachain/mcl-mobile?color=blue)
[![issues](https://img.shields.io/github/issues/marmarachain/mcl-mobile?color=yellow)](https://github.com/marmarachain/marmara-connector/issues)
![language](https://img.shields.io/github/languages/top/marmarachain/mcl-mobile)
![twitter](https://img.shields.io/twitter/follow/marmarachain?label=marmarachain&style=social)

<img src="https://raw.githubusercontent.com/marmarachain/mcl-mobile/master/mcl/assets/images/home.png" width=200 height=429/> <img src="https://raw.githubusercontent.com/marmarachain/mcl-mobile/master/mcl/assets/images/chain.png" width=200 height=429/> <img src="https://raw.githubusercontent.com/marmarachain/mcl-mobile/master/mcl/assets/images/wallet.png" width=200 height=429/> <img src="https://raw.githubusercontent.com/marmarachain/mcl-mobile/master/mcl/assets/images/receive-send.png" width=200 height=429/> <img src="https://raw.githubusercontent.com/marmarachain/mcl-mobile/master/mcl/assets/images/credit.png" width=200 height=429/>

## MCL Mobile
MCL Mobile is an easy to use mobile application for installing Marmara Chain and conducting credit loops on a remote platform which can be a local machine or a server. 
The developed app establishes a connection to a remote platform through SSH technology.
The remote platform is Linux based OS.

For more detailed information on creating Marmara credit loops, kindly refer to [Making Marmara Credit Loops](https://github.com/marmarachain/marmara/wiki/How-to-make-Marmara-Credit-Loops?). 

## Features
- Enables installing Marmara Chain on a remote server,
- Send/receive MCL transactions,
- Enables making Marmara Credit Loops and managing them on a single interface without having to know the commands.
- Provides easy listing and filtering of Marmara Credit Loops.

## Getting Started

- Download link from android app play [for now in testing phase](https://play.google.com/apps/internaltest/4699510321426919881).


## Establishing Marmara Credit Loops Chain in 3 Steps

- Step 1 installing Docker
- Step 2 create MCL image with Dockerfile and run container
- ✨Step 3 Installing MCL Mobile app on your phone ✨


## Step 1 installing Docker

[Docker Desktop](https://www.docker.com/get-started) requires [install on Windows](https://docs.docker.com/docker-for-windows/install/)

Docker Desktop does not start automatically after installation. To start Docker Desktop, search for Docker, and select Docker Desktop in the search results.

![Start Docker Desktop](https://docs.docker.com/docker-for-windows/images/docker-app-search.png "Start Docker Desktop")

For Linux(Ubuntu) environments...

```sh
sudo apt update
sudo apt install snapd
sudo snap install docker
docker --version
docker-machine --version
```

## Step 2 Create MCL Chain Image with Dockerfile and Run Container

MCL Chain is very easy to install and deploy in a Docker container.

By default, the Docker will expose port 22, so change this within the
Dockerfile if necessary. When ready, simply use the Dockerfile to
build the image.

```sh
cd mcl-mobile
docker build -t mclchain .
```

```sh
docker run -d -p 22:22 -v mcl-files:/root --name marmara mclchain
```
> Note: `docker exec -it marmara /bin/bash` is command line run code.

## Step 3 Installing MCL Mobile app on your phone 

To download during testing [Android Apps on Google Play](https://play.google.com/apps/internaltest/4699510321426919881)


## Contact
- B. Gültekin Çetiner [![twitter](https://img.shields.io/twitter/follow/drcetiner?style=social)](https://twitter.com/drcetiner )

Contribution
---
Contributions to the development of this software in any way are very welcomed and can be made through PRs.

Important Notice
---
MCL Mobile is experimental and a work-in-progress. Use at your own risk!
 
License
---
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
