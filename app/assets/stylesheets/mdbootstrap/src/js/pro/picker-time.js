jQuery(($) => {
  const $win = $(window);
  const $doc = $(document);

  // Can I use inline svg ?
  const svgNS = "http://www.w3.org/2000/svg";
  const svgSupported =
    "SVGAngle" in window &&
    (() => {
      const el = document.createElement("div");
      el.innerHTML = "<svg/>";
      const supported = (el.firstChild && el.firstChild.namespaceURI) == svgNS;
      el.innerHTML = "";
      return supported;
    })();

  // Can I use transition ?
  const transitionSupported = (() => {
    const style = document.createElement("div").style;
    return (
      "transition" in style ||
      "WebkitTransition" in style ||
      "MozTransition" in style ||
      "msTransition" in style ||
      "OTransition" in style
    );
  })();

  // Listen touch events in touch screen device, instead of mouse events in desktop.
  const touchSupported = "ontouchstart" in window;
  const mousedownEvent = `mousedown ${touchSupported ? " touchstart" : ""}`;
  const mousemoveEvent = `mousemove.clockpicker ${
    touchSupported ? " touchmove.clockpicker" : ""
  }`;
  const mouseupEvent = `mouseup.clockpicker ${
    touchSupported ? " touchend.clockpicker" : ""
  }`;

  // Vibrate the device if supported
  const vibrate = navigator.vibrate
    ? "vibrate"
    : navigator.webkitVibrate
    ? "webkitVibrate"
    : null;

  function createSvgElement(name) {
    return document.createElementNS(svgNS, name);
  }

  function debounce(func, wait, immediate) {
    var timeout;
    return function () {
      var context = this;
      var args = arguments;
      var later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  function leadingZero(num) {
    return (num < 10 ? "0" : "") + num;
  }

  // Get a unique id
  var idCounter = 0;
  function uniqueId(prefix) {
    var id = ++idCounter + "";
    return prefix ? prefix + id : id;
  }

  // Clock size
  var dialRadius = 135,
    outerRadius = 110,
    // innerRadius = 80 on 12 hour clock
    innerRadius = 80,
    tickRadius = 20,
    diameter = dialRadius * 2,
    duration = transitionSupported ? 350 : 1;

  // Popover template
  var tpl = [
    '<div class="clockpicker_container clockpicker picker">',
    '<div class="picker__holder">',
    '<div class="picker__frame">',
    '<div class="picker__wrap">',
    '<div class="picker__box">',
    '<div class="picker__date-display">',
    '<div class="clockpicker-display">',
    '<div class="clockpicker-display-column">',
    '<span class="clockpicker-span-hours text-primary" tabindex="1" aria-label="Choose hour"></span>',
    ":",
    '<span class="clockpicker-span-minutes" tabindex="2" aria-label="Choose minute"></span>',
    "</div>",
    '<div class="clockpicker-display-column clockpicker-display-am-pm">',
    '<div class="clockpicker-am-pm-block"></div>',
    "</div>",
    "</div>",
    "</div>",
    '<div class="picker__calendar-container">',
    '<div class="clockpicker-plate">',
    '<div class="clockpicker-canvas"></div>',
    '<div class="clockpicker-dial clockpicker-hours"></div>',
    '<div class="clockpicker-dial clockpicker-minutes clockpicker-dial-out"></div>',
    "</div>",
    '<div class="picker__footer">',
    "</div>",
    "</div>",
    "</div>",
    "</div>",
    "</div>",
    "</div>",
  ].join("");

  // ClockPicker
  function ClockPicker(element) {
    var popover = $(tpl),
      plate = popover.find(".clockpicker-plate"),
      holder = popover.find(".picker__holder"),
      hoursView = popover.find(".clockpicker-hours"),
      minutesView = popover.find(".clockpicker-minutes"),
      amPmBlock = popover.find(".clockpicker-am-pm-block"),
      icon = element.children("i"),
      input = element.children("input"),
      isHTML5 = input.prop("type") === "time",
      label = $("label[for=" + input.attr("id") + "]"),
      self = this,
      options = {};

    options.default = element.attr("default") || "";
    options.fromnow = element.attr("fromnow") || 0;
    options.donetext = element.attr("donetext") || "OK";
    options.cleartext = element.attr("cleartext") || "Clear";
    options.closetext = element.attr("closetext") || "Close";
    options.autoclose = element.attr("autoclose") || false;
    options.darktheme = element.attr("darktheme") || false;
    options.twelvehour = element.attr("twelvehour") || false;
    options.vibrate = element.attr("vibrate") || true;
    options.hourstep = element.attr("hourstep") || 1;
    options.minutestep = element.attr("minutestep") || 1;
    options.inputshowpicker = element.attr("inputshowpicker") || false;
    options.min = element.attr("min") || 0;
    options.max = element.attr("max") || 0;

    this.id = uniqueId("cp");
    this.element = element;
    this.holder = holder;
    this.options = options;
    this.isAppended = false;
    this.isShown = false;
    this.currentView = "hours";
    this.input = input;
    this.icon = icon;
    this.label = label;
    this.popover = popover;
    this.plate = plate;
    this.hoursView = hoursView;
    this.minutesView = minutesView;
    this.amPmBlock = amPmBlock;
    this.spanHours = popover.find(".clockpicker-span-hours");
    this.spanMinutes = popover.find(".clockpicker-span-minutes");
    this.footer = popover.find(".picker__footer");
    this.amOrPm = "";
    this.isTwelvehour = options.twelvehour;
    this.minTime = options.min;
    this.maxTime = options.max;
    this.minMinutes = 0;
    this.maxMinutes = 59;
    this.minHours = 0;
    this.maxHours = 23;
    this.isInvalidTimeScope = false;
    this.hoursBeforeChange = null;
    this.minutesBeforeChange = null;

    // round minutestep to multiples of five
    if (options.minutestep > 20) {
      options.minutestep = 20;
    } else if (options.minutestep != 1 && options.minutestep % 5) {
      const rest = options.minutestep % 5;
      if (rest >= 2.5) {
        options.minutestep += 5 - rest;
      } else {
        options.minutestep -= rest;
      }
    }

    this.icon.removeClass("active");
    this.input.on("focus", () => this.icon.addClass("active"));
    this.input.on("blur", () => this.icon.removeClass("active"));
    const parseTimeOptions = (scope) => {
      const time = scope + "Time";
      this[time] = options[scope].split(":");

      // user can set using am/pm. Convert 12h clock settings to 24h clock settings
      if (this[time][1].length === 4) {
        const period = this[time][1].replace(/\d+/g, "").toUpperCase();
        this[time][1] = this[time][1].replace(/\D+/g, "");
        if (period === "PM") this[time][0] = parseInt(this[time][0]) + 12;
      }

      if (this[time].length !== 2) this[time] = null;
      else {
        for (let i = 0; i < this[time].length; i++) {
          this[time][i] = +this[time][i];
        }
      }
    };

    // Parse minTime Option
    if (options.min) {
      parseTimeOptions("min");
      this.minMinutes = this.minTime[1];
      this.minHours = this.minTime[0];
    }

    // Parse maxTime Option
    if (options.max) {
      parseTimeOptions("max");

      // Ensure that max is after min, if not remove the max it's invalid
      if (
        this.minHours > this.maxHours ||
        (this.minHours === this.maxHours && this.minMinutes >= this.maxMinutes)
      ) {
        this.maxTime = 0;
      } else {
        this.maxMinutes = this.maxTime[1];
        this.maxHours = this.maxTime[0];
      }
    }

    // Setup for for 12 hour clock if option is selected
    if (options.twelvehour) {
      $(
        '<span class="am" aria-label="change to am" tabindex="3">' +
          "AM" +
          "</span>"
      )
        .on("click", function () {
          self.togglePeriod("AM");
        })
        .appendTo(this.amPmBlock);
      $(
        '<span class="pm" aria-label="change to pm" tabindex="4">' +
          "PM" +
          "</span>"
      )
        .on("click", function () {
          self.togglePeriod("PM");
        })
        .appendTo(this.amPmBlock);
    }

    if (options.darktheme) popover.addClass("darktheme");

    // If autoclose is not setted, append a button
    $(
      '<button type="button" class="btn btn-flat clockpicker-button clear-button" aria-label="Clear input" tabindex="' +
        (options.twelvehour ? "5" : "3") +
        '">' +
        options.cleartext +
        "</button>"
    )
      .click($.proxy(this.clearInput, this))
      .appendTo(this.footer);
    $(
      '<button type="button" class="btn btn-flat clockpicker-button close-button" aria-label="Close picker" tabindex="' +
        (options.twelvehour ? "6" : "4") +
        '">' +
        options.closetext +
        "</button>"
    )
      .click($.proxy(this.closeInput, this))
      .appendTo(this.footer);
    $(
      '<button type="button" class="btn btn-flat clockpicker-button done-button" aria-label="save" tabindex="' +
        (options.twelvehour ? "7" : "5") +
        '">' +
        options.donetext +
        "</button>"
    )
      .click($.proxy(this.done, this))
      .appendTo(this.footer);
    this.spanHours.click($.proxy(this.toggleView, this, "hours"));
    this.spanMinutes.click($.proxy(this.toggleView, this, "minutes"));

    // Build ticks
    var tickTpl = $('<div class="clockpicker-tick"></div>'),
      i,
      tick,
      radian,
      radius;

    // Hours view
    if (options.twelvehour) {
      for (i = 0; i < 12; i += options.hourstep) {
        tick = tickTpl.clone();
        radian = (i / 6) * Math.PI;
        radius = outerRadius;
        tick.css("font-size", "140%");
        tick.css({
          left: dialRadius + Math.sin(radian) * radius - tickRadius,
          top: dialRadius - Math.cos(radian) * radius - tickRadius,
        });
        tick.html(i === 0 ? 12 : i);
        hoursView.append(tick);
        tick.on(mousedownEvent, mousedown);
        this.disableOutOfRangeElements();
      }
    } else {
      for (i = 0; i < 24; i += options.hourstep) {
        tick = tickTpl.clone();
        radian = (i / 6) * Math.PI;
        var inner = i > 0 && i < 13;
        radius = inner ? innerRadius : outerRadius;
        tick.css({
          left: dialRadius + Math.sin(radian) * radius - tickRadius,
          top: dialRadius - Math.cos(radian) * radius - tickRadius,
        });
        if (inner) {
          tick.css("font-size", "120%");
        }
        tick.html(i === 0 ? "00" : i);
        hoursView.append(tick);
        tick.on(mousedownEvent, mousedown);
        this.disableOutOfRangeElements();
      }
    }

    // Minutes view
    var incrementValue = Math.max(options.minutestep, 5);
    for (i = 0; i < 60; i += incrementValue) {
      for (i = 0; i < 60; i += 5) {
        tick = tickTpl.clone();
        radian = (i / 30) * Math.PI;
        tick.css({
          left: dialRadius + Math.sin(radian) * outerRadius - tickRadius,
          top: dialRadius - Math.cos(radian) * outerRadius - tickRadius,
        });
        tick.css("font-size", "140%");
        tick.html(leadingZero(i));
        minutesView.append(tick);
        tick.on(mousedownEvent, mousedown);
      }
    }

    // Clicking on minutes view space
    plate.on(mousedownEvent, function (e) {
      if ($(e.target).closest(".clockpicker-tick").length === 0)
        mousedown(e, true);
    });

    // Mousedown or touchstart
    function mousedown(e, space) {
      var offset = plate.offset(),
        isTouch = /^touch/.test(e.type),
        x0 = offset.left + dialRadius,
        y0 = offset.top + dialRadius,
        dx = (isTouch ? e.originalEvent.touches[0] : e).pageX - x0,
        dy = (isTouch ? e.originalEvent.touches[0] : e).pageY - y0,
        z = Math.sqrt(dx * dx + dy * dy),
        moved = false;

      // When clicking on minutes view space, check the mouse position
      if (
        space &&
        (z < outerRadius - tickRadius || z > outerRadius + tickRadius)
      )
        return;
      e.preventDefault();

      // Set cursor style of body after 200ms
      var movingTimer = setTimeout(function () {
        self.popover.addClass("clockpicker-moving");
      }, 200);

      // Place the canvas to top
      if (svgSupported) plate.append(self.canvas);

      // Clock
      self.setHand(dx, dy, !space, true);

      // Mousemove on document
      $doc.off(mousemoveEvent).on(mousemoveEvent, function (e) {
        e.preventDefault();
        var isTouch = /^touch/.test(e.type),
          x = (isTouch ? e.originalEvent.touches[0] : e).pageX - x0,
          y = (isTouch ? e.originalEvent.touches[0] : e).pageY - y0;
        if (!moved && x === dx && y === dy)
          // Clicking in chrome on windows will trigger a mousemove event
          return;
        moved = true;
        self.setHand(x, y, false, true);
      });

      // Mouseup on document
      $doc.off(mouseupEvent).on(mouseupEvent, function (e) {
        $doc.off(mouseupEvent);
        e.preventDefault();
        var isTouch = /^touch/.test(e.type),
          x = (isTouch ? e.originalEvent.changedTouches[0] : e).pageX - x0,
          y = (isTouch ? e.originalEvent.changedTouches[0] : e).pageY - y0;
        if ((space || moved) && x === dx && y === dy) self.setHand(x, y);

        let {
          hours,
          minutes,
          amOrPm,
          maxHours,
          minHours,
          maxMinutes,
          minMinutes,
        } = self;

        if (amOrPm === "PM") {
          if (minHours < 12) minHours = 0;
          if (minHours > 12) minHours -= 12;
          if (maxHours > 12) maxHours -= 12;
        }

        // dont toggleView if selected time out of scope
        if (self.isInvalidTimeScope) {
          self.isInvalidTimeScope = false;
          e.stopPropagation();
        } else if (self.currentView === "hours")
          self.toggleView("minutes", duration / 2);
        else if (self.currentView != "hours" && options.autoclose) {
          self.minutesView.addClass("clockpicker-dial-out");
          setTimeout(function () {
            self.done();
          }, duration / 2);
          self.currentHours = 0;
        }

        plate.prepend(canvas);

        // Reset cursor style of body
        clearTimeout(movingTimer);
        self.popover.removeClass("clockpicker-moving");

        // Unbind mousemove event
        $doc.off(mousemoveEvent);
      });
      self.disableOutOfRangeElements();
    }

    if (svgSupported) {
      // Draw clock hands and others
      var canvas = popover.find(".clockpicker-canvas"),
        svg = createSvgElement("svg");
      svg.setAttribute("class", "clockpicker-svg");
      svg.setAttribute("width", diameter);
      svg.setAttribute("height", diameter);
      var g = createSvgElement("g");
      g.setAttribute(
        "transform",
        "translate(" + dialRadius + "," + dialRadius + ")"
      );
      var bearing = createSvgElement("circle");
      bearing.setAttribute("class", "clockpicker-canvas-bearing");
      bearing.setAttribute("cx", 0);
      bearing.setAttribute("cy", 0);
      bearing.setAttribute("r", 2);
      var hand = createSvgElement("line");
      hand.setAttribute("x1", 0);
      hand.setAttribute("y1", 0);
      var bg = createSvgElement("circle");
      bg.setAttribute("class", "clockpicker-canvas-bg");
      bg.setAttribute("r", tickRadius);
      var fg = createSvgElement("circle");
      fg.setAttribute("class", "clockpicker-canvas-fg");
      fg.setAttribute("r", 5);
      g.appendChild(hand);
      g.appendChild(bg);
      g.appendChild(fg);
      g.appendChild(bearing);
      svg.appendChild(g);
      canvas.append(svg);

      this.hand = hand;
      this.bg = bg;
      this.fg = fg;
      this.bearing = bearing;
      this.g = g;
      this.canvas = canvas;
    }

    const tab = 9;
    const enter = 13;
    const arrowUp = 38;
    const arrowDown = 40;
    const space = 32;

    const setTabTrap = () => {
      popover.find(".clockpicker-span-hours").on("keydown", (e) => {
        if (e.keyCode === tab && e.shiftKey) {
          e.preventDefault();
          popover.find(".done-button").focus();
        }
      });

      popover.find(".done-button").on("keydown", (e) => {
        if (e.keyCode === tab && !e.shiftKey) {
          e.preventDefault();
          popover.find(".clockpicker-span-hours").focus();
        }
      });
    };

    const setIconTabindex = () => {
      icon.attr("tabindex", "0");
    };

    const setAriaInputAndIcon = () => {
      icon.attr("aria-haspopup", "true");
    };

    const isNewValueOutOfRange = (val) => {
      let {
        hours,
        isTwelvehour,
        amOrPm,
        currentView,
        maxHours,
        minHours,
        maxMinutes,
        minMinutes,
      } = self;

      if (
        isTwelvehour &&
        currentView === "hours" &&
        amOrPm === "PM" &&
        val < 12
      ) {
        val += 12;
      }

      if (isTwelvehour && currentView === "minutes" && amOrPm === "PM") {
        hours += 12;
      }

      if (currentView === "hours" && (val > maxHours || val < minHours)) {
        return true;
      }

      if (currentView === "minutes" && hours == minHours && val < minMinutes) {
        return true;
      }

      if (currentView === "minutes" && hours == maxHours && val > maxMinutes) {
        return true;
      }

      return false;
    };

    const bindIconKeydown = () => {
      icon.on("keydown", (e) => {
        if (e.keyCode === space || e.keyCode === enter) {
          debounce(this.show(), 100);
        }
      });
    };

    const bindHoursSpanKeydown = () => {
      this.spanHours.on("keydown", (e) => {
        let newValue;

        if (e.keyCode === arrowUp) {
          if (this.currentView !== "hours") {
            this.toggleView("hours");
          }

          if (this.isTwelvehour) {
            if (this.hours === 11) {
              newValue = this.hours + 1;
              const period = this.amOrPm === "AM" ? "PM" : "AM";
              self.togglePeriod(period);
            } else if (this.hours === 12) {
              newValue = 1;
            } else {
              newValue = this.hours + 1;
            }
          } else {
            if (this.hours === 23) {
              newValue = 0;
            } else {
              newValue = this.hours + 1;
            }
          }

          if (isNewValueOutOfRange(newValue)) {
            if (this.isTwelvehour && this.minHours <= 12) {
              self.togglePeriod("AM");
            }
            newValue = this.minHours;
          }

          this.hours = newValue;
          this.spanHours.html(leadingZero(this.hours));
          this.resetClock();
        }

        if (e.keyCode === arrowDown) {
          if (this.currentView !== "hours") {
            this.toggleView("hours");
          }

          if (this.isTwelvehour) {
            if (this.hours === 1) {
              newValue = 12;
            } else if (this.hours === 12) {
              newValue = this.hours - 1;
              const period = this.amOrPm === "AM" ? "PM" : "AM";
              self.togglePeriod(period);
            } else {
              newValue = this.hours - 1;
            }
          } else {
            if (this.hours === 0) {
              newValue = 23;
            } else {
              newValue = this.hours - 1;
            }
          }

          if (isNewValueOutOfRange(newValue)) {
            if (this.isTwelvehour && this.maxHours >= 12) {
              self.togglePeriod("PM");
            }
            newValue = this.maxHours;
          }

          this.hours = newValue;
          this.spanHours.html(leadingZero(this.hours));
          this.resetClock();
        }

        if (e.keyCode === enter) {
          this.toggleView("hours");
        }
      });
    };

    const bindMinutesSpanKeydown = () => {
      this.spanMinutes.on("keydown", (e) => {
        let newValue;
        if (e.keyCode === arrowUp) {
          if (this.currentView !== "minutes") {
            this.toggleView("minutes");
          }

          if (this.minutes === 59) {
            newValue = 0;
          } else {
            newValue = this.minutes + 1;
          }

          if (isNewValueOutOfRange(newValue)) {
            let { hours, amOrPm, minHours, maxHours, minMinutes } = this;

            if (amOrPm === "PM") {
              hours += 12;
            }

            if (hours === minHours) {
              newValue = minMinutes;
            }

            if (hours === maxHours) {
              newValue = 0;
            }
          }

          this.minutes = newValue;
          this.spanMinutes.html(leadingZero(this.minutes));
          this.resetClock();
        }

        if (e.keyCode === arrowDown) {
          if (this.currentView !== "minutes") {
            this.toggleView("minutes");
          }

          if (this.minutes === 0) {
            newValue = 59;
          } else {
            newValue = this.minutes - 1;
          }

          if (isNewValueOutOfRange(newValue)) {
            let { hours, amOrPm, minHours, maxHours, maxMinutes } = this;

            if (amOrPm === "PM") {
              hours += 12;
            }

            if (hours === minHours) {
              newValue = 59;
            }

            if (hours === maxHours) {
              newValue = maxMinutes;
            }
          }

          this.minutes = newValue;
          this.spanMinutes.html(leadingZero(this.minutes));
          this.resetClock();
        }

        if (e.keyCode === enter) {
          this.toggleView("minutes");
        }
      });
    };

    const bindAmPmBlockKeydown = () => {
      if (this.isTwelvehour) {
        popover.find(".am").on("keydown", (e) => {
          if (e.keyCode === enter) {
            e.preventDefault();
            self.togglePeriod("AM");
          }
        });

        popover.find(".pm").on("keydown", (e) => {
          if (e.keyCode === enter) {
            e.preventDefault();
            self.togglePeriod("PM");
          }
        });
      }
    };

    const bindCloseButtonClick = () => {
      popover.find(".close-button").on("click", () => {
        this.close();
      });
    };

    const bindShowOnClick = () => {
      let el;
      if (options.inputshowpicker) {
        el = input;
      } else {
        el = icon;
      }

      el.on("click.clockpicker", debounce($.proxy(this.show, this), 100));
    };

    setTabTrap();
    setIconTabindex();
    setAriaInputAndIcon();
    bindIconKeydown();
    bindHoursSpanKeydown();
    bindAmPmBlockKeydown();
    bindMinutesSpanKeydown();
    bindCloseButtonClick();
    bindShowOnClick();
    raiseCallback(this.options.init);
  }

  function raiseCallback(callbackFunction) {
    if (callbackFunction && typeof callbackFunction === "function")
      callbackFunction();
  }

  // Default options
  ClockPicker.DEFAULTS = {
    default: "", // default time, 'now' or '13:14' e.g.
    fromnow: 0, // set default time to * milliseconds from now (using with default = 'now')
    donetext: "OK", // done button text
    cleartext: "Clear", // clear button text
    closetext: "Cancel",
    autoclose: false, // auto close when minute is selected
    darktheme: false, // set to dark theme
    twelvehour: false, // change to 12 hour AM/PM clock from 24 hour
    vibrate: true, // vibrate the device when dragging clock hand
    hourstep: 1, // allow to multi increment the hour
    minutestep: 1, // allow to multi increment the minute
    inputshowpicker: false,
  };

  // Show or hide popover
  ClockPicker.prototype.toggle = function () {
    this[this.isShown ? "hide" : "show"]();
  };

  // Set popover position
  ClockPicker.prototype.locate = function () {
    var element = this.element,
      popover = $("body").append(this.popover),
      offset = element.offset(),
      width = element.outerWidth(),
      height = element.outerHeight(),
      align = this.options.align,
      self = this;

    this.popover.show();
  };

  // The input can be changed by the user
  // So before we can use this.hours/this.minutes we must update it
  ClockPicker.prototype.parseInputValue = function () {
    var value = this.input.prop("value") || this.options["default"] || "";

    if (value === "now") {
      value = new Date(+new Date() + this.options.fromnow);
    }
    if (value instanceof Date) {
      value = value.getHours() + ":" + value.getMinutes();
    }

    value = value.split(":");

    // Minutes can have AM/PM that needs to be removed
    this.hours = +value[0] || 0;
    this.minutes = +(value[1] + "").replace(/\D/g, "") || 0;

    this.hours =
      Math.round(this.hours / this.options.hourstep) * this.options.hourstep;
    this.minutes =
      Math.round(this.minutes / this.options.minutestep) *
      this.options.minutestep;

    if (this.options.twelvehour) {
      var period = (value[1] + "").replace(/\d+/g, "").toLowerCase();
      this.amOrPm = this.hours > 12 || period === "pm" ? "PM" : "AM";
    }
  };

  // Show popover
  ClockPicker.prototype.show = function (e) {
    // Not show again
    if (this.isShown) {
      return;
    }

    raiseCallback(this.options.beforeShow);
    $(":input").each(function () {
      $(this).attr("tabindex", -1);
    });

    var self = this;
    // Initialize
    this.input.blur();
    this.popover.addClass("picker--opened");
    this.input.addClass("picker__input picker__input--active");

    if (this.options.inputshowpicker) {
      this.input.siblings("label").addClass("active");
    }

    $(document.body).css("overflow", "hidden");
    if (!this.isAppended) {
      // Append popover to body
      this.popover.insertAfter(this.input);
      if (this.options.twelvehour) {
        this.amOrPm = "AM";
        this.amPmBlock.children(".pm").removeClass("active");
        this.amPmBlock.children(".am").addClass("active");
      }
      // Reset position when resize
      $win.on("resize.clockpicker" + this.id, function () {
        if (self.isShown) {
          self.locate();
        }
      });
      this.isAppended = true;
    }
    // Get the time
    this.parseInputValue();

    if (this.hours === 0) {
      this.hours = this.minHours;
    }

    this.hoursBeforeChange = this.hours;
    this.minutesBeforeChange = this.minutes;

    this.spanHours.html(leadingZero(this.hours));
    this.spanMinutes.html(leadingZero(this.minutes));

    if (this.options.twelvehour) {
      this.togglePeriod(this.amOrPm);
    }

    this.disableOutOfRangeElements();
    // Toggle to hours view
    this.toggleView("hours");
    // Set position
    this.locate();
    this.isShown = true;
    this.spanHours.focus();
    // Hide when clicking or tabbing on any element except the clock and input
    $doc.on(
      "click.clockpicker." + this.id + " focusin.clockpicker." + this.id,
      debounce(function (e) {
        var target = $(e.target);
        if (
          target.closest(self.popover.find(".picker__wrap")).length === 0 &&
          target.closest(self.input).length === 0
        )
          self.hide();
      }, 100)
    );
    // Hide when ESC is pressed
    $doc.on(
      "keyup.clockpicker." + this.id,
      debounce(function (e) {
        if (e.keyCode === 27) self.hide();
      }, 100)
    );
    raiseCallback(this.options.afterShow);
  };
  // Hide popover
  ClockPicker.prototype.hide = function () {
    raiseCallback(this.options.beforeHide);
    this.input.removeClass("picker__input picker__input--active");
    this.popover.removeClass("picker--opened");
    $(document.body).css("overflow", "visible");
    this.isShown = false;
    $(":input").each(function () {
      $(this).attr("tabindex", 0);
    });
    // Unbinding events on document
    $doc.off(
      "click.clockpicker." + this.id + " focusin.clockpicker." + this.id
    );
    $doc.off("keyup.clockpicker." + this.id);
    this.input.trigger("blur");
    this.popover.hide();
    raiseCallback(this.options.afterHide);
  };

  ClockPicker.prototype.close = function () {
    this.hours = this.hoursBeforeChange;
    this.minutes = this.minutesBeforeChange;

    this.hide();
  };
  // set invalid or disable some elements if needed
  ClockPicker.prototype.disableOutOfRangeElements = function () {
    let {
      hours,
      minutes,
      currentView,
      isTwelvehour,
      amOrPm,
      maxHours,
      minHours,
      maxMinutes,
      minMinutes,
      options,
    } = this;
    const $hoursTick = $(".clockpicker-hours").children(),
      $minutesTick = $(".clockpicker-minutes").children(),
      $amBtn = $(".am"),
      $pmBtn = $(".pm"),
      $doneBtn = $(".done-button");

    // disable am/pm switch btn when time is out of allow range for am/pm period
    if (isTwelvehour && currentView === "minutes") {
      $doneBtn.removeClass("grey-text disabled");
      if (amOrPm === "AM" && !(hours + 12 <= maxHours) && options.max)
        $pmBtn.addClass("disabled");
      else if (amOrPm === "PM" && !(hours >= minHours) && options.min)
        $amBtn.addClass("disabled");
    }

    // min and max hours is in 24h format, convert to 12h format if needed
    if (isTwelvehour && amOrPm === "PM") {
      if (minHours < 12) minHours = 0;

      if (minHours > 12) minHours -= 12;

      if (maxHours > 12) maxHours -= 12;
    }

    // disable done btn when time is out of allow range
    if (isTwelvehour && currentView === "hours") {
      $amBtn.removeClass("disabled");
      $pmBtn.removeClass("disabled");

      if (amOrPm === "AM" && (!(hours >= minHours) || !(hours <= maxHours))) {
        $doneBtn.addClass("grey-text disabled");
      } else if (
        amOrPm === "PM" &&
        (!(hours >= minHours) || !(hours <= maxHours)) &&
        options.max
      ) {
        $doneBtn.addClass("grey-text disabled");
      } else {
        $doneBtn.removeClass("grey-text disabled");
      }
    }

    // disable done btn when time is out of allow range
    if (currentView === "minutes") {
      if (
        (hours === minHours && minutes < minMinutes) ||
        (hours === maxHours && minutes > maxMinutes)
      )
        $doneBtn.addClass("grey-text disabled");
      else $doneBtn.removeClass("grey-text disabled");
    }

    // set invalid if hours is out of allow range
    if (currentView === "hours") {
      $hoursTick.each((index, el) => {
        let hours = el.innerHTML;

        if (this.isTwelvehour && hours == 12) hours = 0;

        if (hours > maxHours || hours < minHours)
          $(el).addClass("grey-text disabled");
        else $(el).removeClass("grey-text disabled");
      });
    }

    // set invalid if minutes is out of allow range
    if (currentView === "minutes") {
      $minutesTick.each((index, el) => {
        if (minHours == hours && el.innerHTML < minMinutes)
          $(el).addClass("grey-text disabled");
        else if (maxHours == hours && el.innerHTML > maxMinutes)
          $(el).addClass("grey-text disabled");
        else if (el.innerHTML % this.options.minutestep !== 0)
          $(el).addClass("grey-text disabled");
        else $(el).removeClass("grey-text disabled");
      });
    }
  };

  // Toggle to hours or minutes view
  ClockPicker.prototype.toggleView = function (view, delay) {
    var raiseAfterHourSelect = false;
    if (
      view === "minutes" &&
      $(this.hoursView).css("visibility") === "visible"
    ) {
      raiseCallback(this.options.beforeHourSelect);
      raiseAfterHourSelect = true;
    }
    var isHours = view === "hours",
      nextView = isHours ? this.hoursView : this.minutesView,
      hideView = isHours ? this.minutesView : this.hoursView;
    this.currentView = view;

    this.spanHours.toggleClass("text-primary", isHours);
    this.spanMinutes.toggleClass("text-primary", !isHours);

    // Let's make transitions
    hideView.addClass("clockpicker-dial-out");
    nextView.css("visibility", "visible").removeClass("clockpicker-dial-out");

    // Reset clock hand
    this.resetClock(delay);

    // After transitions ended
    clearTimeout(this.toggleViewTimer);
    this.toggleViewTimer = setTimeout(function () {
      hideView.css("visibility", "hidden");
    }, duration);

    this.disableOutOfRangeElements();

    if (raiseAfterHourSelect) raiseCallback(this.options.afterHourSelect);
  };

  ClockPicker.prototype.togglePeriod = function (period) {
    let previsiousPeriod = "pm";

    if (period === "PM") previsiousPeriod = "am";

    this.amOrPm = period;
    this.amPmBlock
      .children(`.${previsiousPeriod.toLowerCase()}`)
      .removeClass("active");
    this.amPmBlock.children(`.${period.toLowerCase()}`).addClass("active");

    this.disableOutOfRangeElements();
  };

  // Reset clock hand
  ClockPicker.prototype.resetClock = function (delay) {
    var view = this.currentView,
      value = this[view],
      isHours = view === "hours",
      unit = Math.PI / (isHours ? 6 : 30),
      radian = value * unit,
      radius = isHours && value > 0 && value < 13 ? innerRadius : outerRadius,
      x = Math.sin(radian) * radius,
      y = -Math.cos(radian) * radius,
      self = this;

    if (svgSupported && delay) {
      self.canvas.addClass("clockpicker-canvas-out");
      setTimeout(function () {
        self.canvas.removeClass("clockpicker-canvas-out");
        self.setHand(x, y);
      }, delay);
    } else this.setHand(x, y);
  };

  // Set clock hand to (x, y)
  ClockPicker.prototype.setHand = function (x, y, roundBy5, dragging) {
    var radian = Math.atan2(x, -y),
      isHours = this.currentView === "hours",
      z = Math.sqrt(x * x + y * y),
      options = this.options,
      inner = isHours && z < (outerRadius + innerRadius) / 2,
      radius = inner ? innerRadius : outerRadius,
      unit,
      value;

    // Calculate the unit
    if (isHours) {
      unit = (options.hourstep / 6) * Math.PI;
    } else {
      unit = (options.minutestep / 30) * Math.PI;
    }

    if (options.twelvehour) radius = outerRadius;

    // Radian should in range [0, 2PI]
    if (radian < 0) radian = Math.PI * 2 + radian;

    // Get the round value
    value = Math.round(radian / unit);

    // Get the round radian
    radian = value * unit;
    // Correct the hours or minutes
    if (isHours) {
      value *= options.hourstep;
      if (!options.twelvehour && !inner == value > 0) {
        value += 12;
      }
      if (options.twelvehour && value === 0) {
        value = 12;
      }
      if (value === 24) {
        value = 0;
      }
    } else {
      value *= options.minutestep;
      if (value === 60) {
        value = 0;
      }
    }
    // disable action when out of allow range
    let { minHours, maxHours, minMinutes, maxMinutes, amOrPm } = this;

    if (isHours) {
      let hours = value;

      if (this.amOrPm === "PM") {
        if (minHours < 12) minHours = 0;
        if (minHours > 12) minHours -= 12;
        if (maxHours > 12) maxHours -= 12;
      }

      if (this.isTwelvehour && hours == 12) hours = 0;

      if (hours < minHours || hours > maxHours) {
        this.isInvalidTimeScope = true;
        return;
      }

      if (this.isTwelvehour && hours === 12) {
        this.isInvalidTimeScope = true;
        return;
      }
    } else {
      let { hours } = this;

      if (amOrPm === "PM") hours += 12;

      if (
        (hours == minHours && value < minMinutes) ||
        (hours == maxHours && value > maxMinutes)
      ) {
        this.isInvalidTimeScope = true;
        return;
      }
    }

    if (isHours) this.fg.setAttribute("class", "clockpicker-canvas-fg");
    else {
      if (value % 5 == 0)
        this.fg.setAttribute("class", "clockpicker-canvas-fg");
      else this.fg.setAttribute("class", "clockpicker-canvas-fg active");
    }

    // Once hours or minutes changed, vibrate the device
    if (this[this.currentView] !== value)
      if (vibrate && this.options.vibrate)
        if (!this.vibrateTimer) {
          // Do not vibrate too frequently
          navigator[vibrate](10);
          this.vibrateTimer = setTimeout(
            $.proxy(function () {
              this.vibrateTimer = null;
            }, this),
            100
          );
        }
    this[this.currentView] = value;
    this[isHours ? "spanHours" : "spanMinutes"].html(leadingZero(value));

    // If svg is not supported, just add an active class to the tick
    if (!svgSupported) {
      this[isHours ? "hoursView" : "minutesView"]
        .find(".clockpicker-tick")
        .each(function () {
          var tick = $(this);
          tick.toggleClass("active", value === +tick.html());
        });
      return;
    }

    // Place clock hand at the top when dragging
    if (dragging || (!isHours && value % 5)) {
      this.g.insertBefore(this.hand, this.bearing);
      this.g.insertBefore(this.bg, this.fg);
      this.bg.setAttribute(
        "class",
        "clockpicker-canvas-bg clockpicker-canvas-bg-trans"
      );
    } else {
      // Or place it at the bottom
      this.g.insertBefore(this.hand, this.bg);
      this.g.insertBefore(this.fg, this.bg);
      this.bg.setAttribute("class", "clockpicker-canvas-bg");
    }

    // Set clock hand and others' position
    var cx = Math.sin(radian) * radius,
      cy = -Math.cos(radian) * radius;
    this.hand.setAttribute("x2", cx);
    this.hand.setAttribute("y2", cy);
    this.bg.setAttribute("cx", cx);
    this.bg.setAttribute("cy", cy);
    this.fg.setAttribute("cx", cx);
    this.fg.setAttribute("cy", cy);
  };

  // Clear clock text
  ClockPicker.prototype.clearInput = function () {
    this.input.val("");
    this.hide();

    if (this.options.afterDone && typeof this.options.afterDone === "function")
      this.options.afterDone(this.input, null);
  };

  // Allow user to get time as Date object
  ClockPicker.prototype.getTime = function (callback) {
    this.parseInputValue();

    var hours = this.hours;
    if (this.options.twelvehour && hours < 12 && this.amOrPm === "PM") {
      hours += 12;
    }

    var selectedTime = new Date();
    selectedTime.setMinutes(this.minutes);
    selectedTime.setHours(hours);
    selectedTime.setSeconds(0);

    return (
      (callback && callback.apply(this.element, selectedTime)) || selectedTime
    );
  };

  // Hours and minutes are selected
  ClockPicker.prototype.done = function () {
    raiseCallback(this.options.beforeDone);
    this.hide();
    this.label.addClass("active");

    var last = this.input.prop("value"),
      outHours = this.hours,
      value = ":" + leadingZero(this.minutes);

    if (this.isHTML5 && this.options.twelvehour) {
      if (this.hours < 12 && this.amOrPm === "PM") {
        outHours += 12;
      }
      if (this.hours === 12 && this.amOrPm === "AM") {
        outHours = 0;
      }
    }

    value = leadingZero(outHours) + value;

    if (!this.isHTML5 && this.options.twelvehour) {
      value = value + this.amOrPm;
    }

    this.input.prop("value", value);
    if (value !== last) {
      this.input.trigger("change");
    }

    if (this.options.autoclose) this.input.trigger("blur");

    raiseCallback(this.options.afterDone);
  };

  // Remove clockpicker from input
  ClockPicker.prototype.remove = function () {
    this.element.removeData("clockpicker");
    this.input.off("focus.clockpicker click.clockpicker");
    if (this.isShown) this.hide();
    if (this.isAppended) {
      $win.off("resize.clockpicker" + this.id);
      this.popover.remove();
    }
  };

  // Extends $.fn.clockpicker
  $.fn.timepicker = function (option) {
    var args = Array.prototype.slice.call(arguments, 1);
    function handleClockPickerRequest() {
      var $this = $(this),
        data = $this.data("clockpicker");
      if (!data) {
        $this.data("clockpicker", new ClockPicker($this));
      } else {
        // Manual operations. show, hide, remove, e.g.
        if (typeof data[option] === "function") data[option].apply(data, args);
      }
    }

    // If we explicitly do a call on a single element then we can return the value (if needed)
    // This allows us, for example, to return the value of getTime
    if (this.length == 1) {
      var returnValue = handleClockPickerRequest.apply(this[0]);

      // If we do not have any return value then return the object itself so you can chain
      return returnValue !== undefined ? returnValue : this;
    }

    // If we do have a list then we do not care about return values
    return this.each(handleClockPickerRequest);
  };

  // autoinit timepicker
  $("div.timepicker").timepicker();

  $("#time-picker-opener").on("click", (e) => {
    e.stopPropagation();
    e.preventDefault();

    const openElementData = e.target.dataset.open;
    const $picker = $(`#${openElementData}`).timepicker("picker");
    $picker.data("clockpicker").show();
  });
});
