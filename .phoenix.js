// .phoenix.js - this file is loaded automatically by phoenix

const INCREMENT_WIDTH = 200;

// Since Window.recent() can sometimes take ~500ms to return, maintain a cache of windows in recent order
// TODO: ideally would have one recent window cache per space
var RECENT_WINDOW_CACHE = null;

function isOverlap(window1, window2) {
  let f1 = window1.frame();
  let f2 = window2.frame();

  return !(
    f1.x >= f2.x + f2.width ||
    f2.x >= f1.x + f1.width ||
    f1.y >= f2.y + f2.height ||
    f2.y >= f1.y + f1.height
  );
}

function computeDisplayFrames() {
  let screenFrame = Screen.main().flippedVisibleFrame();

  let leftHalfFrame = { x: screenFrame.x, y: screenFrame.y, width: screenFrame.width / 2, height:  screenFrame.height };
  let rightHalfFrame = { x: screenFrame.x + screenFrame.width / 2, y: screenFrame.y, width: screenFrame.width / 2, height:  screenFrame.height };

  let leftThirdFrame = { x: screenFrame.x, y: screenFrame.y, width: screenFrame.width / 3, height:  screenFrame.height };
  let middleThirdFrame = { x: screenFrame.x + screenFrame.width / 3, y: screenFrame.y, width: screenFrame.width / 3, height:  screenFrame.height };
  let rightThirdFrame = { x: screenFrame.x + 2 * screenFrame.width / 3, y: screenFrame.y, width: screenFrame.width / 3, height:  screenFrame.height };
  let leftTwoThirdsFrame = { x: screenFrame.x, y: screenFrame.y, width: 2 * screenFrame.width / 3, height:  screenFrame.height };
  let rightTwoThirdsFrame = { x: screenFrame.x + screenFrame.width / 3, y: screenFrame.y, width: 2 * screenFrame.width / 3, height:  screenFrame.height };

  return { leftHalfFrame, rightHalfFrame, leftThirdFrame, middleThirdFrame, rightThirdFrame, leftTwoThirdsFrame, rightTwoThirdsFrame };
}

// Finds three windows that are tiled side-by-side
function findThreeTiledWindows(recentWindows) {
  let currentWindow = Window.focused();
  let windows = recentWindows;

  let screenFrame = Space.active().screens()[0].visibleFrame();

  // loop over all possible 3 window combinations
  for (let i = 0; i < windows.length; i++) {
    for (let j = i + 1; j < windows.length; j++) {
      let firstWindow = currentWindow;
      let secondWindow = windows[i];
      let thirdWindow = windows[j];

      if (
        isOverlap(firstWindow, secondWindow) ||
        isOverlap(firstWindow, thirdWindow) ||
        isOverlap(secondWindow, thirdWindow)
      ) {
        continue;
      }

      let leftmostWindow = null;
      let middleWindow = null;
      let rightmostWindow = null;

      if (firstWindow.frame().x < secondWindow.frame().x) {
        if (firstWindow.frame().x < thirdWindow.frame().x) {
          leftmostWindow = firstWindow;
          if (secondWindow.frame().x < thirdWindow.frame().x) {
            middleWindow = secondWindow;
            rightmostWindow = thirdWindow;
          } else {
            middleWindow = thirdWindow;
            rightmostWindow = secondWindow;
          }
        } else {
          leftmostWindow = thirdWindow;
          middleWindow = firstWindow;
          rightmostWindow = secondWindow;
        }
      } else {
        if (secondWindow.frame().x < thirdWindow.frame().x) {
          leftmostWindow = secondWindow;
          if (firstWindow.frame().x < thirdWindow.frame().x) {
            middleWindow = firstWindow;
            rightmostWindow = thirdWindow;
          } else {
            middleWindow = thirdWindow;
            rightmostWindow = firstWindow;
          }
        } else {
          leftmostWindow = thirdWindow;
          middleWindow = secondWindow;
          rightmostWindow = firstWindow;
        }
      }

      let firstWindowSize =
        firstWindow.frame().width * firstWindow.frame().height;
      let secondWindowSize =
        secondWindow.frame().width * secondWindow.frame().height;
      let thirdWindowSize =
        thirdWindow.frame().width * thirdWindow.frame().height;

      if (
        firstWindowSize + secondWindowSize + thirdWindowSize ==
        screenFrame.width * screenFrame.height
      ) {
        let result = [firstWindow, secondWindow, thirdWindow].sort(
          (a, b) => a.frame().x - b.frame().x
        );
        console.log(
          `the three window titles are: ${JSON.stringify([
            result[0].title(),
            result[1].title(),
            result[2].title(),
          ])}`
        );
        return result;
      }
    }
  }

  return null;
}

