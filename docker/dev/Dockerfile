# Copyright (c) 2017-2019 Takeshi Yonezu
# All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

FROM ubuntu:16.04

ARG NUMCORE=${NUMCORE:-4}
ARG CMAKE_BUILD_TYPE=Release

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y --no-install-recommends install \
    automake build-essential ca-certificates ccache \
    git libssl-dev rsync zlib1g-dev libcurl4-openssl-dev \
    python3 python-software-properties curl \
 && apt-get -y clean

# install cmake 3.11.4
RUN git clone https://gitlab.kitware.com/cmake/cmake.git /tmp/cmake \
 && (cd /tmp/cmake; git checkout 316bd45439ad8ced6b31bcb10303a788038387ef) \
 && (cd /tmp/cmake; /tmp/cmake/bootstrap --system-curl --parallel=${NUMCORE} --enable-ccache) \
 && make -j${NUMCORE} -C /tmp/cmake \
 && make -C /tmp/cmake install \
 && ldconfig \
 && rm -fr /tmp/cmake

# install boost 1.70.0
RUN git clone https://github.com/boostorg/boost /tmp/boost \
 && (cd /tmp/boost; git checkout 8f9a1cf1d15d262e09c16a305034d8bc1e39aca2) \
 && (cd /tmp/boost; git submodule update --init --recursive) \
 && (cd /tmp/boost/libs/variant; curl https://patch-diff.githubusercontent.com/raw/boostorg/variant/pull/68.patch | git apply) \
 && (cd /tmp/boost; /tmp/boost/bootstrap.sh --with-libraries=system,filesystem,thread) \
 && (cd /tmp/boost; /tmp/boost/b2 headers) \
 && (cd /tmp/boost; /tmp/boost/b2 cxxflags="-std=c++14" -j${NUMCORE} install) \
 && ldconfig \
 && rm -fr /tmp/boost

# install protobuf v3.8.0
RUN git clone https://github.com/google/protobuf /tmp/protobuf \
 && (cd /tmp/protobuf; git checkout 09745575a923640154bcf307fba8aedff47f240a) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -Dprotobuf_BUILD_TESTS=OFF \
      -Dprotobuf_BUILD_SHARED_LIBS=ON \
      -H/tmp/protobuf/cmake \
      -B/tmp/protobuf/.build \
 && cmake --build /tmp/protobuf/.build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -fr /tmp/protobuf

# install gflags
RUN git clone https://github.com/gflags/gflags /tmp/gflags \
 && (cd /tmp/gflags; git checkout f8a0efe03aa69b3336d8e228b37d4ccb17324b88) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -H/tmp/gflags \
      -B/tmp/gflags/build \
 && cmake --build /tmp/gflags/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -rf /tmp/gflags

# install c-ares
RUN git clone https://github.com/c-ares/c-ares /tmp/c-ares \
 && (cd /tmp/c-ares; git checkout 3be1924221e1326df520f8498d704a5c4c8d0cce) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -H/tmp/c-ares \
      -B/tmp/c-ares/build \
 && cmake --build /tmp/c-ares/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -rf /tmp/c-ares

# install grpc 1.21.1
RUN git clone https://github.com/grpc/grpc /tmp/grpc \
 && (cd /tmp/grpc; git checkout 75475f090875e737ad6909a6057c59577f0c79b1) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DgRPC_BENCHMARK_PROVIDER="" \
      -DgRPC_ZLIB_PROVIDER=package \
      -DgRPC_CARES_PROVIDER=package \
      -DgRPC_SSL_PROVIDER=package \
      -DgRPC_PROTOBUF_PROVIDER=package \
      -DgRPC_GFLAGS_PROVIDER=package \
      -DBUILD_SHARED_LIBS=ON \
      -H/tmp/grpc \
      -B/tmp/grpc/.build \
 && cmake --build /tmp/grpc/.build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -rf /tmp/grpc

## # install gtest 2019-01-04
## RUN git clone https://github.com/google/googletest /tmp/googletest \
##  && (cd /tmp/googletest; git checkout b6cd405286ed8635ece71c72f118e659f4ade3fb) \
##  && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
##       -H/tmp/googletest \
##       -B/tmp/googletest/build \
##  && cmake --build /tmp/googletest/build --target install -- -j${NUMCORE} \
##  && ldconfig \
##  && rm -rf /tmp/googletest

# install fmtlib 5.3.0
RUN git clone git://github.com/fmtlib/fmt.git /tmp/fmt \
 && cd /tmp/fmt; git checkout 9e554999ce02cf86fcdfe74fe740c4fe3f5a56d5 \
 && mkdir build; cd build \
 && cmake \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DBUILD_SHARED_LIBS=TRUE \
      -DFMT_TEST=OFF .. \
 && cmake --build /tmp/fmt/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && cd /tmp; rm -fr /tmp/fmt

# install spdlog v1.3.1
RUN git clone https://github.com/gabime/spdlog /tmp/spdlog \
 && (cd /tmp/spdlog; git checkout a7148b718ea2fabb8387cb90aee9bf448da63e65) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DSPDLOG_BUILD_BENCH=OFF \
      -DSPDLOG_BUILD_TESTS=OFF \
      -DSPDLOG_FMT_EXTERNAL=ON \
      -H/tmp/spdlog \
      -B/tmp/spdlog/build \
 && cmake --build /tmp/spdlog/build --target install -- -j${NUMCORE} \
 && rm -rf /tmp/spdlog

# install rxcpp
RUN git clone https://github.com/Reactive-Extensions/RxCpp /tmp/RxCpp \
 && (cd /tmp/RxCpp; git checkout f38fb8e3c30b01b07c57e08039b2942f1685224d) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -H/tmp/RxCpp \
      -B/tmp/RxCpp/build \
 && cmake --build /tmp/RxCpp/build --target install -- -j${NUMCORE} \
 && rm -fr /tmp/RxCpp

# install rapidjson
RUN git clone https://github.com/miloyip/rapidjson /tmp/rapidjson \
 && (cd /tmp/rapidjson; git checkout f54b0e47a08782a6131cc3d60f94d038fa6e0a51) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DRAPIDJSON_BUILD_EXAMPLES=OFF \
      -H/tmp/rapidjson \
      -B/tmp/rapidjson/build \
 && cmake --build /tmp/rapidjson/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -fr /tmp/rapidjson

# install libpq
RUN git clone https://git.postgresql.org/git/postgresql.git /tmp/postgresql \
 && cd /tmp/postgresql \
 && git checkout 029386ccbddd0a33d481b94e511f5219b03e6636 \
 && ./configure --without-readline --prefix=/usr/local \
 && make -j${NUMCORE} -C src/bin/pg_config \
 && make -j${NUMCORE} -C src/interfaces/libpq \
 && make -j${NUMCORE} -C src/backend/utils fmgroids.h \
 && cp src/backend/utils/fmgroids.h src/include/utils/fmgroids.h \
 && make -C src/bin/pg_config install \
 && make -C src/interfaces/libpq install \
 && make -C src/include install \
 && ldconfig \
 && rm -fr /tmp/postgresql

# install soci
RUN git clone https://github.com/SOCI/soci /tmp/soci \
 && (cd /tmp/soci; git checkout 349ce86b79e63b99ba95200bc4bd1d83791e9094) \
 && cmake \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DSOCI_CXX_C11=ON \
      -DSOCI_TESTS=OFF \
      -DSOCI_EMPTY=OFF \
      -DWITH_BOOST=ON \
      -DWITH_DB2=OFF \
      -DWITH_FIREBIRD=OFF \
      -DWITH_MYSQL=OFF \
      -DWITH_ODBC=OFF \
      -DWITH_ORACLE=OFF \
      -DWITH_POSTGRESQL=ON \
      -DWITH_SQLITE3=OFF \
      -H/tmp/soci \
      -B/tmp/soci/build \
 && cmake --build /tmp/soci/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -rf /tmp/soci

# install tbb
RUN git clone https://github.com/01org/tbb /tmp/tbb \
 && (cd /tmp/tbb; git checkout eb6336ad29450f2a64af5123ca1b9429ff6bc11d) \
 && make -j${NUMCORE} -C /tmp/tbb tbb_build_prefix=build \
 && cp /tmp/tbb/build/build_debug/*.so* /usr/local/lib \
 && cp /tmp/tbb/build/build_release/*.so* /usr/local/lib \
 && cp -r /tmp/tbb/include/* /usr/local/include \
 && ldconfig \
 && rm -fr /tmp/tbb

# install ed25519 2.0.2
RUN git clone git://github.com/hyperledger/iroha-ed25519.git /tmp/ed25519 \
 && (cd /tmp/ed25519; git checkout eb4c0fce900e2468b94bb9e9498af626bb66c039) \
 && cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
      -DTESTING=OFF \
      -DHASH=sha3_brainhub \
      -DEDIMPL=ref10 \
      -H/tmp/ed25519 \
      -B/tmp/ed25519/build \
 && cmake --build /tmp/ed25519/build --target install -- -j${NUMCORE} \
 && ldconfig \
 && rm -rf /tmp/ed25519

WORKDIR /opt/iroha

CMD ["/bin/bash"]
