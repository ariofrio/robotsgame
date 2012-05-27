var pi = Math.PI;

function normalRelativeAngle(angle) {
  var range = 2*pi;
  angle = angle + pi;
  angle = ((angle % range)+  range) % range;
  return angle-pi;
}
normalRelativeAngle.tests = function() {
  assert(this(pi) == pi);
  assert(this(-pi) == -pi);
  assert(this(2*pi) == 0);
  assert(this(-2*pi) == 0);
  assert(this(3*pi) == pi);
  assert(this(-3*pi) == -pi);
  assert(this(3*pi/2) == -pi/2);
  assert(this(-3*pi/2) == pi/2);
}

self.onmessage = function(ev) {
  var sensors = ev.data;
  var actions = {log: []};

  /*if(sensors.radar.robots.length > 0) {
    // Turn the radar to the enemy's last known location and
    // overshoot (2x) to ensure the enemy does not escape the
    // scan arc.
    var absoluteBearingToTarget =
      sensors.body.heading + sensors.radar.robots[0].bearing;
    actions['radar.turn'] = 2 * normalRelativeAngle(
      absoluteBearingToTarget - sensors.radar.heading);
  } else {
    // Try to find the enemy as fast as possible.
    actions['radar.turn'] = pi/4; // max
  }*/

  actions['thruster.force'] = 200
  actions['thruster.angularVelocity'] = 1

  self.postMessage(actions);
}