function findTwoTiledWindows(recentWindows) {
  let currentWindow = Window.focused();
  let windows = recentWindows;

  let screenFrame = Space.active().screens()[0].visibleFrame();

  for (const w2 of windows) {
    let w1 = currentWindow;

    if (w1.isEqual(w2) || isOverlap(w1, w2)) {
      continue;
    }

    // console.log(`comparing ${w1.app().name()} (${w1.title()}) and ${w2.app().name()} (${w2.title()})`);

    let w1Frame = w1.frame();
    let w2Frame = w2.frame();

    let w1Size = w1Frame.width * w1Frame.height;
    let w2Size = w2Frame.width * w2Frame.height;

    if (w1Size + w2Size === screenFrame.width * screenFrame.height) {
      let result = [w1, w2].sort((a, b) => a.frame().x - b.frame().x);
      console.log(`the two window titles are: ${JSON.stringify([result[0].title(), result[1].title()])}`);
      return result;
    }
  }

  return null;
}

// Finds the two side-by-side tile windows and adjusts the split ratio
function retileTwoWindows(direction) {
  let currentSpace = Space.active();
  let screen = currentSpace.screens()[0];
  let screenFrame = screen.visibleFrame();

  // console.log(`screen frame is ${JSON.stringify(screenFrame)}`);

  var start = Date.now();
  let recentWindows = RECENT_WINDOW_CACHE ? RECENT_WINDOW_CACHE : Window.recent();
  console.log(`took ${Date.now() - start} ms to call Window.recent()`);
  let windows = recentWindows.filter((wndow) => wndow.isVisible() === true);

  // console.log(`checking windows in order: ${windows.map(window => window.app().name())}`);

  // find two windows whose size adds up to screen
  start = Date.now();
  let window1 = null;
  let window2 = null;
  let breakCheck1 = false; // break out of outer loop
  for (const w1 of windows) {
    for (const w2 of windows) {
      if (w1.isEqual(w2) || isOverlap(w1, w2)) {
        continue;
      }

      // console.log(`comparing ${w1.app().name()} (${w1.title()}) and ${w2.app().name()} (${w2.title()})`);

      let w1Frame = w1.frame();
      let w2Frame = w2.frame();

      let w1Size = w1Frame.width * w1Frame.height;
      let w2Size = w2Frame.width * w2Frame.height;

      if (w1Size + w2Size === screenFrame.width * screenFrame.height) {
        window1 = w1;
        window2 = w2;

        breakCheck1 = true;
        break;
      }
    }

    if (breakCheck1) {
      break;
    }
  }

  if (window1 === null || window2 === null) {
    console.log("could not find windows");
    return;
  }

  console.log(`took ${Date.now() - start} ms to find windows`);

  let leftWindow = null;
  let rightWindow = null;

  let w1Frame = window1.frame();
  let w2Frame = window2.frame();

  if (w1Frame.x < w2Frame.x) {
    leftWindow = window1;
    rightWindow = window2;
  } else {
    leftWindow = window2;
    rightWindow = window1;
  }
  console.log(
    `found windows ${leftWindow.app().name()} (${leftWindow.title()}) [left] and  ${rightWindow
      .app()
      .name()} (${rightWindow.title()} [right])`
  );

  let leftFrame = leftWindow.frame();
  let rightFrame = rightWindow.frame();

  console.log(`current frames are ${JSON.stringify([leftFrame, rightFrame])}`);

  leftFrame.width -= INCREMENT_WIDTH * direction;
  rightFrame.width += INCREMENT_WIDTH * direction;
  rightFrame.x -= INCREMENT_WIDTH * direction;

  console.log(`new frames are ${JSON.stringify([leftFrame, rightFrame])}`);

  // TODO: seems like if you try to change both the width and the x of Orion.app window at the same time, it will keep the the same x position (but correctly change the width) - best workaround is likely to always tile Orion.app windows to the left since we only need to adjust one frame property of the left window
  start = Date.now();
  leftWindow.setFrame(leftFrame);
  rightWindow.setFrame(rightFrame);
  console.log(`took ${Date.now() - start} ms to set frames`);
}

