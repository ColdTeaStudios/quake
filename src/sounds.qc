//======================================================================
// SOUND functions
//======================================================================
float SOUND_PLAYONCE = 2;       // When triggered plays once
float SOUND_TRIGGER = 4;        // Wait for trigger and then stop

//----------------------------------------------------------------------
void() ambient_sound_setup =
{
    if (self.volume > 1) self.volume = 1;
    else if (self.volume < 0) self.volume = 0;
    if (self.speed < 0) self.speed = ATTN_NONE;
    else if (self.speed == 0) self.speed = ATTN_NORM;
    ambientsound (self.origin, self.noise, self.volume, self.speed);
};

//============================================================================
/*QUAKED ambient_custom_loop (0.3 0.1 0.6) (-16 -16 -8) (16 16 8) x
Custom ambient (must be looped) sound, CANNOT toggle/switch state
-------- KEYS --------
volume : volume of sound (default 1, capped at 1)
noise : custom sound to play (looped)
-------- SPAWNFLAGS --------
STARTOFF : Wait for trigger, will become static
-------- NOTES --------
Custom ambient (must be looped) sound, CANNOT toggle/switch state
============================================================================*/
void() ambient_custom_loop =
{
    // Check for sound file
    if (self.noise == "") {
        dprint("\b[AMB_CUSTOM_LOOP]\b Missing sound file\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        remove(self);
        return;
    }
    
    precache_sound (self.noise);
    if (self.volume <= 0) self.volume = 1;
    if (self.volume > 1) self.volume = 1;
    
    // Ambient sounds can ONLY be setup on frame 1
    // The command (ambientsound) does not work delayed
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_comp_hum =
{
    self.noise = "ambience/comp1.wav";
    precache_sound (self.noise);
    self.volume = 1;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_drip =
{
    self.noise = "ambience/drip1.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_drone =
{
    self.noise = "ambience/drone6.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_flouro_buzz =
{
    self.noise = "ambience/buzz1.wav";
    precache_sound (self.noise);
    self.volume = 1;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_light_buzz =
{
    self.noise = "ambience/fl_hum1.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_hum1 =
{
    self.noise = "ambience/hum1.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_suck_wind =
{
    self.noise = "ambience/suck1.wav";
    precache_sound (self.noise);
    self.volume = 1;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_swamp1 =
{
    self.noise = "ambience/swamp1.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_swamp2 =
{
    self.noise = "ambience/swamp2.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};
//----------------------------------------------------------------------
void() ambient_thunder =
{
    self.noise = "ambience/thunder1.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    self.speed = ATTN_STATIC;
    ambient_sound_setup();
};

//----------------------------------------------------------------------
// Quoth MOD - Extra ambient sounds
//----------------------------------------------------------------------
void() ambient_generalpurpose =
{
    // Check for sound file
    if (self.noise == "") {
        dprint("\b[AMBIENT_SOUND]\b Missing sound file at ");
        dprint(vtos(self.origin)); dprint("\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        remove(self);
        return;
    }
    precache_sound (self.noise);
    ambient_sound_setup();
};

//----------------------------------------------------------------------
// Travil MOD - Extra ambient sounds
//----------------------------------------------------------------------
void() ambient_lavagurg =
{
    self.noise = "ambience/lavagurg.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    ambient_sound_setup();
};
void() ambient_hevifals =
{
    self.noise = "ambience/hevifals.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    ambient_sound_setup();
};
void() ambient_bublfals =
{
    self.noise = "ambience/bublfals.wav";
    precache_sound (self.noise);
    self.volume = 0.5;
    ambient_sound_setup();
};

//======================================================================
/*QUAKED ambient_custom_sound (0.5 0.1 0.8) (-16 -16 -8) (16 16 8) x PLAYONCE TRIGGER x x x STARTOFF x
Play a sound on a periodic basis
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : targets to trigger each time sound is played
volume  : volume of sound (default 1, capped at 1)
noise   : primary sound (ambience/windgust1a.wav)
noise1  : stop sound (anbience/switch_6off.wav)
noise2  : random sound (ambience/windgust1b.wav)
wait    : random time between sounds (default 20, =-1 no random element)
delay   : minimum time between sounds (default 2)
waitmin : Starting time (waitmin + random() x waitmin, =-1 no delay)
waitmin2: 1 = Will not silence any playing sound if switching off
impulse : channel on which to play sound (0-7) (0 automatic is default)
speed   : attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet
-------- SPAWNFLAGS --------
PLAYONCE : When triggered plays once
TRIGGER  : Constantly waits for trigger events (retrigger)
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Play a sound on a periodic basis
*/
//======================================================================
void() ambient_custom_stop =
{
    // Cannot block via entity state because there is an 'off sound'
    // Need to check against entity internal state for off state
    if (self.state == STATE_OFF) return;

    // Switch off sound emitter, clear next think
    self.state = STATE_OFF;
    self.think = SUB_Null;
    self.nextthink = time + 0.1;

    // Catch play once/disable setting separate
    if (self.estate & ESTATE_DISABLE) return;
    
    // Check for OFF sound, else play silence to clear sound
    if (self.noise1 != "") 
        sound (self, self.impulse, self.noise1, self.volume, self.speed);
    else {
        // If aflag is defined, do not cut off sound
        if (!self.waitmin2) sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
    }
};

//----------------------------------------------------------------------
void() ambient_custom_play =
{
    // Block everything except ON entity state
    if (self.estate & ESTATE_BLOCK) return;

    // Internal state used for switch off sound
    self.state = STATE_ON;
    
    // Check for random volume changes
    if (self.t_width > 0) {
        self.volume = self.t_width + (random() * self.t_length);
        if (self.volume > 1) self.volume = 1;
    }
    
    // Check for weather system?
    if (self.check_weather == TRUE) {
        // Check if weather system still active?
        if (query_weathersystem() == TRUE) {
            // never has multiple sounds
            sound (self, self.impulse, self.noise, self.volume, self.speed);
        }
    }
    else {
        // Check for multiple random sounds
        if (self.noise2 != "" && random() < 0.5)
            sound (self, self.impulse, self.noise2, self.volume, self.speed);
        else sound (self, self.impulse, self.noise, self.volume, self.speed);
        
        // If any targets defined, trigger them
        if (self.target != "") trigger_strs(self.target, self);
    }
    
    // Keep playing sound?
    // If sound is setup to play once, don't turn off sound before finished
    // Let the sound play out and switch off ambient sound entity
    if (self.spawnflags & SOUND_PLAYONCE) self.estate = ESTATE_DISABLE;
    else if (self.spawnflags & SOUND_TRIGGER) self.estate = ESTATE_OFF;
    else {
        // Check for any random time element
        if (self.wait == 0) self.nextthink = time + self.delay;
        else self.nextthink = time + self.delay + random()*self.wait;
        self.think = ambient_custom_play;
    }
};

//----------------------------------------------------------------------
void() ambient_custom_use =
{
    // Deal with STARTOFF functionality first
    if (self.spawnflags & ENT_STARTOFF) {
        // Remove spawnflag and switch ON entity
        self.spawnflags = self.spawnflags - ENT_STARTOFF;
        self.estate_on();
    }
    else {
        // Always allow trigger sounds to keep firing
        if (self.spawnflags & SOUND_TRIGGER) self.estate_on();
        else {          
            // Block USE functionality if state wrong
            if (self.estate & ESTATE_BLOCK) return;

            // Toggle state of ambient sound to start/stop
            if (self.state == STATE_OFF) self.estate_on();
            else self.estate_off();
        }
    }
};

//----------------------------------------------------------------------
void() ambient_custom_on =
{
    self.estate = ESTATE_ON;
    ambient_custom_play();
};

//----------------------------------------------------------------------
void() ambient_custom_off =
{
    ambient_custom_stop();
    self.estate = ESTATE_OFF;
};

//----------------------------------------------------------------------
void() ambient_custom_disable =
{
    self.state = STATE_OFF;
    sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
};

//----------------------------------------------------------------------
void() ambient_custom_sound =
{
    // Check for sound file
    if (self.noise == "") {
        dprint("\b[AMBIENT_SOUND]\b Missing sound file at ");
        dprint(vtos(self.origin)); dprint("\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        remove(self);
        return;
    }
    precache_sound (self.noise);
    
    // Is there an OFF sound defined (used for toggle sounds)
    if (self.noise1 != "") precache_sound (self.noise1);
    // Is there any random alternative sounds
    if (self.noise2 != "") precache_sound (self.noise2);
    
    self.classtype = CT_SOUNDEMITTER;
    self.state = STATE_OFF;
    
    // Check volume range is correct
    if (self.volume <= 0 || self.volume > 1) self.volume = 1;
    
    // Setup defaults for sound waits (-1=no random element)
    if (self.wait == 0) self.wait = 20;
    if (self.wait < 0) self.wait = 0;
    
    if (self.delay <= 0) self.delay = 2;
    if (self.waitmin == 0) self.waitmin = 4;
    if (self.impulse <= 0) self.impulse = 1;

    // attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet 
    if (self.speed < 0) self.speed = ATTN_NONE;
    else if (self.speed == 2) self.speed = ATTN_IDLE;
    else if (self.speed == 3) self.speed = ATTN_STATIC;
    else if (self.speed == 4) self.speed = ATTN_QUIET;
    else self.speed = ATTN_NORM;
        
    // Setup Entity State functionality
    if (self.targetname != "") self.use = entity_state_use;
    self.estate_on = ambient_custom_on;
    self.estate_off = ambient_custom_off;
    self.estate_use = ambient_custom_use;
    self.estate_disable = ambient_custom_disable;
    
    if (self.spawnflags & ENT_STARTOFF) self.estate_off();
    else if (self.spawnflags & SOUND_TRIGGER) self.estate_off();
    else {
        if (self.waitmin > 0) {
            self.nextthink = time + self.waitmin + random()*self.waitmin;
            self.think = self.estate_on;
        }
        else self.estate_on();
    }
};

//----------------------------------------------------------------------
// Quoth version (not 100% compatible)
void() play_sound_triggered = { 
    self.spawnflags = self.spawnflags | ENT_STARTOFF;
    ambient_custom_sound(); 
};

//----------------------------------------------------------------------
void() ambient_custom_water =
{
    if (self.noise == "") self.noise = "ambience/water1.wav";
    if (!self.volume) self.volume = 0.75;
    ambient_custom_loop();
};

//----------------------------------------------------------------------
void() ambient_custom_rain =
{
    if (self.count == 1) {
        // Long dripping water sound
        self.noise = "ambience/rain1_nl.wav";
        if (!self.speed) self.speed = 2;
        if (!self.volume) self.volume = 0.4;
        // Sound is 7s long, 0.1s for overlap
        self.delay = 6.9;
    }
    else {
        // Very short intense rain sound
        self.noise = "ambience/rain2_nl.wav";
        if (!self.speed) self.speed = 1;
        if (!self.volume) self.volume = 0.5;
        // Sound is 3s long, 0.1s for overlap
        self.delay = 2.9;
    }
    
    self.wait = -1;         // pretend loop, no pause
    self.waitmin = -1;      // No start delay
    self.check_weather = TRUE;  // Keep checking weather system
    
    // Always start off, must be triggered
    self.spawnflags = self.spawnflags | ENT_STARTOFF;
    
    // Back into main function
    ambient_custom_sound();
};

//----------------------------------------------------------------------
void() ambient_custom_rumble =
{
    // Always precache all sounds and then randomly pick one
    // load/save games will always generate new random selection
    // and that will produce cache errors everytime
    precache_sound ("ambience/rumble1.wav");
    precache_sound ("ambience/rumble2.wav");
    precache_sound ("ambience/rumble3.wav");
    
    // Pick a random sound to start with
    if (self.count < 0) self.count = random()*3;
        
    // Setup sound wav names
    if (self.count <= 1) {
        self.noise = "ambience/rumble1.wav";
        // Pick an alternative random sound
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/rumble2.wav";
            else self.noise2 = "ambience/rumble3.wav";
        }
    }
    else if (self.count <= 2) {
        self.noise = "ambience/rumble2.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/rumble1.wav";
            else self.noise2 = "ambience/rumble3.wav";
        }
    }
    else {
        self.noise = "ambience/rumble3.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/rumble1.wav";
            else self.noise2 = "ambience/rumble2.wav";
        }
    }
    
    // Default values for rumble
    if (!self.volume) { self.t_width = 0.5; self.t_length = 0.5; }
    if (!self.speed) self.speed = 1;
    if (!self.delay) self.delay = 20;
    if (!self.wait) self.wait = 20;
    if (!self.waitmin) self.waitmin = 6 + random()*6;
    
    // Back into main function
    ambient_custom_sound();
};

//----------------------------------------------------------------------
void() ambient_custom_wind =
{
    // Always precache all sounds and then randomly pick one
    // load/save games will always generate new random selection
    // and that will produce cache errors everytime
    precache_sound ("ambience/windgust1.wav");
    precache_sound ("ambience/windgust2.wav");
    precache_sound ("ambience/windgust3.wav");
    precache_sound ("ambience/windgust4.wav");
    precache_sound ("ambience/windgust5.wav");
    precache_sound ("ambience/windgust6.wav");

    // Pick a random sound to start with
    if (self.count < 0) self.count = random()*6;
        
    // Setup sound wav names
    if (self.count <= 1) {
        self.noise = "ambience/windgust1.wav";
        // Pick an alternative random sound
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust2.wav";
            else self.noise2 = "ambience/windgust3.wav";
        }
    }
    else if (self.count <= 2) {
        self.noise = "ambience/windgust2.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust1.wav";
            else self.noise2 = "ambience/windgust3.wav";
        }
    }
    else if (self.count <= 3) {
        self.noise = "ambience/windgust3.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust1.wav";
            else self.noise2 = "ambience/windgust2.wav";
        }
    }
    else if (self.count <= 4) {
        self.noise = "ambience/windgust4.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust5.wav";
            else self.noise2 = "ambience/windgust6.wav";
        }
    }
    else if (self.count <= 5) {
        self.noise = "ambience/windgust5.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust4.wav";
            else self.noise2 = "ambience/windgust6.wav";
        }
    }
    else {
        self.noise = "ambience/windgust6.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/windgust4.wav";
            else self.noise2 = "ambience/windgust5.wav";
        }
    }
    
    // Default values for wind
    if (!self.volume) self.volume = 1;
    if (!self.speed) self.speed = 1;
    if (!self.delay) self.delay = 10;
    if (!self.wait) self.wait = 10;
    if (!self.waitmin) self.waitmin = 4 + random()*4;
    
    // Back into main function
    ambient_custom_sound();
};

//----------------------------------------------------------------------
void() ambient_custom_wood =
{
    // Always precache all sounds and then randomly pick one
    // load/save games will always generate new random selection
    // and that will produce cache errors everytime
    precache_sound ("ambience/woodcreak2a.wav");
    precache_sound ("ambience/woodcreak2b.wav");
    precache_sound ("ambience/woodcreak2c.wav");
    precache_sound ("ambience/woodcreak2d.wav");

    // Pick a random sound to start with
    if (self.count < 0) self.count = random()*4;
        
    if (self.count <= 1) {
        self.noise = "ambience/woodcreak2a.wav";
        // Pick an alternative random sound
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/woodcreak2b.wav";
            else self.noise2 = "ambience/woodcreak2c.wav";
        }
    }
    else if (self.count <= 2) {
        self.noise = "ambience/woodcreak2b.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/woodcreak2c.wav";
            else self.noise2 = "ambience/woodcreak2d.wav";
        }
    }
    else if (self.count <= 3) {
        self.noise = "ambience/woodcreak2c.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/woodcreak2a.wav";
            else self.noise2 = "ambience/woodcreak2d.wav";
        }
    }
    else {
        self.noise = "ambience/woodcreak2d.wav";
        if (self.lefty) {
            if (random() < 0.5) self.noise2 = "ambience/woodcreak2a.wav";
            else self.noise2 = "ambience/woodcreak2b.wav";
        }
    }
    
    // Default values for wood
    if (!self.volume) self.volume = 1;
    if (!self.speed) self.speed = 2;
    if (!self.delay) self.delay = 15;
    if (!self.wait) self.wait = 30;
    if (!self.waitmin) self.waitmin = 8 + random()*8;
    
    // Back into main function
    ambient_custom_sound();
};

//----------------------------------------------------------------------
void() ambient_custom_chime =
{
    if (self.noise == "") self.noise = "ambience/chimes.wav";
    if (!self.speed) self.speed = 2;
    if (!self.volume) self.volume = 1;
    if (!self.wait) self.wait = 10;
    if (!self.delay) self.delay = 10;
    if (!self.waitmin) self.waitmin = 10 + random()*10;
    if (!self.waitmin2) self.waitmin2 = -1;

    // Back into main function
    ambient_custom_sound();
};
