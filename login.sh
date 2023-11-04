#!/usr/bin/env bash

# Disable built-in system text replacement (since I use espanso for text replacements on Mac)
defaults delete -g NSUserReplacementItems
defaults delete -g NSUserDictionaryReplacementItems
