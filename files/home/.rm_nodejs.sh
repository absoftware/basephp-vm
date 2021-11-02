#!/bin/bash

apt-get remove nodejs
rm -rf /usr/local/bin/npm
rm -rf /usr/local/share/man/man1/node*
rm -rf /usr/local/lib/dtrace/node.d
rm -rf ~/.node-gyp
rm -rf ~/.npm
rm -rf ~/.npm-global
rm -rf /opt/local/bin/node
rm -rf /opt/local/include/node
rm -rf /opt/local/lib/node_modules
rm -rf /usr/local/lib/node*
rm -rf /usr/local/include/node*
rm -rf /usr/local/bin/node*
