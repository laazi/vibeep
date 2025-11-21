
# Project Blueprint

## Overview

This document outlines the plan, style, design, and features of the Flutter application.

## Current Plan

The current plan is to create a Flutter application with the following features:

*   A top timer that acts as a stopwatch.
*   A display for the target time, which is 90 seconds after the last button press.
*   A counter that increments on each button press.
*   A button that spans the width of the screen.
*   The app will beep 10 times when the top timer reaches the target time.

## Implemented Features

### Initial Setup

*   **Project Structure**: Set up a standard Flutter project structure.
*   **Dependencies**: Added the `audioplayers` package for audio playback.
*   **Assets**: Configured the `pubspec.yaml` to include audio assets from the `assets/audio/` directory.

### Core Functionality

*   **Timers**: Implemented a stopwatch (top timer) and a target time display (bottom timer). The font size of the timers has been increased by 1.5x.
*   **Button**: Created a full-width button that triggers the main logic. The button's height has been doubled and its text changed to "TERAZ".
*   **Counter**: Added a counter that increments with each button press.
*   **Audio Playback**: Integrated the `audioplayers` package to play a beeping sound when the timer reaches the target.
