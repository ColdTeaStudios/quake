//======================================================================
// INFO ENTITIES
//======================================================================
// Often used for target spot lights
void() info_null = { remove(self); };
// Easy way to create point targets
void() info_target = {};
// New skyroom feature for QSS clients
void() info_skyroom = { remove(self); };

// Sometimes this entity is used as point or bmmodel entity
// It depends on the mapper and what they are trying to do
void() info_notnull = {};

//======================================================================
/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24) x x x x x x x x Not_Easy Not_Normal Not_Hard Not_DM Dyn_Easy Dyn_Normal Dyn_Hard Dyn_Night
{ model(":progs/player.mdl"); }
DEFAULT starting point for a player
-------- KEYS --------
target : triggered target(s) when used as a client destination
angle  : Starting view angle
-------- SPAWNFLAGS --------
-------- NOTES --------
DEFAULT starting point for a player

======================================================================*/
void() info_player_start = { 
    self.classtype = CT_SPAWNSP;
    self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED info_player_startdev (1 1 0.5) (-16 -16 -24) (16 16 24) x x x x x x x x Not_Easy Not_Normal Not_Hard Not_DM Dyn_Easy Dyn_Normal Dyn_Hard Dyn_Night
{ model(":progs/player.mdl"); }
DEFAULT starting point for a DEVELOPER only
-------- KEYS --------
target : triggered target(s) when used as a client destination
angle  : Starting view angle
-------- SPAWNFLAGS --------
-------- NOTES --------
DEFAULT starting point for a DEVELOPER only

======================================================================*/
void() info_player_startdev = { 
    self.classtype = CT_SPAWNSP;
    self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED info_player_start2 (0.9 0 0) (-16 -16 -24) (16 16 24) x x x x x x x x Not_Easy Not_Normal Not_Hard Not_DM Dyn_Easy Dyn_Normal Dyn_Hard Dyn_Night
{ model(":progs/player.mdl"); }
Starting point for players with runes or startspawn2 system
-------- KEYS --------
target : triggered target(s) when used as a client destination
angle  : Starting view angle
startspawn2 : Unique spawn location number matching a trigger_changelevel
-------- SPAWNFLAGS --------
-------- NOTES --------
Starting point for players with runes or using the startspawn2 system
The startspawn2 system lets players move between maps using exact location

======================================================================*/
void() info_player_start2 = { 
    self.classtype = CT_SPAWNSP;
    self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/player.mdl"); }
Starting position for coop games
-------- KEYS --------
target : triggered target(s) when used as a client destination
angle  : Starting view angle
-------- SPAWNFLAGS --------
STARTOFF : Starts off
-------- NOTES --------
Starting position for coop games

======================================================================*/
void() info_player_coop = { 
    self.classtype = CT_SPAWNCOOP;
    if (self.spawnflags & MON_SPAWN_DELAY) self.estate = ESTATE_OFF;
    else self.estate = ESTATE_ON;
    // Setup Entity State functionality
    if (self.targetname != "") self.use = entity_state_use;
};

//======================================================================
/*QUAKED info_player_deathmatch (0 1 1) (-16 -16 -24) (16 16 24) x x x x x x STARTOFF x Not_Easy Not_Normal Not_Hard Not_DM
{ model(":progs/player.mdl"); }
Starting position for deathmatch games
-------- KEYS --------
target : triggered target(s) when used as a client destination
angle  : Starting view angle
-------- SPAWNFLAGS --------
STARTOFF : Starts off
-------- NOTES --------
Starting position for deathmatch games

======================================================================*/
void() info_player_deathmatch = { 
    self.classtype = CT_SPAWNDM;
    if (self.spawnflags & MON_SPAWN_DELAY) self.estate = ESTATE_OFF;
    else self.estate = ESTATE_ON;
    // Setup Entity State functionality
    if (self.targetname != "") self.use = entity_state_use;
};

//======================================================================
/*QUAKED info_teleport_destination (1 0.5 0.5) (-8 -8 -8) (8 8 32) x
Destination marker for a teleporter
-------- KEYS --------
targetname : link to trigger_teleport
target     : fires when used as a destination (works only once)
angletarget: targeting entity used for custom direction
angles     : Pitch Yaw Roll (destination angle after teleporting)
teledest   : Unique number for multiple teleporter destinations
-------- SPAWNFLAGS --------
-------- NOTES --------
Destination marker for a teleporter

======================================================================*/
void() info_teleport_angle = 
{
    // Find angletarget entity in world
    self.movetarget = find(world, targetname, self.angletarget);
    if (self.movetarget) {
        // Check for bmodel origin on self/angletarget entities
        if (self.bsporigin) self.dest1 = bmodel_origin(self);
        else self.dest1 = self.origin;
        // Find the destination origin
        if (self.movetarget.bsporigin) self.dest2 = bmodel_origin(self.movetarget);
        else self.dest2 = self.movetarget.origin;
        // Update Z axis for any editor offset information
        self.dest1 = self.dest1 - self.view_ofs;
        // Create directional vector from source to target
        self.movedir = normalize(self.dest2 - self.dest1);
        // Convert vector direction to angles
        self.mangle = vectoangles(self.movedir);
        // Spawn a dev marker for visual reasons
        spawn_arrow(self.dest1, self.mangle, SPNMARK_YELLOW);
    }
    else {
        // Display console error and diamond in game
        dprint("\b[INFO_TELE]\b angletarget is missing!\n");
        if (self.bsporigin) spawn_marker(self.oldorigin, SPNMARK_YELLOW);
        else spawn_marker(self.origin, SPNMARK_YELLOW);
        // Reset angletarget field, its broken and not needed
        self.angletarget = "";
    }
};

//----------------------------------------------------------------------
void() info_teleport_convert_updown =
{
    // Setup special mangle/movedir
    // editor -1 = UP and -2 = DOWN
    if (self.mangle == '0 -1 0') {
        self.mangle = '270 0 0'; self.movedir = '0 0 1';
    }
    else if (self.mangle == '0 -2 0') {
        self.mangle = '90 0 0'; self.movedir = '0 0 -1';
    }
};

//----------------------------------------------------------------------
void() info_teleport_destination =
{
    self.classtype = CT_MISCTELEPORT;
    self.estate = ESTATE_ON;
    self.mangle = self.angles;  // Save for later
    self.angles = '0 0 0';      // Don't need to be zero, previous code
    self.view_ofs = '0 0 27';   // Z axis modifier for editor placement
    self.origin = self.origin + self.view_ofs;
    info_teleport_convert_updown();

    // Cannot use info entity if targetname missing
    if (self.targetname == "") {
        dprint("\b[INFO_TELE]\b targetname is missing!\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        entity_hide(self);
    }
    // Check for destination number errors
    else if (self.teledest < 0) {
        dprint("\b[INFO_TELE]\b Dest value cannot be negative\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        self.teledest = 0;
    }

    // Check for angle target setup
    if (self.angletarget != "") {
        self.nextthink = time + 0.1 + random();
        self.think = info_teleport_angle;
    }
};

//======================================================================
/*QUAKED info_teleportinstant_dest (.5 .5 .5) ? x
Destination for an instant teleporter
-------- KEYS --------
targetname : link to trigger_teleport
target     : fires when used as a destination (works only once)
angletarget: targeting entity used for custom direction
angles     : Pitch Yaw Roll (destination angle after teleporting)
teledest   : Unique number for multiple teleporter destinations
-------- SPAWNFLAGS --------
-------- NOTES --------
Destination for an instant teleporter

======================================================================*/
void() info_teleportinstant_dest =
{
    if (check_bmodel_keys()) return;    // Check for bmodel errors

    self.classtype = CT_MISCTELINSTANT;
    self.estate = ESTATE_ON;
    self.mangle = self.angles;  // Save for later
    self.angles = '0 0 0';      // Zero'd to prevent bmodel twisting
    self.view_ofs = '0 0 0';    // Z axis modifier for editor placement
    info_teleport_convert_updown();
    
    // Stuff from InitTrigger
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    self.mdl = self.model;      // Save model for later
    setmodel (self, self.mdl);  // set size and link into world
    self.bbmins = self.mins;    // Save bmodel bounds for later
    self.bbmaxs = self.maxs;

    // Work out true volume origin
    self.bsporigin = TRUE;
    self.oldorigin = bmodel_origin(self);
    
    // Don't need volume brush anymore
    setmodel(self, "");
    setsize(self, VEC_ORIGIN, VEC_ORIGIN);

    // Cannot use info entity if targetname missing
    if (self.targetname == "") {
        dprint("\b[INFO_TELE]\b targetname is missing!\n");
        spawn_marker(self.oldorigin, SPNMARK_YELLOW);
        entity_hide(self);
    }
    // Check for destination number errors
    else if (self.teledest < 0) {
        dprint("\b[INFO_TELE]\b Dest value cannot be negative\n");
        spawn_marker(self.oldorigin, SPNMARK_YELLOW);
        self.teledest = 0;
    }

    // Check for angle target setup
    if (self.angletarget != "") {
        self.nextthink = time + 0.1 + random();
        self.think = info_teleport_angle;
    }
};

//======================================================================
/*QUAKED info_camera_destination (1 0.5 0.5) (-16 -16 -24) (16 16 32) x
Marker for a Cinematic Camera System
-------- KEYS --------
targetname : link to misc_camera entity
angles : Pitch Yaw Roll (facing angle)
-------- SPAWNFLAGS --------
-------- NOTES --------
Marker for a Cinematic Camera System

======================================================================*/
void() info_camera_destination =
{
    self.classtype = CT_MISCTELCAMERA;
    self.estate = ESTATE_ON;
};

//======================================================================
/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16) NO_INTERMIS SOLID x x x x x x Not_Easy Not_Normal Not_Hard Not_DM
This is the camera point for the intermission
-------- KEYS --------
target : triggered target(s) when used as a viewing camera
mangle : Pitch Yaw Roll
fog_density : fog density (Must be >0 to activate feature)
fog_colour  : fog colours (def=0.1 0.1 0.1)
speed       : fog time to change (def=2s)
-------- SPAWNFLAGS --------
NO_INTERMIS : Will not display when proper intermission active
SOLID       : Intermission camera interacts with world
-------- NOTES --------
mangle = up/down, angle, tilt left/right 'pitch roll yaw'
up/left = negative value, down/right = positive value

======================================================================*/
void() info_intermission =
{
    self.classtype = CT_CAMERA;
    self.estate = ESTATE_ON;
    setsize (self, VEC_ORIGIN, VEC_ORIGIN);
    self.movetype = MOVETYPE_NONE;
    self.solid = SOLID_NOT;
    setmodel(self, MODEL_EMPTY);
    self.view_ofs = '0 0 0';
    self.owner = self;
    
    // Check for any trigger fog parameters
    if (self.fog_density > 0) {
        if (!self.speed) self.speed = 2;
        // Double check its within range
        if (self.fog_density > 1) self.fog_density = 1;
        if (CheckZeroVector(self.fog_colour)) self.fog_colour = '0.1 0.1 0.1';
    }
    // Disable fog trigger if density not setup
    else self.fog_density = 0;
    
};

//======================================================================
/*QUAKED info_command (1 0.5 0.5) (-16 -16 -16) (16 16 16) x x x x x x x x
Stuff commands to the console
-------- KEYS --------
targetname : trigger entity (works with entity state system)
message    : Console command to stuff!
-------- SPAWNFLAGS --------
-------- NOTES --------
Stuff commands to the console

======================================================================*/
void() info_command_use =
{
    // Only fire this entity once
    if (self.attack_finished > time) return;
    if (other.flags & FL_CLIENT) self.enemy = other;
    else self.enemy = client_ent;
    self.attack_finished = time + LARGE_TIMER;
    stuffcmd(self.enemy, self.message);
};

//----------------------------------------------------------------------
void() info_command =
{
    if (self.message == "") {
        dprint("\b[INFO_CMD]\b Message cmd missing!\n");
        spawn_marker(self.origin, SPNMARK_YELLOW);
        entity_hide(self);
        return;
    }
    self.classtype = CT_CONTROL;
    //self.use = info_command_use;
    remove(self);
};

//======================================================================
/*QUAKED info_multispawn (1 0.5 0.5) (-16 -16 -16) (16 16 16) x x x x x x x x
Spawn multiple monsters
-------- KEYS --------
targetname : trigger entity (works with entity state system)
wait       : Time between spawning (def=0.3)
count      : Amount of monsters to spawn (def=3)
spawnclassname : classname of monster to spawn
spawnfunction  : classname of monster
-------- SPAWNFLAGS --------
-------- NOTES --------
Spawn multiple monsters

======================================================================*/
void() info_multispawn = { remove(self); }
void() func_hordespawn = { info_multispawn(); };

