#!/bin/bash

WATCH_DIR="./"
RUN_SCRIPT="run.R"
# brew install fswatch

fswatch -o "${WATCH_DIR}" --include ".*\\.qmd$" --exclude ".*" | while read -r ; do
  echo "Detected change in QMD file. Running ${RUN_SCRIPT}..."

  Rscript "${RUN_SCRIPT}"

  echo "Finished running ${RUN_SCRIPT}."
done