// Detects whether the current window config is either two-window tile, three-window tile, or not a tile
function getTiledWindowsConfig(recentWindows) {
  // First check for three-window tile, since that config is less likely to occur by accident
  let threeTiledWindows = findThreeTiledWindows(recentWindows);
  if (threeTiledWindows !== null) {
    return { type: "three-tile", windows: threeTiledWindows };
  }

  let twoTiledWindows = findTwoTiledWindows(recentWindows);
  if (twoTiledWindows !== null) {
    return { type: "two-tile", windows: twoTiledWindows };
  }

  return { type: "none", windows: [] };
}

// When two windows are tiled side-by-side, Ctrl-Shift-H will adjust the split to increase the width of the *right* window
Key.on("h", ["ctrl", "shift"], () => {
  retileTwoWindows(1);
});

// When two windows are tiled side-by-side, Ctrl-Shift-L will adjust the split to increase the width of the *left* window
Key.on("l", ["ctrl", "shift"], () => {
  retileTwoWindows(-1);
});

function moveFocusToRightWindowTile() {
  let currentWindow = Window.focused();
  let recentWindows = RECENT_WINDOW_CACHE ? RECENT_WINDOW_CACHE : Window.recent();
  let tiledWindows = getTiledWindowsConfig(recentWindows);

  if (tiledWindows.type === "none") {
    return;
  }

  if (tiledWindows.type === "three-tile") {
    let leftWindow = tiledWindows.windows[0];
    let middleWindow = tiledWindows.windows[1];
    let rightWindow = tiledWindows.windows[2];

    if (currentWindow.hash() === leftWindow.hash()) {
      middleWindow.focus();
    } else if (currentWindow.hash() === middleWindow.hash()) {
      rightWindow.focus();
    } else if (currentWindow.hash() === rightWindow.hash()) {
      leftWindow.focus();
    }
  }

  if (tiledWindows.type === "two-tile") {
    let leftWindow = tiledWindows.windows[0];
    let rightWindow = tiledWindows.windows[1];

    if (currentWindow.hash() === leftWindow.hash()) {
      rightWindow.focus();
    } else if (currentWindow.hash() === rightWindow.hash()) {
      leftWindow.focus();
    }
  }
}

// When windows are tiled (either two-way or three-way), Ctrl+Shift+K will move window focus to the spatially east window.
Key.on("k", ["ctrl", "shift"], () => {
  moveFocusToRightWindowTile();
});

Key.on("m", ["ctrl"], () => {
  moveFocusToRightWindowTile();
});

// When windows are tiled (either two-way or three-way), Ctrl+Shift+J will move window focus to the spatially west window.
Key.on("j", ["ctrl", "shift"], () => {
  let currentWindow = Window.focused();
  let recentWindows = Window.recent();
  let tiledWindows = getTiledWindowsConfig(recentWindows);

  if (tiledWindows.type === "none") {
    return;
  }

  if (tiledWindows.type === "three-tile") {
    let leftWindow = tiledWindows.windows[0];
    let middleWindow = tiledWindows.windows[1];
    let rightWindow = tiledWindows.windows[2];

    if (currentWindow.hash() === leftWindow.hash()) {
      rightWindow.focus();
    } else if (currentWindow.hash() === middleWindow.hash()) {
      leftWindow.focus();
    } else if (currentWindow.hash() === rightWindow.hash()) {
      middleWindow.focus();
    }
  }

  if (tiledWindows.type === "two-tile") {
    let leftWindow = tiledWindows.windows[0];
    let rightWindow = tiledWindows.windows[1];

    if (currentWindow.hash() === leftWindow.hash()) {
      rightWindow.focus();
    } else if (currentWindow.hash() === rightWindow.hash()) {
      leftWindow.focus();
    }
  }
});

// Move focus to left-most window in tile (if windows are tiled)
Key.on("1", ["ctrl", "cmd"], () => {
  let recentWindows = Window.recent();
  let tiledWindows = getTiledWindowsConfig(recentWindows);

  if (tiledWindows.type === "none") {
    return;
  }

  if (tiledWindows.type === "three-tile") {
    tiledWindows.windows[0].focus();
  }
  if (tiledWindows.type === "two-tile") {
    tiledWindows.windows[0].focus();
  }
});

// Move focus to middle window in tile (if windows are tiled) (or right window if there are only two windows)
Key.on("2", ["ctrl", "cmd"], () => {
  let recentWindows = Window.recent();
  let tiledWindows = getTiledWindowsConfig(recentWindows);

  if (tiledWindows.type === "none") {
    return;
  }

  if (tiledWindows.type === "three-tile") {
    tiledWindows.windows[1].focus();
  }
  if (tiledWindows.type === "two-tile") {
    tiledWindows.windows[1].focus();
  }
});

