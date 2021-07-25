#!/usr/bin/env bash

pushd Advocatus-Proxy
git rebase --interactive upstream/upstream
popd
