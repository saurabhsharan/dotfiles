const INCREMENT_WIDTH = 200;

function isOverlap(window1, window2) {
  let f1 = window1.frame();
  let f2 = window2.frame();

  return !(f1.x >= f2.x + f2.width ||
          f2.x >= f1.x + f1.width ||
          f1.y >= f2.y + f2.height ||
          f2.y >= f1.y + f1.height);
}

// Finds three windows that are tiled side-by-side
function findThreeTiledWindows() {
  let windows = Window.recent();

  let screenFrame = Space.active().screens()[0].visibleFrame();

  // loop over all possible 3 window combinations
  for (let i = 0; i < windows.length; i++) {
    for (let j = i+1; j < windows.length; j++) {
      for (let k = j+1; k < windows.length; k++) {
        let firstWindow = windows[i];
        let secondWindow = windows[j];
        let thirdWindow = windows[k];

        if (isOverlap(firstWindow, secondWindow) || isOverlap(firstWindow, thirdWindow) || isOverlap(secondWindow, thirdWindow)) {
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

        // console.log(`the three window titles are: ${JSON.stringify([firstWindow.title(), secondWindow.title(), thirdWindow.title()])}`);
        // console.log(`the three window frames are: ${JSON.stringify([firstWindow.frame(), secondWindow.frame(), thirdWindow.frame()])}`);

        let firstWindowSize = firstWindow.frame().width * firstWindow.frame().height;
        let secondWindowSize = secondWindow.frame().width * secondWindow.frame().height;
        let thirdWindowSize = thirdWindow.frame().width * thirdWindow.frame().height;

        if (firstWindowSize + secondWindowSize + thirdWindowSize == screenFrame.width * screenFrame.height) {
          return [firstWindow, secondWindow, thirdWindow].sort((a, b) => a.frame().x - b.frame().x);
        }

        // if (firstWindow.frame().x + firstWindow.frame().width === secondWindow.frame().x &&
        //     secondWindow.frame().x + secondWindow.frame().width === thirdWindow.frame().x) {
        //   return [firstWindow, secondWindow, thirdWindow];
        // }
      }
    }
  }

  return null;
}

// Finds the two side-by-side tile windows and adjusts the split ratio
function retileTwoWindows(direction) {
  let currentSpace = Space.active();
  let screen = currentSpace.screens()[0];
  let screenFrame = screen.visibleFrame();

  let windows = currentSpace.windows({}).filter(wndow => wndow.isVisible() === true);

  // find two windows whose size adds up to screen
  let window1 = null;
  let window2 = null;
  for (const w1 of windows) {
    for (const w2 of windows) {
      if (w1 === w2) {
        continue;
      }

      let w1Frame = w1.frame();
      let w2Frame = w2.frame();

      let w1Size = w1Frame.width * w1Frame.height;
      let w2Size = w2Frame.width * w2Frame.height;

      if (w1Size + w2Size === screenFrame.width * screenFrame.height) {
        window1 = w1;
        window2 = w2;
        break;
      }
    }
  }

  if (window1 === null || window2 === null) {
    console.log('could not find windows');
    return;
  }

  console.log(`found windows ${window1.title()} and ${window2.title()}`);

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

  let leftFrame = leftWindow.frame();
  let rightFrame = rightWindow.frame();

  leftFrame.width -= INCREMENT_WIDTH * direction;
  rightFrame.width += INCREMENT_WIDTH * direction;
  rightFrame.x -= INCREMENT_WIDTH * direction;

  leftWindow.setFrame(leftFrame);
  rightWindow.setFrame(rightFrame);
}

// When two windows are tiled side-by-side, Ctrl-Shift-H will adjust the split to increase the width of the *right* window
Key.on('h', ['ctrl', 'shift'], () => {
  // const allSpaces = Space.all();

  // for (var i = 0; i < allSpaces.length; ++i) {
    // let space = allSpaces[i];
    // let spaceWindows = space.windows({});

    // for (const wndow of spaceWindows) {
      // let app = wndow.app();
      // console.log(`space ${i} app ${app.name()} window ${wndow.title()}`);
    // }
  // }

  retileTwoWindows(1);
});

// When two windows are tiled side-by-side, Ctrl-Shift-L will adjust the split to increase the width of the *left* window
Key.on('l', ['ctrl', 'shift'], () => {
  retileTwoWindows(-1);
});

// When three windows are tiled side-by-side, Ctrl-Shift-K will focus the window to the right of the currently focused window
Key.on('k', ['ctrl', 'shift'], () => {
  let threeWindows = findThreeTiledWindows();
  if (threeWindows === null) {
    console.log('could not find three windows');
    return;
  }

  console.log(`three window titles: ${JSON.stringify(threeWindows.map(wndow => wndow.title()))}`);

  let focusedWindowHash = Window.focused().hash();

  let leftWindow = threeWindows[0];
  let middleWindow = threeWindows[1];
  let rightWindow = threeWindows[2];

  if (leftWindow.hash() === focusedWindowHash) {
    middleWindow.focus();
  } else if (middleWindow.hash() === focusedWindowHash) {
    rightWindow.focus();
  } else if (rightWindow.hash() === focusedWindowHash) {
    leftWindow.focus();
  } else {
    console.log(`didn't focus any window`);
  }
});

// When three windows are tiled side-by-side, Ctrl-Shift-J will focus the window to the left of the currently focused window
Key.on('j', ['ctrl', 'shift'], () => {
  let threeWindows = findThreeTiledWindows();
  if (threeWindows === null) {
    console.log('could not find three windows');
    return;
  }

  console.log(`three window titles: ${JSON.stringify(threeWindows.map(wndow => wndow.title()))}`);

  let focusedWindowHash = Window.focused().hash();

  let leftWindow = threeWindows[0];
  let middleWindow = threeWindows[1];
  let rightWindow = threeWindows[2];

  if (leftWindow.hash() === focusedWindowHash) {
    rightWindow.focus();
  } else if (middleWindow.hash() === focusedWindowHash) {
    leftWindow.focus();
  } else if (rightWindow.hash() === focusedWindowHash) {
    middleWindow.focus();
  } else {
    console.log(`didn't focus any window`);
  }
});