// Move focus to right-most window in tile (if windows are tiled)
Key.on("3", ["ctrl", "cmd"], () => {
  let recentWindows = Window.recent();
  let tiledWindows = getTiledWindowsConfig(recentWindows);

  if (tiledWindows.type === "none") {
    return;
  }

  if (tiledWindows.type === "three-tile") {
    tiledWindows.windows[2].focus();
  }
  if (tiledWindows.type === "two-tile") {
    tiledWindows.windows[1].focus();
  }
});

// TODO: Also ignore ScreenFloat.app
const APPS_TO_IGNORE = [
  "rcmd",
  "Bartender 4",
  "Spotify",
  "Dash",
  "Prime Video",
];

// Normal web dev layout
// Move VSCode to the center 1/3rd of the screen, move Chrome to the right 1/3rd of the screen, and move all other windows to the left 1/3rd of the screen
Key.on("a", ["ctrl", "option", "shift", "cmd"], () => {
  const { leftThirdFrame, middleThirdFrame, rightThirdFrame } = computeDisplayFrames();

  let windows = Space.active().windows().filter(w => !APPS_TO_IGNORE.includes(w.app().name()));

  let vscodeWindows = windows.filter(w => w.app().name() === "Code");
  let chromeWindows = windows.filter(w => w.app().name() === "Google Chrome");
  let remainingWindows = windows.filter(w => w.app().name() !== "Code" && w.app().name() !== "Google Chrome");

  vscodeWindows.forEach(w => w.setFrame(middleThirdFrame));
  chromeWindows.forEach(w => w.setFrame(rightThirdFrame));
  remainingWindows.forEach(w => w.setFrame(leftThirdFrame));

  let figmaWindows = windows.filter(w => w.app().name() === "Figma");

  // Quickly focus Figma to bring it to the front
  // Note that .raise() won't work here since that only makes it the frontmost window in the app, not the frontmost window on the screen
  if (figmaWindows.length > 0) {
    figmaWindows[0].focus();
  }

  setTimeout(() => {
    vscodeWindows[0].focus();
  }, 100);
});

// Debug web dev layout
// Move VSCode and iTerm to the left 1/3rd of the screen, move Chrome Dev Tools to the middle 1/3rd of the screen, move Chrome to the right 1/3rd of the screen (and leave all other app windows untouched)
Key.on("b", ["ctrl", "option", "shift", "cmd"], () => {
  let screenFrame = Screen.main().flippedVisibleFrame();

  const { leftThirdFrame, middleThirdFrame, rightThirdFrame } = computeDisplayFrames();

  let windows = Space.active().windows().filter(w => !APPS_TO_IGNORE.includes(w.app().name()));

  let vscodeWindows = windows.filter(w => w.app().name() === "Code");
  let chromeDevToolWindows = windows.filter(w => w.app().name() === "Google Chrome" && w.title().includes("DevTools"));
  let itermWindows = windows.filter(w => w.app().name() === "iTerm2");
  let otherChromeWindows = windows.filter(w => w.app().name() === "Google Chrome" && !w.title().includes("DevTools"));

  vscodeWindows.forEach(w => w.setFrame(leftThirdFrame));
  itermWindows.forEach(w => w.setFrame(leftThirdFrame));
  chromeDevToolWindows.forEach(w => w.setFrame(middleThirdFrame));
  otherChromeWindows.forEach(w => w.setFrame(rightThirdFrame));

  vscodeWindows[0].focus();
});

// Expanded web dev layout
// Move VSCode to left 2/3rd of the screen, and move every other window to the right 1/3rd of the screen
Key.on("c", ["ctrl", "option", "shift", "cmd"], () => {
  let screenFrame = Screen.main().flippedVisibleFrame();

  const { leftTwoThirdsFrame, rightThirdFrame } = computeDisplayFrames();

  let windows = Space.active().windows().filter(w => !APPS_TO_IGNORE.includes(w.app().name()));

  let vscodeWindows = windows.filter(w => w.app().name() === "Code");
  let remainingWindows = windows.filter(w => w.app().name() !== "Code");

  vscodeWindows.forEach(w => w.setFrame(leftTwoThirdsFrame));
  remainingWindows.forEach(w => w.setFrame(rightThirdFrame));

  vscodeWindows[0].focus();

  // Raise the browser Chrome window above the DevTools window
  let chromeBrowserWindows = Space.active().windows().filter(w => w.app().name() === "Google Chrome" && !w.title().includes("DevTools"));
  chromeBrowserWindows.forEach(w => w.raise());
});

// Expanded web dev layout alt
// Move VSCode to right 2/3rd of the screen, and move every other window to left 1/3rd of the screen
Key.on("d", ["ctrl", "option", "shift", "cmd"], () => {
  let screenFrame = Screen.main().flippedVisibleFrame();

  const { leftThirdFrame, rightTwoThirdsFrame } = computeDisplayFrames();

  let windows = Space.active().windows().filter(w => !APPS_TO_IGNORE.includes(w.app().name()));

  let vscodeWindows = windows.filter(w => w.app().name() === "Code");
  let remainingWindows = windows.filter(w => w.app().name() !== "Code");

  remainingWindows.forEach(w => w.setFrame(leftThirdFrame));
  vscodeWindows.forEach(w => w.setFrame(rightTwoThirdsFrame));

  let figmaWindows = windows.filter(w => w.app().name() === "Figma");

  // Quickly focus Figma to bring it to the front
  // Note that .raise() won't work here since that only makes it the frontmost window in the app, not the frontmost window on the screen
  if (figmaWindows.length > 0) {
    figmaWindows[0].focus();
  }

  setTimeout(() => {
    vscodeWindows[0].focus();
  }, 100);
});

function tileTwoMostRecentWindows() {
  const { leftHalfFrame, rightHalfFrame } = computeDisplayFrames();

  let windows = Window.recent();

  if (windows.length < 2) {
    return;
  }

  let leftWindow = windows[0];
  let rightWindow = windows[1];

  // Try to put Roam Research.app on the right
  if (leftWindow.app().name() === "Roam Research") {
    [leftWindow, rightWindow] = [rightWindow, leftWindow];
  }

  // Make sure Orion.app is always on the left
  if (rightWindow.app().name() === "Orion") {
    [leftWindow, rightWindow] = [rightWindow, leftWindow];
  }

  leftWindow.setFrame(leftHalfFrame);
  rightWindow.setFrame(rightHalfFrame);
}

// Tile the two most recent windows
// Special cases/notes:
//  - Will always tile Orion.app on the left (see TODO above for context)
Key.on(",", ["option", "shift"], () => {
  tileTwoMostRecentWindows();
});

Key.on("0", ["ctrl"], () => {
  tileTwoMostRecentWindows();
});

const DEBOUNCE_TIME_MS = 1000;

var invalidateRecentWindowCacheTimeout = null;

function invalidateRecentWindowCacheDebounced() {
  clearTimeout(invalidateRecentWindowCacheTimeout);

  invalidateRecentWindowCacheTimeout = setTimeout(() => {
    invalidateRecentWindowCacheTimeout = null;

    let start = new Date().getTime();
    RECENT_WINDOW_CACHE = Window.recent();
    let finish = new Date().getTime();

    console.log(`refreshed recent window cache, took ${finish - start}ms`);
  }, DEBOUNCE_TIME_MS);
}

Event.on('windowDidOpen', (window) => {
  if (!window.title()) {
    return;
  }
  invalidateRecentWindowCacheDebounced();
});

Event.on('windowDidClose', (window) => {
  if (!window.title()) {
    return;
  }
  invalidateRecentWindowCacheDebounced();
});

Event.on('windowDidMove', (window) => {
  if (!window.title()) {
    return;
  }
  invalidateRecentWindowCacheDebounced();
});

Event.on('windowDidResize', (window) => {
  if (!window.title()) {
    return;
  }
  invalidateRecentWindowCacheDebounced();
});

// App events don't change any window positions, but they can change the order of recent windows

Event.on('appDidLaunch', (app) => {
  invalidateRecentWindowCacheDebounced();
});

Event.on('appDidTerminate', (app) => {
  invalidateRecentWindowCacheDebounced();
});

Event.on('appDidActivate', (app) => {
  invalidateRecentWindowCacheDebounced();
});

Event.on('appDidHide', (app) => {
  invalidateRecentWindowCacheDebounced();
});

Event.on('appDidShow', (app) => {
  invalidateRecentWindowCacheDebounced();
});

Event.on('spaceDidChange', (space) => {
  invalidateRecentWindowCacheDebounced();
});